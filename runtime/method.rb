#BikeMethod represents a method (also a function and lambda) in Bike.
#Example of usage:
#
#     BikeMethod.new(["a", "b"], ..., ..., ...)
#
#This class is not meant to be directly used with its own instances of body, context, and vararg, becouse that is done in DefNode and LambdaNode and most of the instances for body, etc. are done by the parser
#<b>You should rarely need to worry about this class</b>
class BikeMethod
  # The actual value that any internal bike object carries. In this case, it is <tt>"def (#{@params.join(', ')}#{@vararg ? " ...#{@vararg}" : ""}) { ... }"</tt> just to make it so that there is something to see on the repl.
  attr_reader :ruby_value

  # The context that the method (or function) was created in. <b>THIS IS NOT BEING USED FOR CLOSURES OR ANYTHING YET. IT DOES NOT WORK</b>
  attr_reader :context

  # This method just sets the corresponding arguments onto properties of the same name and returns the new object. The only special thing it does is doctor up a +ruby_value+ based on these properties.
  def initialize(params, body,
                 context=Context.new(Constants["Object"]),
                 vararg=nil, private=false)
    @params, @body, @context = params, body, context

    @vararg = vararg
    @private = private

    @ruby_value = "def (#{@params.join(', ')}#{@vararg ? " ...#{@vararg}" : ""}) { ... }"

  end


  # The +call+ method takes the reciever (normally the global instance of Object, unless the function is called using dot-notation) and creates a new context based on the reciever. It also takes a ruby array of all the arguments that were passed in, and maps them to the parameters, deleting them as they go. If there is a vararg, it gets assigned to any arguments that were left over.
  def call (receiver, arguments)
    if Context.new(receiver).locals == @context.locals && @private
      call_method(arguments)
    elsif !@private
      call_method(arguments)
    else
      raise "Called private method outside of class!"
    end
  end

  protected
  def call_method (arguments)
    context = @context
    @params.each_with_index do |param, index|
      context.locals[param] = arguments[index]
    end

    left_overs = arguments
    @params.each do |p|
      left_overs.delete(context.locals[p])
    end

    if @vararg
      context.locals[@vararg] = Constants["Array"].new_with_value(arguments)
    end

    context.locals["self"] = @context
    res = @body.eval(context)
    context.locals.keys.each { |e| $is_set[e] = false  }

    res
  end
end
