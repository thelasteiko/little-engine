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

require 'fox16'
require 'fox16/keys'
require_relative 'littleengine'
require_relative 'v2/littleanim'
include Fox

  class TestObject < GameObject
    attr_accessor :mode
    attr_accessor :state
    def initialize (game,group)
      super(game,group)
      @x = 50
      @y = 50
      @speed = 0.4
      walk_down = Animation.new("resource/mindyimport.png",
          3, 32, 32, @speed, still_frame: 1)
      walk_right = Animation.new("resource/mindyimport.png",
          3, 32, 32, @speed, y: 64, image_height: 32, still_frame: 1)
      walk_left = Animation.new("resource/mindyimport.png",
          3, 32, 32, @speed, y: 32, image_height: 32, still_frame: 1)
      walk_up = Animation.new("resource/mindyimport.png",
          3, 32, 32, @speed, y: 96, image_height: 32, still_frame: 1)
      @anims = [walk_down,walk_left,walk_up,walk_right]
      #@countdown = 100
      @oldmode = 0
      @mode = 0
      @state = LittleInput::RELEASE
    end
    def update
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
  class AnimScene < Scene
    def initialize (game)
      super
      @groups[:testgroup] = Group.new(game, self)
      push(:testgroup, TestObject.new(game,:testgroup))
      @time = 0
    end
    def input_map
      #left,up,right,down
      {KEY_Left => :move, KEY_Up => :move,
        KEY_Right => :move, KEY_Down => :move,}
    end
    def move (args)
      i = args[:code] % 4
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
    game = LittleGame.new
    game.changescene(AnimScene.new(game))
    $FRAME.start(game)
end