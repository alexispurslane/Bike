# BikeMethod represents a method (also a function and lambda) in Bike.
# Example of usage:
#
#     BikeMethod.new(['a', 'b'], ..., ..., ...)
#
# This class is not meant to be directly used with its own instances of body, context, and vararg, becouse that is done in DefNode and LambdaNode and most of the instances for body, etc. are done by the parser
# <b>You should rarely need to worry about this class</b>
class BikeMethod
  # The actual value that any internal bike object carries. In this case, it is <tt>'def (#{@params.join(', ')}#{@vararg ? ' ...#{@vararg}' : ''}) { ... }'</tt> just to make it so that there is something to see on the repl.
  attr_reader :ruby_value

  # The context that the method (or function) was created in. <b>THIS IS NOT BEING USED FOR CLOSURES OR ANYTHING YET. IT DOES NOT WORK</b>
  attr_reader :context

  attr_reader :params, :type, :arg_type, :type_ret
  # This method just sets the corresponding arguments onto properties of the same name and returns the new object. The only special thing it does is doctor up a +ruby_value+ based on these properties.
  def initialize(params, body,
                 context = 'Object',
                 name = '', type_ret = 'Dynamic')
    @params = params.map { |e| e[0] }
    @body = body
    @context = context
    @name = name
    @type = 'Function'
    @type_ret = type_ret
    @type_ret = 'Dynamic' unless @type_ret
    @arg_type = params.map { |e| e[1] }
    @arg_defaults = params.map { |e| e[2] }
    @p_inf = params
    @ruby_value = "#{@private ? 'private ' : ''}def #{@name}(#{@params.join(', ')}) { ... }"
  end

  # The +call+ method takes the reciever (normally the global instance of Object, unless the function is called using dot-notation) and creates a new context based on the reciever. It also takes a ruby array of all the arguments that were passed in, and maps them to the parameters, deleting them as they go. If there is a vararg, it gets assigned to any arguments that were left over.
  def call(receiver, arguments)
    rec_cont = if receiver.is_a? Context
                 receiver
               else
                 Context.new(receiver)
               end
    if rec_cont.locals == @context.locals && @private
      call_method(receiver, arguments)
    elsif !@private
      call_method(receiver, arguments)
    else
      fail 'Called private method outside of class!'
    end
  end

  protected

  def call_method(receiver, arguments)
    context = Context.new(receiver)

    if arguments.length >= @params.length || !@arg_defaults.include?(nil)
      @context.current_class.runtime_methods.each do |k, v|
        context.current_class.runtime_methods[k] = v
      end

      @context.locals.each do |k, v|
        context.locals[k] = v
      end

      context.current_class.runtime_methods[@name] = self
      @params.each_with_index do |param, index|
        if @arg_type[index] != 'Dynamic'
          unless @arg_type[index] == arguments[index].type
            fail "Wrong type in argument #{param} with unexpected type: #{arguments[index].type}"
          end
        end
        if !arguments[index].nil?
          arg = arguments[index]
        else
          arg = @arg_defaults[index].eval(context)
        end
        context.locals[param] = arg
      end

      left_overs = arguments
      @params.each do |p|
        left_overs.delete(context.locals[p])
      end

      if @vararg
        context.locals[@vararg] = Constants['Array'].new_with_value(arguments)
      end

      Constants['self'] = context.current_class
      res = @body.eval(context)
      if @type_ret == 'Dynamic' || @type_ret == res.type
        res
      else
        fail "This function (#{@name}) should return a type of #{@type_ret}, but instead returned a type of #{res.type}"
      end

      res
    elsif @arg_defaults.include?(nil) && arguments.length < @params.length
      @context.locals.each do |k, v|
        context.locals[k] = v
      end

      context.current_class.runtime_methods[@name] = self
      arguments.each_with_index do |arg, index|
        context.locals[@params[index]] = arg
      end

      BikeMethod.new(@p_inf.drop(arguments.length), @body, context, @name, @type_ret)
    end
  end
end
