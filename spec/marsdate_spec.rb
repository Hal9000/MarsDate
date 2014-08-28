$: << "lib"
require 'marsdate'

require 'rubygems'
require 'minitest'
require 'minitest/spec'
require 'minitest/autorun'

require 'pp'

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

describe "Mars date 1/1/1" do
  md = MarsDateTime.new(1,1,1)
  it "should compute backwards to same result" do
    assert_equal([1,1,1,0,0,0],md.ymshms)
  end
  it "should be a Sunday" do
    assert_equal(0,md.dow)
  end
end

describe "Mars date 2/3/4" do
  md = MarsDateTime.new(2,3,4)
  it "should compute backwards to same result" do
    assert_equal([2,3,4,0,0,0],md.ymshms)
  end
end

describe "Mars date 5/4/24" do
  md = MarsDateTime.new(5,4,24)
  it "should compute backwards to same result" do
    assert_equal([5,4,24,0,0,0],md.ymshms)
  end
end

describe "Mars date 1054/20/20" do
  md = MarsDateTime.new(1054,20,20)
  it "should compute backwards to same result" do
    assert_equal([1054,20,20,0,0,0],md.ymshms)
  end
end

describe "Earth date 1/1/22" do
  ed = DateTime.new(1,1,22)
  md = MarsDateTime.new(ed)
  it "should be approximately M-date 1/1/1" do
    assert_equal([1,1,1],md.ymshms[0..2])
  end
  it "should yield a Martian Sunday" do
    assert_equal(md.day_of_week,"Sunday")
  end
end

describe "Earth date May 23, 1961" do
  e = DateTime.new(1961,5,23)
  m = MarsDateTime.new(e)
  it "should yield a Martian Thursday" do
    assert_equal(m.day_of_week,"Thursday")
  end
end

describe "Earth date May 24, 1961" do
  e = DateTime.new(1961,5,24)
  m = MarsDateTime.new(e)
  it "should yield a Martian Friday" do
    assert_equal(m.day_of_week,"Friday")
  end
end

describe "A Martian date/time (y,m,s,h,m,s)" do
  m = MarsDateTime.new(1043,2,15,12,34,45)
  it "should set all its accessors properly" do
    assert_equal(1043,m.myear)
    assert_equal(2,m.month)
    assert_equal(15,m.sol)
    assert_equal(12,m.hr)
    assert_equal(34,m.min)
    assert_equal(45,m.sec)
    assert_equal(4,m.dow)
    assert_equal("Thursday",m.day_of_week)
    assert_equal(43,m.year_sol)
    assert_equal(696715,m.epoch_sol)
  end
end

describe "The 2007 Martian equinox" do
  e = DateTime.new(2007,12,9,17,20,0).new_offset(-5)
  m = MarsDateTime.new(e)
  m11 = MarsDateTime.new(1068,1,1)
  it "should fall on or near 1/1 (MCE)" do
    diff = (m11-m).abs
    flag = diff < 1.0
    assert(flag, "Difference: #{diff}")
  end
end

describe "Constructing without parameters" do
  m = MarsDateTime.new
  e = DateTime.now
  m2e = m.earth_date
  it "should default to today" do
    diff = (e-m2e).abs     # m - e doesn't work!
    assert(diff < 1.0)
  end
end

describe "Constructing with a DateTime" do
  it "should convert from Gregorian to MCE" do
    e = DateTime.new(1902,8,12,7,0,0)
    m = MarsDateTime.new(e)
    diff = (m.earth_date - e).abs   # days as a float
    x = assert(diff < 1.0)
  end
end

describe "A Martian date/time (933,1,2)" do
  m = MarsDateTime.new(933,1,2)
  it "should set the three obvious accessors properly" do
    assert_equal(933,m.myear)
    assert_equal(1,m.month)
    assert_equal(2,m.sol)
  end
end

describe "A Martian date/time (933,1,1)" do
  m = MarsDateTime.new(933,1,1)
  it "should set the three obvious accessors properly" do
    assert_equal(933,m.myear)
    assert_equal(1,m.month)
    assert_equal(1,m.sol)
  end
