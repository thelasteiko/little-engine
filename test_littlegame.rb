
require_relative "littlegame.rb"

class GameObject < Little::Object
	include Little::Focusable
	
	def initialize (x, y)
		super
		point.x = x
		point.y = y
	end
end

class TestDraw < GameObject
	include Little::Traceable
	
	def initialize (x, y)
		super x, y
		#print "Created object\n"
		#@path = Little::Path.new
		path.push(10, 59)
		path.push(83,45)
		#path.each {|i| $FRAME.log self, "each", "#{i}"}
		#game.camera.focus = self
	end
	
	def draw (graphics)
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

class TestImage < GameObject
	def initialize (x, y)
		super x,y
		@image = Gosu::Image.new("resource/hood.png")
		#game.camera.focus = self
		@focused = false
	end
	
	def update (tick)
		if not @focused
			@game.camera.focus = self
			@focused = true
		end
	end
	
	def draw (graphics)
		graphics.image(@image, point, scale: Little::Point.new(2,2),
			rotate_angle: 280)
	end
end

class TestText < GameObject
	include Little::Typeable
	
	def initialize (x, y)
		super x, y
		@font = Gosu::Font.new(24)
	end
	def draw (graphics)
		graphics.text "Testing text.", font, point, do_not_focus:	true
	end
end

class TestAudio < GameObject
	include Little::Audible
	
	def initialize ( x, y)
		super x, y
		load_audio("./resource/song_for_dad.wav", name: "heartbeat", loop: true)
	end
	def update (tick)
		#$FRAME.log self, "update", "Checking playlist: #{playlist}"
		#$FRAME.log self, "update", "Checking done: #{playlist["heartbeat"].done?}"
		if playlist["heartbeat"].done?
			$FRAME.log self, "update", "Attempting to play"
			play "heartbeat"
		end
	end
end

class TestScene < Little::Scene
	def initialize (game)
		super (game)
		push (TestDraw.new(50,50))
		push (TestImage.new(43, 80))
		push (TestText.new(54,92))
		push (TestAudio.new(93,278))
		#push (TestObject.new(game,self,80,100))
	end
	def input_map
		return {
			Little::Input::HOLD => {Little::Input::KEYSET_DIRECTIONAL => :move,
				Little::Input::KEYSET_ALPHA => :type}
		}
	end
	def move (command)
		$FRAME.log self, "move", "I'm going #{command}"
		
	end
	def type (command)
		$FRAME.log self, "type", "Typing #{command}"
	end
end

if __FILE__ == $0
    $FRAME = Little::Game.new(800, 600, "Test", TestScene)
    $FRAME.show
end
