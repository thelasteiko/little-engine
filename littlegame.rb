#!/usr/bin/env ruby

require 'gosu'

# @see{ https://github.com/gosu/gosu/wiki/Getting-Started-on-Linux }
# @see{ http://www.rubydoc.info/github/gosu/gosu/Gosu }

#for logging events in a file
require_relative 'v1/littlelog'
require_relative 'v2/littleinput'
require_relative 'v2/littlegraphics'

#Set this to true to display the debug information.
$DEBUG = true
#Set this to true to display FPS and tick.
$SHOW_FPS = true
#Set this to true to save comments to file.
$LOG = false
#Set this to true for tracking performance.
$PERFORMANCE = false

module Little

    #Game objects do all the heavy lifting in the game.
    #If there's something to see there's a game object
    #behind it. If there's something to do, there's a
    #game object doing it.
    #To use the game object, overwrite the functions.
    class Object
        attr_accessor   :group
        attr_accessor   :scene
        attr_accessor   :remove
        # Creates the object.
        def initialize (game, scene)
          @game = game
          @scene = scene
          @group = nil
          @remove = false
        end
        # Update variables (hint: position) here.
        def __update(params={})
            return nil if @remove
            update (params)
        end
        def update (params={})
        end
        # Draw the object (picture or shape) using
        # the graphics from the canvas.
        # @param tick [Numerical] is the milliseconds since the last
        #                         game loop started.
        def __draw (graphics, tick)
            return nil if @remove
            draw (graphics, tick)
        end
        def draw (graphics, tick
        end    
    end

    # Groups are for layering on the screen.
    # Whatever is in the first group gets drawn first
    # and so on. If a group is not listed when adding
    # objects to the scene, they will be added to a
    # :default group.
    class Group
        attr_accessor :scene
        attr_accessor :entities
        attr_accessor   :order
        
        @@next_order = 1
        
        # Creates the group.
        # @param scene [Scene] is the scene this group belongs to.
        def initialize (game, scene)
          @game = game
          @entities = []
          @scene = scene
            @order = @@next_order
            @@next_order += 1
        end
        # Updates the objects in this group.
        def update(params={})
            @entities.each {|i| i.__update(params)}
            @entities.delete_if {|i| i.remove}
        end
        # Tells the objects in this group to draw.
        # @param graphics [Little::Graphics] graphics object
        # @param tick [Numerical] is the milliseconds since the last
        #                         game loop started.
        def draw (graphics, tick)
            graphics.start_group(@order)
            @entities.each {|i| i.__draw(graphics, tick)}
            graphics.end_group(@order)
        end

        # Add a new object to this group.
        # @param value [GameObject] is the object to add.
        def push (value)
            @entities.push(value)
        end
        # Retrieve one of the objects in the group.
        # @param value [Fixnum] is the index of the object.
        def [] (value)
          return @entities[value]
        end
        def delete (value)
            @entities.delete(value)
        end
        def delete_at(value)
            @entities.delete_at(value)
        end
        def contains(value)
          @entities.contains(value)
        end
        def index(value)
          @entities.index(value)
        end
        def size
          @entities.size
        end
        def empty?
            return @entities.empty?
        end
    end

    # The scene is a convenient way to switch entire sets
    # of objects. This way, the game can switch levels or
    # from a title screen to a level and back.
    # The scene is generally the object that should be
    # overwritten to create custom levels.
    class Scene
        attr_reader :groups
        
        # Initializes the scene by setting up variables
        # and adding starting groups.
        # @param game [Little::Game] is the game object owner.
        def initialize (game)
          @game = game
            default_group = Group.new(game,self)
            default_group.order = Little::Graphics::DEFAULT_ORDER
          @groups = {default: default_group}
        end
        # Calls update on all the groups.
        def update (params={})
          @groups.each{|key, value| value.update(params)}
          @groups.delete_if{|key,value| value.empty?}
        end
        # Calls draw on all the groups.
        # If a particular layering scheme needs to be
        # used, overwrite this.
        # @param graphics [Little::Graphics] is the graphics object with
        #                              which to draw.
        # @param tick [Float] is the milliseconds since the last
        #                         game loop started.
        def draw (graphics, tick)
          @groups.each{|key, value| value.draw(graphics, tick)}
        end
        # Adds a new game object to the indicated group.
        # If the group doesn't exist, it adds a new group.
        # If the group is nil, it adds the value to the :default group.
        # @param group [Group] is the group to add the object to. Use a symbol.
        # @param value [GameObject] is the object to add.
        def push (value,group=nil)
          g = group
          if !group
            g = :default
          end
          if (!@groups[g])
              @groups[g] = Group.new(@game, self)
          end
          value.group = @groups[g]
          @groups[g].push(value)
        end
        # Removes the indicated game object from the scene.
        # @param group [Group] is the group the object belongs to.
        # @param value [Fixnum] is the index of the object to remove.
        def delete_at (value, group=nil)
          if (group)
            #@groups[group].slice!(value)
            @groups[group].delete_at(value)
          else
            @groups[:default].delete_at(value)
          end
        end
        # Removes a game object from the scene.
        # @param value [GameObject] is the object to remove.
        # @return true if the object was removed,
        #         false otherwise.
        def delete(value, group=nil)
          if group and @groups[group]
            @groups[group].delete(value)
          end
          @groups.each do |i|
            i.delete(value)
          end
        end
        
        def [] (index)
          @groups[:default][index]
        end
        
        def at(index)
          @groups[:default][index]
        end
        
        # The input map that relates input events to method names.
        # @return [Hash] of type [Numerical, Symbol] where events are
        #                registered as numbers (the input code) and
        #                responses are symbols representing method names.
        def input_map
            #lists method calls for holding down a button
            {Little::Input::HOLD => {}}
            # the hold hash should have key codes mapped to symbols
            # Ex: {Gosu::KB_W => :move_up}
        end
        # Does clean up when the program closes.
        def on_close
        end
        def group_keys
            return @groups.keys
        end

    end

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
        # @!attribute [rw] camera
        #   @return [Little::Camera] the camera object that translates
        #   all graphics based on a focusable object.
        attr_accessor   :camera
        
        # Creates the game and the variables needed
        # to time the loop correctly.
      def initialize(w, h, c="Test", newscene=nil)
        super(w,h)
        self.caption = c
        @newscene = newscene
        @tick = 0.0
        @time = Gosu.milliseconds #ms since start
        @scene = nil
        @end_game = false
        @num_runs = 0
        @tick_counter = 0
        @input = Little::Input.new(self)
        @camera = Little::Camera.new(w,h)
        @graphics = Little::Graphics.new(self,@camera)
        if $PERFORMANCE
          @@performance_log = Little::Performance.new
        end
        if $LOG
          @@debug_log = Little::Debug.new
        end
        log self,"init","Game initialized"
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
          @scene = @newscene.new(self)
          @newscene = nil
         #start_input if @canvas and @input
         #@scene.load($FRAME.getApp())
        end
        lasttick = @time
        @time = Gosu.milliseconds
        @tick = @time - lasttick
        if ($SHOW_FPS)
            @tick_counter += @tick
            @num_runs += 1
            if (@tick_counter >= 1000)
              log(self,"update","FPS: #{@num_runs}")
              log(self, "update", "TICK: #{@tick/1000.0}")
              @tick_counter = 0
              @num_runs = 0
            end
        end
        handle_input
        @scene ? @scene.update(tick: @tick) : nil
        if $PERFORMANCE
          @@performance_log.inc(:runs)
        end
      end
      def handle_input
        while input.execute
          #handling input
        end
        #check if there are hold down conditions in the scene
        input.exe_running
      end
      def draw
        #print "Test"
        @scene ? @scene.draw(@graphics, @tick/1000.0) : nil
      end
      def button_down(id)
        #used for one shots; save to input manager?
        #the input manager should call the proper method
        #in the scene for the id given
        #log self,"button","#{id}"
        input.add(id)
      end
      def log (sender, method, message="test", exit=false)
          if $DEBUG
            time = Gosu.milliseconds
            print "#{time}:#{sender.class.name}:#{method}:#{message}\n"
          end
          if $LOG
            @@debug_log.log sender,method,note
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

end

#if __FILE__ == $0
#    $FRAME = Little::Game.new(800, 600, "Test")
#    $FRAME.show
#end