end

describe "The Martian date 24/25" do
  describe "in a leap year" do
    year = 1067
    it "should exist" do
      assert( MarsDateTime.leap?(year) )
      MarsDateTime.new(year,24,25)   # may raise exception - no #wont_raise
    end
  end
  describe "in a non-leap year" do
    year = 1066
    it "should not exist" do
      assert( ! MarsDateTime.leap?(year) )
      lambda { MarsDateTime.new(year,24,25) }.must_raise(RuntimeError) 
    end
  end
end

describe "The earth_date convertor" do
  m = MarsDateTime.new(1,1,1)
  it "should convert to a Gregorian date" do
    e = m.earth_date
    assert_equal(1,e.year)
    assert_equal(1,e.month)
    assert((e.day-22).abs <= 1, "e - 22 = #{e.day - 22}")
  end
end

describe "An Earthly date" do
  e1 = DateTime.new(1961,5,31)
  it "should (approximately) make the conversion roundtrip" do
    m1 = MarsDateTime.new(e1)
    e2 = m1.earth_date
    diff = e2 - e1
    assert(diff.abs <= 0.01, "Difference = #{diff}")
  end
end

describe "A Martian date" do
  m1 = MarsDateTime.new(1067,1,1)
  it "should (approximately) make the conversion roundtrip" do
    e1 = m1.earth_date
    m2 = MarsDateTime.new(e1)
    diff = m2 - m1
    assert(diff.abs < 0.01)
  end
end

describe "An arbitrary Martian date" do
  m1 = MarsDateTime.new(1069,15,24)
  m2 = MarsDateTime.new(933,6,4)
  m3 = MarsDateTime.new(1055,14,1)
  it "should format well with strftime" do
    assert_equal("Mon",m1.strftime("%a"))
    assert_equal("Monday",m1.strftime("%A"))
    assert_equal("Aug",m1.strftime("%b"))
    assert_equal("M-August",m1.strftime("%B"))
    assert_equal("24",m1.strftime("%d"))
    assert_equal("24",m1.strftime("%e"))
    assert_equal("1069-15-24",m1.strftime("%F"))
    assert_equal("416",m1.strftime("%j"))
    assert_equal("15",m1.strftime("%m"))
    assert_equal("0",m1.strftime("%s"))
    assert_equal("2",m1.strftime("%u"))
    assert_equal("60",m1.strftime("%U"))
    assert_equal("1",m1.strftime("%w"))
    assert_equal("1069/15/24",m1.strftime("%x"))
    assert_equal("1069",m1.strftime("%Y"))
    assert_equal("\n",m1.strftime("%n"))
    assert_equal("\t",m1.strftime("%t"))
    assert_equal("%",m1.strftime("%%"))

    assert_equal("Wed",m2.strftime("%a"))
    assert_equal("Wednesday",m2.strftime("%A"))
    assert_equal("Leo",m2.strftime("%b"))
    assert_equal("Leo",m2.strftime("%B"))
    assert_equal("04",m2.strftime("%d"))
    assert_equal(" 4",m2.strftime("%e"))
    assert_equal("933-06-04",m2.strftime("%F"))
    assert_equal("144",m2.strftime("%j"))
    assert_equal("06",m2.strftime("%m"))
    assert_equal("0",m2.strftime("%s"))
    assert_equal("4",m2.strftime("%u"))
    assert_equal("21",m2.strftime("%U"))
    assert_equal("3",m2.strftime("%w"))
    assert_equal("933/06/04",m2.strftime("%x"))
    assert_equal("933",m2.strftime("%Y"))

    assert_equal("Sag",m3.strftime("%b"))
    assert_equal("Sagittarius",m3.strftime("%B"))
  end
end

describe "An Earthly date with h:m:s" do
  e1 = DateTime.new(1976,7,4,16,30,0)  # July 4, 1976  16:30
  m1 = MarsDateTime.new(e1)
  it "should make the conversion roundtrip" do
    30.times do
      m1 = MarsDateTime.new(e1)
      e2 = m1.earth_date
      diff = e2 - e1
      assert(diff.abs <= 0.01) { STDERR.puts "    diff = #{diff}" }
      e1 += 1
    end
  end
