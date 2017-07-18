#!/usr/bin/env ruby

require 'gosu'

module Little
	
	class AudioSample
		attr_accessor	:volume
		attr_accessor	:speed
		attr_accessor	:loop
		attr_accessor	:pan
		
		attr_reader		:instance
		attr_reader		:sample
		
		attr_reader		:played_once
		
		def initialize (filename, volume = 1, speed = 1, looping = false, pan = 0)
			@sample = Gosu::Sample.new(filename)
			@volume = volume
			@speed = speed
			@loop = looping
			@pan = pan
			@played_once = false
		end
		
		def play
			#$FRAME.log self, "done", "I am a #{super.class.name}"
			if pan != 0
				@instance = @sample.play_pan(@pan,@volume,@speed,@loop)
			else
				@instance = @sample.play(@volume,@speed,@loop)
			end
			@played_once = true
		end
		
		def done?
			return false if @loop
			return true if not @instance
			if not @instance.playing?
				@instance = nil
				return true
			end
			return false
		end
	end
	# Add this module to an object to have audio.
	# Loaded audio tracks will automatically be assigned to a number, in order
	# The list is not meant to be modified.
	module Audible
		def playlist
			@playlist ||= {}
		end
		# Arguments go in this order: [filename, name, volume, speed, looping, pan]
		def load_audio (*args)
			pl = playlist
			if args.size == 1
				pl[pl.size] = Little::AudioSample.new(args[0])
			elsif args.size == 2
				pl[args[1]] = Little::AudioSample.new(args[0])
			elsif args.size == 3
				pl[args[1]] = Little::AudioSample.new(args[0], args[2])
			elsif args.size == 4
				pl[args[1]] = Little::AudioSample.new(args[0], args[2], args[3])
			elsif args.size == 5
				pl[args[1]] = Little::AudioSample.new(args[0], args[2], args[3], args[4])
			elsif args.size == 6
				pl[args[1]] = Little::AudioSample.new(args[0], args[2], args[3], args[4], args[5])
			end
		end
		
		# Options change the parameters of the audio sample
		def play (sample, options={})
			audio = playlist[sample]
			if options[:volume]
				audio.volume = options[:volume]
			end
			if options[:speed]
				audio.speed = options[:speed]
			end
			if options[:looping]
				audio.loop = options[:looping]
			end
			if options[:pan]
				audio.pan = options[:pan]
			end
			audio.play
		end
	end
end
