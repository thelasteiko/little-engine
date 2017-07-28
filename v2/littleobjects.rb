#!/usr/bin/env ruby

# Little is a small and unassuming game engine based on Gosu.
# All rights go to the Gosu people for the Gosu code.
#
# @author      Melinda Robertson
# @copyright   Copyright (c) 2017 Little, LLC
# @license     GNU

require_relative 'littlegraphics'
require_relative './littleengine'


module Little
module Board

	class Object < Little::Object
		include Little::Shapeable
		
		def initialize (x, y, z, w, h, d=0)
			super()
			@shape = Little::Shape.new(x,y,z,w,h,d)
		end
	
	end

end
end
