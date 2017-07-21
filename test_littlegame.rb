
require_relative "littlegame.rb"
require_relative "v2/littlemanager.rb"

class GameObject < Little::Object
	include Little::Focusable
	
	def initialize (x, y)
		super ()
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
		@speed = 10
	end
	
	def update (tick)
		if not @focused
			#@game.camera.focus = self
			@focused = true
		end
		@tick = tick
	end
	
	def draw (graphics)
		graphics.image(@image, point)
	end
	
	def move (command)
		c = command % 4
		if c == 0
			point.x -= (@speed * @tick)
		elsif c == 1
			point.y += (@speed * @tick)
		elsif c == 2
			point.y -= (@speed * @tick)
		elsif c == 3
			point.x += (@speed * @tick)
		end
	end
end

class TestText < GameObject
	include Little::Typeable
	
	def initialize (x, y)
		super x, y
		@font = Gosu::Font.new(24)
		@string = "Input: "
		@tick_count = 0
	end
	def update (tick)
		@tick_count += tick
		if @tick_count >= 5
			$FRAME.log self, "update", "I'm sending a request."
			@group.scene.queue_request(self, :request)
			@tick_count = 0
		end
	end
	def draw (graphics)
		graphics.text @string, font, point, do_not_focus:	true
	end
	def type (command)
		@string += Gosu::button_id_to_char(command)
	end
	
	def request
		$FRAME.log self, "request", "My request was processed."
		return true
	end
end

class TestAudio < GameObject
	include Little::Audible
	
	def initialize ( x, y)
		super x, y
		load_sample("./resource/song_for_dad.wav", name: "heartbeat", loop: true)
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

class TestBackground < GameObject
	def initialize
		super(0,0)
		@image = Gosu::Image.new("resource/greenandspace.png")
	end
	def draw(graphics)
		graphics.image @image,point, do_not_focus:	true
	end
end

class TestScene < Little::Scene
	include Little::Accessible
	include Little::Manageable
	
	def initialize (game)
		super (game)
		push (TestDraw.new(50,50)), :foreground
		push TestImage.new(43, 80), :player
		push TestText.new(54,92), :text
		push (TestAudio.new(93,278))
		push TestBackground.new, :background
		@type_count = 0
		create_quick_list [:default, :background, :foreground]
		man = Little::LayerManager.new
		add_manager(man)
		man.set_order(:player, 2)
		#push (TestObject.new(game,self,80,100))
	end
	def input_map
		return {
			Little::Input::HOLD => {Little::Input::KEYSET_DIRECTIONAL => :move},
			Little::Input::KEYSET_ALPHA => :type
		}
	end
	def move (command)
		#$FRAME.log self, "move", "I'm going #{command}"
		player.move(command)
	end
	def type (command)
		@type_count += 1
		#$FRAME.log self, "type", "#{@type_count}: Typing #{command}"
		text.type(command.code)
	end
=begin
	def player
		return @groups[:player].object
	end
	def text
		return @groups[:text].object
	end
=end
end

if __FILE__ == $0
    $FRAME = Little::Game.new(800, 600, "Test", TestScene)
    $FRAME.show
end
