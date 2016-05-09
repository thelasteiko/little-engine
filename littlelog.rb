module LittleEngine
#Add log file and performance statistics
#for debug mode.

$STATFILE = "log/stat0507.csv"

class Logger
  attr_reader   :statlist
  attr_reader   :logfile
  attr_reader   :date
  attr_reader   :time
  def initialize
    time = Time.now
    @date = "#{time.year}#{time.month}#{time.day}"
    hour = time.hour < 10 ? "0"+time.hour : time.hour
    min = time.min < 10 ? "0"+time.min : time.min
    sec = time.sec < 10 ? "0"+time.sec : time.sec
    @time = "#{hour}#{min}#{sec}"
    @startime = time.to_f
    @logfile = "Log#{@date}#{@time}.txt"
    open(@logfile, 'w') do |f|
      f.puts "#{time}"
    end
    @statlist = {
      date:@date, runs:0, runtime:0, timeperrun:0}
  end
  def logtofile(sender, method="", note="")
    if sender
      time = Time.now
      hour = time.hour < 10 ? "0"+time.hour : time.hour
      min = time.min < 10 ? "0"+time.min : time.min
      sec = time.sec < 10 ? "0"+time.sec : time.sec
      run = time.to_f-@startime
      line = "#{time.hour}:#{time.min}:#{time.sec}:"+
        "#{run}: #{sender.class.name}.#{method}: "+
        "#{note}"
      open(@logfile, 'a') do |f|
        f.puts line
      end
    end
  end
  def start(stat)
    @statlist = {} if not @statlist
    @statlist[stat] = 0
  end
  def set(stat, value)
    @statlist = {} if not @statlist
    @statlist[stat] = value
  end
  def inc(stat)
    set(stat) if not @statlist
    @statlist[stat] += 1
  end
  def self.create
    
  end
  def save
  #format of args {"stat"=>"value"}
    return if not @statlist
    @statlist[:timeperrun] = @statlist[:runtime] / @statlist[:runs]
    if not File.file?($STATFILE)
      File.open($STATFILE, 'w') do |f|
        f.write("DATE,RUNS,RUN TIME,TIME PER RUN")
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
end