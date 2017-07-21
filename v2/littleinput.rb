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
          ((@time - obj.time).abs < 300)) #less than 3/100th of a second
    end
    def to_s
        return "Little::Command=(#{@code},#{@time})"
    end
  end
  
  #TODO How to manage typed input? Gosu has TextInput so how do I incorporate it?

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
      KEYSET_DIRECTIONAL = "directional"
      KEYSET_WASD = "wasd"

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
      @queue.push(Little::Command.new(@scene, code, Gosu::milliseconds))
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
      while (!@queue.empty? and @last_command == command)
        command = @queue.shift
        $FRAME.log self, "execute", "#{@last_command}==#{command}", verbose: true
      end
      return false if @last_command == command and @queue.empty?
      $FRAME.log self, "execute", "Q=#{@queue.size}, #{@last_command}==#{command}", verbose: true
      #start processing input
      @last_command = command
      #check if the scene is active
      if @scene == command.scene
        return true if call_scene_method(command)
        $FRAME.log self, "execute", "Did not find #{command}", verbose: true
        # did not find a standard numerical code, searching for non-numeric
          code = KEYSET_OTHER
          if (command.code == Gosu::KB_W or
                command.code == Gosu::KB_A or
                command.code == Gosu::KB_S or
                command.code == Gosu::KB_D)
            code = KEYSET_WASD
            return true if call_scene_method(command, code)
          end
          if (command.code == Gosu::KB_RIGHT or
                  command.code == Gosu::KB_LEFT or
                  command.code == Gosu::KB_UP or
                  command.code == Gosu::KB_DOWN)
            code = KEYSET_DIRECTIONAL
            return true if call_scene_method(command, code)
          end
          if (command.code >= Gosu::KB_A and
              command.code <= Gosu::KB_Z)
            code = KEYSET_ALPHA
            return true if call_scene_method(command, code)
          end
          if (command.code >= Gosu::KB_0 and
              command.code <= Gosu::KB_9)
            code = KEYSET_NUMERICAL
            return true if call_scene_method(command, code)
          end
          if command.code >= Gosu::KB_F1 and
              command.code <= Gosu::KB_F12
            code = KEYSET_FUNCTION
            return true if call_scene_method(command, code)
          end
          return true if call_scene_method(command, code)
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
            code = key
            if code.is_a? String
                code = Little::Input::get_code_set(code)
                code.each do |c| #TODO is this too much work?
                    if @game.button_down? (c)
                        @scene.method(value).call(c)
                    end
                end
            else @game.button_down?(key)
                @scene.method(value).call(key)
            end
        end
        return true
    end
    
    def call_scene_method(command, code=nil)
        c = code ? code : command.code
        sym = @mapping[c]
        if sym
            $FRAME.log self, "execute", "Sending #{command} to #{@scene}", verbose: true
            @scene.method(sym).call(command)
            return true
        end
        return false
    end
    # Returns a list of Gosu key codes related to the given keyset.
    def self.get_code_set(code)
          #code = KEYSET_OTHER
          if code == KEYSET_WASD
            return [Gosu::KB_W, Gosu::KB_A, Gosu::KB_S, Gosu::KB_D]
          elsif code == KEYSET_DIRECTIONAL
            return [Gosu::KB_RIGHT, Gosu::KB_LEFT, Gosu::KB_UP, Gosu::KB_DOWN]
          elsif code == KEYSET_ALPHA
            a = []
            b = Gosu::KB_A
            e = Gosu::KB_Z
            while b <= e
                a.push(b)
                b += 1
            end
            return a
          elsif code == KEYSET_NUMERICAL
            a = []
            b = Gosu::KB_0
            e = Gosu::KB_9
            while b <= e
                a.push(b)
                b += 1
            end
            return a
          elsif code == KEYSET_FUNCTION
            a = []
            b = Gosu::KB_F1
            e = Gosu::KB_F12
            while b <= e
                a.push(b)
                b += 1
            end
            return a
          end
    end
  end
end
