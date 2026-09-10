#!/usr/bin/env ruby
# Tests for MarsDateTime::Calendar (MCE y/m/sol ↔ MSD).
# Run: ruby test/calendar_test.rb

require_relative '../lib/marsdate'
require 'date'

module TestUtil
  module_function

  def assert(cond, msg)
    return if cond
    warn "FAIL: #{msg}"
    $cal_failures += 1
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
end

module CalendarTests
  Cal = MarsDateTime::Calendar
  TS = MarsDateTime::TimeScale

  module_function

  def run
    leap_rule_matches_library
    closed_form_leaps
    mean_year_1000
    epoch_is_year1_sol1
    year1_is_leap_taurus_25
    year2_is_short_taurus_24
    century_and_millennium
    round_trip_samples
    round_trip_scan
    reject_invalid
    sol_fraction_bounds
    weekday_year1
    modern_earth_instant
    epoch_report_agrees
  end

  def leap_rule_matches_library
    1.upto(2000) do |y|
      TestUtil.assert_equal(Cal.leap?(y), MarsDateTime.leap?(y), "leap? year #{y}")
    end
  end

  def closed_form_leaps
    brute = 0
    1.upto(2000) do |y|
      brute += 1 if Cal.leap?(y)
      TestUtil.assert_equal(Cal.leaps_through(y), brute, "leaps_through(#{y})")
    end
    TestUtil.assert_equal(Cal.leaps_before(1), 0, 'leaps_before(1)')
    TestUtil.assert_equal(Cal.leaps_before(2), 1, 'leaps_before(2) (year 1 leap)')
  end

  def mean_year_1000
    TestUtil.assert_equal(Cal.leaps_through(1000), 591, '591 leaps per 1000 years')
    TestUtil.assert_equal(Cal.sols_before_year(1001), 668_000 + 591, 'sols in years 1..1000')
  end

  def epoch_is_year1_sol1
    TestUtil.assert_equal(Cal.sol_index(1, 1, 1), 0, '1/1/1 sol index')
    TestUtil.assert_equal(Cal.msd_midnight(1, 1, 1), Cal::EPOCH_MSD, '1/1/1 midnight MSD')
    TestUtil.assert_equal(Cal.ymd(0), [1, 1, 1], 'index 0 → 1/1/1')
    TestUtil.assert_equal(Cal.ymd_from_msd(Cal::EPOCH_MSD), [1, 1, 1], 'EPOCH_MSD → 1/1/1')
    TestUtil.assert_equal(Cal.ymd_from_msd(Cal::EPOCH_MSD + 0.999), [1, 1, 1], 'late on 1/1/1')
    TestUtil.assert_equal(Cal.ymd_from_msd(Cal::EPOCH_MSD + 1), [1, 1, 2], 'next midnight')
  end

  def year1_is_leap_taurus_25
    TestUtil.assert(Cal.leap?(1), 'year 1 is leap (odd)')
    TestUtil.assert_equal(Cal.sols_in_year(1), 669, 'year 1 has 669 sols')
    TestUtil.assert_equal(Cal.sols_in_month(24, 1), 25, 'Taurus year 1 has 25')
    TestUtil.assert_equal(Cal.sol_index(1, 24, 25), 668, 'last sol of year 1')
    TestUtil.assert_equal(Cal.ymd(668), [1, 24, 25], 'index 668 → 1/24/25')
    TestUtil.assert_equal(Cal.ymd(669), [2, 1, 1], 'index 669 → 2/1/1')
  end

  def year2_is_short_taurus_24
    TestUtil.assert(!Cal.leap?(2), 'year 2 is short')
    TestUtil.assert_equal(Cal.sols_in_year(2), 668, 'year 2 has 668 sols')
    TestUtil.assert_equal(Cal.sols_in_month(24, 2), 24, 'Taurus year 2 has 24')
    last = Cal.sol_index(2, 24, 24)
    TestUtil.assert_equal(Cal.ymd(last), [2, 24, 24], 'last sol of year 2')
    TestUtil.assert_equal(Cal.ymd(last + 1), [3, 1, 1], 'next is 3/1/1')
  end

  def century_and_millennium
    TestUtil.assert(!Cal.leap?(100), 'year 100 is not leap')
    TestUtil.assert(Cal.leap?(10), 'year 10 is leap')
    TestUtil.assert(Cal.leap?(1000), 'year 1000 is leap')
    TestUtil.assert_equal(Cal.sols_in_month(24, 100), 24, 'Taurus 100 has 24')
    TestUtil.assert_equal(Cal.sols_in_month(24, 1000), 25, 'Taurus 1000 has 25')
  end

  def round_trip_samples
    samples = [
      [1, 1, 1], [1, 1, 2], [1, 12, 14], [1, 24, 25],
      [2, 1, 1], [2, 24, 24], [10, 24, 25], [100, 24, 24],
      [1000, 24, 25], [1054, 20, 20], [1063, 1, 1]
    ]
    samples.each do |y, m, d|
      n = Cal.sol_index(y, m, d)
      TestUtil.assert_equal(Cal.ymd(n), [y, m, d], "round-trip index #{y}/#{m}/#{d}")
      msd = Cal.msd_midnight(y, m, d)
      TestUtil.assert_equal(Cal.ymd_from_msd(msd), [y, m, d], "round-trip MSD #{y}/#{m}/#{d}")
      TestUtil.assert_equal(Cal.ymd_from_msd(msd + 0.5), [y, m, d], "noon still #{y}/#{m}/#{d}")
    end
  end

  def round_trip_scan
    # Every sol of years 1–12 and a window around 100 / 1000.
    [[1, 12], [98, 102], [998, 1002]].each do |lo, hi|
      (Cal.sols_before_year(lo)...Cal.sols_before_year(hi + 1)).each do |n|
        y, m, d = Cal.ymd(n)
        TestUtil.assert_equal(Cal.sol_index(y, m, d), n, "scan index #{n} → #{y}/#{m}/#{d}")
      end
    end
  end

  def reject_invalid
    TestUtil.assert_raises(ArgumentError, 'Taurus 25 in short year') { Cal.sol_index(2, 24, 25) }
    TestUtil.assert_raises(ArgumentError, 'Taurus 26 in leap year') { Cal.sol_index(1, 24, 26) }
    TestUtil.assert_raises(ArgumentError, 'sol 0') { Cal.sol_index(1, 1, 0) }
    TestUtil.assert_raises(ArgumentError, 'month 0') { Cal.sol_index(1, 0, 1) }
    TestUtil.assert_raises(ArgumentError, 'month 25') { Cal.sol_index(1, 25, 1) }
    TestUtil.assert_raises(ArgumentError, 'year 0') { Cal.sol_index(0, 1, 1) }
    TestUtil.assert_raises(ArgumentError, 'negative index') { Cal.ymd(-1) }
    TestUtil.assert_raises(ArgumentError, 'frac 1.0') { Cal.msd_at(1, 1, 1, 1.0) }
    TestUtil.assert_raises(ArgumentError, 'frac -0.01') { Cal.msd_at(1, 1, 1, -0.01) }
  end

  def sol_fraction_bounds
    TestUtil.assert_equal(Cal.msd_at(1, 1, 1, 0.0), Cal::EPOCH_MSD.to_f, 'frac 0 is midnight')
    mid = Cal.msd_at(1, 1, 1, 0.5)
    TestUtil.assert_equal(Cal.ymd_from_msd(mid), [1, 1, 1], 'frac 0.5 stays on 1/1/1')
    TestUtil.assert((mid - Cal::EPOCH_MSD - 0.5).abs < 1e-12, 'msd_at adds frac')
  end

  def weekday_year1
    TestUtil.assert_equal(Cal.dow(1, 1, 1), 0, '1/1/1 is Sunday')
    TestUtil.assert_equal(Cal.dow(1, 1, 2), 1, '1/1/2 is Monday')
  end

  def modern_earth_instant
    # 2000-01-06 00:00 UTC is a Mars24 worked example (MTC 23:59:39,
    # still the previous sol). Civil date is a regression pin on
    # EPOCH_MSD + the MCE leap rule, not an independent authority.
    dt = DateTime.new(2000, 1, 6, 0, 0, 0)
    msd = TS.msd(dt)
    TestUtil.assert_equal(Cal.ymd_from_msd(msd), [1063, 19, 21],
                          '2000-01-06 00:00 UTC → MCE 1063/19/21')
    TestUtil.assert_equal(Cal.sol_index(1063, 19, 21), msd.floor - Cal::EPOCH_MSD,
                          'sol index = floor(MSD) − EPOCH_MSD')

    dt2 = DateTime.new(2026, 8, 13, 0, 6, 56)
    TestUtil.assert_equal(Cal.ymd_from_msd(TS.msd(dt2)), [1077, 23, 6],
                          '2026-08-13 00:06:56 UTC → MCE 1077/23/6')
  end

  def epoch_report_agrees
    report = TS.epoch_report
    TestUtil.assert_equal(report[:epoch_msd], Cal::EPOCH_MSD,
                          'TimeScale.epoch_report matches Calendar::EPOCH_MSD')
    eq = report[:ls0_msd]
    TestUtil.assert_equal(Cal.ymd_from_msd(eq), [1, 1, 1],
                          'year-1 Ls=0 falls on 1/1/1')
    TestUtil.assert(eq.floor == Cal::EPOCH_MSD, "floor(Ls=0 MSD)=EPOCH_MSD (#{eq})")
  end
end

$cal_failures = 0
CalendarTests.run
if $cal_failures.zero?
  puts 'All calendar tests passed.'
  exit 0
else
  warn "#{$cal_failures} failure(s)"
  exit 1
end
