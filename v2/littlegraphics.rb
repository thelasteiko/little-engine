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
    
    class Path
		attr_accessor	:points
		def initialize (points=[])
			if points.empty?
				@points = points
			else
				@points = Array.new
				i = 1
				while i < points.size
					@points.push(Little::Point.new(points[i-1],points[i]))
					i += 2
				end
			end
		end
		def size
			points.size
		end
		def convert_to_lines
			path_set = []
			i = 1
			while i < points.size
				
			end
		end
		# Creates a list of points defining a line using Bresenham's
		# line algorithm.
		def self.bresenham_line(p1,p2)
			line = []
			dx = p2.x - p1.x
			dy = p2.y - p1.y
			if (dx == 0) # vertical line
				y = p1.y
				if p1.y > p2.y
					while y > p2.y
						line.push (Little::Point.new(p1.x,y)
						y += 1
					end
				elsif p2.y > p1.y
					while y < p2.y
						line.push(Little::Point.new(p1.x,y)
						y -= 1
					end
				end
				return line
			end
			derr = (dy/dx).abs
			error = derr - 0.5
			y = p1.y
			for x in p1.x..p2.x
				line.push(Little::Point.new(x,y))
				error += derr
				if error >= 0.5
					y += 1
					error -= 1.0
				end
			end
			return line
		end
    end
    
    module Focusable
        def point
            @point ||= Little::Point.new
        end
    end
    
    module Shapeable
		def path
			@path ||= Little::Path.new
		end
    end
    # points are clockwise
    class Graphics
		DEFAULT_COLOR = Gosu::Color::WHITE
        def initialize (game, camera)
            @game = game
            @camera = camera
        end
        # Uses the OpenGL method to draw the line. This has inconsistent
        # behavior.
		def line_ogl (point1, point2, color=DEFAULT_COLOR)
			p1 = @camera.translate(point1)
			p2 = @camera.translate(point2)
			Gosu::draw_line(p1.x,p1.y,color,p2.x,p2.y,color)
		end
		# Creates a line between two points using the Bresenham line
		# algorithm and draws the pixels individually.
		def line (point1, point2, color=DEFAULT_COLOR)
			l = Path::bresenham_line(point1,point2)
			l.each do |i|
				pixel(i,color)
			end
		end
		def rect (point, width, height, color=DEFAULT_COLOR)
			#print "into drawing rect \n"
			p = @camera.translate(point)
			#print "translated point\n"
			Gosu::draw_rect(p.x,p.y,width,height,color)
		end
		def pixel(point,color=DEFAULT_COLOR)
			p = @camera.translate(point)
			#Gosu::draw_line(p.x,p.y,color,p.x,p.y,color)
			Gosu::draw_rect(p.x,p.y,1,1,color)
		end
		# Draws points from a path object.
		def path(path, color=DEFAULT_COLOR)
			points = path.points
			i = 1
			while i < points.size
				#pixel(points[i-1])
				line(points[i-1], points[i], color)
				#pixel(points[i])
				i += 1
			end
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
