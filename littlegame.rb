#!/usr/bin/env ruby

# Little is a small and unassuming game engine based on Gosu.
# All rights go to the Gosu people for the Gosu code.
#
# @author      Melinda Robertson
# @copyright   Copyright (c) 2017 Little, LLC
# @license     GNU

require 'gosu'


# @see https://github.com/gosu/gosu/wiki/Getting-Started-on-Linux
# @see http://www.rubydoc.info/github/gosu/gosu/Gosu

#Set this to true to display the debug information.
$DEBUG = true
#Set this to true to show verbose debug info
$VERBOSE = false
#Set this to true to display FPS and tick.
$SHOW_FPS = true
#Set this to true to save comments to file.
$LOG = false
#Set this to true for tracking performance.
$PERFORMANCE = false
$INPUT = true
$GRAPHICS = true
$AUDIO = true

# Prints an error and closes the application if the error is critical.
#
# @param +exception+ - The exception thrown.
# @param +explicit+  - True means a particular and expected exception was thrown.
#                   False means an exception was thrown but we don't know
#                   what kind.
# @param +critical+  - The program won't continue if this is true.
def print_exception(exception, explicit, critical=false)
    puts "[#{explicit ? 'EXPLICIT' : 'INEXPLICIT'}] #{exception.class}: #{exception.message}"
    puts exception.backtrace.join("\n")
    if critical
        abort("Critical exception, exiting.\n")
    else
        puts "Non-critical, continuing..."
    end
end

begin
    # Logs messages and performance to a file.
    if $LOG
        require_relative 'v1/littlelog'
    end
    # Handles user input
    if $INPUT
        require_relative 'v2/littleinput'
    end
    # Draws things on the canvas
    if $GRAPHICS
        require_relative 'v2/littlegraphics'
    end
    # Helper modules and methods for audio
    if $AUDIO
        require_relative 'v2/littleaudio'
    end
rescue LoadError => e
    print_exception(e, true)
rescue Exception => e
    print_exception(e, false)
end

