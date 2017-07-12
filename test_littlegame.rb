
require_relative "littlegame.rb"

class TestObject < Little::Object
	include Little::Focusable
	def initialize (game, scene)
		super game, scene
		@point = Little::Point.new(20,20)
		#print "Created object\n"
	end
	
	def draw (graphics, tick)
		#Gosu::draw_rect(20,20,50,50,Gosu::Color::WHITE)
		#print "drawing object\n"
		graphics.rect(point, 50, 50)
	end
end

class TestScene < Little::Scene
	def initialize(game)
		super(game)
		push(TestObject.new(game,self))
	end
end

if __FILE__ == $0
    $FRAME = Little::Game.new(800, 600, "Test", TestScene)
    $FRAME.show
end
