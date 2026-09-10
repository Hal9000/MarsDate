#!/usr/bin/env ruby
# MarsDateTime constructors on the official MSD timeline.
# Run: ruby test/test.rb

require 'minitest/autorun'
require_relative '../lib/marsdate'
require 'date'

class MarsDateTest < Minitest::Test
  def test_civil_ymd_round_trips
    assert_equal [1, 1, 1, 0, 0, 0], MarsDateTime.new(1, 1, 1).ymshms
    assert_equal [2, 3, 4, 0, 0, 0], MarsDateTime.new(2, 3, 4).ymshms
    assert_equal [5, 4, 24, 0, 0, 0], MarsDateTime.new(5, 4, 24).ymshms
    assert_equal [1054, 20, 20, 0, 0, 0], MarsDateTime.new(1054, 20, 20).ymshms
  end

  def test_year1_sol1_is_sunday
    assert_equal 0, MarsDateTime.new(1, 1, 1).dow
    assert_equal 'Sunday', MarsDateTime.new(1, 1, 1).day_of_week
  end

  def test_epoch_msd
    m = MarsDateTime.new(1, 1, 1)
    assert_equal MarsDateTime::EPOCH_MSD, m.msd
    assert_equal 1, m.epoch_sol
  end

  def test_accessors_ymshms_mxt
    m = MarsDateTime.new(1043, 2, 15, 12, 34, 45)
    assert_equal 1043, m.myear
    assert_equal 2, m.month
    assert_equal 15, m.sol
    assert_equal 12, m.mxt_hour
    assert_equal 34, m.mxt_min
    assert_in_delta 45.0, m.mxt_sec, 0.001
    assert_equal 4, m.dow
    assert_equal 'Thursday', m.day_of_week
    assert_equal 43, m.year_sol
    assert_equal 696715, m.epoch_sol
    assert_equal [1043, 2, 15, 12, 34, 45], m.ymshms
  end

  def test_mtc_constructor
    m = MarsDateTime.new(1, 1, 1, 15, 46, 58, clock: :mtc)
    assert_equal 15, m.mtc_hour
    assert_equal 46, m.mtc_min
    assert_in_delta 58.0, m.mtc_sec, 0.5
    assert_equal [1, 1, 1], [m.year, m.month, m.sol]
  end

  def test_accessors_933
    m = MarsDateTime.new(933, 1, 2)
    assert_equal [933, 1, 2], [m.myear, m.month, m.sol]
    m = MarsDateTime.new(933, 1, 1)
    assert_equal [933, 1, 1], [m.myear, m.month, m.sol]
  end

  def test_taurus_25_leap_only
    assert MarsDateTime.leap?(1067)
    MarsDateTime.new(1067, 24, 25)
    refute MarsDateTime.leap?(1066)
    assert_raises(ArgumentError) { MarsDateTime.new(1066, 24, 25) }
  end

  def test_reject_invalid_clocks
    assert_raises(ArgumentError) { MarsDateTime.new(1, 1, 1, 24, 40, 0) }
    assert_raises(ArgumentError) { MarsDateTime.new(1, 1, 1, 24, 0, 0, clock: :mtc) }
    assert_raises(ArgumentError) { MarsDateTime.new(1, 1, 1, 25, 0, 0) }
    MarsDateTime.new(1, 1, 1, 24, 39, 35) # last MXT second, ok
  end

  def test_earth_before_epoch_rejected
    assert_raises(ArgumentError) { MarsDateTime.new(DateTime.new(1, 1, 22)) }
  end

  def test_official_mtc_examples
    m = MarsDateTime.new(DateTime.new(2000, 1, 6, 0, 0, 0))
    assert_equal [1063, 19, 21], [m.year, m.month, m.sol]
    assert_equal 23, m.mtc_hour
    assert_equal 59, m.mtc_min
    assert_in_delta 39.3, m.mtc_sec, 1.0

    m = MarsDateTime.new(DateTime.new(2026, 8, 13, 0, 6, 56))
    assert_equal [1077, 23, 6], [m.year, m.month, m.sol]
    mtc_hours = m.mtc_hour + m.mtc_min / 60.0 + m.mtc_sec / 3600.0
    assert_in_delta 1 + 6 / 60.0 + 22 / 3600.0, mtc_hours, 2.0 / 3600.0
  end

  def test_offset_independent
    utc = DateTime.new(2000, 1, 1, 12, 0, 0)
    est = utc.new_offset(Rational(-5, 24))
    assert_in_delta MarsDateTime.new(utc).msd, MarsDateTime.new(est).msd, 1e-12
  end

  def test_equinoxes_near_following_new_year
    m = MarsDateTime.new(DateTime.new(2007, 12, 9, 17, 20, 0))
    assert_in_delta 0, MarsDateTime.new(1068, 1, 1) - m, 1.5

    m = MarsDateTime.new(DateTime.new(1609, 3, 12))
    assert_in_delta 0, MarsDateTime.new(856, 1, 1) - m, 1.5

    m = MarsDateTime.new(DateTime.new(1902, 8, 12, 7, 0, 0))
    assert_in_delta 0, MarsDateTime.new(1012, 1, 1) - m, 1.5
  end

  def test_default_constructor_is_now
    assert_in_delta 0, DateTime.now - MarsDateTime.new.earth_date, 1.0
  end

  def test_now_and_today_within_a_day
    assert_operator MarsDateTime.now - MarsDateTime.today, :<, 1.0
  end

  def test_earth_date_of_mars_epoch
    e = MarsDateTime.new(1, 1, 1).earth_date
    assert_equal 1, e.year
    assert_equal 1, e.month
    assert_in_delta 23, e.day, 1
  end

  def test_earth_datetime_round_trip
    e = DateTime.new(1902, 8, 12, 7, 0, 0)
    assert_in_delta 0, MarsDateTime.new(e).earth_date - e, 1.0 / 86400.0
  end

  def test_earth_round_trip
    e1 = DateTime.new(1961, 5, 31)
    e2 = MarsDateTime.new(e1).earth_date
    assert_in_delta 0, e2 - e1, 1.0 / 86400.0
  end

  def test_mars_round_trip
    m1 = MarsDateTime.new(1067, 1, 1)
    m2 = MarsDateTime.new(m1.earth_date)
    assert_in_delta 0, m2 - m1, 1e-8
  end

  def test_earth_round_trip_with_hms
    e1 = DateTime.new(1976, 7, 4, 16, 30, 0)
    30.times do
      e2 = MarsDateTime.new(e1).earth_date
      assert_in_delta 0, e2 - e1, 1.0 / 86400.0
      e1 += 1
    end
  end

  def test_strftime_dates
    m1 = MarsDateTime.new(1069, 15, 24)
    m2 = MarsDateTime.new(933, 6, 4)
    m3 = MarsDateTime.new(1055, 14, 1)

    assert_equal 'Mon', m1.strftime('%a')
    assert_equal 'Monday', m1.strftime('%A')
    assert_equal 'Aug', m1.strftime('%b')
    assert_equal 'M-August', m1.strftime('%B')
    assert_equal '24', m1.strftime('%d')
    assert_equal '24', m1.strftime('%e')
    assert_equal '1069-15-24', m1.strftime('%F')
    assert_equal '416', m1.strftime('%j')
    assert_equal '15', m1.strftime('%m')
    assert_equal '0', m1.strftime('%s')
    assert_equal '2', m1.strftime('%u')
    assert_equal '60', m1.strftime('%U')
    assert_equal '1', m1.strftime('%w')
    assert_equal '1069/15/24', m1.strftime('%x')
    assert_equal '1069', m1.strftime('%Y')
    assert_equal "\n", m1.strftime('%n')
    assert_equal "\t", m1.strftime('%t')
    assert_equal '%', m1.strftime('%%')

    assert_equal 'Wed', m2.strftime('%a')
    assert_equal 'Wednesday', m2.strftime('%A')
    assert_equal 'Leo', m2.strftime('%b')
    assert_equal 'Leo', m2.strftime('%B')
    assert_equal '04', m2.strftime('%d')
    assert_equal ' 4', m2.strftime('%e')
    assert_equal '933-06-04', m2.strftime('%F')
    assert_equal '144', m2.strftime('%j')
    assert_equal '06', m2.strftime('%m')
    assert_equal '0', m2.strftime('%s')
    assert_equal '4', m2.strftime('%u')
    assert_equal '21', m2.strftime('%U')
    assert_equal '3', m2.strftime('%w')
    assert_equal '933/06/04', m2.strftime('%x')
    assert_equal '933', m2.strftime('%Y')

    assert_equal 'Sag', m3.strftime('%b')
    assert_equal 'Sagittarius', m3.strftime('%B')
  end

  def test_strftime_clocks_at_midnight
    m = MarsDateTime.new(1, 1, 1)
    assert_equal '00', m.strftime('%H')
    assert_equal '00', m.strftime('%P')
    assert_equal '00:00:00', m.strftime('%X')
  end

  def test_comparisons
    m1 = MarsDateTime.new(1068, 14, 22)
    m2 = MarsDateTime.new(1068, 14, 21)
    e1 = DateTime.new(2002, 4, 19)
    e2 = DateTime.new(2012, 9, 29)
    assert_operator m1, :>, m2
    assert_operator m2, :<, m1
    assert_operator m1, :>, e1
    assert_operator m2, :<, e2
    assert_equal m1, m1
    refute_equal m1, m2
  end

  def test_year_1043_months_start_thursday
    (1..24).each do |mm|
      assert_equal 'Thursday', MarsDateTime.new(1043, mm, 1).day_of_week
    end
  end

  def test_earth_1961_may_31
    m = MarsDateTime.new(DateTime.new(1961, 5, 31))
    assert_equal 1043, m.year
    assert_equal 7, m.month
    assert_equal 8, m.sol
    assert_equal 'Thursday', m.day_of_week
  end

  def test_martian_april_1_1043_is_thursday
    assert_equal 'Thursday', MarsDateTime.new(1043, 7, 1).day_of_week
  end

  def test_plus_weeks_keeps_weekday
    m = MarsDateTime.new(1068, 1, 1)
    assert_equal m.day_of_week, (m + 7).day_of_week
    assert_equal m.day_of_week, (m + 14).day_of_week
    assert_equal m.day_of_week, (m + 21).day_of_week
  end

  def test_addition_rolls_year
    assert_equal [1067, 1, 1], (MarsDateTime.new(1066, 24, 24) + 1).ymshms[0..2]
    assert_equal [1068, 1, 1], (MarsDateTime.new(1067, 24, 25) + 1).ymshms[0..2]
  end

  def test_subtraction
    md = MarsDateTime.new(1062, 20, 20)
    m2 = MarsDateTime.new(1062, 20, 17)
    assert_in_delta 3.0, md - m2, 1e-9
    assert_in_delta 0, (md - 3) - m2, 1e-9
    assert_in_delta 0, (md - 3.0) - m2, 1e-9
    e = m2.earth_date
    assert_in_delta 3.0, md - e, 1e-8
    d = Date.new(2000, 1, 1)
    dt = DateTime.new(2000, 1, 1, 12, 0, 0)
    assert MarsDateTime.new(dt) - d > 0
    assert_equal 1, MarsDateTime.new(dt) <=> d
  end

  def test_from_msd_and_json
    m = MarsDateTime.new(1043, 2, 15, 12, 34, 45)
    m2 = MarsDateTime.from_msd(m.msd)
    assert_in_delta 0, m2 - m, 0
    m3 = MarsDateTime.from_json(m.to_json)
    assert_in_delta 0, m3 - m, 0
    assert_equal m.msd, MarsDateTime.new(m.msd).msd
  end

  def test_to_s_labels_both_clocks
    s = MarsDateTime.new(1, 1, 1).to_s
    assert_includes s, 'MXT'
    assert_includes s, 'MTC'
    refute_match(/\bhr\b/, s)
  end

  def test_no_unmarked_clock_accessors
    m = MarsDateTime.new(1, 1, 1)
    refute m.respond_to?(:hr)
    refute m.respond_to?(:min)
    refute m.respond_to?(:sec)
  end
end
