require 'gosu'

#for logging events in a file
require_relative 'v1/littlelog'
require_relative 'v2/littleinput'

#Set this to true to display the debug window.
$DEBUG = true
#Set this to true to save comments to file.
$LOG = false
#Set this to true for tracking performance.
$PERFORMANCE = false

class Game < Gosu::Window

    # @!attribute [rw] scene
    #   @return [Scene] is the current scene.
    attr_accessor   :scene
    # @!attribute [rw] end_game
    # @return [Boolean] determines whether or not to continue.
    attr_accessor   :end_game
    # @!attribute [rw] input
    #   @return [LittleInput::Input] manages user input.
    attr_accessor   :input
    
    # Creates the game and the variables needed
    # to time the loop correctly.
  def initialize(w, h, c, newscene=nil,param={})
    super(w,h)
    self.caption = c
    @tick = 0
    @time = Gosu.milliseconds #ms since start
    @scene = nil
    @end_game = false
    @num_runs = 0
    @tick_counter = 0
    if newscene
      @newscene = newscene.new(self,param)
    end
    @input = LittleInput::Input.new(self)
    if $PERFORMANCE
      @@performance_log = LittleLog::Performance.new
    end
    if $LOG
      @@debug_log = LittleLog::Debug.new
    end
    log (self, "init", "Game initialized")
  end
  # Sets the new scene to be updated on the
  # next run of the loop.
  # @param scene [Scene] is the new scene.
  def changescene (scene)
    @newscene = scene
  end
    
  def update
    #print "Opening game"
    if @end_game
      close
    end
    if @newscene
      @scene.on_close if @scene
      @scene = @newscene
      @newscene = nil
     #start_input if @canvas and @input
     #@scene.load($FRAME.getApp())
    end
    lasttick = @time
    @time = Gosu.milliseconds
    @tick = @time - lasttick
    @tick_counter += @tick
    @num_runs += 1
    #input
    if (@tick_counter >= 1000)
      log(self,"update","FPS: #{@num_runs}")
      @tick_counter = 0
      @num_runs = 0
    end
    @scene ? @scene.update(tick: @tick) : nil
    if $PERFORMANCE
      @@performance_log.inc(:runs)
    end
  end
  def handle_input
    while input.execute
      #handling input
    end
  end
  def draw
    #print "Test"
    @scene ? @scene.draw(tick: @tick) : nil
  end
  def button_down(id)
    #used for one shots; save to input manager?
    #the input manager should call the proper method
    #in the scene for the id given
    input.add(id)
  end
  def log (sender, method, message="test", exit=false)
      if $DEBUG
        time = Gosu.milliseconds
        print "#{time}:#{sender.class.name}:#{method}:#{message}\n"
      end
      if $LOG
        @@debug_log.log(sender,method,note)
      end
      if exit
        close
      end
  end
  
  def close
    @scene.on_close if @scene
    if $PERFORMANCE
      @@performance_log.save
    end
    close!
  end
end

if __FILE__ == $0
    $FRAME = Game.new(800, 600, "Test")
    $FRAME.show
end

