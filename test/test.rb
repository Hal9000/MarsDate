#!/usr/bin/env ruby
# Legacy MarsDateTime constructor tests (old Earth-midnight epoch).
# No gems. Run: ruby test/test.rb
#
# These lock current constructor behavior, not TimeScale/Calendar.

require_relative '../lib/marsdate'
require 'date'

$failures = 0

def assert(cond, msg)
  return if cond
  warn "FAIL: #{msg}"
  $failures += 1
end

def assert_equal(got, expected, msg)
  assert(got == expected, "#{msg} (got #{got.inspect}, expected #{expected.inspect})")
end

def assert_raises(klass, msg)
  begin
    yield
  rescue klass
    return
  rescue StandardError => e
    assert(false, "#{msg} (raised #{e.class}: #{e.message})")
    return
  end
  assert(false, "#{msg} (no exception)")
end

# --- Mars civil Y/M/D constructors ---

md = MarsDateTime.new(1, 1, 1)
assert_equal(md.ymshms, [1, 1, 1, 0, 0, 0], '1/1/1 ymshms')
assert_equal(md.dow, 0, '1/1/1 is Sunday')

md = MarsDateTime.new(2, 3, 4)
assert_equal(md.ymshms, [2, 3, 4, 0, 0, 0], '2/3/4 ymshms')

md = MarsDateTime.new(5, 4, 24)
assert_equal(md.ymshms, [5, 4, 24, 0, 0, 0], '5/4/24 ymshms')

md = MarsDateTime.new(1054, 20, 20)
assert_equal(md.ymshms, [1054, 20, 20, 0, 0, 0], '1054/20/20 ymshms')

# --- Earth dates through the old converter ---

ed = DateTime.new(1, 1, 22)
md = MarsDateTime.new(ed)
assert_equal(md.ymshms[0..2], [1, 1, 1], 'Earth 1/1/22 → Mars 1/1/1')
assert_equal(md.day_of_week, 'Sunday', 'Earth 1/1/22 is Martian Sunday')

m = MarsDateTime.new(DateTime.new(1961, 5, 23))
assert_equal(m.day_of_week, 'Thursday', '1961-05-23 is Martian Thursday')

m = MarsDateTime.new(DateTime.new(1961, 5, 24))
assert_equal(m.day_of_week, 'Friday', '1961-05-24 is Martian Friday')

# --- Accessors ---

m = MarsDateTime.new(1043, 2, 15, 12, 34, 45)
assert_equal(m.myear, 1043, 'myear')
assert_equal(m.month, 2, 'month')
assert_equal(m.sol, 15, 'sol')
assert_equal(m.hr, 12, 'hr')
assert_equal(m.min, 34, 'min')
assert_equal(m.sec, 45, 'sec')
assert_equal(m.dow, 4, 'dow')
assert_equal(m.day_of_week, 'Thursday', 'day_of_week')
assert_equal(m.year_sol, 43, 'year_sol')
assert_equal(m.epoch_sol, 696715, 'epoch_sol')

m = MarsDateTime.new(933, 1, 2)
assert_equal([m.myear, m.month, m.sol], [933, 1, 2], '933/1/2 accessors')

m = MarsDateTime.new(933, 1, 1)
assert_equal([m.myear, m.month, m.sol], [933, 1, 1], '933/1/1 accessors')

# --- Taurus 25 ---

assert(MarsDateTime.leap?(1067), '1067 is leap')
MarsDateTime.new(1067, 24, 25) # no exception

assert(!MarsDateTime.leap?(1066), '1066 is not leap')
assert_raises(RuntimeError, 'Taurus 25 in 1066') { MarsDateTime.new(1066, 24, 25) }

# --- Equinox near 1/1 (old epoch, ±1.5 sols) ---

m = MarsDateTime.new(DateTime.new(2007, 12, 9, 17, 20, 0))
assert((MarsDateTime.new(1068, 1, 1) - m).abs < 1.5, '2007 equinox near 1068/1/1')

m = MarsDateTime.new(DateTime.new(1609, 3, 12))
assert((MarsDateTime.new(856, 1, 1) - m).abs < 1.5, '1609 equinox near 856/1/1')

m = MarsDateTime.new(DateTime.new(1902, 8, 12, 7, 0, 0))
assert((MarsDateTime.new(1012, 1, 1) - m).abs < 1.5, '1902 equinox near 1012/1/1')

# --- now / today / default constructor ---

m = MarsDateTime.new
e = DateTime.now
assert((e - m.earth_date).abs < 1.0, 'new() defaults to today')

t1 = MarsDateTime.now
t0 = MarsDateTime.today
assert((t1 - t0) < 1.0, 'now and today less than a day apart')

# --- earth_date ---

e = MarsDateTime.new(1, 1, 1).earth_date
assert_equal(e.year, 1, '1/1/1 earth year')
assert_equal(e.month, 1, '1/1/1 earth month')
assert((e.day - 22).abs <= 1, "1/1/1 earth day ~22 (got #{e.day})")

e = DateTime.new(1902, 8, 12, 7, 0, 0)
m = MarsDateTime.new(e)
assert((m.earth_date - e).abs < 1.0, '1902-08-12 converts within a day')

# --- Round-trips (old converter; 0.01 day slack) ---

e1 = DateTime.new(1961, 5, 31)
e2 = MarsDateTime.new(e1).earth_date
assert((e2 - e1).abs <= 0.01, "Earth 1961-05-31 round-trip (diff #{e2 - e1})")

