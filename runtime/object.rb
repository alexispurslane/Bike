class BikeObject
  attr_accessor :runtime_class, :ruby_value
  def initialize(runtime_class, ruby_value="Class")
    @runtime_class = runtime_class
    @ruby_value = ruby_value
  end
  def call(method, arguments=[])
    @runtime_class.lookup(method).call(self, arguments)
  end
  def apply(context, closure, method, arguments=[])
    context.locals[method].call(closure, arguments)
  end
end


