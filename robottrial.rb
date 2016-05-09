=begin
This will be a robot simulator to test certain algorithms.

I will need:
  map data structure
  robot
    sensors: gets state from map
    motors
    robot body
      slots for sensors and motors
    output state
  interface
    current state
    buttons to go to different operations
  
I will use threads for:
  sensors
  motor control
  output state
  interface
  
On the interface:
  scenes
    build
    edit layout
    run

How to represent orientation?
  keep the layout flat in one cardinal direction
  degrees from north?
How should I rotate?
  The objects will be squares probably
  rotate the x,y points and draw a polygon

Shape object
  rotational
  selectable
  drag and drop
  parent-child
=end

class RotationRectangle
  #do I need FXPoint?
  def initialize (x, y, w, h, degree)
  #constructs four initial points for a rectangle
  #degree is the degree of rotation from cardinal north, clockwise
    @degree = degree
    @w = w
    @h = h
    move(x,y)
  end
  #looks like the offset is about 2/3 of the angle
  def getPoints
  #this should return the points offset by the degree
    pts = []
    offset = @degree * 0.6
    for i in 0...4
      current = @points[i]
      p = FXPoint.new(current.x + offset, current.y + offset)
      pts.push(p)
    end
    return pts
  end
  def move(x, y)
  #this moves the original points
    @points = [FXPoint.new(x,y), FXPoint.new(x+@w,y),
      FXPoint.new(x+@w,y-@h), FXPoint.new(x,y-@h)]
  end
end

class MovementUtil
  def self.rotate (shape)
    return nil if not shape.x
    return nil if not shape.y
    if shape.type is :rectangle
      
    end
  end
  def self.dnd
  end
  def self.select
  end
end

class Sensor
  def initialize (type)
    @type = type
  end
end
class Robot
  def initialize (sensors, motors)
  #The sensors provide data to the robot.
  #The motors drive the robot in different directions
  #depending on the orientation and speed.
    @sensors = sensors
    @motors = motors
  end

end