

require_relative 'v2/littlegraphics'
require_relative "littlegame.rb"


class Box < Little::Object
    include Little::Shapeable
    
    def initialize (x, y, z, w, h, type)
        @shape = Little::Shape.new(x,y,z,w,h,5.0)
        @speed = 10.0
        @type = type
        @angle = 10.0
        @c = @shape.center
        @changed = false
    end
    
    def load
        @p1 = @shape.point		#top left
        @p2 = @shape.point.copy
        @p2.x += width		#top right
        @p3 = @shape.point.copy 
        @p3.x += width		#bottom right
        @p3.y += height
        @p4 = @shape.point.copy
        @p4.y += height		#bottom left
        @game.input.register(self,@scene,
			Little::Input::KEYSET_DIRECTIONAL,:change_angle)
		$FRAME.log self, "update","#{@angle}=>#{@p1.angle_xy(@c)}\n\t#{@p2.angle_xy(@c)}\n\t#{@p3.angle_xy(@c)}\n\t#{@p4.angle_xy(@c)}"
		$FRAME.log self, "update", "#{@p1}\n#{@p2}\n#{@p3}\n#{@p4}"
    end
    
    def update (tick)
		if @changed
		if @type == :tilt
			@p1 = @p1.tilt(@angle,@c)
			@p2 = @p2.tilt(@angle,@c)
			@p3 = @p3.tilt(@angle,@c)
			@p4 = @p4.tilt(@angle,@c)
		elsif @type == :rotate
			@p1 = @p1.rotate(@angle,@c)
			@p2 = @p2.rotate(@angle,@c)
			@p3 = @p3.rotate(@angle,@c)
			@p4 = @p4.rotate(@angle,@c)
		elsif @type == :turn
			@p1 = @p1.turn(@angle,@c)
			@p2 = @p2.turn(@angle,@c)
			@p3 = @p3.turn(@angle,@c)
			@p4 = @p4.turn(@angle,@c)
		end
		@changed = false
		$FRAME.log self, "update","#{@angle}=>#{@p1.angle_xy(@c)}\n\t#{@p2.angle_xy(@c)}\n\t#{@p3.angle_xy(@c)}\n\t#{@p4.angle_xy(@c)}"
		$FRAME.log self, "update", "#{@p1}\n#{@p2}\n#{@p3}\n#{@p4}"
		end
    end
    
    def draw (graphics)
        #draw a box with lines
        graphics.line_ogl(@p1,@p2)
        graphics.line_ogl(@p2,@p3)
        graphics.line_ogl(@p3,@p4)
        graphics.line_ogl(@p4,@p1)
    end
    
    def change_angle
		@changed = true
    end
end

class ObjScene < Little::Scene
    def initialize(game)
        super
        
        push Box.new(300,300,0,50,50,:rotate)
    end

end




if __FILE__ == $0
    $FRAME = Little::Game.new(800, 600, "Test", ObjScene)
    $FRAME.show
end
