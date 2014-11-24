class TestClass < Struct.new(:name)
  def eval
    puts name || "foobar"
    name = name || "foobar"
    puts name || "foobar"
  end
end
TestClass.new("Class").eval()
