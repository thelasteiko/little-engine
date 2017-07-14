
require_relative "littlegame.rb"

class TestObject < Little::Object
	include Little::Focusable
	include Little::Shapeable
	
	def initialize (game, scene)
		super game, scene
		@point = Little::Point.new(0,0)
		#print "Created object\n"
		@path = Little::Path.new
		y = 10
		while y < 100
			@path.push(10,y)
			@path.push(750,y)
			y += 50
		end
		game.camera.focus = self
	end
	
	def draw (graphics, tick)
		#Gosu::draw_rect(20,20,50,50,Gosu::Color::WHITE)
		#print "drawing object\n"
		#graphics.rect(point, 50, 50)
		#graphics.pixel(point)
		graphics.path(path)
		#graphics.line_ogl(point, Little::Point.new(10,60))
		
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
