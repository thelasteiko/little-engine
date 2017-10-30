#!/usr/bin/env ruby

# Little is a small and unassuming game engine based on Gosu.
# All rights go to the Gosu people for the Gosu code.
#
# @author      Melinda Robertson
# @copyright   Copyright (c) 2017 Little, LLC
# @license     GNU



# Something to read configurations for the game engine.

module Little
  # Loads a configuration file into memory.
  # File contents should be formatted as such:
  # [Section]
  # key=value
  class Settings
    # Calls load on initialization.
    def initialize(filename)
      @filename = filename
      @sections = {default: Hash.new}
      @current_section = :default
      load
    end
    # Opens the file and reads the contents into memory.
    def load
      file = File.open(@filename,'r')
      current_s = :default
      file.each do |line|
        if line ~= /^\[\w+\]/
          # we have a section
          s = line.delete('[]').to_sym
          if not @sections[s]
            @sections[s] = Hash.new
          end
          current_s = s
        elsif line ~= /^\w+=.+/
          # we have a key, value pair
          i = line.index('=')
          k = line[0...i].strip
          i2 = line.length - i - 1
          v = line[-i2..-1].strip
          @sections[current_s][k.to_sym] = v
        elsif line.empty?
          current_s = :default
        end
      end
    end
    def start(section)
      @current_section = section
    end
    
    def get_str(key)
      if @sections[@current_section] and @sections[@current_section][key]
        return @sections[@current_section][key]
      end
      return false #should be ok cause value is always string
    end
    
    def get_bool(key)
      str = get_str(key)
      return true if str == "true"
      return true if str == "1"
      return true if str == "yes"
      return false
    end
    
    def get_int(key)
      str = get_str(key)
      return str.to_i
    end
    
    def get_float(key)
      str = get_str(key)
      return str.to_f
    end
    
    def get_ary(key)
      str = get_str(key)
      #try split by different delimiters
      ary = str.split #space
      return ary if ary.length > 1
      ary = str.split(',')
      return ary if ary.length > 1
      ary = str.split(';')
      return ary if ary.length > 1
      ary = str.split('\t')
      return ary if ary.length > 1
      return false
    end
    
    def end
      @current_section = :default
    end
  end
end

# Set global variables here
settings = Little::Settings.new("game.conf")
#Set this to true to display the debug information.
$DEBUG = settings.get_bool(:debug)
#Set this to true to show verbose debug info
$VERBOSE = settings.get_bool(:verbose)
#Set this to true to display FPS and tick.
$SHOW_FPS = settings.get_bool(:show_fps)

# Additional scripts.
$LOG = settings.get_bool(:log)
$INPUT = settings.get_bool(:input)
$GRAPHICS = settings.get_bool(:graphics)
$AUDIO = settings.get_bool(:audio)
$DATABASE = settings.get_bool(:database)

# Prints an error and closes the application if the error is critical.
#
# @param +exception+ - The exception thrown.
# @param +explicit+  - True means a particular and expected exception was thrown.
#                   False means an exception was thrown but we don't know
#                   what kind.
# @param +critical+  - The program won't continue if this is true.
def print_exception(exception, explicit, critical=false)
    puts "[#{explicit ? 'EXPLICIT' : 'INEXPLICIT'}] #{exception.class}: #{exception.message}"
    puts exception.backtrace.join("\n")
    if critical
        abort("Critical exception, exiting.\n")
    else
        puts "Non-critical, continuing..."
    end
end

# Adds various scripts.
begin
    # Logs messages and performance to a file.
    if $LOG
        require_relative 'v1/littlelog'
    end
    # Handles user input and events
    if $INPUT
        require_relative 'v1/littleinput'
    end
    # Draws things on the canvas
    if $GRAPHICS
        require_relative 'v1/littlegraphics'
    end
    # Helper modules and methods for audio
    if $AUDIO
        require_relative 'v1/littleaudio'
    end
    # Handles saving and loading game data
    if $DATABASE
      require_relative 'v2/littledb'
    end
rescue LoadError => e
    print_exception(e, true)
rescue Exception => e
    print_exception(e, false)
end
