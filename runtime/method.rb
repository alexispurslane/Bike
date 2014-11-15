class BikeMethod
  attr_accessor :ruby_value
  def initialize(params, body)
    @params = params
    @body = body
    @ruby_value = "def (#{@params.join(', ')}) { <CODE> }"
  end
  
  def call (receiver, arguments)
    context = Context.new(receiver)

    @params.each_with_index do |param, index|
      context.locals[param] = arguments[index]
    end
    context.locals["self"] = receiver
    @body.eval(context)
  end
end

