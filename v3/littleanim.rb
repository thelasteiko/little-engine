=begin
The next step is to add pictures for animations.

At this point as far as I can tell you need an FXImage
object of some kind to paint it on the canvas. And
then use dc.drawImage([image object], x, y)

Use FXMemoryStream to load the data then construct
an FXImage using it?
I need to know how to open files in Ruby.

Strategy:
  load images for a scene when the scene loads
  attach images and animations to objects
  have the animation object draw the images
=end

#!/usr/bin/env ruby

require 'fox16'
include Fox

class Animation
  def initialize (filename, frames, width, height, duration,
      x=0, y=0, iwidth=0, iheight=0)
    @filename = filename
    @frames = frames
    @width = width
    @height = height
    @duration = duration
    @x = x
    @y = y
    @iw = iwidth
    @ih = iheight
    @ms_per_frame = duration / frames
    @images = []
    @current = 0
    @elapsedtime = 0
  end
  def load (app)
    app.beginWaitCursor do
      FXFileStream.open(@filename, FXStreamLoad) do |stream|
        for i in 0...@frames
          @images[i] = FXPNGImage.new(app, nil, IMAGE_KEEP|IMAGE_SHMI|IMAGE_SHMP)
          @images[i].loadPixels(stream)
          @images[i].create
          if @iw == 0 || @ih == 0
            @iw = @images[i].width
            @ih = @images[i].height
          end
          #x,y,w,h
          @images[i].crop(@width*i % @iw,
            @height*i % @ih, @width, @height)
        end
      end
    end
  end
  def finished?
    @elapsedtime >= @duration
  end
  def reset
    @elapsedtime = 0
    @current = 0
  end
  def play (tick)
    return if @finished?
    @elapsedtime += tick
    if @elapsedtime < (@current + 1) * @ms_per_frame
      return @images[@current]
    end
    @current += 1
    return @images[@current]
  end
  def loop (tick)
    if finished?
      reset
    end
    play(tick)
  end
end