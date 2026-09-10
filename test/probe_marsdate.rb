#!/usr/bin/env ruby
# Diagnostic probes used for the accuracy/functionality review in ai-notes.txt.
# Not a formal test suite: prints observations rather than asserting.
#
#   ruby test/probe_marsdate.rb

require_relative '../lib/marsdate'
require 'date'
require 'json'

def section(title)
  puts "\n==== #{title} ===="
end

def show(label)
  result = yield
  puts "#{label}: #{result.inspect}"
rescue => e
  puts "#{label}: ERROR #{e.class}: #{e.message}"
end

section "Epoch"
puts "EPOCH_MSD: #{MarsDateTime::EPOCH_MSD}"
puts "1/1/1: #{MarsDateTime.new(1,1,1).inspect}"
puts "1/1/1 earth_date: #{MarsDateTime.new(1,1,1).earth_date}"

section "Earth Jan 22 year 1 -> Mars"
m = MarsDateTime.new(DateTime.new(1,1,22))
puts m.inspect
puts m.ymshms.inspect

section "README claimed dates"
[
  [2010,1,1, "Tue M-February 11, 1069"],
  [2011,7,4, "Thu Aries 13, 1069"],
  [2011,9,13, "New Year 1070"],
  [1976,7,20, "Tue Virgo 12, 1051"],
].each do |y,mo,d, expected|
  e = DateTime.new(y,mo,d)
  m = MarsDateTime.new(e)
  puts "#{y}-#{mo}-#{d} => #{m.day_of_week}, #{m.month_name} #{m.sol}, #{m.year}  (expected #{expected})"
end

section "README claimed dates at 00:00 / 12:00 / 17:00 UTC"
[[2010,1,1],[2011,7,4],[2011,9,13],[1976,7,20]].each do |y,mo,d|
  [0,12,17].each do |h|
    m = MarsDateTime.new(DateTime.new(y,mo,d,h))
    puts "#{y}-#{mo}-#{d} #{h}h => #{m.day_of_week} #{m.month_name} #{m.sol} #{m.year} MXT #{m.format_mxt} MTC #{m.format_mtc}"
  end
end

section "Equinoxes without timezone hack"
[
  [2007,12,9,17,20,0, 1068],
  [1609,3,12,0,0,0, 856],
  [1902,8,12,7,0,0, 1012],
].each do |y,mo,d,h,mi,s, my|
  e = DateTime.new(y,mo,d,h,mi,s)
  m = MarsDateTime.new(e)
  m11 = MarsDateTime.new(my,1,1)
  puts "#{e} -> #{m.inspect}  vs #{my}/1/1  diff=#{(m11-m)}"
  e5 = e.new_offset(Rational(-5,24))
  m5 = MarsDateTime.new(e5)
  puts "  with offset -5 hour=#{e5.hour}: #{m5.inspect} diff=#{(m11-m5)}"
end

section "Timezone: same instant different offset"
utc = DateTime.new(2000,1,1,12,0,0)
est = utc.new_offset(Rational(-5,24))
puts "utc=#{utc} hour=#{utc.hour} jd=#{utc.jd}"
puts "est=#{est} hour=#{est.hour} jd=#{est.jd}"
mu = MarsDateTime.new(utc)
me = MarsDateTime.new(est)
puts "mars utc: #{mu.inspect}"
puts "mars est: #{me.inspect}"
puts "msd diff: #{mu.msd - me.msd}"

section "Month 24 invalid sols"
[24,25,26,27,28].each do |sol|
  show("leap 1067/24/#{sol}") { MarsDateTime.new(1067,24,sol).ymshms }
  show("nonleap 1066/24/#{sol}") { MarsDateTime.new(1066,24,sol).ymshms }
end

section "Invalid dates rejected"
show("24:40:00 MXT") { MarsDateTime.new(1,1,1,24,40,0).inspect }
show("1067/24/26") { MarsDateTime.new(1067,24,26).inspect }

section "Hour 24 beyond one sol"
show("24:39:35") { MarsDateTime.new(1,1,1,24,39,35).inspect }
show("24:39:35 MXT vs next midnight") {
  a = MarsDateTime.new(1,1,1,24,39,35)
  b = MarsDateTime.new(1,1,2,0,0,0)
  [a.msd, b.msd, a.msd - b.msd, a.inspect, b.inspect]
}
show("24:40:00 accepted?") { MarsDateTime.new(1,1,1,24,40,0).inspect }
show("24:59:59 accepted?") { MarsDateTime.new(1,1,1,24,59,59).inspect }
show("25:00:00 accepted?") { MarsDateTime.new(1,1,1,25,0,0).inspect }

section "Roundtrip precision"
e1 = DateTime.new(1961,5,31,12,34,56)
m1 = MarsDateTime.new(e1)
e2 = m1.earth_date
puts "e1=#{e1} e2=#{e2} diff_days=#{(e2-e1).to_f} msd=#{m1.msd}"

