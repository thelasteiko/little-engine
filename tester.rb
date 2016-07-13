#!/usr/bin/env ruby

require 'fox16'
require_relative 'littleengine'
require_relative 'v2/littlemenu'
include Fox

  class TestObject < GameObject
    def initialize (game, group)
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
        #$FRAME.log(0, "Updated Position")
      else
        @timeout -= 1
      end
      if not @font
        @font = FXFont.new($FRAME.getApp(), "times", 12, FONTWEIGHT_BOLD)
        @font.create
        $FRAME.log(0, "Font: " + @font.to_s)
      end
    end
    def draw (graphics, tick)
      if @timeout == 0
        #$FRAME.log(0, "Drawing #{@fillcolor} at (#{@x},#{@y}) on #{graphics}")
        #$FRAME.logtofile(self, "draw", "Test message; drawing box.");
      end
      graphics.foreground = @fillcolor
      if @font
        graphics.font = @font
        graphics.drawText(@x, @y + 40, "Hello")
      end
      graphics.fillRectangle(@x,@y,20,20)
    end
  end
  class TestScene < Scene
    def initialize (game)
      super
      push(:testgroup, TestObject.new(game, :testgroup))
    end
  end
#end

#This is a trial run to test that it's working.
if __FILE__ == $0
    app = FXApp.new('Little Game', 'Test')
    $FRAME = LittleFrame.new(app, 400, 300)
    game = LittleGame.new
    game.changescene(TestScene.new(game))
    $FRAME.start(game)
end