#!/usr/bin/env ruby

require 'fox16'
include Fox

# Loads a spritesheet into a series of images and manages
# the progression for playback.
class Animation
  # @!attribute [rw] duration
  #   @return [Float]
  attr_accessor :duration
  # Creates an Animation object. The last argument are optional variables
  # that can be passed in.
  # @param  filename  [String]  is the filename of the spritesheet.
  # @param  frames    [Fixnum]  is the number of frames in the spritesheet.
  # @param  width     [Fixnum]  is the width of each frame in pixels.
  # @param  height    [Fixnum]  is the height of each frame in pixels.
  # @param  duration  [Float]   is how long the animation should last before
  #                             ending or looping.
  # @param  options   [Hash]    A list of optional arguments listed below.
  # @param  still_frame [Fixnum] is the number (starting at 0) for the frame
  #                              to show when the animation is paused.
  # @param  x         [Fixnum]  is where the starting x for the animation
  #                             is on the spritesheet.
  # @param  y         [Fixnum]  is where the starting y for the animation
  #                             is on the spritesheet.
  # @param image_width [Fixnum]  is the total width of the frames if it is
  #                             smaller than the width of the image.
  # @param image_height [Fixnum]  is the total height of the frames if it is
  #                             smaller than the height of the image.
  def initialize (filename, frames, width, height, duration, options = {})
    #x=0, y=0, iwidth=0, iheight=0, still_frame = -1
    @filename = filename
    @frames = frames
    @width = width
    @height = height
    @duration = duration
    @x = options[:x]
    @y = options[:y]
    @iw = options[:image_width]
    @ih = options[:image_height]
    @ms_per_frame = duration / frames
    @images = []
    @current = 0
    @elapsedtime = 0.0
    @frametime = 0.0
    @reverse = false
    @still_frame = options[:still_frame]
  end
  # Loads the image data into the buffer.
  # @param app  [FXApp] is the application that will be using
  #                     this animation object.
  def load (app)
    y = @y ? @y : 0
    for i in 0...@frames
      @images[i] = FXPNGImage.new(app, nil, IMAGE_KEEP|IMAGE_SHMI|IMAGE_SHMP)
      app.beginWaitCursor do
        FXFileStream.open(@filename, FXStreamLoad) do |stream|
          @images[i].loadPixels(stream)
          @images[i].create
        end
      end
      if not @iw
        @iw = @images[i].width
      end
      if not @ih
        @ih = @images[i].height
      end
      #x,y,w,h
      x = @x ? @x : 0
      x += @width*i % @iw
      y = (x == 0 && i > 0) ? y+@height : y
      w = @width
      h = @height
      #puts ("{x:" + x.to_s + ",y:" + y.to_s + ",w:" + w.to_s + ",h:" + h.to_s + "}")
      @images[i].crop(x,y,w,h)
    end
  end
  # Determines if the animation has finished.
  # @return   true if the elapsed time is greater or equal to
  #           the desired duration, false otherwise.
  def finished?
    @elapsedtime >= @duration
  end
  # Resets the animation so it will play again.
  def reset
    @elapsedtime = 0.0
    @current = 0
  end
  # Plays the animation once.
  # @param  tick  [Float] is the milliseconds since the last time
  #                       the game loop ran.
  # @return [FXPNGImage] the next image in the sequence.
  def play (tick)
    if finished?
      return @images[@frames-1]
    end
    @elapsedtime += tick
    @frametime += tick
    if @frametime < @ms_per_frame
      return @images[@current]
    end
    @frametime = 0.0
    @current += 1
    return @images[@current]
  end
  # Plays the animation once in reverse sequence.
  # @param  tick  [Float] is the milliseconds since the last time
  #                       the game loop ran.
  # @return [FXPNGImage] the next image in the sequence.
  def play_reverse (tick)
    if finished?
      return @images[0]
    end
    @elapsedtime += tick
    @frametime += tick
    if @frametime < @ms_per_frame
      return @images[@frames-@current-1]
    end
    @frametime = 0.0
    @current += 1
    return @images[@frames-@current-1]
  end
  # Loops the animation.
  # @param  tick  [Float] is the milliseconds since the last time
  #                       the game loop ran.
  # @return [FXPNGImage] the next image in the sequence.
  def loop (tick)
    if finished?
      reset
    end
    play(tick)
  end
  # Loops the animation by iterating through the buffer
  # forwards and then backwards. (ie. 0 1 2 1 0)
  # @param  tick  [Float] is the milliseconds since the last time
  #                       the game loop ran.
  # @return [FXPNGImage] the next image in the sequence.
  def loop_around (tick)
    if finished?
      @elapsedtime = 0.0
    end
    @elapsedtime += tick
    @frametime += tick
    if @frametime < @ms_per_frame
      return @images[@current]
    end
    if @reverse
      if @current == 0
        @reverse = !@reverse
        @current += 1
      else
        @current -= 1
      end
    else
      if @current == @frames-1
        @reverse = !@reverse
        @current -= 1
      else
        @current += 1
      end
    end
    @frametime = 0.0
    return @images[@current]
  end
  # Pauses the animation or shows a designated still frame.
  # @param  tick  [Float] is the milliseconds since the last time
  #                       the game loop ran.
  # @return [FXPNGImage] the current image or the still frame.
  def pause (tick)
    if @still_frame
      return @images[@still_frame]
    end
    @frametime += tick
    return @images[@current]
  end
  def to_s
    "{i:" + @current.to_s + ",R:" + @reverse.to_s + ",et:" + @elapsedtime.to_s +
        ",d:" + @duration.to_s + ",ms:" + @ms_per_frame.to_s + "}"
  end
end