end

 describe "Martian dates" do
   m1 = MarsDateTime.new(1068,14,22)
   m2 = MarsDateTime.new(1068,14,21)
   e1 = DateTime.new(2002,4,19)
   e2 = DateTime.new(2012,9,29)
   it "should compare with each other" do
     assert(m1 > m2)
     assert(m2 < m1)
   end
   it "should compare with Earth dates" do
     assert(m1 > e1)
     assert(m2 < e2)
   end
   it "should honor equality (within roundoff)" do
     assert(m1 == m1)
     assert(m1 != m2)
   end
 end

describe "The 'now' and 'today' class methods" do
  t1 = MarsDateTime.now
  t0 = MarsDateTime.today
  it "should be less than a day apart" do
    diff = t1 - t0
    assert(diff < 1.0)
  end
end

describe "In M-year 1043, each month" do
  md = (1..24).to_a.map {|mm| MarsDateTime.new(1043,mm,1) }
  it "should start on a Thursday" do
    md.each {|m| assert(m.day_of_week == "Thursday") }
  end
end

describe "Converting 1961/5/31 to Martian" do
  e = DateTime.new(1961,5,31) 
  m = MarsDateTime.new(e)
  it "should yield Friday M-April 9, 1043 MCE" do
    assert(m.year == 1043, "bad year: #{m.year}")
    assert(m.month == 7, "bad month: #{m.month}")
    assert(m.sol == 9, "bad sol: #{m.sol}")
  end
  it "should give a Martian Saturday" do
    assert(m.day_of_week == "Friday", "got: #{m.day_of_week}")
  end
end

describe "The 1609 Martian equinox" do
  e = DateTime.new(1609,3,12).new_offset(-5)
  m = MarsDateTime.new(e)
  m11 = MarsDateTime.new(856,1,1)
  it "should fall on or near 1/1 (MCE)" do
    diff = (m11-m).abs
    assert(diff < 1.0, "Difference = #{diff}")
  end
end

describe "The 1902 Martian equinox" do
  e = DateTime.new(1902,8,12,7,0,0).new_offset(-5)
  m = MarsDateTime.new(e)
  m11 = MarsDateTime.new(1012,1,1)
  it "should fall on or near 1/1 (MCE)" do
    diff = (m11-m).abs
    assert(diff < 1.0, "Difference: #{diff}")
  end
end

describe "A Martian date" do
  puts "***** Entering problem test..."
  m = MarsDateTime.new(1068,1,1)
  p m
  describe "plus 7 days" do
    m2 = m + 7
    p m2
    it "should be the same day of the week" do
      assert_equal(m.day_of_week, m2.day_of_week)
    end
  end
  describe "plus 14 days" do
    m3 = m + 14
    p m3
    it "should be the same day of the week" do
      assert_equal(m.day_of_week, m3.day_of_week)
    end
  end
  describe "plus 21 days" do
    m4 = m + 21
    p m4
    it "should be the same day of the week" do
      assert_equal(m.day_of_week, m4.day_of_week)
    end
  end
  puts "***** Exiting problem test"
end

describe "Martian April 1, 1043" do
  m = MarsDateTime.new(1043,7,1)
  it "should be a Thursday" do
    assert_equal(m.day_of_week,"Thursday")
  end
end
 
describe "A Martian date" do
  md = MarsDateTime.new(1062,20,20)
  m2 = MarsDateTime.new(1062,20,17) 
  it "should allow subtraction of another date" do
    m = md - m2
    assert( (m - 3.0) < 0.01)   # sols
  end
  it "should allow subtraction of an Earth date" do
    e = DateTime.new(1998, 3, 12, 16, 45, 0)
    m = md - e
    assert( (m - 3.0) < 0.01)   # sols
  end
  it "should allow subtraction of a Fixnum" do
    m = md - 3                 # sols
    assert( (m - m2) < 0.01)
  end
  it "should allow subtraction of a Float" do
    m = md - 3.0               # sols
    assert( (m - m2) < 0.01)
  end
end