m1 = MarsDateTime.new(1067, 1, 1)
m2 = MarsDateTime.new(m1.earth_date)
assert((m2 - m1).abs < 0.01, "Mars 1067/1/1 round-trip (diff #{m2 - m1})")

e1 = DateTime.new(1976, 7, 4, 16, 30, 0)
30.times do
  e2 = MarsDateTime.new(e1).earth_date
  assert((e2 - e1).abs <= 0.01, "1976+ round-trip #{e1} (diff #{e2 - e1})")
  e1 += 1
end

# --- strftime ---

m1 = MarsDateTime.new(1069, 15, 24)
m2 = MarsDateTime.new(933, 6, 4)
m3 = MarsDateTime.new(1055, 14, 1)

assert_equal(m1.strftime('%a'), 'Mon', '%a')
assert_equal(m1.strftime('%A'), 'Monday', '%A')
assert_equal(m1.strftime('%b'), 'Aug', '%b M-August')
assert_equal(m1.strftime('%B'), 'M-August', '%B M-August')
assert_equal(m1.strftime('%d'), '24', '%d')
assert_equal(m1.strftime('%e'), '24', '%e')
assert_equal(m1.strftime('%F'), '1069-15-24', '%F')
assert_equal(m1.strftime('%j'), '416', '%j')
assert_equal(m1.strftime('%m'), '15', '%m')
assert_equal(m1.strftime('%s'), '0', '%s')
assert_equal(m1.strftime('%u'), '2', '%u')
assert_equal(m1.strftime('%U'), '60', '%U')
assert_equal(m1.strftime('%w'), '1', '%w')
assert_equal(m1.strftime('%x'), '1069/15/24', '%x')
assert_equal(m1.strftime('%Y'), '1069', '%Y')
assert_equal(m1.strftime('%n'), "\n", '%n')
assert_equal(m1.strftime('%t'), "\t", '%t')
assert_equal(m1.strftime('%%'), '%', '%%')

assert_equal(m2.strftime('%a'), 'Wed', '%a Leo')
assert_equal(m2.strftime('%A'), 'Wednesday', '%A Leo')
assert_equal(m2.strftime('%b'), 'Leo', '%b Leo')
assert_equal(m2.strftime('%B'), 'Leo', '%B Leo')
assert_equal(m2.strftime('%d'), '04', '%d Leo')
assert_equal(m2.strftime('%e'), ' 4', '%e Leo')
assert_equal(m2.strftime('%F'), '933-06-04', '%F Leo')
assert_equal(m2.strftime('%j'), '144', '%j Leo')
assert_equal(m2.strftime('%m'), '06', '%m Leo')
assert_equal(m2.strftime('%s'), '0', '%s Leo')
assert_equal(m2.strftime('%u'), '4', '%u Leo')
assert_equal(m2.strftime('%U'), '21', '%U Leo')
assert_equal(m2.strftime('%w'), '3', '%w Leo')
assert_equal(m2.strftime('%x'), '933/06/04', '%x Leo')
assert_equal(m2.strftime('%Y'), '933', '%Y Leo')

assert_equal(m3.strftime('%b'), 'Sag', '%b Sag')
assert_equal(m3.strftime('%B'), 'Sagittarius', '%B Sag')

# --- Comparisons ---

m1 = MarsDateTime.new(1068, 14, 22)
m2 = MarsDateTime.new(1068, 14, 21)
e1 = DateTime.new(2002, 4, 19)
e2 = DateTime.new(2012, 9, 29)
assert(m1 > m2, 'm1 > m2')
assert(m2 < m1, 'm2 < m1')
assert(m1 > e1, 'm1 > e1')
assert(m2 < e2, 'm2 < e2')
assert(m1 == m1, 'm1 == m1')
assert(m1 != m2, 'm1 != m2')

# --- Weekdays ---

(1..24).each do |mm|
  m = MarsDateTime.new(1043, mm, 1)
  assert_equal(m.day_of_week, 'Thursday', "1043/#{mm}/1 is Thursday")
end

m = MarsDateTime.new(DateTime.new(1961, 5, 31))
assert_equal(m.year, 1043, '1961-05-31 year')
assert_equal(m.month, 7, '1961-05-31 month (M-April)')
assert_equal(m.sol, 9, '1961-05-31 sol')
assert_equal(m.day_of_week, 'Friday', '1961-05-31 weekday')

m = MarsDateTime.new(1043, 7, 1)
assert_equal(m.day_of_week, 'Thursday', '1043/7/1 is Thursday')

m = MarsDateTime.new(1068, 1, 1)
assert_equal((m + 7).day_of_week, m.day_of_week, '+7 same weekday')
assert_equal((m + 14).day_of_week, m.day_of_week, '+14 same weekday')
assert_equal((m + 21).day_of_week, m.day_of_week, '+21 same weekday')

# --- Subtraction ---

md = MarsDateTime.new(1062, 20, 20)
m2 = MarsDateTime.new(1062, 20, 17)
assert((md - m2 - 3.0).abs < 0.01, 'subtract another Mars date')
e = DateTime.new(1998, 3, 12, 16, 45, 0)
assert((md - e - 3.0).abs < 0.01, 'subtract an Earth date')
assert(((md - 3) - m2).abs < 0.01, 'subtract a Fixnum (sols)')
assert(((md - 3.0) - m2).abs < 0.01, 'subtract a Float (sols)')

if $failures.zero?
  puts 'All MarsDateTime tests passed.'
  exit 0
else
  warn "#{$failures} failure(s)"
  exit 1
end
