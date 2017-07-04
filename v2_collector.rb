#!/usr/bin/env ruby

require_relative 'littleengine'
require_relative 'v2/littleinput'

# The player object reponds to input from the
# keyboard arrow keys.
class Player < GameObject
  # @!attribute [rw] state
  # @return [FixNum] whether a key is pressed or released.
  attr_accessor :state
  # @!attribute [rw] mode
  # @return [FixNum] the direction the player is moving in.
  attr_accessor :mode
  # @!attribute [rw] x
  # @return [Float] the x location of the player.
  attr_accessor :x
  # @!attribute [rw] y
  # @return [Float] the y location of the player.
  attr_accessor :y
  def initialize (game, group)
    super
    @x = 50
    @y = 50
    @width = 20
    @height = 20
    @fillcolor = Fox.FXRGB(255, 235, 205)
    @speed = 2.0
    @state = LittleInput::RELEASE
    @mode = 0
  end
  def update(param={})
    if @state == LittleInput::PRESS
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
    c = @game.scene.groups[:candy].entities
    c.each do |i|
      if i.inside?(@x+5,@y+5)
        @game.scene.inc_score
        i.remove = true
      end
    end
  end
  def draw(graphics,tick)
    graphics.foreground = @fillcolor
    graphics.fillRectangle(@x,@y,@width,@height)
  end
  
end
class TextObject < GameObject
  def initialize(game, group, x, y, text)
    super(game,group)
    @x = x
    @y = y
    @text = text
    @color = Fox.FXRGB(255,255,255)
  end
  def draw (graphics, tick)
    graphics.foreground = @color
    if @font
      graphics.font = @font
      graphics.drawText(@x,@y,@text)
    end
  end
  def load(app)
    @font = FXFont.new(app,"times",16,FONTWEIGHT_BOLD)
    @font.create
  end
end
class ScoreBoard < TextObject
  attr_accessor :score
  def initialize(game, group, x, y, text)
    super
    @score = 0
  end
  def update(params={})
    @text = "Score: #{@score}"
  end
end

class Candy < GameObject
  attr_accessor :x
  attr_accessor :y
  def initialize(game, group,x,y,r,color)
    super(game,group)
    @x = x
    @y = y
    @r = r
    @color = color
  end
  def draw(graphics, tick)
    graphics.foreground = @color
    graphics.fillCircle(@x,@y,@r)
  end
  def inside?(x,y)
    #distance = sqrt((x-x)^2 + (y-y)^2)
    d = Math.sqrt((@x-x)**2 + (@y-y)**2)
    #if d <= @r
      #$FRAME.log(self, "inside?", "(#{@x}-#{x})+(#{@y}-#{y})=#{d}")
    #end
    return d <= @r+5
  end
end

class Monster < Candy
  def initialize(game,group,x,y,r,color)
    super
    @vx = 0.5
    @vy = 0.5
    @ax = 0
    @ay = 0
    @f = 0.1
    @maxv = 1.2
  end
  def update(param={})
    #acceleration...changes with velocity...
    #if it's outside the box...
    @x += @vx
    @y += @vy
    #find the player and gavitate towards it
    player = @game.scene.player
    #increase acc by the degree of dist in each dir
    dx = player.x - @x
    dy = player.y - @y
    @ax = dx * param[:tick]
    @ay = dy * param[:tick]
    @vx += @ax
    @vy += @ay
    if @vx < 0
      @vx = -@maxv if @vx < -@maxv
    else
      @vx = @maxv if @vx > @maxv
    end
    if @vy < 0
      @vy = -@maxv if @vy < -@maxv
    else
      @vy = @maxv if @vy >= @maxv
    end
    
    limitx = @game.canvas.width
    limity = @game.canvas.height
    if @x-@r <= 0 || @x+@r >= limitx+10
      #reverse x
      @vx = -@vx
      #@ax -= @f either more negative or less neg
      @ax *= @f
      #ax = -@ax
    end
    if @y-@r <= 0 || @y+@r >= limity+10
      @vy = -@vy
      @ay *= @f
      #@ay = -@ay
    end
