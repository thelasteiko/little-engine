

require_relative 'v2/littlegraphics'
require_relative "littlegame.rb"


class Box < Little::Object
    include Little::Shapeable
    
    def initialize (x, y, z, w, h)
        @shape = Little::Shape.new(x,y,z,w,h)
    end
    
    def load
        p1 = point
        p2 = point.copy
        p2.x += @w
        p3 = point.copy
        p3 += @w
    end
    
    def draw (graphics)
        #draw a box with lines
    end
end

class ObjScene < Little::Scene
    def initialize(game)
        super
        
        
    end

end




if __FILE__ == $0
    $FRAME = Little::Game.new(800, 600, "Test", GridScene)
    $FRAME.show
end