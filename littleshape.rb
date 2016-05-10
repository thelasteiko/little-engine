=begin
The shape classes pair with constraints and themes to draw
a shape on the canvas. The shape is part of a component that
can have child components all with their own shape.
=end

#The shape class defines how to draw a certain shape.
#this is just a base class giving directions as to what
#needs to be in the shape...I think...
class Shape
  attr_accessor:  constraint
  attr_accessor:  theme
  #@param constraint [Constraint] lists the numerical size parameters.
  #@param theme [Theme] lists the color and style parameters.  
  def initialize (constraint, theme)
    @constraint = constraint
    @theme = theme
  end
  
  #@param graphics [FXDCWindow] the display component on which
  #                             the shape will be drawn.
  #@param tick [Float] the length of the current game loop.
  def draw (graphics, tick)
    #dependent on the type of shape
  end
  
  def copy
    Shape.new(@constraint.copy, @theme.copy)
  end
end

class Rectangle < Shape
  def draw (graphics, tick)
    if @theme.fill_color
      graphics.foreground = @theme.fill_color
      graphics.fillRectangle(@contraint.x, @constraint.y,
        @constraint.w, @constraint.y)
    end
    if @theme.stroke_color
      graphics.foreground = @theme.stroke_color
      graphics.drawRectangle(@constraint.x, @constraint.y,
        @constraint.w, @constraint.y)
    end
  end
  
end