#!/usr/bin/env ruby
require_relative 'littleengine'

#This is a trial run to test that it's working.
if __FILE__ == $0
    $FRAME = LittleFrame.new(400, 300)
    game = LittleGame.new(Scene)
    $FRAME.start(game)
end