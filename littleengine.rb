#!/usr/bin/env ruby

#Resources used:
#http://www.fxruby.org/doc/book.html
#http://www.rubydoc.info/gems/fxruby/


=begin
This is a basic game engine meant for expirementation
and learning. It's overly commented without too many
bells and whistles. It probably has some bad habits
and is not the most efficient design.

If you want a serious game engine, this is not it.
If you want a framework that's easy to play with
then you're in the right place.

All resources used are easy to find and install. As
a note, this was created using Ruby 2.2.4.23 on
Windows 7. Please see the README for directions
on how to run this demo.

THIS IS THE DEBUG VERSION. It has an optional debug window to display
error messages in.

@author  Melinda Robertson
@version 1.3
=end

#for logging events in a file
require_relative 'v1/littlelog'
require_relative 'v3/littleinput'

#I'm using fxruby for the GUI portion.
require 'fox16'
include Fox

#How many milliseconds the loop should take to run.
$MS_PER_FRAME = 0.08
#Set this to true to display the debug window.
$DEBUG = true
#Set this to true to save statistics and comments to file.
$LOG = false

#Game objects do all the heavy lifting in the game.
#If there's something to see there's a game object
#behind it. If there's something to do, there's a
#game object doing it.
#To use the game object, overwrite the functions.
class GameObject
    #Creates the object.
    def initialize (group)
        @group = group
    end
    #Update variables (hint: position) here.
    def update
    end
    #Draw the object (picture or shape) using
    #the graphics from the canvas.
    def draw (graphics, tick)
    end
end
#I use groups to separate game objects into
#categories. This helps with layering when objects
#have overlapping positions on the screen.
class Group
    #Creates the group.
    def initialize (scene)
        @entities = []
        @scene = scene
    end
    #Updates the objects in this group.
    def update
        @entities.each {|i| i.update}
    end
    #Tells the objects in this group to draw.
    def draw (graphics, tick)
        @entities.each {|i| i.draw(graphics, tick)}
    end
    #Add a new object to this group.
    def push (value)
        @entities.push(value)
    end
end
#The scene is a convenient way to switch entire sets
#of objects. This way, the game can switch levels or
#from a title screen to a level and back.
#The scene is generally the object that should be
#overwritten to create custom levels.
class Scene
    # Initializes the scene by setting up variables
    # and adding starting groups.
    # @param game [LittleGame] is the game object owner.
    def initialize (game)
      @game = game
      @groups = Hash.new
      @inputqueue = []
      startinput
    end
    #Calls update on all the groups.
    def update
      @groups.each{|key, value| value.update}
    end
    #Calls draw on all the groups.
    #If a particular layering scheme needs to be
    #used, overwrite this.
    def draw (graphics, tick)
      @groups.each{|key, value| value.draw(graphics, tick)}
    end
    #Adds a new game object to the indicated group.
    #If the group doesn't exist, it adds a new group.
    def push (group, value)
        if (!@groups[group])
            @groups[group] = Group.new(self)
        end
        @groups[group].push(value)
    end
    def input_map
      []
    end
end
#Here are guts of the game engine. This has the
#actual game loop which runs continuosly, updating
#each object until the program is halted.
#I recommend checking out
#http://gameprogrammingpatterns.com/game-loop.html
#to see how a game loop works. This website was
#used as the resource for this engine.
class LittleGame
    attr_accessor   :canvas
    attr_accessor   :tick
    attr_accessor   :scene
    attr_accessor   :input
    #Creates the game and the variables needed
    #to time the loop correctly.
    def initialize
        @tick = 0
        @time = Time.now
        @input = LittleInput::Input.new(self)
        @scene = nil
        @canvas = nil
        @newscene = nil
    end
    # Creates listeners for the canvas when it is added.
    # @param canvas [FXCanvas] is the canvas object for which input
    #                          is required.
    def canvas=(canvas)
      @canvas = canvas
      if @canvas and @input
        @canvas.connect(SEL_KEYPRESS) do |sender, selector, data|
          @input.add(data.code, []) #scene should already have needed data
        end
        @canvas.connect(SEL_LEFTBUTTONPRESS) do |sender, selector, data|
          @input.add(LittleInput::MOUSE_LEFT,
            {x: data.click_x, y: data.click_y})
        end
        @canvas.connect(SEL_RIGHTBUTTONPRESS) do |sender, selector, data|
          @input.add(LittleInput::MOUSE_RIGHT,
            {x: data.click_x, y: data.click_y})
        end
        @canvas.connect(SEL_MIDDLEBUTTONPRESS) do |sender, selector, data|
          @input.add(LittleInput::MOUSE_MIDDLE,
            {x: data.click_x, y: data.click_y})
        end
        @canvas.connect(SEL_MOUSEWHEEL) do |sender, selector, data|
          @input.add(LittleInput::MOUSE_WHEEL,
            {x: data.click_x, y: data.click_y,
            type: data.type, state: data.state,
            click_count: data.click_count})
        end
        @canvas.connect(SEL_MOTION) do |sender, selector, data|
          @input.add(LittleInput::MOUSE_MOTION,
            {x1: data.last_x, y1: data.last_y,
            x2: data.click_x, y2: data.click_y})
        end
      end
    end
    # Sets the new scene to be updated on the
    # next run of the loop.
    # @param scene [Scene] is the new scene.
    def changescene (scene)
        @newscene = scene
        start_input if @canvas and @scene and @input
    end
    def start_input
      if @scene
        @input.connect(@scene, @scene.input_map)
      end
    end
    #This method is called to begin the loop.
    #Notice that this has no looping structure.
    #The 'loop' portion is actually in the GUI.
    def run
        #$FRAME.log(1, "Running.")
        return if not @canvas
        if (@newscene)
            @scene = @newscene
            @newscene = nil
        end
        lasttick = (@time.to_f)
        @time = Time.now
        @tick = (@time.to_f)-lasttick
        loop
    end
    #The guts and glory of the game loop.
    #This guy does all the heavy lifting.
    def loop
        input
        while (@tick > $MS_PER_FRAME) do
            update
            @tick -= $MS_PER_FRAME
        end
        graphics = FXDCWindow.new(@canvas)
        draw(graphics, @tick)
        graphics.end
    end
    #Process the input.
    def input
      #TODO this is where the input needs a check
    end
    #Update the objects.
    def update
        @scene ? @scene.update : nil
    end
    #Draw the objects.
    def draw (graphics, tick)
        graphics.foreground = @canvas.backColor
        graphics.fillRectangle(0, 0, @canvas.width, @canvas.height)
        @scene ? @scene.draw(graphics, tick) : nil
    end
