=begin
A short remake of Galaga that is not exactly Galaga.
It just kinda looks like Galaga.

Needs:
  main scene
    player
    enemies
    score
  opening scene
    title
    click to play
    brief directions
  end game, win or lose
    game over text
    click to play
=end

#!/usr/bin/env ruby

require 'fox16'
require 'fox16/keys'
require_relative 'littleengine'
require_relative 'v2/littleanim'
require_relative 'v3/littlemenu'
include Fox

class LogoBox < Component
  def initialize (game, group)
    super(game, group)
    
  end
end

class TextBox < Component
  def initialize (game, group, parent, x, y, h, text)
    super(game, group, parent, x, y, 0, h)
    @text = text
  end
end

class StartScene < Scene

end

class MainScene < Scene

end

class EndScene < Scene

end

if __FILE__ == $0
  $FRAME = LittleFrame.new(800, 800)
  game = LittleGame.new
  game.changescene(StartScene.new(game))
  $FRAME.start(game)
end
