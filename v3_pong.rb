#!/usr/bin/env ruby

require 'fox16'
require_relative 'littleengine'
include Fox

class Ball < GameObject
  attr_accessor :x
  attr_accessor :y
  attr_accessor :r
  def initialize (game, group, x = 20, y = 20, r = 10)
    super(game, group)
    @x = x
    @y = y
    @r = r
    @fillcolor = Fox.FXRGB(255,235,205)
    @speed = 5.0
    @dx = 1.0
    @dy = 1.0
  end
  
  def draw (graphics, tick)
    graphics.foreground = @fillcolor
    graphics.fillCircle(@x,@y,@r)
  end
  def update
    cw = @game.canvas.width
    ch = @game.canvas.height
    if @x <= 0 or @x >= cw
      reverse_x
    end
    if @y <= 0
      reverse_y
    end
    @x = @x + (@speed * @dx)
    @y = @y + (@speed * @dy)
  end
  def reverse_x
    @dx = -@dx
  end
  def reverse_y
    @dy = -@dy
  end
end

class Bumper < GameObject
  def initialize (game, group, x = 20, y = 20)
    super(game, group)
    @x = x
    @y = y
    @fillcolor = Fox.FXRGB(255,235,205)
  end
  def draw (graphics, tick)
    graphics.foreground = @fillcolor
    graphics.fillRectangle(@x,@y,100,20)
  end
  def update
    ball = @group.scene[:ball][0]
    if ball.y > @y
      @group.scene.game_over = true
      return
    end
    if ball.y+ball.r >= @y and ball.x >= @x and ball.x <= @x+100
      ball.reverse_y
    end
  end
  def move (args)
    w = 300
    if @game.canvas
      w = @game.canvas.width
    end
    w = w - 20
    x = args[:x] - 50
    if x > 0 and x + 50 < w
      @x = x
    elsif x <= 0
      @x = 0
    else
      @x = w-80
    end
  end
end

class GameOverText < GameObject
  def initialize (game, group)
    super
    @x = (game.canvas.width / 2)
    @y = (game.canvas.height / 2)
    @text = "Game Over"
    @fillcolor = Fox.FXRGB(255,235,205)
  end
  def update
    if not @font
      @font = FXFont.new($FRAME.getApp(), "times", 12, FONTWEIGHT_BOLD)
      @font.create
    end
  end
  def draw(graphics, tick)
    if @font
      graphics.foreground = @fillcolor
      graphics.font = @font
      graphics.drawText(@x, @y, @text)
    end
  end
end

class Pong < Scene
  attr_accessor :game_over
  def initialize (game)
    super
    @groups[:user] = Group.new(game, self)
    @groups[:ball] = Group.new(game, self)
    push(:user, Bumper.new(game, @groups[:user], 20, 280))
    push(:ball, Ball.new(game, @groups[:ball], 20, 20))
    @game_over = false
  end
  def input_map
    {LittleInput::MOUSE_MOTION => :motion}
  end
  def update
    super
    if @game_over
      @game.changescene(GameOver.new(@game))
    end
  end
  def motion (args)
    bumper = @groups[:user][0]
    bumper.move({x: args[:x1], y: args[:y1]})
  end
end

class GameOver < Scene
  def initialize (game)
    super
    @groups[:text] = Group.new(game, self)
    push(:text, GameOverText.new(game, @groups[:text]))
  end
end

if __FILE__ == $0
  app = FXApp.new('Little Game', 'Test Input')
  game = LittleGame.new
  $FRAME = LittleFrame.new(app, 400, 300, game)
  game.changescene(Pong.new(game))
  $FRAME.start
end
