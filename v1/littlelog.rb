#The file to which statistics will be saved.
$STATFILE = "log/stat201605.csv"
#The list of statistics that will be saved.
$STAT_LIST = [:date, :run, :runtime, :timeperrun]
#Add log file and performance statistics
#for debug mode.
#@author Melinda Robertson
class LittleLogger
  attr_reader   :statlist
  attr_reader   :logfile
  attr_reader   :date
  attr_reader   :time
  #Creates a new logger that saves the time of creation.
  def initialize
    @time = Time.now
    @date = "#{time.year}#{time.month}#{time.day}"
    hour = time.hour < 10 ? "0"+time.hour.to_s : time.hour
    min = time.min < 10 ? "0"+time.min.to_s : time.min
    sec = time.sec < 10 ? "0"+time.sec.to_s : time.sec
    strtime = "#{hour}#{min}#{sec}"
    #@startime = time.to_f
    @logfile = "Log#{@date}#{strtime}.txt"
    open(@logfile, 'w') do |f|
      f.puts "#{time}"
    end
    @statlist = Hash.new
    $STAT_LIST.each {|i| @statlist[i] = 0}
  end
  #Logs a comment to the file.
  #@param sender [Class] the class requesting the log.
  #@param method [String] should be the name of the method that
  #                       made the call.
  #@param note [String] is the message to record in the log file.
  def logtofile(sender, method="", note="")
    if sender
      time = Time.now
      hour = time.hour < 10 ? "0"+time.hour.to_s : time.hour
      min = time.min < 10 ? "0"+time.min.to_s : time.min
      sec = time.sec < 10 ? "0"+time.sec.to_s : time.sec
      run = time-@time
      line = "#{hour}:#{min}:#{sec}:"+
        "#{run}: #{sender.class.name}.#{method}: "+
        "#{note}"
      open(@logfile, 'a') do |f|
        f.puts line
      end
    end
  end
  #Adds a numerical statistic to the list, initialized to 0.
  #@param stat [Symbol] the statistic type to add.
  def start(stat)
    @statlist = {} if not @statlist
    @statlist[stat] = 0
  end
  #Sets the value of a statistic.
  #@param stat [Symbol] the statistic type.
  #@param value [Numerical] the value of the statistic.
  def set(stat, value)
    @statlist = {} if not @statlist
    @statlist[stat] = value
  end
  #Increment the indicated numerical statistic.
  #@param stat [Symbol] the statictic type.
  def inc(stat)
    set(stat) if not @statlist
    @statlist[stat] += 1
  end
  #Saves the list of statistics to a file.
  def save
  #format of args {"stat"=>"value"}
    return if not @statlist
    @statlist[:runtime] = (Time.now - @time).to_f
    @statlist[:timeperrun] = @statlist[:runtime] / @statlist[:runs]
    if not File.file?($STATFILE)
      File.open($STATFILE, 'w') do |f|
        $STAT_LIST.each do |i|
          f.write(i.to_s)
          f.write(",")
        end
        f.write("\n")
      end
    end
    File.open($STATFILE, 'a') do |f|
      @statlist.each_pair do |k,v|
        f.write(v)
        f.write(',')
      end
      f.write('\n')
    end
  end
end