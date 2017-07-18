#!/usr/bin/env ruby

=begin
 Little::Point
    Simple x,y,z point representation. Adds comparison, subtraction and offset
    convenience methods.
 Little::Path
    List of points with added capabilities that track width, height, rectangular
    bounds and a method to translate points listed relative to rectangular bounds.
    ie. relative to the top right bounds of the path
 Little::Graphics
    The graphics object uses the camera to focus and track proper placement
    and draw order.
 Little::Camera
    Keeps the play area focused on one object.
=end
require 'gosu'
require 'texplay'

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
        def to_s
            return "Little::Point(#{@x},#{@y},#{@z})"
        end
        # Determines if this point is strictly above and to the left
        # of the argument point. top_left
        def < (pt)
            return (@x < pt.x and @y < pt.y)
        end
        # Determines if this point is strictyl below and to the right
        # of the argument point. bottom_right
        def > (pt)
            return (@x > pt.x and @y > pt.y)
        end
    end
    
    # List of Little::Point with added capabilities for drawing.
    # Keeps track of the rectangular bounds, width and height
    class Path
        attr_accessor   :points
        # Defines upper and lower bounds on the path
        attr_reader     :top_left
        attr_reader     :bottom_right
        
        def initialize (*args)
            @points = Array.new
            @top_left = Little::Point.new(9999,9999)
            @bottom_right = Little::Point.new(0,0)
            if args.size > 0
                i = 1
                while i < args.size
                    np = Little::Point.new(args[i-1],args[i])
                    check(np)
                    @points.push(np)
                    i += 1
                end
            end
        end
        def each
            @points.each {|i| yield (i)}
        end
        def size
            @points.size
        end
        def push(*args)
            if args.size == 1
                check (args[0])
                @points.push(args[0])
            elsif args.size == 2
                #$FRAME.log self, "push", "#{args[0]},#{args[1]}"
                np = Little::Point.new(args[0],args[1])
                check (np)
                @points.push(np)
            end
        end
        # We need a method that return a list of points relative to
        # the top_left
        def to_relative
            a = []
            @points.each do |i|
                p = i.subtract(@top_left)
                a.push(p)
            end
            return a
        end
        def [] (index)
            return @points[index]
        end
        def width
            return (@bottom_right.x-@top_left.x).abs
        end
        def height
            return (@bottom_right.y-@top_left.y).abs
        end
        protected
        # Modifies the rectangular bounds of this path by checking each
        # incoming point
        def check (np)
            #$FRAME.log self, "check", "NP #{np}"
            #$FRAME.log self, "check", "TL #{@top_left}"
            if np.x < @top_left.x
                @top_left.x = np.x
            end
            if np.y < @top_left.y
                @top_left.y = np.y
            end
            if np.x > @bottom_right.x
                @bottom_right.x = np.x
            end
            if np.y > @bottom_right.y
                @bottom_right.y = np.y
            end
        end
    end
    
    module Focusable
        def point
            @point ||= Little::Point.new
        end
    end
    
    module Traceable
        def path
            @path ||= Little::Path.new
        end
    end
    
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
        # behavior but less buggy than line
        def line_ogl (point1, point2, options={ 
                                color: DEFAULT_COLOR, do_not_focus: false})
            p1 = point1
            p2 = point2
            if not options[:color]
                options[:color] = DEFAULT_COLOR
            end
            if not options[:do_not_focus]
                p1 = @camera.translate(p1)
                p2 = @camera.translate(p2)
            end            
            Gosu::draw_line(p1.x,p1.y, options[:color],
                p2.x,p2.y, options[:color], @order)
        end
        # Creates a line between two points. Really buggy
        def line (point1, point2, options={color: DEFAULT_COLOR, do_not_focus: false})
            path = Little::Path.new
            path.push(point1)
            path.push(point2)
            p = path.to_relative
            img = TexPlay::create_blank_image(@game, path.width, path.height)
            img.polyline p, :color => options[:color]
            center = path[0]
            if not options[:do_not_focus]
                center = @camera.translate(center)
            end
            img.draw center.x, center.y, 1
        end
        # Draws a rectangle according to the provided options.
        # Needs at least a point, width and height.
        def rect (point, width, height, options={color: DEFAULT_COLOR,
                                                do_not_focus: false})
            if options.size < 3
                return nil
            end
            if not options[:color]
                options[:color] = DEFAULT_COLOR
            end
            p = options[:point]
            if not p
                p = Little::Point.new(options[:x], options[:y])
            end
            if not options[:do_not_focus]
                #print "into drawing rect \n"
                p = @camera.translate(p)
            end
            #$FRAME.log self, "rect", "Color: #{options[:color]}"
            Gosu::draw_rect(p.x,p.y,options[:width],options[:height],
                options[:color],@order)
        end
        # Colors a single pixel.
        def pixel(point, options={color: DEFAULT_COLOR, do_not_focus: false})
            p = options[:point]
            if not p
                p = Little::Point.new(options[:x], options[:y])
            end
            if not options[:color]
                options[:color] = DEFAULT_COLOR
            end
            #$FRAME.log self, "pixel", "Point 1 #{p.x}, #{p.y}"
            if not options[:do_not_focus]
                p = @camera.translate(p)
                #$FRAME.log self, "pixel", "Point 2 #{p.x}, #{p.y}"
            end
            img = TexPlay::create_image(@game, 1, 1, :color => options[:color] )
            img.draw p.x, p.y, 1
        end
        # Colors a set of pixels.
        def pixels (points, options={   color: DEFAULT_COLOR,
                                        do_not_focus: false})
            p = points.to_relative
            if not options[:color]
                options[:color] = DEFAULT_COLOR
            end
            img = nil
            if points.is_a? Little::Path
                img = TexPlay::create_image(@game, points.width, points.height)
            else
                img = TexPlay::create_image(@game, @camera.width, @camera.height)
            end
            img.paint do
                p.each do |i|
                    #$FRAME.log self, "each", "#{i}"
                    pixel i, :color => options[:color]
                end
            end
            center = points[0]
            if not options[:do_not_focus]
                center = @camera.translate(center)
            end
            img.draw center.x,center.y,1
        end
        # Draws points from a path object using TexPlay. This works better than line.
        def path(path, options={color: DEFAULT_COLOR, do_not_focus: false})
            if not options[:color]
                options[:color] = DEFAULT_COLOR
            end
            img = TexPlay::create_blank_image(@game, path.width, path.height)
            p = path.to_relative
            #$FRAME.log self, "path", "#{p.size}"
            img.paint do
                polyline p, color: options[:color]
            end
            center = path.top_left
            if not options[:do_not_focus]
                center = @camera.translate(center)
            end
            img.draw center.x, center.y, 1
        end
        
        # Draws an image, rotate goes clockwise from north
        def image(image, point, options={ color: DEFAULT_COLOR,
                                    do_not_focus: false,
                                    scale: Little::Point.new(1,1,1),
                                    rotate_angle:   nil,      # in degrees w/ 0 being north or up and going clockwise
                                    rotate_center: nil})    # "relative rotation origin"
            p = point
            if not options[:color]
                options[:color] = DEFAULT_COLOR
            end
            if not options[:do_not_focus]
                p = @camera.translate(point)
            end
            if options[:rotate_angle]
                r = options[:rotate_center]
                if not r
                    r = Little::Point.new(0.5,0.5)
                end
                #draw_rot(x, y, z, angle, center_x = 0.5, center_y = 0.5, scale_x = 1, scale_y = 1, color = 0xff_ffffff, mode = :default
                image.draw_rot(p.x,p.y, @order,
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
        attr_reader     :width
        attr_reader     :height
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
        
        def translate_on (origin, point)
            # use the origin to translate?
        end
    end
end
