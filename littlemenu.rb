=begin
Experiments for a menu system.

Let's start simple.
What does a menu need?
  container
  children
  theme
  layout
  location/constraints
=end

class Contraint
  attr_accessor:  x   #top left
  attr_accessor:  y   #top left
  attr_accessor:  x1  #bottom right
  attr_accessor:  y1  #bottom right
  attr_accessor:  w   #width
  attr_accessor:  h   #height
  attr_accessor:  r   #radius
  attr_accessor:  xc  #center x
  attr_accessor:  yc  #center y
  
  def initialize (x=0, y=0, w=0, h=0)
    @x = x
    @y = y
    @w = w
    @h = h
    if w = h 
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
  def copy
    Constraint.new(@x,@y,@w,@h)
  end
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
end

#To draw the component I need to have a shape to draw.
#Fox.FXRGB(255, 235, 205)
#use the fx ruby rgb colors
class Theme
  #http://www.rubydoc.info/gems/fxruby/Fox/FXColor
  attr_accessor: stroke_color
  attr_accessor: fill_color
  #string representing style: "dash", "dot"
  attr_accessor: border_style
  #pixel point size of border
  attr_accessor: border_size
  #http://www.rubydoc.info/gems/fxruby/Fox/FXFont
  attr_accessor: font
  #attr_accessor: font_size
  attr_accessor: font_color
  attr_accessor: corner_style
  
  def copy
    theme = Theme.new
    theme.stroke_color = @stroke_color
    theme.fill_color = @fill_color
    theme.border_style = @border_style
    theme.border_size = @border_size
    theme.font = @font
    theme.font_color = @font_color
    theme.corner_style = @corner_style
    return theme
  end
end

class Component < GameObject
  #parent must be defined
  attr_accessor: parent
  attr_reader: children
  #adopt the theme from parent unless theme is defined
  attr_accessor: layout
  attr_accessor: shape
  
  def initialize (group, parent=nil, x=0, y=0, w=0, h=0)
    super(group)
    @parent = parent
    @children = []
    if parent
      @shape = parent.shape.copy
    end
    @shape.theme = parent.shape.theme if parent
    @shape.constraint = Constraint.new(x,y,w,h)
    @layout = FloatLayout.new(self)
  end
  def add(child)
    child.parent = self
    @children.push(child)
    if not child.theme
      child.theme = @theme
    end
    @layout.add(child)
  end
  def remove_index(child)
    @children.delete_at(child)
  end
  def remove_object(child)
    @children.delete(child)
  end
  def [](child)
    @children[child]
  end
  def []=(index, child)
    @children[index] = child
  end
  def update
    @layout.update(@children)
  end
  def draw (graphics, tick)
    @shape.draw(graphics, tick)
    @children.each do |i|
      i.draw(graphics, tick)
    end
  end
end


