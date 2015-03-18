# Classes are objects in Bike so they inherit from BikeObject. BikeClass is the way of representing Bike Classes that are initialized or not initialized. There are no properties in bike classes, only methods, which is conveiniently simple for syntax and code.
class BikeClass < BikeObject
  # +runtime_methods+ is the property that holds all of the instances methods. It does not hold any of the super-classes methods, but all mixin methods are copied into it.
  attr_reader :runtime_methods
  # +runtime_superclass+ holds the BikeClass for the superclass of this object. +Object+ is the great-grandsuperclass of everything.
  attr_reader :runtime_superclass
  # +ruby_value+ is a dummy value <tt>"<class>"</tt>
  attr_reader :ruby_value
  attr_reader :superclass_name

  # The initialization is basicly getting the superclass from constants, copying all of the methods from all of the mixins into the +runtime_methods+ property and then returning.
  def initialize(superclass="Object", mixins=[])
    @runtime_methods = {}
    @runtime_class = Constants["Class"]
    @runtime_superclass = Constants[superclass]
    @superclass_name = superclass

    @ruby_value = "<class>"
  end

  # Lookup a method and return it. Looks through all of the +runtime_methods+ all the way up the superclass chain.
  def lookup(method_name)
    method = @runtime_methods[method_name]
    unless method
      if @runtime_superclass
        return @runtime_superclass.lookup(method_name)
      else
        raise "Method not found: #{method_name.inspect} of #{@superclass_name}"
      end
    end
    method
  end
  # Helper method to define a method on this class from Ruby. <b>Only use this in bootstrap.rb to keep the code organized</b>
  #
  #     def :method_name, { |receiver, arguments| ...body... }
  #
  def def(name, &block)
    @runtime_methods[name.to_s] = block
  end

  # Create a new instance of this class
  def new
    BikeObject.new(self)
  end

  # Create an instance of this Bike class that holds a Ruby value. Like a String,
  # Number or true.
  def new_with_value(value)
    BikeObject.new(self, value)
  end
end
