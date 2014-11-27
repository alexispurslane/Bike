class BikeClass < BikeObject
  # Classes are objects in Bike so they inherit from BikeObject.
  attr_reader :runtime_methods, :runtime_superclass, :runtime_mixins, :ruby_value
  def initialize(superclass="Object", mixins=[])
    @runtime_mixins = mixins
    @runtime_methods = {}
    if mixins != nil
      mixins.each do |e|
        Constants[e].runtime_methods.each_pair do |key, method| 
          @runtime_methods[key] = method
        end
      end
    end
    @runtime_class = Constants["Class"]
    @runtime_superclass = Constants[superclass]
    @ruby_value = "<class>"
  end
  # Lookup a method
  def lookup(method_name)
    method = @runtime_methods[method_name]
    unless method
      if @runtime_superclass
        method = @runtime_superclass.lookup(method_name)
      else
        raise "Method not found: #{method_name} of #{@runtime_superclass}"
      end
    end
    method
  end
  # Helper method to define a method on this class from Ruby.
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
