class BikeMethod
  attr_accessor :ruby_value, :context
  def initialize(params, body, context, vararg)
    @params = params
    @body = body
    @context = context
    @vararg = vararg
    @ruby_value = "def (#{@params.join(', ')}#{@vararg ? " ...#{@vararg}" : ""}) { ... }"
  end
  
  def call (receiver, arguments)
    context = Context.new(receiver)
    @params.each_with_index do |param, index|
      context.locals[param] = arguments[index > 0 ? index-1 : index]
      arguments.delete_at(index > 0 ? index-1 : index)
    end
    context.locals[@vararg] = Constants["Array"].new_with_value(arguments)
    context.locals["self"] = receiver
    @body.eval(context)
  end
end

