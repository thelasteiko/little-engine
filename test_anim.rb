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
          3, 32, 32, 1000)
      @imagecreated = false
      @countdown = 100
    end
    def update
      if not @image
        create_buffer
      end
      if @image and @countdown > 0
        @countdown -= 1
      end
    end
    def draw (graphics, tick)
      if @image
        if @countdown <= 0
          @image.crop(32,32,32*2,32*2) #won't work
        end
        graphics.drawImage(@image,@x,@y)
        if not @imagecreated
          $FRAME.log(1, "W: " + @image.width.to_s + ", H: " + @image.height.to_s)
          @imagecreated = true
        end
      end
    end
    def create_buffer
      @image = FXPNGImage.new($FRAME.getApp(), nil, IMAGE_KEEP|IMAGE_SHMI|IMAGE_SHMP)
      return false if not @image
      $FRAME.getApp().beginWaitCursor do
        FXFileStream.open(@filename, FXStreamLoad) {|stream| @image.loadPixels(stream)}
        @image.create
      end
      @image.crop(0,0,32,32)
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
    app = FXApp.new('Little Game', 'Test')
    game = LittleGame.new
    $FRAME = LittleFrame.new(app, 400, 300, game)
    game.changescene(AnimScene.new(game))
    $FRAME.start
end