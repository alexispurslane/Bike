require_relative 'parser'
require_relative 'runtime'

# First, we create an simple wrapper class to encapsulate the interpretation process.
# All this does is parse the code and call eval on the node at the top of the AST.
class Interpreter
  def initialize
    @parser = Parser.new
  end

  def eval(code)
    @parser.parse(code).eval(RootContext)
  end
end
# The Nodes class will always be at the top of the AST. Its only purpose it to
# contain other nodes. It correspond to a block of code or a series of expressions.
#
# The eval method of every node is the 'interpreter' part of our language.
# All nodes know how to evalualte themselves and return the result of their evaluation.
# The context variable is the Context in which the node is evaluated (local
# variables, current self and current class).
class Nodes
  def eval(context)
    return_value = nil
    nodes.each do |node|
      return_value = node.eval(context)
    end
    return_value || Constants['nil'] # Last result is return value (or nil if none).
  end
end

# We're using Constants that we created before when bootstrapping the runtime to access
# the objects and classes from inside the runtime.
#
# Next, we implement eval on other node types. Think of that eval method as how the
# node bring itself to life inside the runtime.
class NumberNode
  def eval(_)
    Constants['Number'].new_with_value(value, 'Number')
  end
end

# Returns a Bike-compatable String class that wraps a ruby string.
class StringNode
  def eval(_)
    Constants['String'].new_with_value(value, 'String')
  end
end

# Wraps a ruby array, and then wraps all of the arrays elements
class ArrayListNode
  def eval(context)
    Constants['Array'].new_with_value(value.map { |e| e.eval(context) })
  end
end

# Wraps ruby `true`
class TrueNode
  def eval(_)
    Constants['true']
  end
end

# Wraps ruby `false`
class FalseNode
  def eval(_)
    Constants['false']
  end
end

# Wraps ruby `nil`
class NilNode
  def eval(_)
    Constants['nil']
  end
end

# Returns the constant with the corresponding name. A constant is a class.
class GetConstantNode
  def eval(_)
    Constants[name]
  end
end

# Gets value of variable
class GetLocalNode
  def eval(context)
    context.locals[name] || Constants[name] ||
      context.current_class.runtime_methods[name]
  end
end

# Imports the named file into a variable, or into a variable with the file name.
class ImportNode
  def eval(context)
    context.locals[into || file.sub('.bk', '')] = Interpreter.new.eval File.read(file)
  end
end

# Sets a variable local to the scope.
class SetLocalNode
  def eval(context)
    if !context.set[name]
      context.locals[name] = value.eval(context)
      context.set[name] = true
      context.locals[name]
    else
      fail 'Attemt to re-assign variable using normal variable.'
    end
  end
end

# Sets a destructuring local variables.
class SetLocalDescNode
  def eval(context)
    name.each do |name|
      if !context.set[name]
        context.locals[name] = value.eval(context).call(name, [])
        context.set[name] = true
      else
        fail 'Attemt to re-assign variable using normal variable.'
      end
    end
    Constants['nil']
  end
end

# Array destructuring.
class SetLocalAryNode
  def eval(context)
    context.locals[head] = array.eval(context).ruby_value[0]
    context.locals[tail] = Constants['Array'].new_with_value(
      array.eval(context).ruby_value.drop(1))
    Constants['nil']
  end
end

# Sets a class into the scope
class SetClassNode
  def eval(context)
    if bike_class
      klass = bike_class.eval(context)
    else
      klass = context.current_self
    end
    klass.runtime_methods[method] = lambda.eval(context)
    Constants['nil']
  end
end

# The CallNode for calling a method is a little more complex. It needs to set the +receiver+
# first and then evaluate the +arguments+ before calling the method.
class CallNode
  def eval(context)
    value = context.current_self # Default to self if no receiver.
    value = receiver.eval(context) if receiver

    fail "Receiver #{receiver.name} cannot be resolved!" unless value

    if is_splat
      fail 'Cannot find splat arg identifier.' unless arguments.eval(context)
      evaluated_arguments = arguments.eval(context).ruby_value if arguments.eval(context)
    else
      evaluated_arguments = arguments.map { |arg| arg.eval(context) }
    end

    value.call(method, evaluated_arguments, context)
  end
end

# Used for all applying of functions
class ApplyNode
  def eval(context)
    evaluated_arguments = arguments.map { |arg| arg.eval(context) }
    if is_expr
      method.eval(context).call(context.current_self, evaluated_arguments)
    else
      value = context.current_self
      value.apply(context, method, evaluated_arguments)
    end
  end
end

# Boolean OR
class OrNode
  def eval(context)
    cond = first.eval(context).ruby_value
    if cond
      second.eval(context).ruby_value
    else
      cond
    end
  end
