
require_relative "littlegame.rb"

class TestDraw < Little::Object
	include Little::Focusable
	include Little::Traceable
	
	def initialize (game, scene, x, y)
		super game, scene
		@point = Little::Point.new(x,y)
		#print "Created object\n"
		#@path = Little::Path.new
		path.push(10, 59)
		path.push(83,45)
		#path.each {|i| $FRAME.log self, "each", "#{i}"}
		#game.camera.focus = self
	end
	
	def draw (graphics, tick)
		#Gosu::draw_rect(20,20,50,50,Gosu::Color::WHITE)
		#print "drawing object\n"
		#graphics.rect(point, 50, 50)
		#graphics.pixel(point: point)
		graphics.path(path)
		#graphics.line_ogl(point, Little::Point.new(10,60))
		#graphics.line(point, Little::Point.new(10,60))
		#graphics.rect(50,50,point: point)
		#graphics.pixels(path, color: Gosu::Color::BLUE)
	end
end

class TestImage < Little::Object
	include Little::Focusable
	
	def initialize (game, scene, x, y)
		super game, scene
		point.x = x
		point.y = y
		@image = Gosu::Image.new("resource/hood.png")
		game.camera.focus = self
	end
	
	def draw (graphics, tick)
		graphics.image(@image, point, scale: Little::Point.new(2,2),
			rotate_angle: 280)
	end
end

class TestScene < Little::Scene
	def initialize(game)
		super(game)
		push (TestDraw.new(game,self,50,50))
		push (TestImage.new(game, self, 43, 80))
		#push (TestObject.new(game,self,80,100))
	end
end

if __FILE__ == $0
    $FRAME = Little::Game.new(800, 600, "Test", TestScene)
    $FRAME.show
end
