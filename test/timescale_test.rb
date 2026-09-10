#!/usr/bin/env ruby
# Tests for MarsDateTime::TimeScale (NASA/Allison / Mars24).
# Run: ruby test/timescale_test.rb

require 'minitest/autorun'
require_relative '../lib/marsdate/timescale'
require 'date'

class TimeScaleTest < Minitest::Test
  TS = MarsDateTime::TimeScale

  def test_tai_utc_table
    assert_in_delta 10.0, TS.tai_utc(Date.new(1972, 1, 1)), 1e-9
    assert_in_delta 32.0, TS.tai_utc(Date.new(1999, 6, 1)), 1e-9
    assert_in_delta 32.0, TS.tai_utc(Date.new(2000, 1, 6)), 1e-9
    assert_in_delta 37.0, TS.tai_utc(Date.new(2017, 1, 1)), 1e-9
    assert_in_delta 37.0, TS.tai_utc(Date.new(2026, 8, 13)), 1e-9
    assert_in_delta 64.184, TS.tt_utc(Date.new(2000, 1, 6)), 1e-9
    assert_in_delta 69.184, TS.tt_utc(Date.new(2017, 1, 1)), 1e-9
  end

  def test_mars24_2000_jan_6
    # Mars24 worked example: 2000-01-06 00:00:00 UTC → MST 23:59:39
    dt = DateTime.new(2000, 1, 6, 0, 0, 0)
    assert_in_delta 2_451_549.5, TS.jd_ut(dt), 1e-9
    assert_in_delta 2_451_549.500742407, TS.jd_tt(dt), 2e-6
    h, m, s = TS.mtc_hms(dt)
    hours = hms_to_hours(h, m, s)
    assert_in_delta hms_to_hours(23, 59, 39), hours, 1.5 / 3600.0
    assert_equal 23, h
    assert_equal 59, m
  end

  def test_offset_independent
    utc = DateTime.new(2000, 1, 1, 12, 0, 0)
    est = utc.new_offset(Rational(-5, 24))
    assert_in_delta TS.msd(utc), TS.msd(est), 1e-12
    assert_in_delta TS.mtc_hours(utc), TS.mtc_hours(est), 1e-12
  end

  def test_wikipedia_2026_aug_12
    # Wikipedia Timekeeping_on_Mars snapshot: 12 Aug 2026 00:25:08 UTC
    # JDTT = 2461264.51825, MSD = 54251.08514, MTC = 02:02:36
    dt = DateTime.new(2026, 8, 12, 0, 25, 8)
    assert_in_delta 2_461_264.51825, TS.jd_tt(dt), 5e-5
    assert_in_delta 54_251.08514, TS.msd(dt), 5e-5
    h, m, s = TS.mtc_hms(dt)
    assert_in_delta hms_to_hours(2, 2, 36), hms_to_hours(h, m, s), 2.0 / 3600.0
  end

  def test_mxt_vs_mtc
    dt = DateTime.new(2000, 1, 6, 0, 0, 0)
    frac = TS.sol_fraction(dt)
    assert_operator frac, :>=, 0
    assert_operator frac, :<, 1
    si = TS.mxt_si_seconds(dt)
    assert_in_delta frac * TS::SOL_SI_SECONDS, si, 1e-6
    mtc_h = TS.mtc_hours(dt)
    mxt_h = si / 3600.0
    assert_in_delta mtc_h * TS::SOL_DAYS, mxt_h, 1e-6
    assert_includes 88_775.0..88_776.0, TS::SOL_SI_SECONDS
  end

  def test_ls_j2000_region
    dt = DateTime.new(2000, 1, 6, 0, 0, 0)
    ls = TS.ls_deg(TS.jd_tt(dt))
    assert_in_delta 277.19, ls, 0.05
  end

  def test_earth_from_msd_round_trip
    dt = DateTime.new(2000, 1, 6, 0, 0, 0)
    back = TS.earth_from_msd(TS.msd(dt))
    assert_in_delta 0, (back - dt).to_f, 1e-9

    dt = DateTime.new(2026, 8, 13, 0, 6, 56)
    back = TS.earth_from_msd(TS.msd(dt))
    assert_in_delta 0, (back - dt).to_f, 1e-8
  end

  def test_year1_caption_treats_tt_as_ut
    r = TS.epoch_report
    assert_match(/no year-1/, r[:caveat])
    assert_equal(-665773, r[:epoch_msd])
    cap = r[:epoch_earth_if_tt_were_ut]
    assert_equal 1, cap.year
    assert_equal 1, cap.month
    assert_equal 23, cap.day
    assert_equal 13, cap.hour
    assert_equal 40, cap.min
    eq = r[:ls0_earth_if_tt_were_ut]
    assert_equal 1, eq.year
    assert_equal 1, eq.month
    assert_equal 24, eq.day
    assert_equal 5, eq.hour
    assert_equal 53, eq.min
  end

  def test_year1_equinox_sol
    hint = DateTime.new(1, 1, 22, 12, 0, 0)
    eq = TS.vernal_equinox_jd_tt(hint.ajd.to_f)
    ls = TS.ls_deg(eq)
    dist = [ls, (ls - 360).abs].min
    assert_operator dist, :<, 0.01, "year-1 Ls=0 search: Ls=#{ls} at JD_TT=#{eq}"
    m = TS.msd(jd_tt: eq)
    assert_operator m, :<, 0, "year-1 MSD should be before 1873 (got #{m})"
    frac = m % 1.0
    frac += 1 if frac < 0
    assert_operator frac, :>=, 0
    assert_operator frac, :<, 1
  end

  private

  def hms_to_hours(h, m, s)
    h + m / 60.0 + s / 3600.0
  end
end