# The Little module is used as a namespace for all the things.
module Little

    # Game objects do all the heavy lifting in the game.
    # If there's something to see there's a game object
    # behind it. If there's something to do, there's a
    # game object doing it.
    # To use the game object, overwrite the load, update and draw functions.
    class Object
        # @!attribute [rw] game
        #   @return [Little::Game] object for this game.
        attr_accessor   :game
        # @!attribute [rw] group
        #   @return [Little::Group] group this object belongs to
        #   It is set to :default if no group is specified when the object is
        #   added to the scene.
        attr_accessor   :group
        # @!attribute [rw] scene
        #   @return [Little::Scene] scene this object belongs to.
        attr_accessor   :scene
        # @!attribute [rw] remove
        #   @return [Boolean]   A flag that tells the group to remove
        #   this object on update.
        attr_accessor   :remove
        
        # Creates the object with all variables set to nil or false.
        def initialize
            $FRAME.log self, "init", "Object initialized.", verbose: true
            @remove = false
        end
        # Called after the objects are added to a group. Perform here any
        # initialization operations that require the game, scene or group.
        def load
            $FRAME.log self, "load", "Not implemented."
        end
        # Bumper method that ensures update is not called if the object
        # is set to be removed.
        #
        # @param tick [Number] The seconds between this update and the last.
        #               Normally 0.0 < tick < 1.0
        def __update(tick)
            return nil if @remove
            update tick
        end
        # Update variables (hint: position) here.
        #
        # @param tick [Number] The seconds between this update and the last.
        #               Normally 0.0 < tick < 1.0
        def update (tick)
            $FRAME.log self, "update", "Not implemented", verbose: true
        end
        
        if $GRAPHICS
            # Bumper method that ensures draw is not called if the object
            # is set to be removed.
            #
            # @param graphics [Little::Graphics] object that adds some
            #                   functionality to the standard Gosu draw
            #                   methods.
            def __draw (graphics)
                return nil if @remove
                draw graphics
            end
            # Draw the object (picture or shape) using
            # the graphics from the canvas.
            #
            # @param graphics [Little::Graphics] object that adds some
            #                   functionality to the standard Gosu draw
            #                   methods.
            def draw (graphics)
                $FRAME.log self, "draw", "Not implemented", verbose: true
            end
        else
            # Bumper method that ensures draw is not called if the object
            # is set to be removed.
            def __draw
                return nil if @remove
                draw
            end
            # Draw the object (picture or shape) using straight Gosu.
            def draw
                $FRAME.log self, "draw", "Not implemented", verbose: true
            end
        end

        # Performs any clean-up operations when the scene or game closes.
        def on_close
            $FRAME.log self, "on_close", "Not implemented", verbose: true
        end
    end

    # Groups categorize objects to make them easier to find.
    # If a group is not listed when adding
    # objects to the scene, they will be added to a
    # :default group.
    class Group
        # @!attribute [rw] game
        #   @return [Little::Game] object for this game.
        attr_accessor   :game
        # @!attribute [rw] scene
        #   @return [Little::Scene] scene this object belongs to.
        attr_accessor   :scene
        # @!attribute [r] entities
        #   @return [Array]  The list of Little::Objects.
        attr_reader     :entities
        # @!attribute [rw] remove
        #   @return [Boolean] A flag that tells the scene to remove
        #   this group on update.
        attr_accessor   :remove
        # @!attribute [rw] order
        #   @return [Fixnum] The default drawing order for the objects
        #   in this group.
        attr_accessor   :order
        
        # Counter for the order.
        @@next_order = 0
        
        # Creates the group. The entities array is created here.
        # @param game   [Little::Game] is the game object.
        # @param scene  [Little::Scene] is the scene this group belongs to.
        def initialize (game, scene)
            @game = game
            @entities = []
            @scene = scene
            @remove = false
            @order = @@next_order
            @@next_order += 1
        end
        
        # Updates the objects in this group.
        #
        # @param tick [Number] The seconds between this update and the last.
        #               Normally 0.0 < tick < 1.0   
        def update(tick)
            @entities.each {|i| i.__update(tick)}
            @entities.delete_if {|i| i.remove}
        end
        
        if $GRAPHICS
            # Tells the objects in this group to draw.
            #
            # @param graphics [Little::Graphics] object that adds some
            #                   functionality to the standard Gosu draw
            #                   methods. Can be nil.
            def draw (graphics)
                graphics.start_group(@order) if graphics
                @entities.each {|i| i.__draw(graphics)}
                graphics.end_group(@order) if graphics
            end
        
        else
            # Tells the objects in this group to draw.
            def draw
                @entities.each {|i| i.__draw}
            end
        end

        # Add a new object to this group. Also sets the group attribute
        # of the object.
        #
        # @param obj    [Little::Object] object to add to this group.
        #               This sets the object's group attribute to
        #               this group object.
        def push (obj)
            obj.group = self
            @entities.push(obj)
        end
        # Iterates through each object and does something according
        # to a given block.
        # For a block {|i| ... }
        # @yield [i]    Gives each object in this group to the block.
        def each
            @entities.each {|i| yield (i)}
        end
        # Retrieve one of the objects in the group.
        #
        # @param i  [Fixnum] The index of the object.
        def [] (i)
          return @entities[i]
        end
        # Deletes an object by reference.
        #
        # @param obj    [Little::Object] object to delete.
        def delete (obj)
            @entities.delete(obj)
        end
        # Deletes an object by index.
        #
        # @param i  [Fixnum] The index of the object.
        def delete_at(i)
            @entities.delete_at(i)
        end
        # Returns true if the object's group attribute is this
        # group and the object is a Little::Object. Faster than
        # index.
        #
        # @see #index
        #
        # @param obj    [Little::Object] object to check for.
        def include?(obj)
            return false if not obj.is_a? Little::Object
            obj.group == self
        end
        # Retrieves the index of an object. This has a different searching
        # behaviour from include?
        #
        # @see #include?
        #
        # @param obj    [Little::Object] object to search for.
        def index(obj)
          @entities.index(obj)
        end
        # The number of objects in the group.
        def size
          @entities.size
        end
        # Returns true if there are no objects in this group.
        def empty?
            return @entities.empty?
        end
        # Performs any clean-up operations when the scene or game closes.
        def on_close
            @entities.each {|i| i.on_close}
        end
        # Return only the first object.
        def object
            return @entities[0]
        end
    end

    # The scene is a convenient way to switch entire sets
    # of objects. This way, the game can switch levels or
    # from a title screen to a level and back.
    # The scene is generally the object that should be
    # overwritten to create custom levels.
    class Scene
        # @!attribute [rw] game
        #   @return [Little::Game] object for this game.
        attr_reader     :game
        if $INPUT
            # The optional Hash that the Little::Input object can
            # use to map scene methods to user input.
            # Generally KEY_CODE => :symbol_of_method_name
            attr_reader     :input_map
        end

        # Initializes the scene by setting up variables
        # and adding starting groups.
        #
        # @param +game+  - The Little::Game object for this game.
        def initialize (game)
            @game = game
            default_group = Group.new game, self
            #default_group.order = Little::Graphics::DEFAULT_ORDER
            @groups = {default: default_group}
            @request_mutex = Mutex.new
        end
        # Calls load for all object after the scene has been fully
        # initialized.
        def load
            @groups.each do |k,v|
                v.each{|obj| obj.load}
            end
        end
        
        # Calls update on all the groups. A thread is created for
        # each group and the main process will wait until all threads
        # finish. After they are done the scene will process any requests
        # from objects and then delete any objects that are tagged for
        # removal.
        # @param +tick+  - The seconds between this update and the last.
        #               Normally 0.0 < tick < 1.0    
        def update (tick)
          #@groups.each{|key, value| value.each{|i| i.__update(tick)}}
            threads = []
            @groups.each do |key, value|
                threads.push (Thread.new { value.each {|i| i.__update(tick) }})
            end
            threads.each do |t|
                #$FRAME.log self, "update", "#{t.value}"
                t.join
            end
            process_requests
          @groups.delete_if{|key,value| value.remove}
        end
        if $GRAPHICS
            # Calls draw on all the groups.
            #
            # @param +graphics+  - The Little::Graphics object that adds some
            #                   functionality to the standard Gosu draw
            #                   methods. Can be nil.
            def draw (graphics)
              @groups.each do |key, value|
                graphics.start_group(value.order) if graphics
                value.each{|i| i.__draw(graphics)}
                graphics.end_group(value.order) if graphics
              end
              @game.camera.changed = false  
            end
        else
            # Calls draw on all the groups.
            def draw
              @groups.each do |key, value|
                value.each{|i| i.__draw}
              end
            end
        end
        # Adds a new game object to the indicated group.
        # If the group doesn't exist, it adds a new group.
        # If the group is nil, it adds the object to the :default group.
        # This also sets the game and scene attributes of the object.
        #
        # @param +obj+   - The Little::Object to add to the scene.
        # @param +group+ - Optional, the symbol of the group to add the
        #               object to.
        def push (obj,group=nil)
            obj.game = @game
            obj.scene = self
          g = group
          if !group
            g = :default
          end
          if (!@groups[g])
              @groups[g] = Group.new @game, self
          end
          #value.group = @groups[g]
          @groups[g].push(obj)
        end
        # Removes the indicated game object from the scene.
        #
        # @param +i+     - The index of the object.
        # @param +group+ - The symbol of the group to delete from. If this
        #               is not provided, the scene will attempt to delete
        #               from the :default group.
        def delete_at (i, group=nil)
          if (group)
            @groups[group].delete_at(i)
          else
            @groups[:default].delete_at(i)
          end
        end
        
        # Removes a game object from the scene. If the group symbol
        # is provided, returns the object deleted or nil if it can't
        # be found.
        #
        # @param +obj+   - The object to delete.
        # @param +group+ - If the group symbol is provided, the scene will
        #               attempt to delete the object from the specified
        #               group. Otherwise it will attempt to delete from
        #               all groups.
        def delete(obj, group=nil)
          if group and @groups[group]
            return @groups[group].delete(obj)
          end
          @groups.each do |i|
            i.delete(obj)
          end
        end
        # Alias for at(i)
        #
        # @param +i+ - The index of the object in the :default group.
        def [] (i)
          @groups[:default][i]
        end
        # Retrieves an object in the :default group according to index.
        #
        # @param +i+ - The index of the object in the :default group.
        def at(i)
          @groups[:default][i]
        end
        
        # Queues a request from a Little::Object. The method is called
        # on the sender after all threads return during update. This
        # allows an object to affect another object outside its group
        # in a thread-safe manner. Each method queued should return true
        # or false. If it returns true it will be deleted from the queue,
        # false indicates the method failed and needs to be called again.
        #
        # @param +sender+    - The object whose method will be called.
        # @param +method+    - The symbolized name of the method to be called.
        # ==== Example
        # @scene.request(self, :move_player)
        def request(sender, method)
            @request_mutex.synchronize {
                if not @request_queue
                    @request_queue = Hash.new
                end
                @request_queue[sender] = method
            }
        end
        # Does clean up when the program or scene closes.
        def on_close
            @groups.each {|k,v| v.on_close}
        end
        # Retrieves a list of the group symbols.
        def group_keys
            return @groups.keys
        end
        # Short summary of the scene. Returns a string indicating
        # the class name, object id, and number of groups.
        def to_s
            return "Little::Scene::#{self.class.name}<#{self.object_id}>=#{@groups.size}"
        end
        # Processes requests made during the multi-threaded update.
        private
        def process_requests
            return nil if not @request_queue or @request_queue.empty?
            @request_queue.delete_if do |sender, method|
                # Return true for the request to be deleted, or
                # false if we need to try again
                sender.method(method).call
                #$FRAME.log self, "process_request", "Sent back #{r}"
            end
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
        # The first scene created should not need parameters.
        #
        # +newscene+ - The class name of the scene to instantiate first.
      def initialize(w, h, c="Test", newscene=nil)
        super(w,h)
        self.caption = c
        @log_mutex = Mutex.new
        @newscene = newscene
        @newscene_param = nil
        @tick = 0.0
        @time = Gosu.milliseconds #ms since start
        @scene = nil
        @end_game = false
        @num_runs = 0
        @tick_counter = 0
        @input = $INPUT ? Little::Input.new(self) : nil
        @camera = $GRAPHICS ? Little::Camera.new(w,h) : nil
        @graphics = $GRAPHICS ? Little::Graphics.new(self,@camera) : nil
        if $PERFORMANCE
          @@performance_log = Little::Performance.new
        end
        if $LOG
          @@debug_log = Little::Debug.new
        end
        log self,"init","Game initialized: Gosu v. #{Gosu::VERSION}"
      end
      # Sets the new scene to be updated on the
      # next run of the loop.
      # @param scene [Scene] is the new scene.
      #
      # +scene+ All scenes should be passed by class name.
      # +scene_param+ - Parameters to be passed to the new scene on instantiation.
      def changescene (scene, scene_param=nil)
        @newscene = scene
        @newscene_param = scene_param
      end
        
      def update
        #print "Opening game"
        if @end_game
          close
        end
        if @newscene
          @scene.on_close if @scene
            if @newscene_param
                @scene = @newscene.new self, @newscene_param
            else
                @scene = @newscene.new (self)
            end
            # don't keep stray references
          @newscene = nil
          @newscene_param = nil
          @input.connect(@scene) #connect to input manager
          @scene.load
        end
        lasttick = @time
        @time = Gosu.milliseconds
        @tick = @time - lasttick
        if ($SHOW_FPS)
            @tick_counter += @tick
            @num_runs += 1
            if (@tick_counter >= 1000)
              log(self,"update","FPS: #{@num_runs}")
              log(self, "update", "TICK: #{@tick/100.0}")
              @tick_counter = 0
              @num_runs = 0
            end
        end
        @input ? handle_input : nil
        @scene ? @scene.update(@tick / 100.0) : nil
        if $PERFORMANCE
          @@performance_log.inc(:runs)
        end
      end
      def handle_input
        #check if there are hold down conditions in the scene
        @input.service_requests
        @input.exe_running
        while @input.execute
          #handling input
        end
      end
      def draw
        #print "Test"
        if $GRAPHICS
            @scene ? @scene.draw(@graphics) : nil
        else
            @scene ? @scene.draw : nil
        end
      end
      def button_down(id)
        #the input manager should call the proper method
        #in the scene for the id given
        #log self,"button","#{id}"
        if @input
            @input.add(id)
        end
      end
        # Prints a message to the screen.
        #
        # @param +sender+    - The object sending the message.
        # @param +method+    - A string or symbol representing the method from
        #               which the message is sent.
        # @param +message+   - The message to print to screen.
        # @param +options+   - [verbose: Boolean, exit: Boolean]
        def log (sender, method, message="test", options={})
            @log_mutex.synchronize {
                if $DEBUG
                    return nil if options[:verbose] and not $VERBOSE
                    time = Gosu.milliseconds
                    print "#{time}:#{sender.class.name}<#{sender.object_id}>:#{method}:#{message}\n"
                end
                if $LOG
                    @@debug_log.log sender,method,note
                end
                if options[:exit]
                    close
                end
            }
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

