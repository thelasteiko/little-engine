#!/usr/bin/env ruby

# Little is a small and unassuming game engine based on Gosu.
# All rights go to the Gosu people for the Gosu code.
#
# @author      Melinda Robertson
# @copyright   Copyright (c) 2017 Little, LLC
# @license     GNU

require 'gosu'

# Originally designed to interact with the FoxFx canvas, this input handler has
# been modified to handle any type of event. This functionality is really for
# handling events triggered from separate threads. Events registered with the
# input handler are thread-safe.

module Little
  
  class Command
    attr_accessor   :scene
    attr_accessor	  :target
    # @!attribute   [rw]    method_sym
    #   @return [Symbol]    A symbol representing the method to call on the target
    attr_accessor	:method_sym
    # @!attribute   [rw]    code
    #   @return [Fixnum]    The key code associated with the command.
    attr_accessor   :code
    # @!attribute   [rw]    args
    #   @return [Array]     Not being used currently, may be used in future.
    attr_accessor   :args
    # @!attribute   [rw]    time
    #   @return [Fixnum]    The timestamp for this command in milliseconds.
    attr_accessor   :time
    
    def initialize (target, scene, method_sym, options={})
        @target = target
        @scene = scene
        @method_sym = method_sym
        @code = options[:code] ? options[:code] : nil
        @time = options[:time] ? options[:time] : nil
        @args = options[:args] ? options[:args] : nil
    end
    
    def == obj
        return false if not obj.is_a? Little::Command
        t = true
        if @time and obj.time
			#less than 3/100th of a second
			t = ((@time - obj.time).abs < 300)
        end
        return (@code == obj.code and @scene == obj.scene and
			@target == obj.target and
			@method_sym == obj.method_sym and t)
    end
    
    def to_s
        return "Little::Command=(#{@target},#{@scene},#{@method_sym},#{@code},#{@time})"
    end
    
  end
  
  #TODO How to manage typed input? Gosu has TextInput so how do I incorporate it?

  # Helper class for handling input and events. The scene should be
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
    # @param game [Little:Game] is the game object just in case.
    def initialize(game)
      @queue = Array.new
      @queue_mutex = Mutex.new
      @game = game
      @last_command = nil
      @hold_map = Hash.new
      @single_map = Hash.new
      @request_queue = []
    end
    # Connect a differenct scene so that it's methods
    # get called during user input. If the scene has an input_map
    # it will be added to this object's input maps.
    # @param scene [Scene] is the current scene.
    def connect(scene)
      return nil if @scene == scene.class.name
      @scene = scene.class.name
      clear
      return nil if not scene.input_map
      
      scene.input_map.each do |key, value|
        if key == Little::Input::HOLD
          value.each do |k,v|
            register(scene,@scene,k,v, hold: true)
          end
        else
          register(scene, @scene, key, value)
        end
      end
    end
    
    #Registers an object with a code that will be called
    # whenever the key or button is pressed
    # === Attributes
    # +target+ 		- The object whose method will be called.
    # +sending_scene+ 	- The scene the object belongs to.
    # +code+ 			- Fixnum or String that input will respond to.
    # +method_sym+		- The symbol representing the method to call.
    # +options+			- Hash of additional options: [args: Array, hold: Boolean]
    def register (target, sending_scene, code, method_sym, options={})
      #return nil if sending_scene.class.name != @scene
      sc = sending_scene.class.name
      $FRAME.log self, "register", "Registering #{target} to #{code}", verbose: true
      if method_sym.is_a? String
        method_sym = method_sym.to_sym
      end
      opt = {
        code:	code,
        time:	Gosu::milliseconds,
        args:	options[:args]}
      if options[:hold]
        if not @hold_map[code]
          @hold_map[code] = []
        end
        @hold_map[code].push(Little::Command.new(
            target, sc, method_sym, opt))
      else
        if not @single_map[code]
          @single_map[code] = []
        end
        @single_map[code].push(Little::Command.new(
            target, sc, method_sym, opt))
      end
    end
    
    # Queues requests from objects that are called once and do not have
    # a corresponding code or continuous response.
    # === Attributes
    # +target+ 		- The object whose method will be called.
    # +sending_scene+ 	- The scene the object belongs to.
    # +method_sym+		- The symbol representing the method to call.
    # +options+			- Hash of additional options: [args: Array]
    def request(target, sending_scene, method_sym, options={})
		#$FRAME.log self, "request", "Processing incoming request: #{target}, #{method_sym}"
      @queue_mutex.synchronize {
        return nil if sending_scene.class.name != @scene
        opt = {
          time:	Gosu::milliseconds,
          args:	options[:args]}
              @request_queue.push Little::Command.new(
          target, sending_scene.class.name, method_sym, opt)
      }
    end
    
    # The game calls this method on button_down. It registers the key
    # code as an event and queues it for processing.
    # @param code [Numeric] is the key or mouse code. This should
    #                       have a related response in the mapping.
    def add(code)
      @queue.push(Little::Command.new(self, @scene, nil,
          code: code, time: Gosu::milliseconds))
      #$FRAME.log self,"add","#{code}"
    end
    
    # Executes the next command in the input queue.
    # @return true if the command could be executed,
    #         false otherwise.
    def execute
        # ensure that all parameters are valid
      return false if not @scene
      return false if @queue.empty?
      command = @queue.shift
      while (!@queue.empty? and @last_command == command)
        command = @queue.shift
        #$FRAME.log self, "execute", "#{@last_command}==#{command}", verbose: true
      end
      return false if @last_command == command and @queue.empty?
      #$FRAME.log self, "execute", "Q=#{@queue.size}, #{@last_command}==#{command}"
      #start processing input
      @last_command = command
      #check if the scene is active
      if @scene == command.scene
        return true if call_method(command)
        #$FRAME.log self, "execute", "Did not find #{command}", verbose: true
        # did not find a standard numerical code, searching for non-numeric
          code = KEYSET_OTHER
          if (command.code == Gosu::KB_W or
                command.code == Gosu::KB_A or
                command.code == Gosu::KB_S or
                command.code == Gosu::KB_D)
            code = KEYSET_WASD
            return true if call_method(command, code)
          end
          if (command.code == Gosu::KB_RIGHT or
                  command.code == Gosu::KB_LEFT or
                  command.code == Gosu::KB_UP or
                  command.code == Gosu::KB_DOWN)
            code = KEYSET_DIRECTIONAL
            return true if call_method(command, code)
          end
          if (command.code >= Gosu::KB_A and
              command.code <= Gosu::KB_Z)
            code = KEYSET_ALPHA
            return true if call_method(command, code)
          end
          if (command.code >= Gosu::KB_0 and
              command.code <= Gosu::KB_9)
            code = KEYSET_NUMERICAL
            return true if call_method(command, code)
          end
          if command.code >= Gosu::KB_F1 and
              command.code <= Gosu::KB_F12
            code = KEYSET_FUNCTION
            return true if call_method(command, code)
          end
          return true if call_method(command, code)
      end
      #if the scene is not active or does not have a
      #corresponding response, return false
      return false
    end
    # Process any input that has a continuous response, such as a button
    # being held down.
    def exe_running
        return false if not @scene
        return false if @hold_map.empty?
        @hold_map.each do |key, ary| # key code => array of commands
            if key.is_a? String
              code = Little::Input::get_code_set(key)
              code.each do |c| #TODO is this too much work?
                if @game.button_down? (c)
                  ary.each do |lc|
                    if lc.scene == @scene
                      req = lc.target
                      sym = lc.method_sym
                      # Send the command from input so we know the key code
                      m = req.method(sym)
                      if m.arity == 1
                        m.call(c)
                      elsif m.arity == 2
                        m.call(c, lc.args)
                      else
                        m.call
                      end
                    end
                  end
                end
              end
            elsif @game.button_down?(key)
              ary.each do |lc|
                if lc.scene == @scene
                  req = lc.target
                  sym = lc.method_sym
                  m = req.method(sym)
                  if m.arity > 0
                    # Send the command from input so we know the key code
                    req.method(sym).call(key)
                  else
                    req.method(sym).call
                  end
                end
              end
            end
        end
        return true
    end
    # Processes the requests made by objects during threaded execution.
    # This helps ensure that race conditions do not occur.
	def service_requests
      @request_queue.delete_if do |c|
			#$FRAME.log self, "service_requests", "Serviceing #{c}"
          req = c.target
          if req and not req.remove
              if c.args
                  req.method(c.method_sym).call(c.args)
              else
                  req.method(c.method_sym).call
              end
          end
      end
    end
    # Scrubs the queues by removing dead objects
    def clean
        @single_map.each do |k,v|
            v.delete_if do |i|
                return true if not i.target
                return true if i.target.remove
                false
            end
        end
        @hold_map.each do |k, v|
            v.delete_if do |i|
                return true if not i.target
                return true if i.target.remove
                false
            end
        end
        @request_queue.delete_if {
            return true if not i.target
            return true if i.target.remove
            false
        }
    end
	# Removes everything from all maps and queues.
    def clear
        @single_map.clear
        @hold_map.clear
        @request_queue.clear
        @queue.clear
        @last_command = nil
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
    
    # Commands here do not have the target or method
    # Everything is in the mapped array
    # TODO separate event listeners and events
    # === Attributes
    # +command+ - 	Record of the button or key being pressed, this is
    #				different from the registered command.
    # +code+ -		Sent if the key in the map is not directly related
    #				to a button number. Optional
    private
    def call_method(command, code=nil)
		#$FRAME.log self, "execute", "Sending #{code} to #{@scene}"
        c = code ? code : command.code
        ary = @single_map[c]
        if ary
			#$FRAME.log self, "execute", "Sending #{code} to #{@scene}"
            ary.each do |lc| # check through each object registered to this code
				if lc.scene == @scene
					req = lc.target
					sym = lc.method_sym
					m = req.method(sym)
					if m.arity > 0
						# Send the command from input so we know the key code
						m.call(command.code)
					else
						m.call
					end
				end
			end
            return true
        end
        return false
    end
  end
end
