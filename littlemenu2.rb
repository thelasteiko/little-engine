module LittleLayout
  
  class HorizontalFloat
    attr_accessor :pad
    def initialize (constraint, pad=10)
      @pad = 10
      @pad = pad
      reset_constraint(constraint)
    end
    # Inserts a new component into the layout.
    # @param child [Component] is the component to add.
    def add (child)
      #change add_contraints based on layout type
      if @add_contraint.x1 < (child.constraint.w + @add_constraint.x)
        @add_constraint.y += @add_height
        @add_height = 0
      end
      if @add_constraint.y1 < (child.constraint.h + @add_constraint.y)
        return false
      end
      if @add_height < child.constraint.h + @pad
        @add_height = child.constraint.h + @pad
      end
      child.set(@add_constraint)
      true
    end
    def update(constraint, children)
      reset_constraint(constraint)
      children.each do |i|
        add(i) if i.visible?
      end
    end
    
    private
    def reset_constraint(constraint)
      @add_height = 0
      @add_contraint = constraint.copy
      @add_contraint.x += @pad
      @add_contraint.y += @pad
      @add_contraint.x1 -= @pad
      @add_contraint.y1 -= @pad
    end
  end
  
  class VerticalFloat
    @add_width = 0
  end

end