#!/usr/bin/env ruby
# Tests for MarsDateTime::Calendar (MCE y/m/sol ↔ MSD).
# Run: ruby test/calendar_test.rb

require 'minitest/autorun'
require_relative '../lib/marsdate'
require 'date'

class CalendarTest < Minitest::Test
  Cal = MarsDateTime::Calendar
  TS = MarsDateTime::TimeScale

  def test_leap_rule_matches_library
    1.upto(2000) do |y|
      assert_equal MarsDateTime.leap?(y), Cal.leap?(y), "leap? year #{y}"
    end
  end

  def test_closed_form_leaps
    brute = 0
    1.upto(2000) do |y|
      brute += 1 if Cal.leap?(y)
      assert_equal brute, Cal.leaps_through(y), "leaps_through(#{y})"
    end
    assert_equal 0, Cal.leaps_before(1)
    assert_equal 1, Cal.leaps_before(2)
  end

  def test_mean_year_1000
    assert_equal 591, Cal.leaps_through(1000)
    assert_equal 668_000 + 591, Cal.sols_before_year(1001)
  end

  def test_epoch_is_year1_sol1
    assert_equal 0, Cal.sol_index(1, 1, 1)
    assert_equal Cal::EPOCH_MSD, Cal.msd_midnight(1, 1, 1)
    assert_equal [1, 1, 1], Cal.ymd(0)
    assert_equal [1, 1, 1], Cal.ymd_from_msd(Cal::EPOCH_MSD)
    assert_equal [1, 1, 1], Cal.ymd_from_msd(Cal::EPOCH_MSD + 0.999)
    assert_equal [1, 1, 2], Cal.ymd_from_msd(Cal::EPOCH_MSD + 1)
  end

  def test_year1_is_leap_taurus_25
    assert Cal.leap?(1)
    assert_equal 669, Cal.sols_in_year(1)
    assert_equal 25, Cal.sols_in_month(24, 1)
    assert_equal 668, Cal.sol_index(1, 24, 25)
    assert_equal [1, 24, 25], Cal.ymd(668)
    assert_equal [2, 1, 1], Cal.ymd(669)
  end

  def test_year2_is_short_taurus_24
    refute Cal.leap?(2)
    assert_equal 668, Cal.sols_in_year(2)
    assert_equal 24, Cal.sols_in_month(24, 2)
    last = Cal.sol_index(2, 24, 24)
    assert_equal [2, 24, 24], Cal.ymd(last)
    assert_equal [3, 1, 1], Cal.ymd(last + 1)
  end

  def test_century_and_millennium
    refute Cal.leap?(100)
    assert Cal.leap?(10)
    assert Cal.leap?(1000)
    assert_equal 24, Cal.sols_in_month(24, 100)
    assert_equal 25, Cal.sols_in_month(24, 1000)
  end

  def test_round_trip_samples
    samples = [
      [1, 1, 1], [1, 1, 2], [1, 12, 14], [1, 24, 25],
      [2, 1, 1], [2, 24, 24], [10, 24, 25], [100, 24, 24],
      [1000, 24, 25], [1054, 20, 20], [1063, 1, 1]
    ]
    samples.each do |y, m, d|
      n = Cal.sol_index(y, m, d)
      assert_equal [y, m, d], Cal.ymd(n), "round-trip index #{y}/#{m}/#{d}"
      msd = Cal.msd_midnight(y, m, d)
      assert_equal [y, m, d], Cal.ymd_from_msd(msd), "round-trip MSD #{y}/#{m}/#{d}"
      assert_equal [y, m, d], Cal.ymd_from_msd(msd + 0.5), "noon still #{y}/#{m}/#{d}"
    end
  end

  def test_round_trip_scan
    [[1, 12], [98, 102], [998, 1002]].each do |lo, hi|
      (Cal.sols_before_year(lo)...Cal.sols_before_year(hi + 1)).each do |n|
        y, m, d = Cal.ymd(n)
        assert_equal n, Cal.sol_index(y, m, d), "scan index #{n} → #{y}/#{m}/#{d}"
      end
    end
  end

  def test_reject_invalid
    assert_raises(ArgumentError) { Cal.sol_index(2, 24, 25) }
    assert_raises(ArgumentError) { Cal.sol_index(1, 24, 26) }
    assert_raises(ArgumentError) { Cal.sol_index(1, 1, 0) }
    assert_raises(ArgumentError) { Cal.sol_index(1, 0, 1) }
    assert_raises(ArgumentError) { Cal.sol_index(1, 25, 1) }
    assert_raises(ArgumentError) { Cal.sol_index(0, 1, 1) }
    assert_raises(ArgumentError) { Cal.ymd(-1) }
    assert_raises(ArgumentError) { Cal.msd_at(1, 1, 1, 1.0) }
    assert_raises(ArgumentError) { Cal.msd_at(1, 1, 1, -0.01) }
  end

  def test_sol_fraction_bounds
    assert_equal Cal::EPOCH_MSD.to_f, Cal.msd_at(1, 1, 1, 0.0)
    mid = Cal.msd_at(1, 1, 1, 0.5)
    assert_equal [1, 1, 1], Cal.ymd_from_msd(mid)
    assert_in_delta 0.5, mid - Cal::EPOCH_MSD, 1e-12
  end

  def test_weekday_year1
    assert_equal 0, Cal.dow(1, 1, 1)
    assert_equal 1, Cal.dow(1, 1, 2)
  end

  def test_modern_earth_instant
    # 2000-01-06 00:00 UTC is a Mars24 worked example (MTC 23:59:39,
    # still the previous sol). Civil date is a regression pin on
    # EPOCH_MSD + the MCE leap rule, not an independent authority.
    dt = DateTime.new(2000, 1, 6, 0, 0, 0)
    msd = TS.msd(dt)
    assert_equal [1063, 19, 21], Cal.ymd_from_msd(msd)
    assert_equal msd.floor - Cal::EPOCH_MSD, Cal.sol_index(1063, 19, 21)

    dt2 = DateTime.new(2026, 8, 13, 0, 6, 56)
    assert_equal [1077, 23, 6], Cal.ymd_from_msd(TS.msd(dt2))
  end

  def test_epoch_report_agrees
    report = TS.epoch_report
    assert_equal Cal::EPOCH_MSD, report[:epoch_msd]
    eq = report[:ls0_msd]
    assert_equal [1, 1, 1], Cal.ymd_from_msd(eq)
    assert_equal Cal::EPOCH_MSD, eq.floor
    # Caption only: TT read as UT. Does not move EPOCH_MSD.
    cap = report[:epoch_earth_if_tt_were_ut]
    assert_equal [1, 1, 23, 13, 40],
                 [cap.year, cap.month, cap.day, cap.hour, cap.min]
    assert_in_delta 27, cap.sec, 1
  end
end
