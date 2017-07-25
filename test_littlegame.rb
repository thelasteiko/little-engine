
require_relative "littlegame.rb"
require_relative "v2/littlemanager.rb"

class GameObject < Little::Object
	include Little::Focusable
	
	def initialize (x, y)
		super()
		point.x = x
		point.y = y
		@order = -2
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
		path.push(45, 90)
		path.push(90,10)
		#path.each {|i| $FRAME.log self, "each", "#{i}"}
		#game.camera.focus = self
		@order = -1
	end
	def load
		@image = path.to_img
	end
	def draw (graphics)
		#Gosu::draw_rect(20,20,50,50,Gosu::Color::WHITE)
		#print "drawing object\n"
		#graphics.rect(point, 50, 50)
		#graphics.pixel(point: point)
		#graphics.path(path)
		#graphics.line_ogl(point, Little::Point.new(10,60))
		#graphics.line(point, Little::Point.new(10,60))
		#graphics.rect(50,50,point: point)
		#graphics.pixels(path, color: Gosu::Color::BLUE)
		#$FRAME.log self, "draw", "#{point}"
		graphics.image(@image, point)
	end
end

class TestImage < GameObject
	def initialize (x, y)
		super x,y
		@image = Gosu::Image.new("resource/hood.png")
		#game.camera.focus = self
		@focused = false
		@speed = 10
		@level = y
		@order = 2
	end
	
	def load
		@game.input.register(self, @scene, Little::Input::KEYSET_DIRECTIONAL,
				:move, hold:	true)
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
	def load
		@game.input.register(self, @scene, Little::Input::KEYSET_ALPHA,:type)
	end
	def update (tick)
		@tick_count += tick
		#if @tick_count >= 5
			#$FRAME.log self, "update", "I'm sending a request."
			#@scene.queue_request(self, :request)
			#@game.input.request(self, @group.scene, :request, args: @game.scene.player)
			#@tick_count = 0
		#end
		#request(@scene.player)
	end
	def draw (graphics)
		graphics.text @string, font, point, do_not_focus:	true
	end
	def type (command)
		@string += Gosu::button_id_to_char(command)
	end
	
	def request (player)
		#$FRAME.log self, "request", "My request was processed."
		#@string = "#{player.point.x}, #{player.point.y}"
		#$FRAME.log self, "request", "Obj at #{point.y} is changing player #{(@c * point.y)}."
		#player.point.x += (@c * point.y)
		return true
	end
end

class TestAudio < GameObject
	include Little::Audible
	
	def initialize
		super 0,0
		load_sample("./resource/song_for_dad.wav", name: "heartbeat", loop: true)
	end
	def update (tick)
		#$FRAME.log self, "update", "Checking playlist: #{playlist}"
		#$FRAME.log self, "update", "Checking done: #{playlist["heartbeat"].done?}"
		if playlist["heartbeat"].done?
			#$FRAME.log self, "update", "Attempting to play"
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
		graphics.image @image,point #, do_not_focus:	true
	end
end

class TestScene < Little::Scene
	
	def initialize (game)
		super (game)
		push (TestDraw.new(50,50)), :foreground
		push TestImage.new(43, 80), :player
		#push (TestAudio.new)
		push TestBackground.new, :background
		@type_count = 0
		#create_quick_list [:default, :background, :foreground, :text]
		push TestText.new(10, 10), :text
		#man = Little::LayerManager.new
		#add_manager(man)
		#man.set_order(:player, 2)
		#man.set_order(:background, 1)
		#man.set_order(:foreground, 3)
		#push (TestObject.new(game,self,80,100))
		$FRAME.log self, "init", "W: #{game.width}, H: #{game.height}"
	end
	def player
		return @groups[:player].object
	end
=begin
	def move (command)
		#$FRAME.log self, "move", "I'm going #{command}"
		player.move(command)
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
