#!/usr/bin/env ruby

require_relative './littlegame'

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
		attr_reader		:type
		attr_reader		:ordering
		attr_accessor	:changed
		def initialize (type = "base", ordering={})
			super
			@type = type
			@ordering = ordering #set ordering of listed groups?
			@changed = true
		end
		# Just like a Little::Object, update is called every cycle
		# If no changes are to be made to the ordering it skips this so it doesn't
		# bog down the game.
		# It will always run the full update if its the first time.
		def update
			# to differentiate between changing and not, we return true
			return true if not @changed
			# we must be registered as a manager to access groups
			g = @scene.request_groups(self)
			if g
				#ensure the we and the scene match keys
				keys = @scene.group_keys
				keys.each do |k|
					# don't worry about ordering if its not there
					if not @ordering[k]
						@ordering[k] = 99 #drawing last
						$FRAME.log self, "update", "#{k} is not managed."
					end
				end
				update_groups(g)
			end
			@changed = false
		end
		def update_groups(g)
			# We do something based on what manager we have.
			$FRAME.log self, "update_groups", "Not implemented"
		end

	end
	
	class LayerManager < Little::Manager
		def initialize
			super ("layer", {
				background:	0,
				midground:	50,
				foreground:	98
			})
			
		end
		
		# Updates the z-order (draw order) of each group based on the
		# manager's ordering hash. If a group can't be found, create one.
		# The manager should have full control over groups.
		def update_groups(g)
			@ordering.each do |k, v|
				#change the order attribute to match the ordering array
				if not g[k]
					# The manager should always have the more correct
					# listing of groups, so add any that aren't there.
					g[k] = Group.new(@game,@scene)
				end
				g[k].order = v
			end
		end
		def set_order (sym, num)
			if @ordering[sym]
				@ordering[sym] = num
				@changed = true
			end
		end
		# Add an object that can move between layers.
		# These objects will change z-order depending on the perspective
		# that manager is trying for. We have to add it to a new group
		# and change order based on x, y, z
		def add_moveable (object)
			$FRAME.log self. "add_moveable", "Not implemented"
		end
	end
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
				return @groups[:managers].contains(requester)
			end
			return false
		end
		
		def add_manager(manager)
			if not @groups
				@groups = Hash.new
			end
			if not @groups[:managers]
				@groups[:managers] = Little::Group.new(@game, self)
				@groups[:managers].order = -1
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
end
