#!/usr/bin/env ruby

# Little is a small and unassuming game engine based on Gosu.
# All rights go to the Gosu people for the Gosu code.
#
# @author      Melinda Robertson
# @copyright   Copyright (c) 2017 Little, LLC
# @license     GNU

require_relative '../littlegame.rb'

module Little

	# Manages the groups in a scene by manipulating z-order and such.
	# Even though they are Little::Objects they should not be drawn but
	# maybe for debugging?
	# The ordering of the groups changes based on the rules of the manager.
	# The manager most likely relates to a certain perspective,
	# ie. top down, side-scrolling etc.
	# So it should change the ordering of groups based on what's happening
	# in the game.
	class Manager < Little::Object
		MIN_ORDER = 0
		MAX_ORDER = 99
		attr_reader		:type
		attr_reader		:ordering
		attr_accessor	:changed
		def initialize (type = "base", ordering={})
			super()
			@type = type
			@ordering = ordering #set ordering of listed groups?
			@changed = true
		end
		# Just like a Little::Object, update is called every cycle
		# If no changes are to be made to the ordering it skips this so it doesn't
		# bog down the game.
		# It will always run the full update if its the first time.
		def update (tick)
			return nil if not @changed
			return nil if not @group or not @group.scene
			@game.input.request(self, @group.scene, :__update_groups)
		end
		def __update_groups
			#$FRAME.log self, "update_groups", "Change is #{@changed}"
			# to differentiate between changing and not, we return true
			return true if not @changed
			# We do something based on what manager we have.
			# we must be registered as a manager to access groups
			g = @scene.request_groups(self)
			if g
				#ensure the we and the scene match keys
				keys = @scene.group_keys
				keys.each do |k|
					# don't worry about ordering if its not there
					if not @ordering[k]
						@ordering[k] = 99 #drawing last
						#$FRAME.log self, "update", "#{k} is not managed."
					end
				end
				update_groups(g)
			end
			@changed = false
			return true
		end
		
		def update_groups(g)
			$FRAME.log self, "update_groups", "Not implemented"
		end

	end
	
	# Layer manager isn't needed if objects handle their own ordering.
	
	
	# Add to a scene to allow manager objects to manipulate
	# the scene's groups.
	module Manageable
		TYPE_NAMES = [
			"base", "layer"
		]
		
		def request_groups (requester)
			if permissable(requester)
				return @groups ||= Hash.new
			end
			return nil
		end
		
		def permissable (requester)
			return true if requester == self
			if @groups and @groups[:managers]
				return @groups[:managers].include?(requester)
			end
			return false
		end
		
		def add_manager(manager)
			if not @groups
				@groups = Hash.new
			end
			if not @groups[:managers]
				@groups[:managers] = Little::Group.new(@game, self)
			end
			manager.game = @game
			manager.scene = self
			@groups[:managers].push(manager)
		end
		# Returns the requested manager or nil if it can't be found.
		def get_manager(type)
			return nil if not @groups
			return nil if not @groups[:managers]
			@groups[:managers].each do |m|
				return m if m.type == type
			end
			return nil
		end
	end
	# Add to a scene and call the method to create methods that return
	# the first object for every group not excluded
	# The method can be called more than once
	module Accessible
		def create_quick_list (exclude=[:default])
			return nil if not @groups
			keys = @groups.keys
			keys.each do |sym|
				if not exclude.include?(sym)
					define_singleton_method("#{sym}") do
						return @groups[sym].object
					end
				end
			end
		end
	end
	
end