m = MarsDateTime.new(1067,1,1,12,34,45)
e = m.earth_date
m2 = MarsDateTime.new(e)
puts "m=#{m.inspect} m2=#{m2.inspect} diff_sols=#{m2-m}"
puts "msd=#{m.msd}"
puts "earth=#{e} earth h:m:s=#{e.hour}:#{e.min}:#{e.sec}"

section "numeric constructor is MSD"
m = MarsDateTime.new(54252.04608352365)
puts "from MSD 54252.046... => #{m.inspect}"

section "JSON roundtrip"
m = MarsDateTime.new(1043,2,15,12,34,45)
json = m.to_json
m2 = MarsDateTime.from_json(json)
puts "json=#{json}"
puts "orig inspect=#{m.inspect} msd=#{m.msd}"
puts "restored inspect=#{m2.inspect} msd=#{m2.msd}"
puts "year=#{m2.year} month=#{m2.month} +"
show("restored + 1") { (m2 + 1).inspect }

section "YAML properties vs actual ivars"
m = MarsDateTime.new(1,1,1)
puts "actual ivars: #{m.instance_variables}"
puts "to_yaml_properties: #{m.to_yaml_properties}"

section "MXT / MTC at end of sol"
m = MarsDateTime.new(1,1,1,24,39,35)
puts "MXT 24:39:35 => MXT #{m.format_mxt} MTC #{m.format_mtc}"
m0 = MarsDateTime.new(1,1,1,0,0,0)
puts "midnight => MXT #{m0.format_mxt} MTC #{m0.format_mtc}"

section "Date vs DateTime constructor"
d = Date.new(2000,1,1)
dt = DateTime.new(2000,1,1,15,30,0)
puts "from Date: #{MarsDateTime.new(d).inspect}"
puts "from DateTime: #{MarsDateTime.new(dt).inspect}"
show("subtract Date") { MarsDateTime.new(dt) - d }
show("subtract DateTime") { MarsDateTime.new(dt) - dt }
show("compare Date") { MarsDateTime.new(dt) <=> d }

section "Negative / pre-epoch"
show("year 0") { MarsDateTime.new(0,1,1).inspect }
show("year -1") { MarsDateTime.new(-1,1,1).inspect }
show("MSD -1") { MarsDateTime.new(-1).inspect }
show("MSD 0") { MarsDateTime.new(0).inspect }
show("MSD before epoch") { MarsDateTime.new(MarsDateTime::EPOCH_MSD - 1).inspect }

section "Addition across year boundary / leap"
m = MarsDateTime.new(1066,24,24) # last sol of non-leap
puts "1066/24/24 + 1 = #{(m+1).inspect}"
m = MarsDateTime.new(1067,24,25) # last sol of leap
puts "1067/24/25 + 1 = #{(m+1).inspect}"
m = MarsDateTime.new(1067,24,24)
puts "1067/24/24 + 1 = #{(m+1).inspect}"

section "earth_date of 1 MXT second"
m = MarsDateTime.new(1,1,1,0,0,1)
puts "1 second MXT: msd=#{m.msd} earth=#{m.earth_date}"

section "strftime %s, comments, trailing percent"
m = MarsDateTime.new(1,1,1,12,34,45)
puts "%H=#{m.strftime('%H')} (MTC) %P=#{m.strftime('%P')} (MXT)"
puts "%s=#{m.strftime('%s')}"
puts "%I unimplemented: #{m.strftime('%I')}"
m = MarsDateTime.new(1,1,1)
puts "strftime end percent: [#{m.strftime("foo%")}]"

section "DateTime.now fractional seconds"
dt = DateTime.now
puts "now sec=#{dt.sec} frac=#{dt.sec_fraction} offset=#{dt.offset}"

section "today vs now"
puts "Date.today=#{Date.today} DateTime.now=#{DateTime.now}"
puts "today=#{MarsDateTime.today.inspect}"
puts "now=#{MarsDateTime.now.inspect}"
puts "diff sols=#{MarsDateTime.now - MarsDateTime.today}"

section "sols_in_month vs constructor"
puts "sols_in_month 24 leap: #{MarsDateTime.sols_in_month(24,1067)}"
puts "sols_in_month 24 nonleap: #{MarsDateTime.sols_in_month(24,1066)}"

section "Average year vs SOLS_PER_MYEAR"
leaps = 0
1.upto(1000) { |y| leaps += 1 if MarsDateTime.leap?(y) }
avg = 668 + leaps/1000.0
puts "leap years per 1000: #{leaps} avg=#{avg} constant=#{MarsDateTime::SOLS_PER_MYEAR}"

section "Viking / README month names"
m = MarsDateTime.new(DateTime.new(1976,7,20))
puts "month number #{m.month} name #{m.month_name} (Virgo should be month 8)"
puts MarsDateTime::Months.each_with_index.map { |n,i| "#{i}:#{n}" }.join(", ")
