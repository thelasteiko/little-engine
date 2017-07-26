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
require 'chipmunk'

module Little

    # Describes a point in a 3D plain.
    class Point
        
        attr_accessor   :x
        attr_accessor   :y
        attr_accessor   :z
        def initialize (x=0.0,y=0.0,z=0.0)
            @x = x
            @y = y
            @z = z
        end
        # Offset from the center of the anything, given its width, height
        # and depth if applicable.
        def get_center_offset(width, height, depth=0.0)
            return Little::Point.new(@x-(width/2),@y-(height/2),@z-(depth))
        end
        # Returns a new point with the provides point's attributes
        # subtracted from this one's.
        def subtract(p)
            return Little::Point.new(@x-p.x,@y-p.y,@z-p.z)
        end
        # Adds the provided point's attributes to this one's.
        # Changes the original object.
        def add!(p)
            @x += p.x
            @y += p.y
            @z += p.z
        end
        def == obj
            return false if not obj.is_a? Little::Point
            return (@x == obj.x and @y == obj.y and @z == obj.z)
        end
        def to_s
            return "Little::Point<#{object_id}>(#{@x},#{@y},#{@z})"
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
        # Returns a new object with the same attributes.
        def copy
            return Little::Point.new(@x,@y,@z)
        end
        # Rotates the specified number of degrees around the given center
        # in the x,y direction. Angles go clockwise, a la not unit circle
        def rotate (angle, center)
            return copy if angle == 0
            rad = angle.degrees_to_radians
            rx = @x*Math.cos(rad) - @y*Math.sin(rad)
            ry = @x*Math.sin(rad) + @y*Math.cos(rad)
            return Little::Point.new(rx,ry,@z)
        end
        # Rotates the specified number of degrees around the given center
        # in the x,z direction. Angles go clockwise, a la not unit circle
        def turn (angle, center)
            return copy if angle == 0
            rad = angle.degrees_to_radians
            rx = @x*Math.cos(rad) - @z*Math.sin(rad)
            rz = @x*Math.sin(rad) + @z*Math.cos(rad)
            #puts "result: #{rx}, #{rz}"
            return Little::Point.new(rx,@y,rz)
        end
        # Tilts the specified number of degrees around the given center
        # in the y,z direction. Angles go up, back and around
        def tilt (angle, center)
            return copy if angle == 0
            rad = angle.degrees_to_radians
            ry = @z*Math.cos(rad) - @y*Math.sin(rad)
            rz = @z*Math.sin(rad) + @y*Math.cos(rad)
            return Little::Point.new(@x,ry,rz)
        end
        # Returns a copy of the point transformed according to the
        # provided angles. Angles are in degrees.
        # ==== Attributes
        # +rotation_angle+   - The angle of rotation along the x,y plain.
        # +turn_angle+  - The angle of rotation along the x,z plain.
        # +center+  - The center point around which to transform.
        def transform (rotation_angle, turn_angle, center)
            return copy if rotation_angle == 0 and turn_angle == 0
            radr = rotation_angle.degrees_to_radians
            radtu = turn_angle.degrees_to_radians
            
            rx = @x*Math.cos(radr) - @y*Math.sin(radr)
            ry = @x*Math.sin(radr) + @y*Math.cos(radr)
            rz = @x*Math.sin(radtu) + @z*Math.cos(radtu)
            #puts "result 1: #{rx}, #{ry}, #{rz}"
            rx = rx*Math.cos(radtu) - @z*Math.sin(radtu)
            ry = @z*Math.sin(radtu) + ry*Math.cos(radtu)
            #puts "result 2: #{rx}, #{ry}, #{rz}"
            return Little::Point.new(rx,ry,rz)
        end
        # Uses all three dimensions to calculate distance.
        def distance3D (pt)
            Math.sqrt((@x - pt.x)**2 + (@y - pt.y)**2 + (@z - pt.z)**2)
        end
        # Calculates the 'flat' distance accross the canvas using x,y
        def distance2D (pt)
            Math.sqrt((@x-pt.x)**2 + (@y-pt.y)**2)
        end
        # Calculates the conceptual depth distance using x,z
        def distance1Dx (pt)
            Math.sqrt((@x-pt.x)**2 + (@z-pt.z)**2)
        end
        # Calculates the conceptual depth distance using y,z
        def distance1Dy (pt)
            Math.sqrt((@y-pt.y)**2 + (@z-pt.z)**2)
        end
        # Uses x,y as the center and z as the radius
        def to_circle(color=Gosu::Color::WHITE, filled=true)
            return @circle if @circle
            width = @z*2 + 1
            @circle = TexPlay::create_blank_image($FRAME, width, width)
            #$FRAME.log self, "to_circle", "#{to_s}::#{color}"
            p = @z
            @circle.paint do
                circle p, p, p, :color => color
                if filled
                    fill p,p, :color => color
                end
            end
            return @circle
        end
        
        def to_vec
            return CP::Vec2.new(@x,@y)
        end
        
        def cx
            @x+@z
        end
        def cy
            @y+@z
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
            elsif args.size == 3
                np = Little::Point.new(args[0],args[1],args[2])
                check (np)
                @points.push(np)
            end
        end
        # Adds a set of Little::Points
        def add_pts(pts)
            pts.each {|p| push(p)}
        end
        # Adds to the path using a list of numbers.
        # The list should be an even number of points.
        def add_nums(nums)
            i = 1
            while i < nums.size
                push(nums[i-1],nums[i])
                i += 2
            end
        end
        # We need a method that return a list of points relative to
        # the top_left
        def relative_to_top_left
            a = []
            @points.each do |i|
                p = i.subtract(@top_left)
                a.push(p)
            end
            return a
        end
        
        def relative_to_center
            a = []
            c = center
            @point.each do |i|
                p = i.subtract(c)
                a.push p
            end
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
        
        def center
            return Little::Point.new(@bottom_right.x-(width/2),
                @bottom_left.y-(height)/2)
        end
        
        def to_img (color = Gosu::Color::WHITE)
            return @img if @img
            @img = TexPlay::create_blank_image($FRAME, width, height)
            p = relative_to_top_left
            #$FRAME.log self, "path", "#{p.size}"
            @img.paint do
                polyline p, color: color
            end
            return @img
        end
        # This method should return a list of points from the center
        # around...
        def to_cp_bounds
            b = []
            pt = relative_to_center
            pt.each do |p|
                b.push CP::Vec2.new p.x, p.y
            end
            return b
        end
        
        protected
        # Modifies the rectangular bounds of this path by checking each
        # incoming point.
        def check (np)
            #$FRAME.log self, "check", "NP #{np}"
            #$FRAME.log self, "check", "TL #{@top_left}"
            if np.x < @top_left.x
                @top_left.x = np.x
            end
            if np.y < @top_left.y
                @top_left.y = np.y
            end
            if np.z < @top_left.z
                @top_left.z = np.z
            end
            if np.x > @bottom_right.x
                @bottom_right.x = np.x
            end
            if np.y > @bottom_right.y
                @bottom_right.y = np.y
            end
            if np.z > @bottom_right.z
                @bottom_right.z = np.z
            end
        end
    end
    
    module Focusable
        def point
            @point ||= Little::Point.new
        end
        
        def x
            return point.x
        end
        
        def y
            return point.y
        end
        
        def z
            return point.z
        end
    end
    
    module Traceable
        def path
            @path ||= Little::Path.new
        end
    end
    
    module Typeable
        def font
            @font ||= Gosu::Font.new(12)
        end
    end
    
    # The shape just defines a rectangular bounds for an object.
    # The object is drawn at point and the amount of space it occupies
    # is defined by dimensions.
    class Shape
        include Little::Focusable
        
        HEAD_TOP_LEFT       = 0
        HEAD_TOP_RIGHT      = 1
        HEAD_BOTTOM_RIGHT   = 2
        HEAD_BOTTOM_LEFT    = 3
        FEET_TOP_LEFT       = 4
        FEET_TOP_RIGHT      = 5
        FEET_BOTTOM_RIGHT   = 6
        FEET_BOTTOM_LEFT    = 7
        
        # Width, height, depth
        attr_accessor   :dimensions
        attr_accessor   :angle
        attr_accessor   :rotation
        
        def initialize (x=0, y=0, z=0, w=0, h=0, d=0)
            @point = Little::Point.new(x,y,z)
            @dimensions = Little::Point.new(w,h,d)
            @angle = 90.0
            @rotation = 0.0
        end
        
        def width
            return @dimensions.x
        end
        def height
            return @dimensions.y
        end
        def depth
            return @dimensions.z
        end
        def dim?
            if @dimensions.z == 0
                return 2
            else
                return 3
            end
        end
        # The center of the 3D shape.
        def center
            Little::Point.new(@point.x + width/2, @point.y-height/2,
                    @point.z - depth/2)
        end
        # The center of the top/lid/head of the shape.
        def center_head
            Little::Point.new(@point.x + width/2, @point.y,
                    @point.z - depth/2)
        end
        # The center of the bottom/feet of the shape.
        def center_feet
            Little::Point.new(@point.x + width/2, @point.y-height,
                    @point.z - depth/2)
        end
        def inside? (*pt)
            if pt.size == 1
                nil
            elsif pt.size == 2
                nil
            end
        end
        # Points go clockwise, from top to bottom, from back top left
        def [](pt)
            if pt == HEAD_TOP_LEFT
                return @point.copy
            elsif pt == HEAD_TOP_RIGHT
                return Little::Point.new(@point.x + width, @point.y,
                        @point.z)
            elsif pt == HEAD_BOTTOM_RIGHT
                return Little::Point.new(@point.x + width, @point.y,
                        @point.z - depth)
            elsif pt == HEAD_BOTTOM_LEFT
                return Little::Point.new(@point.x, @point.y,
                        @point.z - depth)
            elsif pt == FEET_TOP_LEFT
                return Little::Point.new(@point.x, @point.y - height,
                        @point.z)
            elsif pt == FEET_TOP_RIGHT
                return Little::Point.new(@point.x + width,
                        @point.y - height,
                        @point.z)
            elsif pt == FEET_BOTTOM_RIGHT
                return Little::Point.new(@point.x + width,
                        @point.y - height,
                        @point.z - depth)
            elsif pt == FEET_BOTTOM_LEFT
                return Little::Point.new(@point.x, @point.y - height,
                        @point.z - depth)
            end
        end
    end
    module Shapeable
        def shape
            @shape ||= Little::Shape.new
        end
        
        def width
            shape.width
        end
        
        def height
            shape.height
        end
        
        def depth
            shape.depth        
        end
        
        def x
            shape.point.x
        end
        
        def y
            shape.point.y
        end
        
        def z
            shape.point.z
        end
    end
    
    class Graphics
        
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
            #$FRAME.log self, "end_group", "Order: #{order}==#{@order}"
            if @order == order
                @order = DEFAULT_ORDER
            end
        end
        # Uses the OpenGL method to draw the line. This has inconsistent
        # behavior but less buggy than line
        def line_ogl (point1, point2, options={})
            color = options[:color] ? options[:color] : Gosu::Color::WHITE
            ord = options[:order] ? options[:order] : @order
            p1 = point1
            p2 = point2
            set_default(options)
            if not options[:do_not_focus]
                p1 = @camera.translate(p1)
                p2 = @camera.translate(p2)
            end            
            Gosu::draw_line(p1.x,p1.y, color,
                p2.x,p2.y, color, ord)
        end
        # Creates a line between two points. Really buggy
        # Use the :to_img option to create an image of the line.
        # Saving the image rather than recreating it makes it non-buggy
        def line (point1, point2, options={})
            color = options[:color] ? options[:color] : Gosu::Color::WHITE
            ord = options[:order] ? options[:order] : @order
            path = Little::Path.new
            path.push(point1)
            path.push(point2)
            p = path.relative_to_top_left
            img = TexPlay::create_blank_image(@game, path.width, path.height)
            img.polyline p, :color => color
            center = path[0]
            if not options[:do_not_focus]
                center = @camera.translate(center)
            end
            if options[:to_img]
                return img
            end
            img.draw center.x, center.y, ord
        end
        # Draws a rectangle according to the provided options.
        # Needs at least a point, width and height.
        def rect (point, width, height, options={})
            color = options[:color] ? options[:color] : Gosu::Color::WHITE
            ord = options[:order] ? options[:order] : @order
            if not options[:do_not_focus]
                #print "into drawing rect \n"
                p = @camera.translate(p)
            end
            #$FRAME.log self, "rect", "Color: #{options[:color]}"
            Gosu::draw_rect(p.x,p.y,width,height,
                color,ord)
        end
        # Colors a single pixel.
        def pixel(point, options={})
            color = options[:color] ? options[:color] : Gosu::Color::WHITE
            ord = options[:order] ? options[:order] : @order
            p = point
            set_default(options)
            #$FRAME.log self, "pixel", "Point 1 #{p.x}, #{p.y}"
            if not options[:do_not_focus]
                p = @camera.translate(p)
                #$FRAME.log self, "pixel", "Point 2 #{p.x}, #{p.y}"
            end
            img = TexPlay::create_image(@game, 1, 1, color: color )
            img.draw p.x, p.y, ord
        end
        # Colors a set of pixels.
        def pixels (points, options={})
            color = options[:color] ? options[:color] : Gosu::Color::WHITE
            ord = options[:order] ? options[:order] : @order
            p = points.relative_to_top_left
            img = nil
            if points.is_a? Little::Path
                img = TexPlay::create_image(@game, points.width, points.height)
            else
                img = TexPlay::create_image(@game, @camera.width, @camera.height)
            end
            img.paint do
                p.each do |i|
                    #$FRAME.log self, "each", "#{i}"
                    pixel i, color: color
                end
            end
            center = points[0]
            if not options[:do_not_focus]
                center = @camera.translate(center)
            end
            img.draw center.x,center.y, ord
        end
        # Draws points from a path object using TexPlay. This works better than line.
        def path(path, options={})
            color = options[:color] ? options[:color] : Gosu::Color::WHITE
            ord = options[:order] ? options[:order] : @order
            img = TexPlay::create_blank_image(@game, path.width, path.height)
            p = path.relative_to_top_left
            #$FRAME.log self, "path", "#{p.size}"
            img.paint do
                polyline p, color: color
            end
            if options[:to_img]
                return img
            end
            center = path.top_left
            if not options[:do_not_focus]
                center = @camera.translate(center)
            end
            img.draw center.x, center.y, ord
        end
        
        # Draws an image, rotate goes clockwise from north
        # WARNING: if you use the rotate option and have an angle transformation
        # set to the camera, it may not produce the result you are expecting.
        def image(image, point, options={})    # "relative rotation origin"
            color = options[:color] ? options[:color] : Gosu::Color::WHITE
            ord = point.z
            if not options[:do_not_use_z]
                ord = options[:order] ? options[:order] : @order
            end
            if options[:shape]
                d = ord/options[:shape].depth
                options[:scale] = Little::Point.new(d,d)
            end
            if not options[:scale]
                options[:scale] = Little::Point.new(1,1)
            end
            p = point
            #$FRAME.log self, "image", "Drawing at order #{options[:order]}"
            if not options[:do_not_focus]
                p = @camera.translate(point)
            end
            #$FRAME.log self, "image", "4(#{p})"
            if options[:rotate_angle]
                r = options[:rotate_center] ? options[:rotate_center] : Little::Point.new(0.5,0.5)
                #draw_rot(x, y, z, angle, center_x = 0.5, center_y = 0.5, scale_x = 1, scale_y = 1, color = 0xff_ffffff, mode = :default
                image.draw_rot(p.x,p.y, ord,
                    options[:rotate_angle],r.x,r.y,
                    options[:scale].x,options[:scale].y,
                    color)
            else
                image.draw(p.x,p.y,ord,options[:scale].x,options[:scale].y)
            end
        end
        
        def text (string, font, point, options={})
            set_default(options)
            p = point
            if not options[:do_not_focus]
                p = @camera.translate(point)
            end
            if options[:alignment]
               font.draw_rel(string, p.x, p.y, options[:order],
                    options[:alignment].x, options[:alignment].y,
                    options[:scale].x, options[:scale].y,
                    options[:color])
            else
                font.draw(string, p.x, p.y, options[:order],
                    options[:scale].x, options[:scale].y,
                    options[:color])
            end
        end
        
        # These functions provide default values for the graphics object.
        # So the user (and I) don't have to provide all the things
        def default_options
            return {
                color:          Gosu::Color::WHITE,
                do_not_focus:   false,
                alignment:      nil,
                scale:          Little::Point.new(1,1,1),
                rotate_angle:   0,
                rotate_center:  Little::Point.new(0.5,0.5),
                order:          @order,
                to_img:         false,
                do_not_use_z:   false,
                shape:          nil
            }
        end
        
        private
        def set_default (opt)
            dopt = default_options
            keys = dopt.keys
            keys.each do |k|
                if not opt[k]
                    opt[k] = dopt[k]
                end
            end
            opt[:order] = @order
            #$FRAME.log self, "set_default", "Order: #{opt[:order]}"
        end

    end
    
    # Keeps the graphics object focused on a particular game object,
    # that is kept at the center of the game window,
    # so long as the object includes the Focusable module, or responds
    # to point and point.x and point.y
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
            #$FRAME.log self, "translate", "1(#{point})"
            if @focus and @focus.point and not @focus.remove
                #focus is at the center
                offset = @focus.point.get_center_offset(@width, @height)
                #print "2(#{offset.x},#{offset.y})\n"
            else
                offset = Little::Point.new
            end
            #$FRAME.log self, "translate", "2(#{offset})"
            #p = point.clone #don't change the original
            #print "3(#{p.x-offset.x},#{p.y})\n"
            p = point.subtract(offset)
            #$FRAME.log self, "translate", "3(#{p})"
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
