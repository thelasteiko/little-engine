

require_relative 'v2/littlegraphics'
require_relative "littlegame.rb"
require_relative "v2/littlemanager.rb"

class RotatingImage < Little::Object
	include Little::Focusable
	include Little::Shapeable
	
	def initialize(center, start, type)
		super()
		@point = center
		@start = start
		@current = start
		@angle = 0.0
		@tick_counter = 0.0
		@speed = 10.0
		@type = type
		#@shape = Little::Shape.new(
	end
	
	def load
		@image = Gosu::Image.new("resource/hood.png")
	end
	
	def update (tick)
		@tick_counter += tick
		if @tick_counter >= 1
			@angle += (@speed * tick)
			@angle = 0.0 if @angle >= 360
			if @type == :turn
				@current = @start.turn(@angle,@point)
			elsif @type == :rotate
				@current = @start.rotate(@angle,@point)
			elsif @type == :tilt
				@current = @start.tilt(@angle,@point)
			elsif @type == :pos_diagonal
				@current = @start.transform(15.0,@angle,@point)
			end
			@tick_counter = 0.0
		end
	end
	
	def draw (graphics)
		graphics.image(@image,@current,
	end
end

class Tick < Little::Object
	include Little::Focusable
	
	def initialize(center, start, type, color)
		super()
		@point = center
		@start = start
		@current = start
		@angle = 0.0
		@tick_counter = 0.0
		@speed = 10.0
		@type = type
		@color = color
	end
	
	def load
		@game.camera.focus = self
	end
	
	def update (tick)
		@tick_counter += tick
		if @tick_counter >= 1
			@angle += (@speed * tick)
			@angle = 0.0 if @angle >= 360
			if @type == :turn
				@current = @start.turn(@angle,@point)
			elsif @type == :rotate
				@current = @start.rotate(@angle,@point)
			elsif @type == :tilt
				@current = @start.tilt(@angle,@point)
			elsif @type == :pos_diagonal
				@current = @start.transform(15.0,@angle,@point)
			end
			@tick_counter = 0.0
		end
	end
	
	def draw (graphics)
		graphics.line_ogl(@point,@current, color: @color)
	end
end


class PointScene < Little::Scene
	def initialize(game)
		super
		center = Little::Point.new(0,0,0)
		push Tick.new(center,
			Little::Point.new(0,-100,0), :static,
			Gosu::Color::WHITE)
		push Tick.new(center,
			Little::Point.new(0,-100,0), :rotate,
			Gosu::Color::BLUE)
		push Tick.new(center,
			Little::Point.new(0,0,-100), :turn,
			Gosu::Color::GREEN)
		push Tick.new(center,
			Little::Point.new(0,0,100), :tilt,
			Gosu::Color::RED)
		di_start = Little::Point.new(100,0,0)#.rotate(45.0, center)
		push Tick.new(center,di_start, :pos_diagonal,
			Gosu::Color::CYAN)
		
	end
end

if __FILE__ == $0
    $FRAME = Little::Game.new(800, 600, "Test", PointScene)
    $FRAME.show
end


