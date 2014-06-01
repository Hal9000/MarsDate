require 'date'

class MarsDateTime

  VERSION = "1.0.8"

  include Comparable

  MSEC_PER_SOL   = 88775244
  SOLS_PER_MYEAR = 668.5921
  MSEC_PER_DAY   = 86400000

  FAKE_MSEC_PER_MYEAR = (668*MSEC_PER_SOL)

  TimeStretch    = MSEC_PER_SOL/MSEC_PER_DAY.to_f

  Months = %w[ UNDEFINED
               January   Gemini      February Cancer
               March     Leo         April    Virgo 
               May       Libra       June     Scorpio 
               July      Sagittarius August   Capricorn 
               September Aquarius    October  Pisces 
               November  Aries       December Taurus ]   
               # no month 0

  Week   = %w[ Sunday Monday Tuesday Wednesday Thursday Friday Saturday ]

  EpochMCE  = DateTime.new(1,1,21)
  EpochCE   = DateTime.new(1,1,1)
  FudgeOffset = 67784 + 44000 + 1099 + 87 - 56
  JulianDay1 = 1721443  # was ...24

  attr_reader :year, :month, :sol, :epoch_sol, :year_sol
  attr_reader :shr, :smin, :ssec    # stretched time
  attr_reader :mems

  attr_reader :dow, :day_of_week
  attr_reader :mhrs, :mmin, :msec

  alias myear year
  alias hr   mhrs
  alias min  mmin
  alias sec  msec

  def self.leap?(myear)    # class method for convenience
    return (myear % 2 == 1) if (myear % 10 != 0)
    return true if (myear % 1000 == 0)
    return false if (myear % 100 == 0)
    return true
  end

  def self.sols_in_month(m, year)
    return 28 if m < 24
    return 25 if leap?(year)
    return 24
  end

  def self.now
    d = DateTime.now
    MarsDateTime.new(d)
  end

  def self.today
    d = DateTime.now
    MarsDateTime.new(d)
  end

  def leaps(myr)
    n = 0
    1.upto(myr) {|i| n+=1 if leap?(i) } 
    n
  end

  def to_yaml_properties
    %w[@myear @month @sol @epoch_sol @year_sol @dow @day_of_week @msme @mhrs @mmin @msec]
  end

  def inspect
    time = ('%02d' % @mhrs) + ":" + ('%02d' % @mmin) + ":" + ('%02d' % @msec)
    "#@year/#{'%02d' % @month}/#{'%02d' % @sol} " + 
    "(#@year_sol, #@epoch_sol) #@day_of_week " +
    time
  end

  def to_s
    time = self.strftime('%H:%M:%S [%P:%Q:%R]')
    "#@day_of_week, #{Months[@month]} #@sol, #@year at #{time}"
  end

  def leap?(myear)
    MarsDateTime.leap?(myear)    # DRY
  end

  def month_name
    Months[@month]
  end

  ###########

  def initialize(*params)
    n = params.size
    case n
      when 3..6
        init_yms(*params)
      when 0
        init_datetime(DateTime.now)
      when 1
        case params.first
          when Integer, Float
            init_mems(params.first)
          when DateTime
            init_datetime(params.first)
        else
          raise "Expected number or DateTime" 
        end
      else
        raise "Bad params: #{params.inspect}"
    end
    compute_stretched
  end

  def check_ymshms(my, mm, msol, mhr=0, mmin=0, msec=0)
    text = ""
    text << "year #{my} is not an integer\n" unless my.is_a? Fixnum
    text << "month #{mm} is out of range" unless (1..24).include? mm
    text << "sol #{msol} is out of range" unless (1..28).include? msol
    text << "hour #{mhr} is out of range" unless (0..24).include? mhr
    text << "minute #{mmin} is out of range" unless (0..59).include? mmin
    text << "second #{msec} is out of range" unless (0..59).include? msec
    if !leap?(my) && mm == 24 && msol > 24
      text << "sol #{msol} is invalid in a non-leap year" 
    end
    raise text unless text.empty?
  end

  def init_yms(my, mm, msol, mhr=0, mmin=0, msec=0)
    check_ymshms(my, mm, msol, mhr, mmin, msec)
    zsol = msol - 1  # z means zero-based
    zmy  = my - 1    # my means Martian year
    zesol = zmy*668 + leaps(my-1) + (mm-1)*28 + zsol
