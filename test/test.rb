require './lib/marsdate'

require 'rubygems'
require 'minitest/autorun'
require 'shoulda'
require 'pp'

class MarsDateTest < MiniTest::Test

  def my_assert(expr)
    if !expr && block_given?
      puts "\n--- DEBUG: "
      yield 
    end
    assert(expr)
  end

  def my_assert_equal(e1, e2)
    if e1 != e2 && block_given?
      puts "\n--- DEBUG: "
      yield 
    end
    assert_equal(e1, e2)
  end

  ## experimenting...
  
  context "Mars date 1/1/1" do
    md = MarsDateTime.new(1,1,1)
    should "compute backwards to same result" do
      assert_equal([1,1,1,0,0,0],md.ymshms)
    end
    should "be a Sunday" do
      assert_equal(0,md.dow)
    end
  end

  context "Mars date 2/3/4" do
    md = MarsDateTime.new(2,3,4)
    should "compute backwards to same result" do
      assert_equal([2,3,4,0,0,0],md.ymshms)
    end
  end

  context "Mars date 5/4/24" do
    md = MarsDateTime.new(5,4,24)
    should "compute backwards to same result" do
      assert_equal([5,4,24,0,0,0],md.ymshms)
    end
  end

  context "Mars date 1054/20/20" do
    md = MarsDateTime.new(1054,20,20)
    should "compute backwards to same result" do
      assert_equal([1054,20,20,0,0,0],md.ymshms)
    end
  end

  context "Earth date 1/1/22" do
    ed = DateTime.new(1,1,22)
    md = MarsDateTime.new(ed)
    should "be approximately M-date 1/1/1" do
      assert_equal([1,1,1],md.ymshms[0..2])
    end
    should "yield a Martian Sunday" do
      assert_equal(md.day_of_week,"Sunday")
    end
  end

  context "Earth date May 23, 1961" do
    e = DateTime.new(1961,5,23)
    m = MarsDateTime.new(e)
    should "yield a Martian Thursday" do
      assert_equal(m.day_of_week,"Thursday")
    end
  end

  context "Earth date May 24, 1961" do
    e = DateTime.new(1961,5,24)
    m = MarsDateTime.new(e)
    should "yield a Martian Friday" do
      assert_equal(m.day_of_week,"Friday")
    end
  end

  context "A Martian date/time (y,m,s,h,m,s)" do   ###
    m = MarsDateTime.new(1043,2,15,12,34,45)
    should "set all its accessors properly" do
      assert_equal(1043, m.myear)
      assert_equal(2, m.month)
      assert_equal(15, m.sol)
      assert_equal(12, m.hr)
      assert_equal(34, m.min)
      assert_equal(45, m.sec)
      assert_equal(4, m.dow)
      assert_equal("Thursday", m.day_of_week)
      assert_equal(43, m.year_sol)
      assert_equal(696715, m.epoch_sol)
    end
  end

  context "The 2007 Martian equinox" do  ###
    e = DateTime.new(2007,12,9,17,20,0)
    m = MarsDateTime.new(e)
    m11 = MarsDateTime.new(1068,1,1)
    should "fall on or near 1/1 (MCE)" do
      diff = (m11-m).abs
      flag = diff < 1.5
      assert(flag)
    end
  end

  context "Constructing without parameters" do
    m = MarsDateTime.new
    e = DateTime.now
    m2e = m.earth_date
    should "default to today" do
      diff = (e-m2e).abs     # m - e doesn't work!
      assert(diff < 1.0)
    end
  end

  context "Constructing with a DateTime" do
    should "convert from Gregorian to MCE" do
      e = DateTime.new(1902,8,12,7,0,0)
      m = MarsDateTime.new(e)
      diff = (m.earth_date - e).abs   # days as a float
      x = assert(diff < 1.0)
    end
  end

  context "A Martian date/time (933,1,2)" do
    m = MarsDateTime.new(933,1,2)
    should "set the three obvious accessors properly" do
      assert_equal(933, m.myear)
      assert_equal(1, m.month)
      assert_equal(2, m.sol)
    end
  end

  context "A Martian date/time (933,1,1)" do
    m = MarsDateTime.new(933,1,1)
    should "set the three obvious accessors properly" do
      assert_equal(933, m.myear)
      assert_equal(1, m.month)
      assert_equal(1, m.sol)
    end
  end

  context "The Martian date 24/25" do
    context "in a leap year" do
      year = 1067
      should "exist" do
        assert(MarsDateTime.leap?(year))
        assert(MarsDateTime.new(year,24,25))  # no exception raised
      end
    end
    context "in a non-leap year" do
      year = 1066
      should "not exist" do
        assert(! MarsDateTime.leap?(year))
        assert_raises(RuntimeError) { MarsDateTime.new(year,24,25) }
      end
    end
  end

  context "The earth_date convertor" do
    m = MarsDateTime.new(1, 1, 1)
    should "convert to a Gregorian date" do
      e = m.earth_date
      assert_equal(1,e.year)
      assert_equal(1,e.month)
      assert((e.day-22).abs <= 1)
    end
  end

  context "An Earthly date" do
    e1 = DateTime.new(1961, 5, 31)
    should "(approximately) make the conversion roundtrip" do
      m1 = MarsDateTime.new(e1)
      e2 = m1.earth_date
      diff = e2 - e1
      assert(diff.abs <= 0.01)
    end
  end

  context "A Martian date" do
    m1 = MarsDateTime.new(1067, 1, 1)
    should "(approximately) make the conversion roundtrip" do
      e1 = m1.earth_date
      m2 = MarsDateTime.new(e1)
      diff = m2 - m1
      assert(diff.abs < 0.01)
    end
  end

  context "An arbitrary Martian date" do
    m1 = MarsDateTime.new(1069, 15, 24)
    m2 = MarsDateTime.new(933, 6, 4)
    m3 = MarsDateTime.new(1055, 14, 1)
    should "format well with strftime" do
      assert_equal("Mon", m1.strftime("%a"))
      assert_equal("Monday", m1.strftime("%A"))
      assert_equal("Aug", m1.strftime("%b"))
      assert_equal("M-August", m1.strftime("%B"))
      assert_equal("24", m1.strftime("%d"))
      assert_equal("24", m1.strftime("%e"))
      assert_equal("1069-15-24", m1.strftime("%F"))
      assert_equal("416", m1.strftime("%j"))
      assert_equal("15", m1.strftime("%m"))
      assert_equal("0", m1.strftime("%s"))
      assert_equal("2", m1.strftime("%u"))
      assert_equal("60", m1.strftime("%U"))
      assert_equal("1", m1.strftime("%w"))
      assert_equal("1069/15/24", m1.strftime("%x"))
      assert_equal("1069", m1.strftime("%Y"))
      assert_equal("\n", m1.strftime("%n"))
      assert_equal("\t", m1.strftime("%t"))
      assert_equal("%", m1.strftime("%%"))
  
      assert_equal("Wed", m2.strftime("%a"))
      assert_equal("Wednesday", m2.strftime("%A"))
      assert_equal("Leo", m2.strftime("%b"))
      assert_equal("Leo", m2.strftime("%B"))
      assert_equal("04", m2.strftime("%d"))
      assert_equal(" 4", m2.strftime("%e"))
      assert_equal("933-06-04", m2.strftime("%F"))
      assert_equal("144", m2.strftime("%j"))
      assert_equal("06", m2.strftime("%m"))
      assert_equal("0", m2.strftime("%s"))
      assert_equal("4", m2.strftime("%u"))
      assert_equal("21", m2.strftime("%U"))
      assert_equal("3", m2.strftime("%w"))
      assert_equal("933/06/04", m2.strftime("%x"))
      assert_equal("933", m2.strftime("%Y"))
  
      assert_equal("Sag", m3.strftime("%b"))
      assert_equal("Sagittarius", m3.strftime("%B"))
    end
  end

  context "An Earthly date with h:m:s" do
    e1 = DateTime.new(1976,7,4,16,30,0)  # July 4, 1976  16:30
    m1 = MarsDateTime.new(e1)
    should "make the conversion roundtrip" do
      30.times do
        m1 = MarsDateTime.new(e1)
        e2 = m1.earth_date
        diff = e2 - e1
        assert(diff.abs <= 0.01) { STDERR.puts "    diff = #{diff}" }
        e1 += 1
      end
    end
  end

   context "Martian dates" do
     m1 = MarsDateTime.new(1068,14,22)
     m2 = MarsDateTime.new(1068,14,21)
     e1 = DateTime.new(2002,4,19)
     e2 = DateTime.new(2012,9,29)
     should "compare with each other" do
       assert(m1 > m2)
       assert(m2 < m1)
     end
     should "compare with Earth dates" do
       assert(m1 > e1)
       assert(m2 < e2)
     end
     should "honor equality (within roundoff)" do
       assert(m1 == m1)
       assert(m1 != m2)
     end
   end

  context "The 'now' and 'today' class methods" do
    t1 = MarsDateTime.now
    t0 = MarsDateTime.today
    should "be less than a day apart" do
      diff = t1 - t0
      assert(diff < 1.0)
    end
  end

  context "In M-year 1043, each month" do
    md = (1..24).to_a.map {|mm| MarsDateTime.new(1043,mm,1) }
    should "start on a Thursday" do
      md.each {|m| assert(m.day_of_week == "Thursday") }
    end
  end

  context "Converting 1961/5/31 to Martian" do
    e = DateTime.new(1961, 5, 31) 
    m = MarsDateTime.new(e)
    should "yield M-April 9, 1043 MCE" do
      assert(m.year == 1043)
      assert(m.month == 7)
      assert(m.sol == 9)
    end
    should "give a Martian Friday" do
      assert(m.day_of_week == "Friday")
    end
  end

  context "The 1609 Martian equinox" do
    e = DateTime.new(1609, 3, 12)
    m = MarsDateTime.new(e)
    m11 = MarsDateTime.new(856,1,1)
    should "fall on or near 1/1 (MCE)" do
      diff = (m11-m).abs
      assert(diff < 1.5)
    end
  end

  context "The 1902 Martian equinox" do
    e = DateTime.new(1902,8,12,7,0,0)
    m = MarsDateTime.new(e)
    m11 = MarsDateTime.new(1012,1,1)
    should "fall on or near 1/1 (MCE)" do
      diff = (m11-m).abs
      assert(diff < 1.5)
    end
  end

  context "A Martian date" do
    m = MarsDateTime.new(1068,1,1)
    context "plus 7 days" do
      m2 = m + 7
      should "be the same day of the week" do
        assert_equal(m.day_of_week, m2.day_of_week)
      end
    end
    context "plus 14 days" do
      m3 = m + 14
      should "be the same day of the week" do
        assert_equal(m.day_of_week, m3.day_of_week)
      end
    end
    context "plus 21 days" do
      m4 = m + 21
      should "be the same day of the week" do
        assert_equal(m.day_of_week, m4.day_of_week)
      end
    end
  end

  context "Martian April 1, 1043" do
    m = MarsDateTime.new(1043,7,1)
    should "be a Thursday" do
      assert_equal(m.day_of_week,"Thursday")
    end
  end
 
  context "A Martian date" do
    md = MarsDateTime.new(1062,20,20)
    m2 = MarsDateTime.new(1062,20,17) 
    should "allow subtraction of another date" do
      m = md - m2
      assert( (m - 3.0) < 0.01)   # sols
    end
    should "allow subtraction of an Earth date" do
      e = DateTime.new(1998, 3, 12, 16, 45, 0)
      m = md - e
      assert( (m - 3.0) < 0.01)   # sols
    end
    should "allow subtraction of a Fixnum" do
      m = md - 3                 # sols
      assert( (m - m2) < 0.01)
    end
    should "allow subtraction of a Float" do
      m = md - 3.0               # sols
      assert( (m - m2) < 0.01)
    end
  end

end

