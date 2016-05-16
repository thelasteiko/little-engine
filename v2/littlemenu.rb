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

requires_relative 'littleshape.rb'
requires_relative 'littlelayout.rb'

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
  def clone
    Constraint.new(@x,@y,@w,@h)
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
end

#To draw the component I need to have a shape to draw.
#Fox.FXRGB(255, 235, 205)
#use the fx ruby rgb colors
class Theme
  #http://www.rubydoc.info/gems/fxruby/Fox/FXColor
  attr_accessor :stroke_color #border
  attr_accessor :fill_color   #inside shape
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
    @border_style = "solid"
    @border_size = 2
    #@font = FXFont.new(getApp(), "times", 36, FONTWEIGHT_NORMAL)
    @font_type = "times"
    @font_size = 12
    @font_color = Fox.FXRGB(0,0,0)
    @font_weight = FONTWEIGHT_NORMAL
    @corner_style = "sharp"
  end
  #Returns a FXFont instance
  def font(app)
    font = FXFont.new(app, @font_type, @font_size, @font_weight)
    font.create
    return font
  end
  def clone
    theme = Theme.new
    theme.stroke_color = @stroke_color.clone if @stroke_color
    theme.fill_color = @fill_color.clone if @fill_color
    theme.border_style = @border_style.clone if @border_style
    theme.border_size = @border_size if @border_size
    theme.font_type = @font_type.clone if @font_type
    theme.font_size = @font_size if @font_size
    theme.font_weight = @font_weight if @font_weight
    theme.font_color = @font_color.clone if @font_color
    theme.corner_style = @corner_style.clone if @corner_style
    return theme
  end
end

class Component < GameObject
  #parent must be defined
  attr_reader   :parent
  attr_reader   :children
  #adopt the theme from parent unless theme is defined
  attr_reader   :layout
  attr_reader   :shape
  attr_reader   :font
  attr_accessor :content #some value to display or store
  
  # Creates a new component to use in a GUI.
  # If the width and height are equal then a radius will
  # be calculated for the contraints as well.
  # @param group [Group] is the game object group.
  # @param parent [Component] is the parent container.
  # @param x [Numeric] is the x coordinate of the top left corner.
  # @param y [Numeric] is the y coordinate of the top left corner.
  # @param w [Numeric] is the width.
  # @param h [Numeric] is the height.
  def initialize (group, parent=nil, x=0, y=0, w=0, h=0)
    super(group)
    @parent = parent
    @children = []
    constraint = Constraint.new(x,y,w,h)
    if parent
      @shape = parent.shape.copy
      @shape.theme = parent.shape.theme
      @shape.constraint = constraint
    else
      @shape = Shape::Rectangle.new(constraint, Theme.new)
    end
    @layout = FloatLayout.new(@shape.constraint)
  end
  
  # Adds a component as a child.
  # Sets the initial shape and theme to this object's
  # shape and theme if they have not been defined yet.
  # @param child [Component] is the component to add.
  def add(child)
    child.parent = self
    @children.push(child)
    safe_add_child(child, child.visible?)
  end
  
  # Alias for @see Component.add
  def <<(child)
    add(child)
  end
  
  # Removes the child component at the indicated index.
  # @param index [Numeric] is the index to delete.
  # @return [Component] the deleted child.
  def remove_index(index)
    child = @children.delete_at(index)
    child.hide
    return child
  end
  # Removes the child component.
  # @param child [Component] is the component to delete.
  # @return [Component] the deleted child.
  def remove_object(child)
    child.hide
    @children.delete(child)
  end
  # Returns the index of a child component if it exists.
  # @param child [Component] is the component to find.
  # @return [Numeric] index of the child or nil.
  def index(child)
    @children.index(child)
  end
  # Finds a child given an index.
  # @param index [Numeric] is the index.
  # @return [Component] is a child at that index or nil.
  def [](index)
    @children[index]
  end
  # Safely replaces a child with another component.
  # @param index [Numeric] is the index of the child to remove.
  # @param child [Component] is the child to add.
  # @return [Component] the child that was removed.
  def []=(index, child)
    ch2 = @children[index]
    @children[index] = child
    safe_add_child(child, false)
    return ch2
  end
  # Safely replaces a child with another component.
  # @param child [Component] is the child to replace.
  # @param component [Component] is the child to insert.
  # @return [Component] the child that was removed.
  def replace(child, component)
    i = index(child)
    ch2 = @children.delete(child)
    @children.insert(i, component)
    safe_add_child(child, false)
    return ch2
  end
  # Inserts a new component into the layout.
  # 
  def insert(index, child)
    @children.insert(index, child)
    safe_add_child(child, false)
  end
  def update
    @layout.update(@constraint,@children)
  end
  def draw (graphics, tick)
    @shape.draw(graphics, tick) if visible?
    @children.each do |i|
      i.draw(graphics, tick)
    end
  end
  
  def visible?
    @isVisible
  end
  def show
    @isVisible = true
  end
  def hide
    @isVisible = false
  end
  
private
  def safe_add_child(child, add_to_layout)
    if not child.shape
      child.shape = @shape.copy
      child.shape.theme = @shape.theme
    end
    @layout.add(child) if add_to_layout
  end
end