=begin
    @ax += dx
    @ay += dy
    if @ax > -1 && @ax < 1
      @ax *= (param[:tick] * 0.03)
    else
      @ax /= (param[:tick] * 0.03)
    end
    if @ay > -1 && @ay < 1
      @ay *= (param[:tick] * 0.03)
    else
      @ay /= (param[:tick] * 0.03)
    end
=end
    $FRAME.log(self, "update", "#{@vx},#{@vy},#{@ax},#{@ay}")
    if inside?(player.x, player.y)
      @game.scene.lose
    end
  end
end


class MainScene < Scene
  def initialize(game, param={})
    super
    #add player and scoreboard, these are at default
    push(Player.new(@game,self))
    push(ScoreBoard.new(@game,self,10,30,"Score: 0"))
  end
  def load(app)
    super
    for i in 0...1
      make(Candy,10,Fox.FXRGB(34,51,129),:candy)
    end
    make(Monster,15,Fox.FXRGB(25,193,184))
  end
  def update(params={})
    super
    if @groups[:candy].size < 10
      make(Candy,10,Fox.FXRGB(34,51,129),:candy)
    end
  end
  def make(obj, r, color, place=nil)
    xlimit = @game.canvas.width
    ylimit = @game.canvas.height
    push(obj.new(@game,:candy,Random.rand(xlimit-10)+5,
          Random.rand(ylimit-10)+5,r,color),place)
  end
  def input_map
    #left,up,right,down
    {KEY_Left => :move, KEY_Up => :move,
      KEY_Right => :move, KEY_Down => :move,}
  end
  
  def move (args)
    #$FRAME.log(self,"move", "Moving: " + direction)
    i = args[:code] % 4
    player.mode = i
    player.state = args[:state]
  end
  
  def inc_score
    score_board.score += 1
  end
  def player
    @groups[:default][0]
  end
  def score_board
    @groups[:default][1]
  end
  def lose
    @game.changescene(LoseScene.new(@game, score: score_board.score))
  end
end

class StartScene < Scene
  def load(app)
    limitx = @game.canvas.width
    limity = @game.canvas.height
    push(TextObject.new(@game,self,limitx/2-100,
        limity/2-40,"Press ENTER to Play"))
    push(TextObject.new(@game,self,limitx/2-80,
        limity/2+20,"You are the square."))
    push(TextObject.new(@game,self,limitx/2-80,
        limity/2+40,"Avoid the big circle."))
    push(TextObject.new(@game,self,limitx/2-80,
        limity/2+60,"Get the little circles."))
    push(TextObject.new(@game,self,limitx/2-80,
        limity/2+80,"Use the arrow keys."))
    super
  end
  def input_map
    {KEY_Return => :next_scene}
  end
  def next_scene(args)
    @game.changescene(MainScene.new(@game))
  end
end

class LoseScene < Scene
  def initialize(game, param={})
    super
    @finalscore = param[:score]
  end
  def load(app)
    limitx = @game.canvas.width
    limity = @game.canvas.height
    push(TextObject.new(@game,self,limitx/2-100,
        limity/2-40,"YOU LOSE"))
    push(TextObject.new(@game,self,limitx/2-100,
        limity/2-20,"Final Score: #{@finalscore}"))
    push(TextObject.new(@game,self,limitx/2-100,
        limity/2+20,"Play again? press (Y/N)"))
    super
  end
  def input_map
    {KEY_Y => :play_again,
      KEY_y => :play_again,
      KEY_N => :end_game,
      KEY_n => :end_game}
  end
  def play_again(args)
    @game.changescene(MainScene.new(@game))
  end
  def end_game(args)
    @game.end_game = true
  end
end

if __FILE__ == $0
    $FRAME = LittleFrame.new(400, 300)
    game = LittleGame.new(StartScene)
    $FRAME.start(game)
end
