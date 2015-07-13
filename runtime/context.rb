# Context works to provide lexical scoping and a concept of +self+ to functions and classes.
class Context
  # +locals+ contains all of the local variables in this scope.
  attr_accessor :locals, :set
  # +current_self+ contains the thing that all methods will be added to.
  attr_reader :current_self
  # +current_class+ is a way to access the BikeClass behind the self.
  attr_reader :current_class
  def initialize(current_self, current_class = current_self.runtime_class)
    @locals = {}
    @set = {}
    @current_self = current_self
    @current_class = current_class
  end
end
