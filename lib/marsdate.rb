require 'date'
require 'json'
require_relative 'marsdate/timescale'
require_relative 'marsdate/calendar'

class MarsDateTime

  VERSION = "2.0.0"

  include Comparable

  Months = %w[ UNDEFINED
               M-January   Gemini      M-February Cancer
               M-March     Leo         M-April    Virgo
               M-May       Libra       M-June     Scorpio
               M-July      Sagittarius M-August   Capricorn
               M-September Aquarius    M-October  Pisces
               M-November  Aries       M-December Taurus ]
               # no month 0

  Week = %w[ Sunday Monday Tuesday Wednesday Thursday Friday Saturday ]

  EPOCH_MSD = Calendar::EPOCH_MSD
  SOL_DAYS = TimeScale::SOL_DAYS
  SOL_SI_SECONDS = TimeScale::SOL_SI_SECONDS
  SOLS_PER_MYEAR = Calendar::MEAN_YEAR

  attr_reader :msd
  attr_reader :year, :month, :sol, :epoch_sol, :year_sol
  attr_reader :dow, :day_of_week
  attr_reader :mtc_hour, :mtc_min, :mtc_sec
  attr_reader :mxt_hour, :mxt_min, :mxt_sec

  alias myear year
  alias day  sol

  def self.leap?(myear)
    Calendar.leap?(myear)
  end

  def self.short?(myear)
    !leap?(myear)
  end

  def self.long?(myear)
    leap?(myear)
  end

  def self.sols_in_month(m, year)
    Calendar.sols_in_month(m, year)
  end

  def self.from_msd(msd)
    obj = allocate
    obj.send(:init_from_msd, msd)
    obj
  end

  def self.now
    new(DateTime.now)
  end

  def self.today
    new(Date.today)
  end

  def self.from_json(str)
    hash = JSON.parse(str)
    msd = hash['msd'] || hash[:msd]
    raise ArgumentError, 'JSON must include msd' if msd.nil?
    from_msd(msd)
  end

  def initialize(*params, clock: :mxt)
    n = params.size
    case n
    when 3..6
      init_yms(*params, clock: clock)
    when 0
      init_from_msd(TimeScale.msd(DateTime.now))
    when 1
      case params.first
      when Integer, Float
        init_from_msd(params.first)
      when Date, DateTime
        init_from_msd(TimeScale.msd(params.first))
      else
        raise ArgumentError, "Expected MSD, Date, or DateTime (got #{params.first.class})"
      end
    else
      raise ArgumentError, "Bad params: #{params.inspect}"
    end
  end

  def as_json(_options = {})
    { msd: @msd,
      year: @year,
      month: @month,
      sol: @sol,
      epoch_sol: @epoch_sol,
      year_sol: @year_sol,
      dow: @dow,
      day_of_week: @day_of_week,
      mtc: format_mtc,
      mxt: format_mxt }
  end

  def to_json(*options)
    as_json.to_json(*options)
  end

  def to_yaml_properties
    %w[@msd]
  end

  def inspect
    format('%d/%02d/%02d (%d, %d) %s MXT %s MTC %s MSD %.8f',
           @year, @month, @sol, @year_sol, @epoch_sol, @day_of_week,
           format_mxt, format_mtc, @msd)
  end

  def to_s
    "#{@day_of_week}, #{month_name} #{@sol}, #{@year} at MXT #{format_mxt} / MTC #{format_mtc}"
  end

  def format_mtc
    TimeScale.format_hms(@mtc_hour, @mtc_min, @mtc_sec)
  end

  def format_mxt
    TimeScale.format_hms(@mxt_hour, @mxt_min, @mxt_sec)
  end

  def leap?
    MarsDateTime.leap?(@year)
  end

  def short?
    !leap?
  end

  def long?
    leap?
  end

  def month_name
    Months[@month]
  end

  def ymshms
    [@year, @month, @sol, @mxt_hour, @mxt_min, @mxt_sec.to_i]
  end

  def -(other)
    case other
    when MarsDateTime
      @msd - other.msd
    when Date, DateTime
      @msd - MarsDateTime.new(other).msd
    when Integer, Float
      self + (-other)
    else
      raise ArgumentError, "Unexpected data type #{other.class}"
    end
  end

  def +(sols)
    MarsDateTime.from_msd(@msd + sols.to_f)
  end

  def <=>(other)
    case other
    when MarsDateTime
      @msd <=> other.msd
    when Date, DateTime
      @msd <=> MarsDateTime.new(other).msd
    else
      raise ArgumentError, "Invalid comparison with #{other.class}"
    end
  end

  def earth_date
    TimeScale.earth_from_msd(@msd)
  end

  def strftime(fmt)
    str = fmt.dup
    pieces = str.scan(/(%.|[^%]+)/).flatten
    final = ''
    zmonth = '%02d' % @month
    zsol = '%02d' % @sol
    zhh = '%02d' % @mtc_hour
    zmm = '%02d' % @mtc_min
    zss = '%02d' % @mtc_sec.to_i
    zhc = '%02d' % @mxt_hour
    zmc = '%02d' % @mxt_min
    zsc = '%02d' % @mxt_sec.to_i

    pieces.each do |piece|
      case piece
      when '%a'; final << @day_of_week[0..2]
      when '%A'; final << @day_of_week
      when '%b'; final << (@month.odd? ? month_name[2..4] : month_name[0..2])
      when '%B'; final << month_name
      when '%d'; final << zsol
      when '%e'; final << ('%2d' % @sol)
      when '%F'; final << "#{@year}-#{zmonth}-#{zsol}"
      when '%H'; final << zhh
      when '%j'; final << @year_sol.to_s
      when '%m'; final << zmonth
      when '%M'; final << zmm
      when '%s'; final << @mtc_sec.to_i.to_s
      when '%S'; final << zss
      when '%u'; final << (@dow + 1).to_s
      when '%U'; final << (@year_sol / 7 + 1).to_s
      when '%w'; final << @dow.to_s
      when '%x'; final << "#{@year}/#{zmonth}/#{zsol}"
      when '%X'; final << "#{zhh}:#{zmm}:#{zss}"
      when '%Y'; final << @year.to_s
      when '%n'; final << "\n"
      when '%t'; final << "\t"
      when '%%'; final << '%'
      when '%P'; final << zhc
      when '%Q'; final << zmc
      when '%R'; final << zsc
      else
        final << piece
      end
    end
    final
  end

  private

  def init_yms(my, mm, msol, mhr = 0, mmin = 0, msec = 0, clock: :mxt)
    Calendar.check_ymd!(my, mm, msol)
    check_hms!(mhr, mmin, msec, clock)
    frac = frac_from_hms(mhr, mmin, msec, clock)
    init_from_msd(Calendar.msd_at(my, mm, msol, frac))
  end

  def init_from_msd(msd)
    @msd = msd.to_f
    index = @msd.floor - EPOCH_MSD
    if index < 0
      raise ArgumentError, "MSD #{@msd} is before MCE 1/1/1 (EPOCH_MSD=#{EPOCH_MSD})"
    end
    @year, @month, @sol = Calendar.ymd_from_msd(@msd)
    @epoch_sol = Calendar.sol_index(@year, @month, @sol) + 1
    @year_sol = (@month - 1) * 28 + @sol
    @dow = Calendar.dow(@year, @month, @sol)
    @day_of_week = Week[@dow]
    frac = TimeScale.sol_fraction_of(@msd)
    @mtc_hour, @mtc_min, @mtc_sec = TimeScale.hours_to_hms(frac * 24.0)
    @mxt_hour, @mxt_min, @mxt_sec = TimeScale.hours_to_hms(
      frac * SOL_SI_SECONDS / 3600.0
    )
  end

  def check_hms!(h, min, sec, clock)
    unless h.is_a?(Numeric) && min.is_a?(Numeric) && sec.is_a?(Numeric)
      raise ArgumentError, 'hour/minute/second must be numeric'
    end
    unless min >= 0 && min < 60 && sec >= 0 && sec < 60
      raise ArgumentError, "minute/second out of range (#{min}:#{sec})"
    end
    case clock.to_sym
    when :mtc
      hours = h.to_f + min.to_f / 60.0 + sec.to_f / 3600.0
      unless hours >= 0.0 && hours < 24.0
        raise ArgumentError, "MTC #{h}:#{min}:#{sec} is outside [00:00:00, 24:00:00)"
      end
    when :mxt
      si = h.to_f * 3600.0 + min.to_f * 60.0 + sec.to_f
      unless si >= 0.0 && si < SOL_SI_SECONDS
        raise ArgumentError, "MXT #{h}:#{min}:#{sec} is outside one sol"
      end
    else
      raise ArgumentError, "clock must be :mtc or :mxt (got #{clock.inspect})"
    end
  end

  def frac_from_hms(h, min, sec, clock)
    case clock.to_sym
    when :mtc
      (h.to_f + min.to_f / 60.0 + sec.to_f / 3600.0) / 24.0
    when :mxt
      (h.to_f * 3600.0 + min.to_f * 60.0 + sec.to_f) / SOL_SI_SECONDS
    end
  end
end
