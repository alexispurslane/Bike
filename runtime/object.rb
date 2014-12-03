# BikeObject represeints the bare skeleton of what an object should have in the Bike runtime. It also provides a pre-programed call and apply methods, that depend on the lookup method being defined in BikeClass
class BikeObject
  $watches = []
  attr_accessor :runtime_class, :ruby_value, :watches
  def initialize(runtime_class, ruby_value="<object>")
    @runtime_class = runtime_class
    @ruby_value = ruby_value
  end
  # Calls a runtime method.
  def call(method, arguments=[])
    watches_for_method = $watches.keep_if { |v| v[:prop] == method }
    watches_for_method.each do |v|
      v[:meth].call(self, [Constants["Array"].new_with_value(arguments.first.ruby_value)])
    end
    @runtime_class.lookup(method).call(self, arguments)
  end
  # Calls a method that has been stored as a variable (like calling a lambda that was passed into a function.) In Bike this is done using the +$+ operator.
  def apply(context, method, arguments=[])
    context.locals[method].call(context, arguments)
  end

  def observe (prop, method)
    $watches << { :prop => prop + "=", :meth => method }
  end
end
