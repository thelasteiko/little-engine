#!/usr/bin/env ruby

require 'fox16'
require_relative 'littleengine'
include Fox

class Ball < GameObject
  def initialize (game, x = 20, y = 20)
    super(game)
    @x = x
    @y = y
    @fillcolor = Fox.FXRGB(255,235,205)
  end
  
  def draw (graphics, tick)
    graphics.foreground = @fillcolor
    #TODO draw a circle
    #graphics.fillCir(@x,@y,20,20)
  end
  def update
    #TODO implement physics
  end
end

class Bumper < GameObject
  def initialize (game, x = 20, y = 20)
    super(game)
    @x = x
    @y = y
    @fillcolor = Fox.FXRGB(255,235,205)
  end
  def draw (graphics, tick)
    graphics.foreground = @fillcolor
    graphics.fillRectangle(@x,@y,100,20)
  end
  def move (args)
    w = 300
    if @group.canvas
      w = @group.canvas.width
    end
    x = args[:x] - 50
    if x > 0 or x + 100 < w
      @x = x
    end
  end
end

class Pong < Scene
  def initialize (game)
    super
    @groups[:user] = Group.new(self)
    @groups[:ball] = Group.new(self)
    push(:user, Bumper.new(@groups[:user], 20, 280))
  end
  def input_map
    {LittleInput::MOUSE_MOTION => :motion}
  end
  
  def motion (args)
    bumper = @groups[:user][0]
    bumper.move({x: args[:x1], y: args[:y1]})
  end
end

if __FILE__ == $0
  app = FXApp.new('Little Game', 'Test Input')
  game = LittleGame.new
  $FRAME = LittleFrame.new(app, 400, 300, game)
  game.changescene(Pong.new(game))
  $FRAME.start
end
