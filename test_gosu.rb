require 'gosu'

$DEBUG = true

class Game < Gosu::Window
  def initialize(w,h,c,ns=nil)
    super(w,h)
    self.caption = c
    @newscene = ns
    @tick = 0
    @time = Gosu.milliseconds
    @scene = nil
    @end_game = false
    @num_runs = 0
    @tick_counter = 0
  end
  
  def update
    print "update"
    lasttick = @time
    @time = Gosu.milliseconds
    @tick = @time - lasttick
    @tick_counter += @tick
    @num_runs += 1
    if (@tick_counter >= 1000)
      log(self, "update", "FPS: #{@num_runs}")
      @tick_counter = 0
      @num_runs = 0
    end
  end
  
  def draw
    print "draw"
  end
  
  def changescene (scene)
    @newscene = scene
  end
  
  def log (sender, method, message="text", exit = false)
    if $DEBUG
      time = Gosu.milliseconds
      print "#{time}:#{sender.class.name}:#{method}:#{message}\n"
    end
    if exit
      close
    end
  end
  
  def close
    @scene.on_close if @scene
    close!
  end
end

if __FILE__ == $0
  $FRAME = Game.new(800,600,"Test")
  $FRAME.show
end