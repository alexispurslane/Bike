# BikeObject represeints the bare skeleton of what an object should have in the Bike runtime. It also provides a pre-programed call and apply methods, that depend on the lookup method being defined in BikeClass
class BikeObject
  attr_accessor :runtime_class, :ruby_value, :watches, :runtime_methods, :type, :name
  def initialize(runtime_class, ruby_value = 'Object', type = runtime_class.ruby_value, name = nil)
    @runtime_class = runtime_class
    @runtime_methods = @runtime_class.runtime_methods
    @ruby_value = ruby_value
    @type = type
    @name = name
  end
  # Calls a runtime method.
  def call(method, arguments=[], context)
    value = (@runtime_class.lookup(method) || context.locals[method])
    if value.nil?
      fail 'Undefined method or function. Maybe function was defined after?'
    else
      value.call(self, arguments)
    end
  end
  # Calls a method that has been stored as a variable (like calling a lambda that was passed into a function.) In Bike this is done using the +$+ operator.
  def apply(context, method, arguments=[])
    value = (@runtime_class.lookup(method) || context.locals[method])
    fail 'Undefined stored lambda. Check your argument values.' unless value
    value.call(self, arguments[0].ruby_value)
  end
end
