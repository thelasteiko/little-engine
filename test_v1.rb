#!/usr/bin/env ruby

require_relative 'littlegame'

class BouncyBall < Little::Object
	include Little::Focusable
	MAX_SPEED = 5
	def initialize (x, y, r)
		super()
		point.x = x
		point.y = y
		point.z = r
		@vector = Little::Point.new(5,0)
		@accel = 2
	end
	
	def load
		@img = point.to_circle(@game, Gosu::Color::RED)
	end
	
	def update (tick)
		@vector.x += @accel
		@vector.y += @accel
		if @vector.x.abs > MAX_SPEED
			@vector.x = @vector.x < 0 ? -MAX_SPEED : MAX_SPEED
		end
		if @vector.y.abs > MAX_SPEED
			@vector.y = @vector.y < 0 ? -MAX_SPEED : MAX_SPEED
		end
		
		point.add!(@vector)
		
		bx1 = 5
		by1 = 5
		bx2 = @game.width - 5
		by2 = @game.height - 5
		
		cxl = point.x
		cxr = point.cx + point.z
		cyu = point.y
		cyd = point.cy + point.z
		
		if cxl <= bx1 || cxr >= bx2
			@vector.x = -@vector.x
		end
		if cyu <= by1 || cyd >= by2
			@vector.y = -@vector.y
		end
	end
	
	def draw (graphics)
		graphics.image(@img, point, color:	Gosu::Color::RED)	
	end
end

class BallScene < Little::Scene
	def initialize (game)
		super(game)
		push(BouncyBall.new(20,20,32), :balls)
	end
end

if __FILE__ == $0
    $FRAME = Little::Game.new(800, 600, "Test", BallScene)
    $FRAME.show
end
