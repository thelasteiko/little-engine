#!/usr/bin/env ruby

require 'gosu'

module Little

	class Audio
		attr_reader		:filename
		attr_accessor	:volume
		attr_accessor	:loop
		attr_reader		:play_count
		
		def initialize (filename, volume = 1, loop = false)
			@filename = filename
			@volume = volume
			@loop = loop
			@play_count = 0
		end
		def play
			@play_count += 1
			__play
		end
		protected
		def __play
			$FRAME.log self, "__play", "Not implemented"
		end
		
		def pause
			$FRAME.log self, "pause", "Unsupported"
		end
		
		def stop
			$FRAME.log self, "stop", "Unsupported"
		end
		
	end
	
	class AudioSample < Little::Audio
		
		attr_accessor	:speed
		attr_accessor	:pan
		
		attr_reader		:instance
		attr_reader		:sample
		
		def initialize (filename, volume = 1, loop = false, speed = 1, pan = 0)
			super (filename, volume, loop)
			@sample = Gosu::Sample.new(filename)
			@speed = speed
			@pan = pan
		end
		protected
		def __play
			#$FRAME.log self, "done", "I am a #{super.class.name}"
			if @instance and @instance.paused?
				@instance.resume
			elsif pan != 0
				@instance = @sample.play_pan(@pan,@volume,@speed,@loop)
			else
				@instance = @sample.play(@volume,@speed,@loop)
			end
		end
		
		def done?
			return true if @play_count == 0
			return true if not @instance
			return false if @loop
			if not @instance.playing?
				@instance = nil
				return true
			end
			return false
		end
		
		def pause
			if @instance
				@instance.pause
			end
		end
		
		def stop
			if @instance
				@instance.stop
				@instance = nil
			end
		end
	end
	
	class AudioTrack < Little::Audio
		attr_reader		:track
		attr_accessor	:override
		
		def initialize(filename, volume = 1, loop = false, override = false)
			super (filename, volume, loop)
			@track = Gosu::Song.new(filename)
			@override = override
		end
		protected
		def __play
			if @override
				@track.play(@loop)
			else
				# waits for the current song to finish even if
				# this is the current song
				cs = Gosu::Song::current_song
				if not (cs and cs.playing?)
					@track.play(@loop)
				end
			end
		end
		
		def pause
			@track.pause
		end
		
		def stop
			@track.stop
		end
		
		def playing?
			return @track.playing?
		end
	end
	# Add this module to an object to have audio.
	# Loaded audio tracks will automatically be assigned to a number, in order
	# The list is not meant to be modified.
	module Audible
		def current_audio
			@current_audio ||= nil
		end
		def playlist
			@playlist ||= {}
		end
		# Arguments are: [filename, name, volume, speed, looping, pan]
		def load_sample (filename, options={})
			pl = playlist
			name = options[:name] ? options[:name] : pl.size
			vol = options[:volume] ? options[:volume] : 1
			sp = options[:speed] ? options[:speed] : 1
			loop = options[:loop] ? options[:loop] : false
			pan = options[:pan] ? options[:pan] : 0
			pl[name] = Little::AudioSample.new(filename,vol,loop,sp,pan)
		end
		
		def load_track (filename, options={})
			pl = playlist
			name = options[:name] ? options[:name] : pl.size
			vol = options[:volume] ? options[:volume] : 1
			loop = options[:loop] ? options[:loop] : false
			ovr = options[:override] ? options[:override] : false
			pl[name] = Little::AudioTrack.new(filename, vol, loop, ovr)	
		end
		
		# Options change the parameters of the audio sample
		def play (name, options={})
			audio = playlist[name]
			if not audio
				current_audio = nil
				return nil
			end
			if options[:volume]
				audio.volume = options[:volume]
			end
			if options[:loop]
				audio.loop = options[:loop]
			end
			if audio.is_a? Little::AudioSample
				if options[:speed]
					audio.speed = options[:speed]
				end
				if options[:pan]
					audio.pan = options[:pan]
				end
			else if audio.is_a? Little::AudioTrack
				if options[:override]
					audio.override = options[:override]
				end
			end
			audio.play
			current_audio = name
		end
		
		def Audible.default_list
			return [:name, :volume, :speed, :loop, :pan, :override]
		end
	end
end
