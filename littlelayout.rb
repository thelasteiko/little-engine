=begin
The layout classes are a set of directions of how to display
components. this is meant to be used with the littlemenu ruby
suite.
=end


class Layout
  attr_accessor:  constraint
  attr_accessor:  pad
  attr_accessor:  add_contraint
  attr_reader:    add_height
  attr_reader:    add_width
  
  def initialize (parent, pad=10)
    @constraint = parent.constraint
    @pad = pad
    @add_contraint = @constraint.copy
    @add_contraint.x += @pad
    @add_contraint.y += @pad
    @add_contraint.x1 -= @pad
    @add_contraint.y1 -= @pad
    @add_height = 0
    @add_width = 0
  end
  def add (child)
    child.set(@add_constraint)
    #change add_contraints based on layout type
  end
end

class FloatLayout
  attr_accessor: orientation
  
  def initialize (parent, pad)
    super
  end
  def add (child)
    super
    
  end
end