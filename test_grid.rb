
require_relative 'v2/littlegraphics'
require_relative "littlegame.rb"

require_relative "v2/littlemanager.rb"

class Line < Little::Object
	def initialize (x1, y1, x2, y2)
		@start_orig = Little::Point.new(x1,y1)
		@end_orig = Little::Point.new(x2,y2)
		@start_cur = @start_orig
		@end_cur = @end_orig
	end
	
	def update (tick)
		# transform points according to camera
		# while start rotates in the +, end rotates in the -
		if @game.camera.changed
			#$FRAME.log self, "update", "Moved from #{@start_orig}, #{@end_orig}"
			f = Little::Point.new
			#Little::Point.new((@game.width - 20) / 2, (@game.height - 20) / 2)
			#$FRAME.log self, "update", "With focus #{f.x}, #{f.y}"
			#$FRAME.log self, "update", "And angles #{@game.camera.view_angles.x},#{@game.camera.view_angles.y}"
			#$FRAME.log self, "update", "#{@game.camera.view_angles}"
			a = @game.camera.view_angles
			@start_cur = @start_orig.transform(a.x,a.y,a.z,f)
			@end_cur = @end_orig.transform(a.x,a.y,a.z,f)
			#$FRAME.log self, "update", "Moved to #{@start_cur}, #{@end_cur}\n"
		end
	end
	
	def draw (graphics)
		graphics.line_ogl(@start_cur,@end_cur, color: Gosu::Color::BLUE)
	end
end

class Pointer < Little::Object
	include Little::Focusable
	def initialize (mxp, myp)
		point.x = mxp
		point.y = myp
		@held_pt = point.copy
		@turn = 0.0
		@tilt = 0.0
		@rotate = 0.0
		@speed = 0.7
	end
	
	def load
		@game.input.register(self,@scene,Gosu::MS_LEFT, :move_camera, hold:	true)
		@game.input.register(self,@scene,Little::Input::KEYSET_DIRECTIONAL,
			:move_by_key, hold: true)
		@game.input.register(self,@scene,Little::Input::KEYSET_WASD,
			:move_by_key, hold: true)
		@img = Gosu::Image.new("resource/paper-plane.png")
	end
	
	def update (tick)
		@speed = tick
		point.x = @game.mouse_x
		point.y = @game.mouse_y
	end
	
	def draw(graphics)
		graphics.image(@img,point, do_not_focus: true,
			scale:	Little::Point.new(0.1,0.1))
	end
	
	def move_camera
		# turn and tilt the camera based on the difference in x and y
		# change in x => turn
		@turn += (@game.mouse_x - @held_pt.x) * @speed
		# change in y => tilt
		@tilt += (@game.mouse_y - @held_pt.y) * @speed
		@held_pt.x = @game.mouse_x
		@held_pt.y = @game.mouse_y
		#$FRAME.log self, "move_camera", "Moving to #{@turn}, #{@tilt}"
		@game.camera.tilt_turn(@tilt,@turn)
	end
	def move_by_key(c)
		if c == Gosu::KB_RIGHT
			@turn += @speed
			#@tilt += @speed / 2
			@rotate = @game.camera.tilt_turn(@tilt,@turn)
		elsif c == Gosu::KB_LEFT
			@turn -= @speed
			#@tilt -= @speed / 2
			@rotate = @game.camera.tilt_turn(@tilt,@turn)
		elsif c == Gosu::KB_UP
			@tilt += @speed
			#@turn += @speed / 2
			@rotate = @game.camera.tilt_turn(@tilt,@turn)
		elsif c == Gosu::KB_DOWN
			@tilt -= @speed
			#@turn -= @speed / 2
			@rotate = @game.camera.tilt_turn(@tilt,@turn)
		elsif c == Gosu::KB_A
			@rotate += @speed
			@turn = @game.camera.tilt_rotate(@tilt,@rotate)
		elsif c == Gosu::KB_D
			@rotate -= @speed
			@tilt = @game.camera.turn_rotate(@turn,@rotate)
		end
		#$FRAME.log self, "move_camera", "Moving to #{@turn}, #{@tilt}"
		
	end
end

class GridScene < Little::Scene
	def initialize (game)
		super
		# add horizontal and vertical lines
		w = game.width - 10
		h = game.height - 10
		x = - (w/2)
		y = - (h/2)
		s = 32
#		push Line.new(x,y,w,y)
		while y < 64
			# horizontal
			push Line.new(x,y,w-(w/2),y), :gridh
			y += s
		end
		y = - (h/2)
		while x < 64
			# vertical
			push Line.new(x,y,x,h-(h/2)), :gridv
			x += s
		end
		game.camera.focus = Little::Point.new
		push Pointer.new(w/2,h/2), :pointer
	end
end

if __FILE__ == $0
    $FRAME = Little::Game.new(800, 600, "Test", GridScene)
    $FRAME.show
end

