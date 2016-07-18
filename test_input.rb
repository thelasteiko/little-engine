#!/usr/bin/env ruby

require 'fox16'
require 'fox16/keys'
require_relative 'littleengine'
include Fox

# Tests processing input using the LittleInput module.
class Mover < GameObject
  def initialize (game, group, x = 20, y = 20)
    super(game, group)
    @x = x
    @y = y
    @fillcolor = Fox.FXRGB(255,235,205)
  end
  def draw (graphics, tick)
    graphics.foreground = @fillcolor
    graphics.fillRectangle(@x,@y,20,20)
  end
  def move (direction, amount)
    $FRAME.log(1, "Moving: " + direction + " " + amount.to_s)
    if direction == "up"
      @y = @y - amount
    elsif direction == "down"
      @y = @y + amount
    elsif direction == "right"
      @x = @x + amount
    elsif direction == "left"
      @x = @x - amount
    elsif direction == "click"
      @x = amount[:x]
      @y = amount[:y]
    end
  end
end

class InputTestScene < Scene
include LittleInput
  def initialize (game)
    super
    @groups[:movement] = Group.new(game,self)
    @mover = Mover.new(game, self, 50, 50)
    push(:movement, @mover)
    @amount = 10
  end
  def input_map
    {65363 => :right, 65361 => :left,
      65362 => :up, 65364 => :down,
      LittleInput::MOUSE_LEFT => :click,
      LittleInput::MOUSE_MOTION => :motion}
  end
  def left (args=nil)
    @mover.move("left", @amount)
  end
  def right (args=nil)
    @mover.move("right", @amount)
  end
  def up (args=nil)
    @mover.move("up", @amount)
  end
  def down (args=nil)
    @mover.move("down", @amount)
  end
  def click (args)
    @mover.move("click", args)
  end
  def motion (args) #this will cancel out click
    @mover.move("click", {x: args[:x1], y: args[:y1]})
  end
end

if __FILE__ == $0
  $FRAME = LittleFrame.new(400, 300)
  game = LittleGame.new
  game.changescene(InputTestScene.new(game))
  $FRAME.start(game)
end