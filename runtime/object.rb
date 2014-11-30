# BikeObject represeints the bare skeleton of what an object should have in the Bike runtime. It also provides a pre-programed call and apply methods, that depend on the lookup method being defined in BikeClass
class BikeObject
  attr_accessor :runtime_class, :ruby_value
  def initialize(runtime_class, ruby_value="<object>")
    @runtime_class = runtime_class
    @ruby_value = ruby_value
  end
  # Calls a runtime method.
  def call(method, arguments=[])
    @runtime_class.lookup(method).call(self, arguments)
  end
  # Calls a method that has been stored as a variable (like calling a lambda that was passed into a function.) In Bike this is done using the +$+ operator.
  def apply(context, closure, method, arguments=[])
    context.locals[method].call(closure, arguments)
  end
  def each
    if @ruby_value.is_a?(Array)
      @ruby_value.each { |e| yield e }
    else
      yield @ruby_value
    end
  end
  include Enumerable
end
