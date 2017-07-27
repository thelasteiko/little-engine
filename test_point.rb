

require_relative 'v2/littlegraphics'
require_relative "littlegame.rb"

# Little is a small and unassuming game engine based on Gosu.
# All rights go to the Gosu people for the Gosu code.
#
# Author::      Melinda Robertson
# Copyright::   Copyright (c) 2017 Little, LLC
# License::     GNU

require_relative "v2/littlemanager.rb"

class RotatingImage < Little::Object
	include Little::Focusable
	include Little::Shapeable
	
	def initialize(center, start, type)
		super()
		@point = Little::Point.new(0,0,0)
		@center = center
		@start = start
		@current = start
		@angle = 0.0
		@tick_counter = 0.0
		@speed = 20.0
		@type = type
		dim = Little::Point.new(16,16,16)
		@shape = Little::Shape.new(start,dim)
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
				@current = @start.transform(45.0,@angle,@point)
			end
			@tick_counter = 0.0
		end
	end
	
	def draw (graphics)
		#$FRAME.log self, "draw", "Drawing image?"
		graphics.image(@image,@current, shape: @shape)
	end
end

class Tick < Little::Object
	include Little::Focusable
	
	def initialize(center, start, type, color)
		super()
		@point = Little::Point.new(0,0,0)
		@center = center
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
			@angle = 0.0 if @angle >= 359
			if @type == :turn
				@current = @start.turn(@angle,@center)
			elsif @type == :rotate
				@current = @start.rotate(@angle,@center)
			elsif @type == :tilt
				@current = @start.tilt(@angle,@center)
			elsif @type == :pos_diagonal
				@current = @start.transform(15.0,@angle,@center)
			end
			@tick_counter = 0.0
		end
	end
	
	def draw (graphics)
		graphics.line_ogl(@center,@current, color: @color)
	end
end


class PointScene < Little::Scene
	def initialize(game)
		super
		center = Little::Point.new(12,0,0)
		push Tick.new(Little::Point.new(0,0,0),
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
			
		push RotatingImage.new(center,
			Little::Point.new(32,0,0), :pos_diagonal)
		
	end
end

if __FILE__ == $0
    $FRAME = Little::Game.new(800, 600, "Test", PointScene)
    $FRAME.show
end


