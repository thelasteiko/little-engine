#!/usr/bin/env ruby

require 'gosu'

module Little

    class Point
        attr_accessor   :x
        attr_accessor   :y
        attr_accessor   :z
        def initialize (x=0.0,y=0.0,z=0.0)
            @x = x
            @y = y
            @z = z
        end
        def get_center_offset(width, height, depth=0.0)
			#TODO not sure about z yet
			return Little::Point.new(@x-(width/2),@y-(height/2),@z-(depth))
        end
        def subtract(p)
			return Little::Point.new(@x-p.x,@y-p.y,@z-p.z)
        end
        def == obj
			return false if not obj.is_a? Little::Point
			return (@x == obj.x and @y == obj.y and @z == obj.z)
        end
    end
    
    module Focusable
        def point
            @point ||= Little::Point.new
        end
    end
    # points are clockwise
    class Graphics
		DEFAULT_COLOR = Gosu::Color::WHITE
        def initialize (game, camera)
            @game = game
            @camera = camera
        end
		def line (point1, point2, color=DEFAULT_COLOR)
			p1 = @camera.translate(point1)
			p2 = @camera.translate(point2)
			Gosu::draw_line(p1.x,p1.y,color,p2.x,p2.y,color)
		end
		def rect (point, width, height, color=DEFAULT_COLOR)
			#print "into drawing rect \n"
			p = @camera.translate(point)
			#print "translated point\n"
			Gosu::draw_rect(p.x,p.y,width,height,color)
		end
    end
    # Keeps the graphics object focused on a particular game object,
    # that is keep it at the center of the game window,
    # so long as the object includes the Focusable module.
    class Camera
        # @!attribute [rw] focus
        #   @return [Little::Object] the object to focus on
        attr_accessor   :focus
        # Initializes a camera with a set width and height for the screen.
        # @param width [Fixnum] the width of the window
        # @param height [Fixnum] the height of the window
        def initialize (width, height)
            @focus = nil
            @width = width
            @height = height
        end
        
        def translate (point)
            offset = Little::Point.new
            if @focus and @focus.point
                #focus is at the center
                offset = @focus.point.get_center_offset(width, height)
            end
            p = point.clone #don't change the original
            p.subtract(offset)
            return p #just to be clear
        end
		def translate_all(points)
			a = []
			points.each do |p|
				a.push translate(p)
			end
			return a
		end
    end
end
