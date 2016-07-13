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
require_relative 'littleengine'
require_relative 'v3/littleanim'
include Fox

  class TestObject < GameObject
    def initialize (game,group)
      super(game,group)
      @x = 50
      @y = 50
      @anim = Animation.new("resource/mindyimport.png",
          3, 32, 32, 0.3)
      @countdown = 100
    end
    def update
      
    end
    def draw (graphics, tick)
      image = @anim.loop_around (tick)
      if image
        #puts @anim.to_s
        graphics.drawImage(image,@x,@y)
      end
    end
    def load (app)
      @anim.load(app)
    end
  end
  class AnimScene < Scene
    def initialize (game)
      super
      @groups[:testgroup] = Group.new(game, self)
      push(:testgroup, TestObject.new(game,:testgroup))
    end
  end

#This is a trial run to test that it's working.
if __FILE__ == $0
    $FRAME = LittleFrame.new(400, 300)
    game = LittleGame.new
    game.changescene(AnimScene.new(game))
    $FRAME.start(game)
end