end

# Boolean AND
class AndNode
  def eval(context)
    cond = first.eval(context)
    if cond.ruby_value
      sec = second.eval(context)
      if sec.ruby_value
        sec
      else
        cond
      end
    end
  end
end

# Node for defining a named function
class DefNode
  def eval(context)
    method = BikeMethod.new(params, body, context, name, type_ret)
    context.current_class.runtime_methods[name] = method
  end
end

# Lambda: anonymous function
class LambdaNode
  def eval(context)
    BikeMethod.new(params, body, context, 'recurse')
  end
end

# Defining a class is done in three steps:
#
# 1. Reopen or define the class.
# 2. Create a special context of evaluation (set current_self and current_class to the new class).
# 3. Evaluate the body of the class inside that context.
#
# Check back how DefNode was implemented, adding methods to context.current_class. Here is
# where we set the value of current_class.
class ClassNode
  def eval(context)
    random_name = 'UnknownClass' + (0...8).map { (65 + rand(26)).chr }.join
    classname = name || random_name

    unless Constants[classname] # Class doesn't exist yet
      Constants[classname] = BikeClass.new(superclass, classname, [], classname)
    end

    class_context = Context.new(Constants[classname], Constants[classname])

    context.locals.each do |name, value|
      class_context.locals[name] = value
    end

    body.eval(class_context)

    Constants[classname]
  end
end

# An enumeration + an algebraic datatype
class DataNode
  def eval(context)
    bike_class = BikeClass.new('Object', name, [], name)

    class_context = Context.new(bike_class, bike_class)
    class_context.locals['self'] = bike_class

    string_clone = Constants['String'].clone
    string_clone.name = name + 'Type'
    Constants[name + 'Type'] = string_clone
    types.each do |e|
      bike_class.def e.to_sym do |_, _|
        Constants['String'].new_with_value(Digest::SHA1.hexdigest("#{name}.#{e}"))
      end
    end
    bike_class.def :is_algebraic do |_, _|
      true
    end

    Constants[name] = bike_class.call('new', [])
  end
end

# Alias a type
class TypeAliasNode
  def eval(_)
    clone = Constants[type].clone
    clone.name = talias
    Constants[talias] = clone
  end
end

# A hash is an anonymous class with syntactic sugar.
class HashNode
  def eval(_)
    bike_class = BikeClass.new('Object')

    class_context = Context.new(bike_class, bike_class)
    class_context.locals['self'] = bike_class

    key_values.each do |e|
      key = e[0]
      val = e[1]
      bike_class.def key.to_sym do |_, _|
        val.eval(class_context)
      end
    end
    bike_class.call('new', [])
  end
end

# An anonymous class that corrosponds to a file
class PackageNode
  def eval(context)
    bike_class = BikeClass.new
    class_context = Context.new(bike_class, bike_class)
    class_context.locals['self'] = bike_class

    context.current_class.runtime_methods.each do |k, v|
      class_context.current_class.runtime_methods[k] = v
    end

    context.locals.each do |name, value|
      class_context.locals[name] = value
    end
    body.eval(class_context)

    bike_class.call('new', [])
  end
end

# Finally, to implement if in our language,
# we turn the condition node into a Ruby value to use Ruby's if.
class IfNode
  def eval(context)
    if elseifs
      conditions = [condition] + elseifs.map(&:condition) + [TrueNode.new]
      bodys = [body] + elseifs.map(&:body) + [else_body]
    else
      conditions = [condition, TrueNode.new]
      bodys = [body, else_body]
    end
    conditions.each_with_index do |cond, i|
      if cond.eval(context).ruby_value && !bodys[i].nil?
        return bodys[i].eval(context)
      end
    end
    Constants['nil']
  end
end

# A python-esque for loop
class ForNode
  def eval(context)
    thing = iterator.eval(context)
    if thing.ruby_value == '<object>'
      thing.runtime_class.runtime_methods.keys.each do |m|
        context.locals[value] = thing.call(m, [])
        context.locals[key] = Constants['String'].new_with_value(m)
        body.eval(context)
      end
      Constants['nil']
    else
      thing.ruby_value.each do |e|
        context.locals[key] = e
        body.eval(context)
      end
      Constants['nil']
    end
  end
end

# Unless == if not expression
class UnlessNode
  def eval(context)
    if !condition.eval(context).ruby_value
      body.eval(context)
    else # If no body is evaluated, we return nil.
      Constants['nil']
    end
  end
end

# A While loop
class WhileNode
  def eval(context)
    body.eval(context) while condition.eval(context).ruby_value
  end
end
