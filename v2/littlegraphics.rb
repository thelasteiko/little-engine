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
        attr_accessor   :points
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
        def push(x,y)
            @points.push(Little::Point.new(x,y))
        end
        # Creates a list of points defining a line using Bresenham's
        # line algorithm. X_X TODO
        def self.bresenham_line(p1,p2)
            line = []
            x1 = 0
            y1 = 0
            x2 = 0
            y2 = 0
            if p1.y < p2.y
				x1 = p1.x
				y1 = p1.y
				x2 = p2.x
				y2 = p2.y
            else
				x1 = p2.x
				y1 = p2.y
				x2 = p1.x
				y2 = p1.y
            end
            dx = x2 - x1
            dy = y2 - y1
            
            print "(#{dx},#{dy})\n"
            if (dx == 0) # vertical line
                y = p1.y
                if p1.y > p2.y
                    while y > p2.y
                        line.push (Little::Point.new(p1.x,y))
                        y -= 1
                    end
                elsif p2.y > p1.y
                    while y < p2.y
                        line.push(Little::Point.new(p1.x,y))
                        y += 1
                    end
                end
                return line
            end #vertical line
            
            derr = (dy/dx).abs
            error = derr - 0.5
            x = x1
            s = y1
            e = y2
            a = 1
            if (dy/dx) < 0
                a = -1
            end
            print "#{x}:#{a}(#{s},#{e})\n"
            for y in s..e
                while error < 0.5
					print "(#{x},#{y})\n"
					line.push(Little::Point.new(x,y))
					x += a
					error += derr
				end
                if error >= 0.5
					print "#{error},#{x}\n"
                    x += a
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
	    DEFAULT_ORDER = 0
        def initialize (game, camera)
            @game = game
            @camera = camera
                @order = DEFAULT_ORDER
        end
        def start_group(order)
                @order = order
        end
        def end_group(order)
            if @order == order
                @order = DEFAULT_ORDER
            end
        end
        # Uses the OpenGL method to draw the line. This has inconsistent
        # behavior.
        def line_ogl (point1, point2, options={color: DEFAULT_COLOR, focus: true})	
		p1 = point1
		p2 = point2
            if options[:focus]
	        p1 = @camera.translate(point1)
                p2 = @camera.translate(point2)
	    end            
            Gosu::draw_line(p1.x,p1.y, options[:color],
		    p2.x,p2.y, options[:color], @order)
        end
        # Creates a line between two points using the Bresenham line
        # algorithm and draws the pixels individually.
        def line (point1, point2, options={color: DEFAULT_COLOR, focus: true})
            #print "creating line\n"
            l = Path::bresenham_line(point1,point2)
            l.each do |i|
                pixel(i,color)
            end
        end
        def rect (point, width, height, options={color: DEFAULT_COLOR, focus: true})
		    p = point
		    if options[:focus]
                #print "into drawing rect \n"
            	    p = @camera.translate(point)
		    end
            #print "translated point\n"
            Gosu::draw_rect(p.x,p.y,width,height,options[:color],@order)
        end
        # Colors a single pixel. Cost heavy.
            # TODO use Texplay instead
        def pixel(point, options={color: DEFAULT_COLOR, focus: true})
                p = point
                if options[:focus]
                        #print "into drawing rect \n"
                        p = @camera.translate(point)
                end
            #Gosu::draw_line(p.x,p.y,color,p.x,p.y,color)
            Gosu::draw_rect(p.x,p.y,1,1,options[:color],@order)
        end
        # Draws points from a path object.
        def path(path, options={color: DEFAULT_COLOR, focus: true})
            points = path.points
            i = 1
            while i < points.size
                #pixel(points[i-1])
                #line(points[i-1], points[i], color)
                line_ogl(points[i-1],points[i], color)
#               print "Drawing: (#{points[i-1].x},#{points[i-1].y})"
#               print "->(#{points[i].x},#{points[i].y})\n"
                #pixel(points[i])
                i += 1
            end
        end
        def image(image, point, options={   color: DEFAULT_COLOR,
                                            focus: true,
                                            scale: Little::Point.new(1,1,1),
                                            rotate: false,
                                            rotate_angle:   0,      # TODO: check this -> in degrees w/ 0 being north or up and going clockwise
                                            rotate_center: Little::Point.new(0.5,0.5)})    # "relative rotation origin"
                p = point
                r = options[:rotate_center]
                if options[:focus]
                    p = @camera.translate(point)
                    if options[:rotate]
                        #r = @camera.translate(r) #TODO not sure about the affect of the rotate center
                    end
                end
                if options[:rotate]
                    #draw_rot(x, y, z, angle, center_x = 0.5, center_y = 0.5, scale_x = 1, scale_y = 1, color = 0xff_ffffff, mode = :default
                    image.draw_rot(p.x,p.y.@order,
                        options[:rotate_angle],r.x,r.y,
                        options[:scale].x,options[:scale].y,
                        options[:color])
                else
                    image.draw(p.x,p.y,@order,options[:scale].x,options[:scale].y)
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
            #print "1(#{point.x},#{point.y})\n"
            if @focus and @focus.point and not @focus.remove
                #focus is at the center
                offset = @focus.point.get_center_offset(@width, @height)
                #print "2(#{offset.x},#{offset.y})\n"
            else
		offset = Little::Point.new
	    end
            #p = point.clone #don't change the original
            #print "3(#{p.x-offset.x},#{p.y})\n"
            p = point.subtract(offset)
            #print "4(#{p.x},#{p.y})\n"
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
