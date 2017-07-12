#!/usr/bin/env ruby

require_relative 'littlegraphics'
require_relative './littleengine'

# Namespace for constants related to objects.
module LittleObject
  #The direction of the objects in relation to
  #the arrow key pressed.
  S = 0
  W = 1
  N = 2
  E = 3
  WASD = 5
  ARROW = 4
  #converts arrow to wasd
  CT_A_W = [2,0,1,3]
  #converts wasd to arrow
  CT_W_A = [1,2,0,3]
  class Path
    attr_accessor :direction
    attr_accessor :moving
    attr_accessor :how_long
    attr_accessor :current_count
    def initialize(direction=0, how_long=0, moving = true)
      @direction = direction
      @how_long = how_long
      @moving = moving
      @current_count = 0
    end
    def reset
      @current_count = 0
    end
    def end?
      @current_count == @how_long
    end
  end
end
# The Moveable class is used for an object the player
# controls. It has animations associated with each cardinal
# direction. Other animations should be added to the end.
class Moveable < GameObject
  include LittleObject
  # @!attribute [rw] state
  # @return [FixNum] whether a key is pressed or released.
  attr_accessor :state
  # @!attribute [rw] mode
  # @return [FixNum] the direction the object is moving in.
  attr_accessor :mode
  # @!attribute [rw] x
  # @return [Float] the x location.
  attr_accessor :x
  # @!attribute [rw] y
  # @return [Float] the y location.
  attr_accessor :y
  def initialize(game, group, x=0, y=0, speed=0, mode=0,
      anim=[])
    super(game, group)
    @x = x
    @y = y
    @speed = speed
    @state = LittleInput::RELEASE
    @oldmode = mode
    @mode = mode
    @anim = anim
  end
  # Prompts the object to change x,y coordinates according to
  # speed if the appropriate button is pressed.
  def update(param={})
    if @oldmode != @mode
      @anim[@oldmode].reset
      @oldmode = @mode
    end
    if @state == LittleInput::PRESS
      if @mode == LittleObject::S
        @y += @speed
      elsif @mode == LittleObject::W
        @x -= @speed
      elsif @mode == LittleObject::N
        @y -= @speed
      elsif @mode == LittleObject::E
        @x += @speed
      end
    end
  end
  # Draws the object's animation frame.
  # @see Scene::draw
  def draw(graphics, tick)
    image = nil
    if @state == LittleInput::PRESS
      image = @anim[@mode].loop_around(tick)
    elsif @state == LittleInput::RELEASE
      image = @anim[@mode].pause(tick)
    else
      $FRAME.log(self,"draw","Unexpected state.")
    end
    if image
      graphics.drawImage(image,@x,@y)
    end
  end
  # Loads the animation images.
  # @see Scene::load
  def load(app)
    @anim.each{|i| i.load(app)}
  end
end

def Automaton < Moveable
  include LittleObject
  def initialize(game, group, x=0, y=0, speed=0, mode=0,
      anim=[], path=[])
    super(game, group, x, y, speed, mode, anim)
    @path = path
    @counter = 0
  end
  def update(param={})
    p = @path[@counter]
    if p.end?
      @counter = (@counter + 1) % @path.size
      @state = LittleObject::RELEASE
      p.reset
    else
      @mode = p.direction
      @state = LittleObject::PRESS
    end
    super
  end
end

# Handles the input mapping for a scene requiring a player
# object that moves with input from the user.
class MoveScene < Scene
  include LittleObject
  # @!attribute [rw] player
  #  @return [Moveable] the user controlled object.
  attr_accessor :player
  # Creates the scene.
  # @param [Moveable] params[:player] is the user's object.
  # @param [FixNum] either LittleObject::WASD or LittleObject::ARROW,
  #                 depends on what input the user should use.
  def initialize(game,params={})
    super
    @player = params[:player] ? params[:player] : nil
    @mode = params[:mode] ? params[:mode] : LittleObject::WASD
  end
  def input_map
    if @mode == LittleObject::ARROW
      {KEY_Left => :move, KEY_Up => :move,
        KEY_Right => :move, KEY_Down => :move}
    else
      {KEY_w => :move, KEY_W => :move,
        KEY_a => :move, KEY_A => :move,
        KEY_s => :move, KEY_S => :move,
        KEY_d => :move, KEY_D => :move}
    end
  end
  def move(args)
    i = args[:code] % @mode
    if @mode == LittleObject::WASD
      i -= 1
      i = CT_W_A[i]
    end
    if @player
      @player.mode = i
      @player.state = args[:state]
    end
  end
end


module Simple

class Text < GameObject
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

end
