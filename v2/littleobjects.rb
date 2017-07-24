#!/usr/bin/env ruby

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
