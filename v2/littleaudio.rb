#!/usr/bin/env ruby

require 'gosu'

module Little
	module Audible
		def playlist
			@playlist ||= []
		end
		def load_sample (sample, name = nil)
			pl = playlist
			if name
				pl.push(name => Gosu::Sample.new(sample))
			else
				pl.push(pl.size => Gosu::Sample.new(sample))
			end
		end
		def play (sample, volume = 1, speed = 1, looping = false, pan = 0)
			if pan != 0
				playlist[sample].play_pan(pan,volume,speed,looping)
			else
				playlist[sample].play(volume,speed,looping)
			end
		end
	end
end
