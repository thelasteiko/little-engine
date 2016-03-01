require 'fox16'
require_relative 'littleengine'
include Fox

#This is a trial run to test that it's working.
if __FILE__ == $0
    app = FXApp.new('Little Game', 'Test')
    game = LittleEngine::LittleGame.new
    game.changescene(LittleEngine::Scene.new(game))
    $FRAME = LittleEngine::LittleFrame.new(app, 400, 300, game)
    $FRAME.start
end