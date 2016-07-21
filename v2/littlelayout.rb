=begin
The layout classes are a set of directions of how to display
components. this is meant to be used with the littlemenu ruby
suite.
=end


module LittleLayout
  
  class HorizontalFloat
    attr_accessor :pad
    def initialize (shape, pad=10)
      @pad = pad
      @shape = shape
      reset_constraint(shape.constraint)
    end
    # Inserts a new component into the layout.
    # @param child [Component] is the component to add.
    def add (child)
      #change add_contraints based on layout type
      return false if not canAdd?(child)
      if @add_constraint.x1 < (child.shape.constraint.w + @add_constraint.x)
        @add_constraint.y += @add_height #already has @pad added
        @add_height = 0
      end
      if @add_constraint.y1 < (child.shape.constraint.h + @add_constraint.y)
        return false
      end
      if @add_height < child.shape.constraint.h + @pad
        @add_height = child.shape.constraint.h + @pad
      end
      child.shape.set(@add_constraint)
      @add_constraint.x += child.shape.constraint.w + @pad
      true
    end
    
    def canAdd?(child)
      cond = child.shape.constraint.w < (@add_constraint.x1 - @add_constraint.x)
      cond2 = child.shape.constraint.h < (@add_constraint.y1 - @add_constraint.y)
      if not (cond and cond2)
        if @add_constraint.fit
          #change either the width or height
          #let's do this based on the layout
          #here we'll have the h grow bc else everything would
          #have to be re-added
          @shape.constraint.h += child.shape.constraint.h + @pad
          @add_constraint.h = @shape.constraint.h
          return true
        end
      end
      return (cond and cond2)
    end
    
    def update(constraint, children)
      reset_constraint(constraint)
      children.each do |i|
        result = add(i) if i.visible?
        i.hide if not result
      end
    end
    
    def to_s
      str = "Horizontal Float:\n"
      str += "\tAdd: " + (@add_constraint ? @add_constraint.to_s : "*") + ", "
      str += "Height: " + @add_height.to_s + ", Pad: " + @pad.to_s
    end
    
    private
    def reset_constraint(constraint)
      @add_height = 0
      c = constraint.clone
      @add_constraint = c
      @add_constraint.x += @pad
      @add_constraint.y += @pad
      @add_constraint.x1 -= @pad
      @add_constraint.y1 -= @pad
    end
  end
  
  class VerticalFloat
    @add_width = 0
  end

  class
end