require_relative "parser"
require_relative "runtime"

$gc = 0

def gensym (base="AnonymousClass_")
  $gc += 1
  r = "#{base}#{$gc}".to_sym

  r
end

# First, we create an simple wrapper class to encapsulate the interpretation process.
# All this does is parse the code and call `eval` on the node at the top of the AST.
class Interpreter
  def initialize
    @parser = Parser.new
  end
  
  def eval(code)
    @parser.parse(code).eval(RootContext)
  end
end
# The `Nodes` class will always be at the top of the AST. Its only purpose it to
# contain other nodes. It correspond to a block of code or a series of expressions.
# 
# The `eval` method of every node is the "interpreter" part of our language.
# All nodes know how to evalualte themselves and return the result of their evaluation.
# The `context` variable is the `Context` in which the node is evaluated (local
# variables, current self and current class).
class Nodes
  def eval(context)
    return_value = nil
    nodes.each do |node|
      return_value = node.eval(context)
    end
    return_value || Constants["nil"] # Last result is return value (or nil if none).
  end
end

# We're using `Constants` that we created before when bootstrapping the runtime to access
# the objects and classes from inside the runtime.
#
# Next, we implement `eval` on other node types. Think of that `eval` method as how the
# node bring itself to life inside the runtime.
class NumberNode
  def eval(context)
    Constants["Number"].new_with_value(value)
  end
end

class StringNode
  def eval(context)
    Constants["String"].new_with_value(value)
  end
end

class ArrayListNode
  def eval(context)
    new_value = []
    value.each do |e|
      new_value << BikeClass.new.new_with_value(e.value)
    end
    Constants["Array"].new_with_value(new_value)
  end
end

class TrueNode
  def eval(context)
    Constants["true"]
  end
end

class FalseNode
  def eval(context)
    Constants["false"]
  end
end

class NilNode
  def eval(context)
    Constants["nil"]
  end
end

class GetConstantNode
  def eval(context)
    Constants[name]
  end
end

class GetLocalNode
  def eval(context)
    unless dotIdent
      context.locals[name] || Constants[name]
    else
      class_context = Context.new(Constants[dotIdent], Constants[dotIdent])
      puts Constants[dotIdent]
      class_context.locals[name]
    end
  end
end
class ImportNode
  def eval(context)
    if into == nil
      context.locals[file.downcase.sub '.bk', ''] = Interpreter.new.eval File.read(file)
    else
      context.locals[into] = Interpreter.new.eval File.read(file)
    end
  end
end

# When setting the value of a constant or a local variable, the `value` attribute
# is a node, created by the parser. We need to evaluate the node first, to convert
# it to an object, before storing it into a variable or constant.
class SetConstantNode
  def eval(context)
    Constants[name] = value.eval(context)
  end
end

class SetLocalNode
  @@is_set = {}
  def eval(context)
    if !@@is_set[name]
      context.locals[name] = value.eval(context)
      @@is_set[name] = true
      context.locals[name]
    else
      raise "Attemt to re-assign variable using normal variable."
    end
  end
end
class SetLocalDescNode
  def eval(context)
    name.each do |name|
      if !@@is_set[name]
        context.locals[name] = value.eval(context).call(name, [])
        @@is_set[name] = true
      else
        raise "Attemt to re-assign variable using normal variable."
      end
    end
    Constants["nil"]
  end
end
class SetMutLocalDescNode
  def eval(context)
    name.each do |name|
      if !@@is_set[name]
        context.locals[name] = value.eval(context).call(name, [])
      else
        raise "Attemt to re-assign variable using mutable variable."
      end
    end
    Constants["nil"]
  end
end
class SSetLocalNode
  def eval(context)
    if !@@is_set[name]
      if context.locals[name]
        context.locals[name] = value.eval(context)
      else
        raise "Attemt to assign undeclared mutable variable."
      end
      context.locals[name]
    else
      raise "Attemt to re-assign normal variable."
    end
  end
end
class SetMutLocalNode
  def eval(context)
    if !@@is_set[name]
      context.locals[name] = value.eval(context)
    else
      raise "Attemt to re-assign variable using mutable variable."
    end
  end
end



# The `CallNode` for calling a method is a little more complex. It needs to set the receiver
# first and then evaluate the arguments before calling the method.
class CallNode
  def eval(context)
    if receiver
      value = receiver.eval(context)
    else
      value = context.current_self # Default to `self` if no receiver.
    end
    if !value
      raise "Receiver cannot be resolved by either getting current context, or through dot notation!"
    end
    
    if !is_splat
      evaluated_arguments = arguments.map { |arg| arg.eval(context) }
    else
      evaluated_arguments = context.locals[arguments]
      if !evaluated_arguments
        raise "Cannot find splatted argument identifier."
      else
        evaluated_arguments = evaluated_arguments.ruby_value.clone
      end
    end

    value.call(method, evaluated_arguments)
  end
end

class ApplyNode
  def eval(context)
    value = context.current_self
    if !value
      raise "Receiver cannot be resolved by getting current context!"
    end
    
    evaluated_arguments = arguments.map { |arg| arg.eval(context) }
    value.apply(context, context.locals[method].context, method, evaluated_arguments)
  end
end

# Defining a method, using the `def` keyword, is done by adding a method to the current class.
class DefNode
  def eval(context)
    method = BikeMethod.new(params, body, context.current_class, vararg)
    context.current_class.runtime_methods[name] = method
  end
end
class LambdaNode
  def eval(context)
    BikeMethod.new(params, body, context.current_class)
  end
end

# Defining a class is done in three steps:
#
# 1. Reopen or define the class.
# 2. Create a special context of evaluation (set `current_self` and `current_class` to the new class).
# 3. Evaluate the body of the class inside that context.
#
# Check back how `DefNode` was implemented, adding methods to `context.current_class`. Here is
# where we set the value of `current_class`.
class ClassNode
  def eval(context)
    classname = name || gensym()

    bike_class = Constants[classname] # Check if class is already defined
    
    unless bike_class # Class doesn't exist yet
      sup = Constants[superclass]
      bike_class = BikeClass.new(sup, mixins)
      Constants[classname] = bike_class # Define the class in the runtime
    end
    
    class_context = Context.new(bike_class, bike_class)
    class_context.locals["self"] = bike_class
    body.eval(class_context)
    
    bike_class
  end
end
class HashNode
  def eval(context)
    bike_class = BikeClass.new(Constants["Object"], [])
    
    class_context = Context.new(bike_class, bike_class)
    class_context.locals["self"] = bike_class
    key_values.each do |e|
      key = e[0]
      val = e[1]
      bike_class.def key.to_sym do |receiver, arguments|
        val.eval(class_context)
      end
    end
    bike_class.call("new", [])
  end
end

class PackageNode
  def eval(context)
    sup = Constants["Object"]
    bike_class = BikeClass.new(sup)
    class_context = Context.new(bike_class, bike_class)
    body.eval(class_context)
    
    bike_class.call("new", [])
  end
end

# Finally, to implement `if` in our language,
# we turn the condition node into a Ruby value to use Ruby's `if`.
class IfNode
  def eval(context)
    if condition.eval(context).ruby_value
      body.eval(context)
    else # If no body is evaluated, we return nil.
      if else_body
        else_body.eval(context)
      else
        Constants["nil"]
      end
    end
  end
end
class UnlessNode
  def eval(context)
    if !condition.eval(context).ruby_value
      body.eval(context)
    else # If no body is evaluated, we return nil.
      Constants["nil"]
    end
  end
end
class WhileNode
  def eval(context)
    while condition.eval(context).ruby_value
      body.eval(context)
    end
  end
end
