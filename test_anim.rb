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
require_relative 'v3/littleanim'
include Fox

  class TestObject < GameObject
    attr_accessor :mode
    def initialize (game,group)
      super(game,group)
      @x = 50
      @y = 50
      walk_down = Animation.new("resource/mindyimport.png",
          3, 32, 32, 0.3)
      walk_right = Animation.new("resource/mindyimport.png",
          3, 32, 32, 0.3, 0, 64, 0, 32)
      walk_left = Animation.new("resource/mindyimport.png",
          3, 32, 32, 0.3, 0, 32, 0, 32)
      walk_up = Animation.new("resource/mindyimport.png",
          3, 32, 32, 0.3, 0, 96, 0, 32)
      @anims = [walk_down,walk_left,walk_up,walk_right]
      @countdown = 100
      @oldmode = 0
      @mode = 0
    end
    def update
      if @oldmode != @mode
        @anims[@oldmode].reset
        @oldmode = @mode
      end
    end
    def draw (graphics, tick)
      image = @anims[@mode].loop_around(tick)
      if image
        #puts @anim.to_s
        graphics.drawImage(image,@x,@y)
      end
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
        $FRAME.log(1, "t: " + (args[:time]-@time).to_s)
      @time = args[:time]
      mover = @groups[:testgroup][0]
      mover.mode = i
    end
  end

#This is a trial run to test that it's working.
if __FILE__ == $0
    $FRAME = LittleFrame.new(400, 300)
    game = LittleGame.new
    game.changescene(AnimScene.new(game))
    $FRAME.start(game)
end