
require_relative "littlegame.rb"

class TestObject < Little::Object
	def initialize (game, scene)
		super game, scene
	end
	
	def draw (tick)
		Gosu::draw_rect(20,20,50,50,Gosu::Color::WHITE)
	end
end

class TestScene < Little::Scene
	def initialize(game)
		super(game)
		push(TestObject.new(game,self))
	end
end

if __FILE__ == $0
    $FRAME = Little::Game.new(800, 600, "Test", TestScene)
    $FRAME.show
end
