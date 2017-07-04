=begin
The next step is to add pictures for animations.

At this point as far as I can tell you need an FXImage
object of some kind to paint it on the canvas. And
then use dc.drawImage([image object], x, y)

Use FXMemoryStream to load the data then construct
an FXImage using it?
I need to know how to open files in Ruby.

Strategy:
  load images for a scene when the scene loads
  attach images and animations to objects
  have the animation object draw the images
=end

#!/usr/bin/env ruby

require_relative 'littleengine'
require_relative 'v3/littleanim'

  class Player < GameObject
    attr_accessor :mode
    attr_accessor :state
    def initialize (game,group)
      super(game,group)
      @x = 5
      @y = 5
      fr = 3
      mod = 0.1
      xs = 32
      ys = 32
      @speed = (32/fr)*mod
      #spd_of_walk = @speed / (fr*(1+(@speed*0.32)))
      spd_of_walk = (fr / (@speed))*mod
      walk_down = Animation.new("resource/mindyimport.png",
          fr, xs, ys, spd_of_walk, still_frame: 1)
      walk_right = Animation.new("resource/mindyimport.png",
          fr, xs, ys, spd_of_walk, y: 64, image_height: xs, still_frame: 1)
      walk_left = Animation.new("resource/mindyimport.png",
          fr, xs, ys, spd_of_walk, y: 32, image_height: xs, still_frame: 1)
      walk_up = Animation.new("resource/mindyimport.png",
          fr, xs, ys, spd_of_walk, y: 96, image_height: xs, still_frame: 1)
      @anims = [walk_down,walk_left,walk_up,walk_right]
      #@countdown = 100
      @oldmode = 0
      @mode = 0
      @state = LittleInput::RELEASE
    end
    def update(param={})
      if @oldmode != @mode
        @anims[@oldmode].reset
        @oldmode = @mode
      elsif @state == LittleInput::PRESS
        if @mode == 0
          @y += @speed
        elsif @mode == 1
          @x -= @speed
        elsif @mode == 2
          @y -= @speed
        elsif @mode == 3
          @x += @speed
        end
      end
    end
    def draw (graphics, tick)
      image = nil
      if @state == LittleInput::PRESS
        image = @anims[@mode].loop_around(tick)
      elsif @state == LittleInput::RELEASE
        image = @anims[@mode].pause(tick)
      end
      if image
        #puts @anim.to_s
        graphics.drawImage(image,@x,@y)
      end
    end
    def reset
      @anims[@mode].reset
    end
    def load (app)
      @anims.each{|i| i.load(app)}
    end
  end
  
=begin
  class HorizontalLineObject < GameObject
    def initialize (game, group, x)
      super(game,group)
      @color = Fox.FXRGB(255,255,255)
      @x = x
    end
    def draw(graphics, tick)
      graphics.foreground = @color
      graphics.drawLine(@x, 0, @x, @game.canvas.height)
    end
  end
=end

  class MainScene < Scene
    def initialize (game,params={})
      super
      @groups[:testgroup] = Group.new(game, self)
      push(Player.new(game,:testgroup),:testgroup)
      offset = 5
      for i in 0...13
        push(HorizontalLineObject.new(game,:lines,i*32+offset),:lines)
      end
      @time = 0
    end
    def input_map
      #left,up,right,down
      {KEY_Left => :move, KEY_Up => :move,
        KEY_Right => :move, KEY_Down => :move}
    end
    def move (args)
      i = args[:code] % 4 #NOTE key to cardinal movement
      #  $FRAME.log(1, "t: " + (args[:time]-@time).to_s)
      #@time = args[:time]
      mover = @groups[:testgroup][0]
      mover.mode = i
      mover.state = args[:state]
    end
  end

#This is a trial run to test that it's working.
if __FILE__ == $0
    $FRAME = LittleFrame.new(400, 300)
    game = LittleGame.new(AnimScene)
    $FRAME.start(game)
end