end
#This is the program window that holds the canvas.
#The canvas is where everything is drawn. The frame
#also calls the run method periodically to keep the
#game going. The framework used is from fxruby.
class LittleFrame < FXMainWindow
    attr_reader :logger
    # Creates the window components and adds the game.
    # @param app [FXApp] is the application that will be running.
    # @param w [Fixnum] is the width in pixels.
    # @param h [Fixnum] is the height in pixels.
    # @param game [LittleGame] is the game engine.
    def initialize (app, w, h, game)
        myh = h
        if $DEBUG #make room for the log console
          myh = (h*1.4)
        end
        super(app, "Game Frame", :width => w, :height => myh)
        @app = app #this is the main application
        @contents = FXVerticalFrame.new(self, LAYOUT_FILL_X|LAYOUT_FILL_Y)
        @canvas = FXCanvas.new(@contents, :opts => LAYOUT_FILL_X|LAYOUT_FILL_Y|LAYOUT_TOP|LAYOUT_LEFT)
        if $DEBUG #create the console for debug messages
          debugframe = FXVerticalFrame.new(@contents,:opts => FRAME_SUNKEN|LAYOUT_FILL_X|LAYOUT_TOP|LAYOUT_LEFT)
          FXLabel.new(debugframe, "Console", nil, JUSTIFY_CENTER_X|LAYOUT_FILL_X)
          FXHorizontalSeparator.new(debugframe, SEPARATOR_RIDGE|LAYOUT_FILL_X)
          @@console = FXText.new(debugframe, opts: TEXT_READONLY|TEXT_WORDWRAP|TEXT_AUTOSCROLL|LAYOUT_FILL_X)
          @@console.setText("Starting...\n")
        end
        @@logger = LittleLogger.new if $LOG
        @canvas.backColor = Fox.FXRGB(0, 0, 0)
        game.canvas = @canvas
        @game = game
    end
    # Creates the application, adds a timeout function
    # that calls the run method periodically, shows
    # the window and starts the game.
    def start
        @app.create
        @app.addTimeout($MS_PER_FRAME * 1000.0, :repeat => true) do
          @@logger.inc(:run) if @@logger
          @game.run
            #Messages can be logged by using this command
            #anywhere in the running game.
            #$FRAME.log(0, "Game is running")
        end
        show(PLACEMENT_SCREEN)
        @app.run
    end
    # Shows details of the frame and its objects.
    # @return [String] representation of the application.
    def to_s
        str = ""
        str += @app.to_s
        str += "\n" + @game.to_s
        str += "\n" + @canvas.to_s
    end
    # Logs a comment to the console.
    # @param id [Numerical] is the error id if applicable.
    # @param message [String] is the message to pint to the console.
    # @param exit [true, false] is the optional parameter to signal
    #                          the application to close.
    def log (id=0, message="test", exit=false)
      if @@console
        time = Time.now
        @@console.appendText("#{time}: #{id}: #{message}\n")
      end
      if exit
        abort
      end
    end
    # Adds a line to the log file.
    # @param sender [Object] is the object that made the request.
    # @param method [String] is the method name this was called from.
    # @param note [String] is the note to save to the log file.
    def logtofile(sender, method="", note="")
      @@logger.logtofile(sender, method, note) if @@logger
    end
end

=begin
#This is a trial run to test that it's working.
if __FILE__ == $0
    app = FXApp.new('Little Game', 'Test')
    game = LittleEngine::LittleGame.new
    game.changescene(LittleEngine::Scene.new(game))
    $FRAME = LittleEngine::LittleFrame.new(app, 400, 300, game)
    $FRAME.start
end
=end

