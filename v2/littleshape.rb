=begin
The shape classes pair with constraints and themes to draw
a shape on the canvas. The shape is part of a component that
can have child components all with their own shape.
=end

# Defines bounds for a shape.
# @author Melinda Robertson
# @version 20160606
class Constraint
  attr_accessor :x   #top left
  attr_accessor :y   #top left
  attr_accessor :x1  #bottom right
  attr_accessor :y1  #bottom right
  attr_accessor :w   #width
  attr_accessor :h   #height
  attr_accessor :r   #radius
  attr_accessor :xc  #center x
  attr_accessor :yc  #center y
  # Creates a constraint object.
  # @param x [Fixnum] is the top left x coordinate.
  # @param y [Fixnum] is the top left y coordinate.
  # @param w [Fixnum] is the width.
  # @param h [Fixnum] is the height.
  def initialize (x=0, y=0, w=0, h=0)
    @x = x
    @y = y
    @w = w
    @h = h
    if w == h 
      @r = w/2
      @xc = x+@r
      @yc = y+@r
    else
      @r = 0
      @xc = 0
      @yc = 0
    end
    @x1 = x+w
    @y1 = y+h
  end
  # Creates a deep copy of the object.
  def clone
    c = Constraint.new(@x,@y,@w,@h)
    return c
  end
  # Sets the x and y values and re-calculates derived values.
  # @param constraint [Contraint] holds the new x and y values.
  def set(constraint)
    @x = constraint.x
    @y = constraint.y
    if @r > 0
      @xc = @x+@r
      @yc = @y+@r
    end
    @x1 = @x+@w
    @x2 = @x+@w
  end
  # Returns a string representation of the object.
  def to_s
    str = "{x:" + @x.to_s + ",y:" + @y.to_s + ",x1:" + @x1.to_s + ",y1:" + @y1.to_s + ",w:"
    str += @w.to_s + ",h:" + @h.to_s + ",r:" + @r.to_s + "," + @xc.to_s + "," + @yc.to_s + "}"
    return str
  end
end

#To draw the component I need to have a shape to draw.
#Fox.FXRGB(255, 235, 205)
#use the fx ruby rgb colors

# Colors, size and style related to appearance of a shape.
class Theme
  #http://www.rubydoc.info/gems/fxruby/Fox/FXColor
  attr_accessor :stroke_color #border
  attr_accessor :fill_color   #inside shape
  attr_accessor :highlight_color #when selected
  #string representing style: "dash", "dot"
  attr_accessor :border_style
  #pixel point size of border
  attr_accessor :border_size
  #http://www.rubydoc.info/gems/fxruby/Fox/FXFont
  attr_accessor :font_type
  attr_accessor :font_size
  attr_accessor :font_color
  attr_accessor :font_weight
  attr_accessor :corner_style
  
  #Creates the default theme.
  def initialize
    @stroke_color = Fox.FXRGB(0,0,0)
    @fill_color = Fox.FXRGB(255,255,255)
    @highlight_color = Fox.FXRGB(55,55,55)
    @border_style = "solid"
    @border_size = 2
    #@font = FXFont.new(getApp(), "times", 36, FONTWEIGHT_NORMAL)
    @font_type = "times"
    @font_size = 12
    @font_color = Fox.FXRGB(0,0,0)
    @font_weight = FONTWEIGHT_NORMAL
    @corner_style = "sharp"
  end
  
  # Returns a FXFont instance.
  # @param app [FXApp] is the parent application.
  def font(app)
    font = FXFont.new(app, @font_type, @font_size, @font_weight)
    font.create
    return font
  end
  # Creates a deep copy of the object.
  def clone
    theme = Theme.new
    theme.stroke_color = @stroke_color if @stroke_color
    theme.fill_color = @fill_color if @fill_color
    theme.highlight_color = @highlight_color if @highlight_color
    theme.border_style = @border_style.clone if @border_style
    theme.border_size = @border_size if @border_size
    theme.font_type = @font_type.clone if @font_type
    theme.font_size = @font_size if @font_size
    theme.font_weight = @font_weight if @font_weight
    theme.font_color = @font_color if @font_color
    theme.corner_style = @corner_style.clone if @corner_style
    return theme
  end
  # Creates a string representation of the object.
  def to_s
    str = "{SC:" + (@stroke_color ? @stroke_color.to_s : "*") + ","
    str += "FC:" + (@fill_color ? @fill_color.to_s : "*") + ","
    str += "HC:" + (@highlight_color ? @highlight_color.to_s : "*") + ","
    str += "BST:" + (@border_style ? @border_style.to_s : "*") + ","
    str += "BSI:" + (@border_size ? @border_size.to_s : "*")
    return str
  end
end

# The shape module holds classes that represent different
# shapes.
module LittleShape
  class Rectangle
    attr_accessor :constraint #shape boundaries
    attr_accessor :theme      #color and style
    
    # Creates a rectangle object.
    # @param constraint [Constraint] lists the numerical size parameters.
    # @param theme [Theme] lists the color and style parameters.  
    def initialize (constraint, theme)
      @constraint = constraint
      @theme = theme
    end
    
    # Draws the shape with a graphics object.
    # @param graphics [FXDCWindow] the display component on which
    #                              the shape will be drawn.
    # @param tick [Float] the length of the current game loop.
    def draw (graphics, tick)
      if @theme.fill_color
        graphics.foreground = @theme.fill_color
        graphics.fillRectangle(@constraint.x, @constraint.y,
          @constraint.w, @constraint.h)
      end
      if @theme.stroke_color
        graphics.foreground = @theme.stroke_color
        graphics.drawRectangle(@constraint.x, @constraint.y,
          @constraint.w, @constraint.h)
      end
      #TODO support for borders and corner styles
    end
    
    # Creates a deep copy of the object.
    def clone
      Rectangle.new(@constraint.clone, @theme.clone)
    end
    
    # Short cut to reset x and y values according to the
    # given constraint.
    # @param constraint [Constraint] holds the new x and y values.
    def set (constraint)
      @constraint.set(constraint)
    end
    
    # Determines if a point intersects with this shape.
    # @param x [Fixnum] is the x coordinate.
    # @param y [Fixnum] is the y coordinate.
    def inside?(x, y)
      @constraint.x < x and @constraint.x1 > x and @constraint.y < y and @constraint.y1 > y
    end
    
    # Creates a string representation of the object.
    def to_s
      str = "Rectangle:\n"
      str += "\tConstraint: " + (@constraint ? @constraint.to_s : "*") + "\n"
      str += "\tTheme: " + (@theme ? @theme.to_s : "*")
      return str
    end
  end
end