#   @mems is "Martian (time since) epoch in milliseconds"
    @mems = zesol*MSEC_PER_SOL + (mhr*3600 + mmin*60 + msec)*1000
    @year, @month, @sol, @mhrs, @mmin, @msec = my, mm, msol, mhr, mmin, msec
    @epoch_sol = zesol + 1
    @dow = (@epoch_sol-1) % 7
    @day_of_week = Week[@dow]
    @year_sol  = (mm-1)*28 + msol
  end

  def compute_stretched
    # Handle stretched time...
    sec = @mhrs*3600 + @mmin*60 + @msec
    sec /= TimeStretch
    @shr,  sec = sec.divmod(3600)
    @smin, sec = sec.divmod(60)
    @ssec = sec.round
  end

  def init_mems(mems)
    full_years = 0
    loop do
      millisec = FAKE_MSEC_PER_MYEAR
      millisec += MSEC_PER_SOL if leap?(full_years+1)
      break if mems < millisec
      mems -= millisec
      # puts "Subtracting #{millisec} -- one full year => #{mems}"
      full_years += 1
    end

    mspm = MSEC_PER_SOL*28
    full_months,mems = mems.divmod(mspm)
    full_days, mems  = mems.divmod(MSEC_PER_SOL)
    full_hrs, mems   = mems.divmod(3_600_000)
    full_min, mems   = mems.divmod(60_000)
    sec = mems/1000.0

    my = full_years + 1      # 1-based
    mm = full_months + 1
    ms = full_days + 1
    mhr = full_hrs           # 0-based
    mmin = full_min
    msec = sec.to_i
    frac = sec - msec        # fraction of a sec

#    # check for leap year...
#    if mm == 24
#      max = leap?(my) ? 25 : 24
#      diff = ms - max
#      if diff > 0
#        my, mm, ms = my+1, 1, diff
#      end
#    end

    init_yms(my, mm, ms, mhr, mmin, msec)
  end

  def init_datetime(dt)
    days = dt.jd - JulianDay1
    secs = days*86400 + dt.hour*3600 + dt.min*60 + dt.sec
    secs -= FudgeOffset
    init_mems(secs*1000)
  end

  def ymshms
    [@year, @month, @sol, @mhrs, @mmin, @msec]
  end

  def -(other)
    case other
      when MarsDateTime
        diff = @mems - other.mems
        diff.to_f / MSEC_PER_SOL
      when DateTime
        other = MarsDateTime.new(other)
        diff = @mems - other.mems
        diff.to_f / MSEC_PER_SOL
      when Fixnum, Float
        self + (-other)
    else
      raise "Unexpected data type"
    end
  end

  def +(sols)
    millisec = sols * MSEC_PER_SOL
    MarsDateTime.new(@mems + millisec)
  end

  def <=>(other)
    case other
      when MarsDateTime
        @mems <=> other.mems
      when DateTime
        @mems <=> MarsDateTime.new(other).mems
    else
      raise "Invalid comparison"
    end
  end

  def earth_date
    secs = @mems/1000 + FudgeOffset
    days,secs = secs.divmod(86400)
    hrs, secs = secs.divmod(3600)
    min, secs = secs.divmod(60)
    jday = days + JulianDay1
    DateTime.jd(jday, hrs, min, secs)
  end

  def strftime(fmt)
    str = fmt.dup
    pieces = str.scan(/(%.|[^%]+)/).flatten
    final = ""
    zmonth = '%02d' % @month
    zsol = '%02d' % @sol
    zhh = '%02d' % @mhrs  # stretched
    zmm = '%02d' % @mmin
    zss = '%02d' % @msec
    zhc = '%02d' % @shr   # canonical
    zmc = '%02d' % @smin
    zsc = '%02d' % @ssec
   
    pieces.each do |piece|
      case piece
        when "%a"; final << @day_of_week[0..2]
        when "%A"; final << @day_of_week
        when "%b"; final << month_name[0..2]
        when "%B"; final << month_name
        when "%d"; final << zsol
        when "%e"; final << ('%2d' % @sol)
        when "%F"; final << "#@year-#@month-#@sol"
        when "%H"; final << zhh
        when "%j"; final << @year_sol.to_s
        when "%m"; final << @month.to_s
        when "%M"; final << zmm
        when "%s"; final << @msec.to_s  # was: (@mems*1000).to_i.to_s
        when "%S"; final << zss
        when "%u"; final << (@dow + 1).to_s
        when "%U"; final << (@year_sol/7 + 1).to_s
        when "%w"; final << @dow.to_s
        when "%x"; final << "#@year/#{zmonth}/#{zsol}"
        when "%X"; final << "#{zhh}:#{zmm}:#{zss}"
        when "%Y"; final << @year.to_s
        when "%n"; final << "\n"
        when "%t"; final << "\t"
        when "%%"; final << "%"
        when "%P"; final << ("%02d" % @shr)
        when "%Q"; final << ("%02d" % @smin)
        when "%R"; final << ("%02d" % @ssec)
        else
          final << piece
      end
    end
    final
  end
  
=begin
    *  %I - Hour of the day, 12-hour clock (01..12)
    *  %p - Meridian indicator (``AM''  or  ``PM'')
       %U - Week  number  of the current year,
               starting with the first Sunday as the first
               day of the first week (00..53)
       %W - Week  number  of the current year,
               starting with the first Monday as the first
               day of the first week (00..53)
    *  %y - Year without a century (00..99)
       %Z - Time zone name

=end

end

if $0 == __FILE__
  puts MarsDateTime::VERSION
end
