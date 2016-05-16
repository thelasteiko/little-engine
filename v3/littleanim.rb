=begin
The next step is to add pictures for animations.

At this point as fas as I can tell you need an FXImage
object of some kind to paint it on the canvas. And
then use dc.drawImage([image object], x, y)

Use FXMemoryStream to load the data then construct
an FXImage using it?
I need to know how to open files in Ruby.
=end

#!/usr/bin/env ruby

require 'fox16'
require_relative 'littleengine'
include Fox

# In order to use the debugger, these classes
# must be wrapped in a module that includes LittleEngine
module MyGame
  include LittleEngine
  class TestObject < GameObject
    def initialize (group)
      super
      @x = 50
      @y = 50
      @fillcolor = Fox.FXRGB(255, 235, 205)
      @timeout = 10
    end
    def update
      if @timeout == 0
        @x += 5
        @timeout = 10
        $FRAME.log(0, "Updated Position")
      else
        @timeout -= 1
      end
    end
    def draw (graphics, tick)
      if @timeout == 0
        $FRAME.log(0, "Drawing #{@fillcolor} at (#{@x},#{@y}) on #{graphics}")
      end
      graphics.foreground = @fillcolor
      graphics.fillRectangle(@x,@y,20,20)
    end
  end
  class TestScene < Scene
    def initialize (game)
      super
      @groups[:testgroup] = LittleEngine::Group.new(self)
      push(:testgroup, MyGame::TestObject.new(:testgroup))
    end
  end
end

#This is a trial run to test that it's working.
if __FILE__ == $0
    app = FXApp.new('Little Game', 'Test')
    game = LittleEngine::LittleGame.new
    game.changescene(MyGame::TestScene.new(game))
    $FRAME = LittleEngine::LittleFrame.new(app, 400, 300)
    $FRAME.start(game)
end