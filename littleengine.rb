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

author:  Melinda Robertson
version: 1.0
=end

#I'm using fxruby for the GUI portion.
require 'fox16'
include Fox

#How many milliseconds the loop should take to run.
$MS_PER_FRAME = 0.08

#All basic components of the engine are in this
#module.
module LittleEngine
#Game objects do all the heavy lifting in the game.
#If there's something to see there's a game objects
#behind it. If there's something to do, there's a
#game object doing it.
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
    #Initializes the scene by setting up variables
    #and adding starting groups.
    def initialize (game)
      @game = game
      @groups = Hash.new
      @inputqueue = []
      startinput
    end
    #Add input listeners for the canvas here.
    def startinput
    end
    #Processes the input added to the inputqueue.
    #Each tick serves only one input at a time.
    #Optionally the input can be processed right
    #after it is received. In that case, handle
    #it in the listener itself.
    def input
      return nil if @inputqueue.empty?
      #pop each command and process
      current = @inputqueue.pop
      #how you process the command is dependent
      #on the structure of the game.
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
            @groups[group] = new Group(self)
        end
        @groups[group].push(value)
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
    #Creates the game and the variables needed
    #to time the loop correctly.
    def initialize
        @tick = 0
        @time = Time.now
        @scene = nil
        @canvas = nil
        @newscene = nil
    end
    #Sets the new scene to be updated on the
    #next run of the loop.
    def changescene (scene)
        @newscene = scene
    end
    #This method is called to begin the loop.
    #Notice that this has no looping structure.
    #The 'loop' portion is actually in the GUI.
    def run
        return if not @canvas
        if (@newscene)
            @scene = @newscene
            @newscene = nil
        end
        lasttick = (@time.to_f)
        @time = Time.now
        @tick = (@time.to_f)-lasttick
        #puts @tick
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
        @scene ? @scene.input : nil
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
    #Creates the window components and adds the game.
    def initialize (app, w, h, game)
        super(app, "Game Frame", :width => w, :height => h)
        @app = app
        @contents = FXHorizontalFrame.new(self, LAYOUT_FILL_X|LAYOUT_FILL_Y)
        @canvas = FXCanvas.new(@contents, :opts => LAYOUT_FILL_X|LAYOUT_FILL_Y|LAYOUT_TOP|LAYOUT_LEFT)
        @canvas.backColor = Fox.FXRGB(0, 0, 0)
        game.canvas = @canvas
        @game = game
    end
    #Creates the application, adds a timeout function
    #that calls the run method periodically, shows
    #the window and starts the game.
    def start
        @app.create
        @app.addTimeout($MS_PER_FRAME * 1000.0, :repeat => true) do
            @game.run
        end
        show(PLACEMENT_SCREEN)
        @app.run
    end
    def to_s
        str = ""
        str += @app.to_s
        str += "\n" + @game.to_s
        str += "\n" + @canvas.to_s
    end
end
end

#This is a trial run to test that it's working.
if __FILE__ == $0
    app = FXApp.new('Little Game', 'Test')
    game = LittleEngine::LittleGame.new
    game.changescene(LittleEngine::Scene.new(game))
    frame = LittleEngine::LittleFrame.new(app, 200, 200, game)
    frame.start
end


