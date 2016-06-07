module MyModule
  def add_some_variable
    @some_variable = true
  end
  def some_variable
    @some_variable |= false
  end
end

class MyClass
include MyModule
  attr_accessor :this_variable
  def initialize
    @this_variable = true
  end
end


c1 = MyClass.new

puts c1.this_variable

c1.add_some_variable

puts c1.some_variable
