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

require_relative 'littleshape'
require_relative 'littlelayout'

# Base component for a menu item. This implementation
# can have child members.
# @author Melinda Robertson
# @version 20160603
class Component < GameObject
  #parent must be defined
  attr_accessor :parent
  attr_reader   :children
  #adopt the theme from parent unless theme is defined
  attr_reader   :layout
  attr_accessor   :shape
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
  def initialize (game, group, shape=nil, layout=nil, parent=nil)
    super(game, group)
    @parent = parent
    @children = []
    #so that children can have a different theme
    if not @shape or not @layout
      start_default(parent,shape,layout)
    else
      @shape = shape
      @layout = layout
    end
  end
  # Creates the new object with the default shape.
  # @param parent [Component] is the parent of the new object.
  def start_default(parent,shape,layout)
    constraint = Constraint.new
    if parent
      @shape = parent.shape.clone
      @shape.theme = parent.shape.theme
      @shape.constraint = constraint
    else
      if not shape
        @shape = LittleShape::Rectangle.new(constraint, Theme.new)
      end
    end
    if not layout
      @layout = LittleLayout::HorizontalFloat.new(@shape)
    end
  end
  
  # Adds a component as a child.
  # Sets the initial shape and theme to this object's
  # shape and theme if they have not been defined yet.
  # @param child [Component] is the component to add.
  def add(child, default=true)
    @children.push(child)
    safe_add_child(child, child.visible?, default)
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
  # Inserts a new component into the layout. This does not automatically
  # show the child. Set show before adding.
  # @param index [Fixnum] is the index of the child to insert in front of.
  # @param child [Component] is the component to insert.
  def insert(index, child)
    @children.insert(index, child)
    safe_add_child(child, false)
  end
  def count
    @children.size
  end
  # Updates the layout by recreating it.
  def update
    @layout.update(@shape.constraint,@children)
  end
  # Draws this and all child components.
  # @param graphics [FXDCWindow] is the graphics component for a canvas
  #                              where objects will be drawn.
  # @param tick [Fixnum] is the amount of time since the last game loop started.
  def draw (graphics, tick)
    if visible?
      @shape.draw(graphics, tick)
      @children.each do |i|
        i.draw(graphics, tick)
      end
    end
  end
  # Checks if the component should be drawn.
  def visible?
    @isVisible |= false
  end
  # Sets the component to be drawn.
  def show
    @children.each {|i| i.show}
    @isVisible = true
  end
  # Sets the component to not be drawn.
  def hide
    @children.each {|i| i.hide}
    @isVisible = false
  end
  
  def to_s
    str = "Parent: " + (@parent ? "T" : "F") + "\n"
    str += "Children: " + (@children ? count.to_s : "0") + "\n"
    str += "Layout: " + (@layout ? @layout.to_s : "F") + "\n"
    str += "Shape: " + (@shape ? @shape.to_s : "F")
    return str
  end
  
private
  # Adds a child by updating the shape, theme and adding it to the layout.
  # @param child [Component] is the component to add.
  # @param add_to_layout [TrueClass] is true to add to the layout.
  # @param adopt_theme [TrueClass] is true to adopt the shape of the parent.
  def safe_add_child(child, add_to_layout, adopt_theme)
    child.parent = self
    if not child.shape or adopt_theme
      child.shape = @shape.clone
      child.shape.theme = @shape.theme
    end
    @layout.add(child) if add_to_layout
  end
end

# Defines types of menus and adds helper methods.
module MenuType
  # The component contains other components that can be selected.
  module SelectContainer
    # Selects a child from the components' list of children.
    # @param index [Fixnum] is the index of the child to select.
    def select_index(index)
      if @children and @children[index]
        if @selected_child
          @selected_child.deselect
        end
        if @children[index].selectable?
          @children[index].select
          @selected_child = @children[index]
        end
      end
    end
    # Selects a child from the component's list of children.
    # @param child [Component] is the component child to select.
    def select_child(child)
      if @children and @children.include?(child)
        select_index(@children.index(child))
      end
    end
    # Deselects the current child.
    def deselect_child
      if @selected_child
        @selected_child.deselect
        @selected_child = nil
      end
    end
    # Returns the current selection or nil.
    # @return [Component] current selection or nil.
    def selected_child
      @selected_child |= nil
    end
  end
  #The component is able to be selected by the user.
  module Select
    # States if the component is currently selected.
    # @return true if it is selected, false otherwise.
    def selected?
      @selected |= false
    end
    # States if the component can be selected.
    # @return true if it can be selected, false otherwise.
    def selectable?
      @selectable |= true
    end
    def select
      @selected = true
    end
    def deselect
      @selected = false
    end
    
    def disable_select
      @selectable = false
    end
    def enable_select
      @selectable = true
    end
  end
  
  module Drag
    def draggable?
      @draggable |= true
    end
  end
  module Scroll
    def scrollable?
      @scrollable |= true
    end
  end
  module Expand
    def expandable?
      @expandable |= true
    end
  end
end


