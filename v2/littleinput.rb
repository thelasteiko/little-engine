#!/usr/bin/env ruby

#require 'fox16'
#require 'fox16/keys'
#include Fox

# Namespace for input functionality.
# Keyboard keys start at 0x0020 so custom codes
# can be created up to 20.
module LittleInput
  # Markers for the command.
  HOLD = 0
  #CODE = 1
  #ARGS = 2
  # Markers for mouse input.
  MOUSE_LEFT = 0
  MOUSE_RIGHT = 1
  MOUSE_MIDDLE = 4
  MOUSE_WHEEL = 2
  MOUSE_MOTION = 3
  # Markers for key type
  KEYSET_OTHER = 8
  KEYSET_NUMERICAL = 5
  KEYSET_ALPHA = 6
  KEYSET_FUNCTION = 7
  
  PRESS = 9
  RELEASE = 10
  
  class Command
    attr_accessor   :scene
    attr_accessor   :code
    attr_accessor   :args
    
    def initialize (scene, code, args)
        @scene = scene
        @code = code
        @args = args
    end
    
    def == obj
        return false if not obj.is_a? LittleInput::Command
        return (@code == obj.code and @scene == obj.scene)
    end
  end
  
  #TODO I need to manage when buttons are kept pressed
  # down which gosu distinguishes between using button_down?
  # inside the update method

  # Helper class for handling input. The scene should be
  # the current scene.
  class Input
    include LittleInput
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
    def add(code, args = [])
      @queue.push(LittleInput::Command.new(@scene, code, args))
      #$FRAME.log self,"add","#{code}"
    end
    
    # Executes the next command in the input queue.
    # @return true if the command could be executed,
    #         false otherwise.
    def execute
      return false if @queue.empty?
      
      #command = @queue.slice!(0)
      command = @queue.shift
      $FRAME.log self, "execute", "#{command.code}"
      
      return false if not @mapping or not @scene
      return false if @last_command == command
      
      @last_command = command
      #check if the scene is active
      if @scene == command.scene
        #access the appropriate method using call
        sym = @mapping[command.code]
        if sym
          #as a note, all methods using this must take arguments
          #for this not to throw errors
          #@scene.send(sym, command[LittleInput::ARGS])
          @scene.method(sym).call(command.args)
          return true
        end
        if command.code > LittleInput::MOUSE_MIDDLE
          code = LittleInput::KEYSET_OTHER
          if (command.code >= KEY_A and
              command.code <= KEY_Z) or
              (command.code >= KEY_a and
              command.code <= KEY_z)
            code = LittleInput::KEYSET_ALPHA
          elsif (command.code >= KEY_0 and
              command.code <= KEY_1)
            code = LittleInput::KEYSET_NUMERICAL
          elsif command.code >= KEY_F1 and
              command.code <= KEY_R15
            code = LittleInput::KEYSET_FUNCTION
          end
          sym = @mapping[code]
          if sym
            #as a note, all methods using this must take arguments
            #for this not to throw errors
            @scene.method(sym).call(command.args)
            return true
          end
        end
      end
      #if the scene is not active or does not have a
      #corresponding response, return false
      return false
    end
    def exe_running
        return false if not @scene or not @mapping
        a = @mapping[LittleInput::HOLD]
        return false if not a
        a.each do |i|
            sym = @mapping[i]
            if sym
                @scene.method(sym).call #TODO no args for hold?
            end
        end
        return true
    end
  end
end
