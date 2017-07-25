

require_relative 'v2/littlegraphics'
require_relative "littlegame.rb"
require_relative "v2/littlemanager.rb"

class Pointer < Little::Object
	include Little::Focusable
	
	def initialize (x, y, z=0)
		super()
		point.x = x
		point.y = y
		point.z = z
		@order = z
	end
	
	def order
		point.z
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
		push Tick.new(Little::Point.new(0,0,0),
			Little::Point.new(0,-100,0), :static,
			Gosu::Color::WHITE)
		push Tick.new(Little::Point.new(0,0,0),
			Little::Point.new(0,-100,0), :rotate,
			Gosu::Color::BLUE)
		push Tick.new(Little::Point.new(0,0,0),
			Little::Point.new(0,0,-100), :turn,
			Gosu::Color::GREEN)
		push Tick.new(Little::Point.new(0,0,0),
			Little::Point.new(0,0,100), :tilt,
			Gosu::Color::RED)
	end
end

if __FILE__ == $0
    $FRAME = Little::Game.new(800, 600, "Test", PointScene)
    $FRAME.show
end


