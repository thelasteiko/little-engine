#!/usr/bin/env ruby

require 'gosu'

# Namespace for input functionality.
# Keyboard keys start at 0x0020 so custom codes
# can be created up to 20.
module Little
  
  class Command
    attr_accessor   :scene
    # @!attribute   [rw]    code
    #   @return [Fixnum]    The key code associated with the command.
    attr_accessor   :code
    # @!attribute   [rw]    args
    #   @return [Array]     Not being used currently, may be used in future.
    attr_accessor   :args
    # @!attribute   [rw]    time
    #   @return [Fixnum]    The timestamp for this command in milliseconds.
    attr_accessor   :time
    
    def initialize (scene, code, time, args=nil)
        @scene = scene
        @code = code
        @time = time
        @args = args
    end
    
    def == obj
        return false if not obj.is_a? Little::Command
        return (@code == obj.code and @scene == obj.scene and
          ((@time - obj.time).abs < 100)) #less than 1/100th of a second
    end
  end
  
  #TODO I need to manage when buttons are kept pressed
  # down which gosu distinguishes between using button_down?
  # inside the update method

  # Helper class for handling input. The scene should be
  # the current scene.
  class Input
      # Markers for the command.
      HOLD = "hold"

      # Markers for key type
      KEYSET_OTHER = "other"
      KEYSET_NUMERICAL = "numerical"
      KEYSET_ALPHA = "alpha"
      KEYSET_FUNCTION = "function"

    # Creates an input object.
    # @param game [LittleGame] is the game object just in case.
    def initialize(game)
      @queue = Array.new
      @game = game
      @last_command = nil
    end
    # Connect a differenct scene so that it's methods
    # get called during user input.
    # @param scene [Scene] is the current scene.
    # @param mapping [Array] is an array of symbols that relate back to
    #                         methods in the scene for various inputs.
    def connect(scene)
      @scene = scene
      @mapping = scene.input_map
    end
    
    # Should be called when any type of input is received.
    # @param code [Numeric] is the key or mouse code. This should
    #                       have a related response in the mapping.
    # @param args [Object] whatever is needed for the event to execute.
    def add(code)
      @queue.push(LittleInput::Command.new(@scene, code, Gosu::milliseconds))
      #$FRAME.log self,"add","#{code}"
    end
    
    # Executes the next command in the input queue.
    # @return true if the command could be executed,
    #         false otherwise.
    def execute
        # ensure that all parameters are valid
      return false if not @mapping or not @scene
      return false if @queue.empty?
      command = @queue.shift
      #Need to add a timestamp...
      while (!@queue.empty? and @last_command == command)
        command = @queue.shift
        $FRAME.log self, "execute", "#{command.code}"
      end
      return false if @last_command == command and @queue.empty?
      
      #start processing input
      @last_command = command
      #check if the scene is active
      if @scene == command.scene
        #access the appropriate method using call
        sym = @mapping[command.code]
        if sym
          #@scene.send(sym, command[LittleInput::ARGS])
          @scene.method(sym).call#(command.args)
          return true
        end
        # did not find a standard numerical code, searching for non-numeric
          code = KEYSET_OTHER
          if (command.code >= Gosu::KB_A and
              command.code <= Gosu::KB_Z)
            code = KEYSET_ALPHA
          elsif (command.code >= Gosu::KB_0 and
              command.code <= Gosu::KB_9)
            code = KEYSET_NUMERICAL
          elsif command.code >= Gosu::KB_F1 and
              command.code <= Gosu::KB_F12
            code = KEYSET_FUNCTION
          end
          sym = @mapping[code]
          if sym
            @scene.method(sym).call#(command.args)
            return true
          end
      end
      #if the scene is not active or does not have a
      #corresponding response, return false
      return false
    end
    # Process any input that has a continuous response, such as a button
    # being held down.
    def exe_running
        return false if not @scene or not @mapping
        a = @mapping[Little::Input::HOLD]
        return false if not a
        a.each do |key, value| # key code => method name symbol
            if @game.button_down?(key)
                @scene.method(value).call
            end
        end
        return true
    end
  end
end
