#!/usr/bin/env ruby

require 'fox16'
require_relative 'littleengine'
include Fox

# In order to use the debugger, these classes
# must be wrapped in a module that includes LittleEngine
module MyGame
  include LittleEngine
  class SquareObject < GameObject
    def initialize (group)
      super
      @x = 50
      @y = 50
      @fillcolor = Fox.FXRGB(255, 235, 205)
    end
    def update
    end
    def draw (graphics, tick)
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
    def startinput
      @canvas.connect(SEL_LEFTBUTTONPRESS, method(:create))
      @canvas.connect(SEL_RIGHTBUTTONPRESS, method(:switch))
      @canvas.connect(SEL_KEYPRESS) do |sender, sel, data|
        @inputqueue.push([:keypress, data.code])
      end
    end
  end
end

#This is a trial run to test that it's working.
if __FILE__ == $0
    app = FXApp.new('Little Game', 'Test')
    game = LittleEngine::LittleGame.new
    game.changescene(MyGame::TestScene.new(game))
    $FRAME = LittleEngine::LittleFrame.new(app, 400, 300, game)
    $FRAME.start
end