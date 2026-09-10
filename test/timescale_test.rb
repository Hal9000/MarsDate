#!/usr/bin/env ruby
# Tests for MarsDateTime::TimeScale (NASA/Allison / Mars24).
# Run: ruby test/timescale_test.rb

require_relative '../lib/marsdate/timescale'
require 'date'

module TestUtil
  module_function

  def assert(cond, msg)
    return if cond
    warn "FAIL: #{msg}"
    $ts_failures += 1
  end

  def assert_close(got, expected, tol, msg)
    assert((got - expected).abs <= tol, "#{msg} (got #{got}, expected #{expected} ± #{tol})")
  end

  def hms_to_hours(h, m, s)
    h + m / 60.0 + s / 3600.0
  end
end

module TimeScaleTests
  TS = MarsDateTime::TimeScale

  module_function

  def run
    tai_utc_table
    mars24_2000_jan_6
    offset_independent
    wikipedia_2026_aug_12
    mxt_vs_mtc
    ls_j2000_region
    year1_equinox_sol
  end

  def tai_utc_table
    TestUtil.assert_close(TS.tai_utc(Date.new(1972, 1, 1)), 10.0, 1e-9, 'TAI-UTC 1972-01-01')
    TestUtil.assert_close(TS.tai_utc(Date.new(1999, 6, 1)), 32.0, 1e-9, 'TAI-UTC mid-1999')
    TestUtil.assert_close(TS.tai_utc(Date.new(2000, 1, 6)), 32.0, 1e-9, 'TAI-UTC 2000-01-06')
    TestUtil.assert_close(TS.tai_utc(Date.new(2017, 1, 1)), 37.0, 1e-9, 'TAI-UTC 2017-01-01')
    TestUtil.assert_close(TS.tai_utc(Date.new(2026, 8, 13)), 37.0, 1e-9, 'TAI-UTC 2026')
    TestUtil.assert_close(TS.tt_utc(Date.new(2000, 1, 6)), 64.184, 1e-9, 'TT-UTC 2000-01-06')
    TestUtil.assert_close(TS.tt_utc(Date.new(2017, 1, 1)), 69.184, 1e-9, 'TT-UTC 2017+')
  end

  def mars24_2000_jan_6
    # Mars24 worked example: 2000-01-06 00:00:00 UTC → MST 23:59:39
    dt = DateTime.new(2000, 1, 6, 0, 0, 0)
    TestUtil.assert_close(TS.jd_ut(dt), 2_451_549.5, 1e-9, 'JD_UT 2000-01-06 00:00')
    TestUtil.assert_close(TS.jd_tt(dt), 2_451_549.500742407, 2e-6, 'JD_TT 2000-01-06')
    h, m, s = TS.mtc_hms(dt)
    hours = TestUtil.hms_to_hours(h, m, s)
    expected = TestUtil.hms_to_hours(23, 59, 39)
    TestUtil.assert_close(hours, expected, 1.5 / 3600.0, 'Mars24 MST 23:59:39 ±1.5s')
    TestUtil.assert(h == 23 && m == 59, "MST should be 23:59:xx, got #{TS.format_hms(h, m, s)}")
  end

  def offset_independent
    utc = DateTime.new(2000, 1, 1, 12, 0, 0)
    est = utc.new_offset(Rational(-5, 24))
    TestUtil.assert_close(TS.msd(utc), TS.msd(est), 1e-12, 'same instant → same MSD')
    TestUtil.assert_close(TS.mtc_hours(utc), TS.mtc_hours(est), 1e-12, 'same instant → same MTC')
  end

  def wikipedia_2026_aug_12
    # Wikipedia Timekeeping_on_Mars snapshot: 12 Aug 2026 00:25:08 UTC
    # JDTT = 2461264.51825, MSD = 54251.08514, MTC = 02:02:36
    dt = DateTime.new(2026, 8, 12, 0, 25, 8)
    TestUtil.assert_close(TS.jd_tt(dt), 2_461_264.51825, 5e-5, 'Wiki JD_TT 2026-08-12')
    TestUtil.assert_close(TS.msd(dt), 54_251.08514, 5e-5, 'Wiki MSD 2026-08-12')
    h, m, s = TS.mtc_hms(dt)
    hours = TestUtil.hms_to_hours(h, m, s)
    TestUtil.assert_close(hours, TestUtil.hms_to_hours(2, 2, 36), 2.0 / 3600.0, 'Wiki MTC 02:02:36')
  end

  def mxt_vs_mtc
    dt = DateTime.new(2000, 1, 6, 0, 0, 0)
    frac = TS.sol_fraction(dt)
    TestUtil.assert(frac >= 0 && frac < 1, 'sol fraction in [0,1)')
    si = TS.mxt_si_seconds(dt)
    TestUtil.assert_close(si, frac * TS::SOL_SI_SECONDS, 1e-6, 'MXT SI seconds = frac × sol')
    # Stretched 24h vs SI: MXT hours ≈ MTC hours × SOL_DAYS
    mtc_h = TS.mtc_hours(dt)
    mxt_h = si / 3600.0
    TestUtil.assert_close(mxt_h, mtc_h * TS::SOL_DAYS, 1e-6, 'MXT hours = MTC hours × sol/day')
    TestUtil.assert(TS::SOL_SI_SECONDS.between?(88_775.0, 88_776.0), 'sol length ~88775.244 s')
  end

  def ls_j2000_region
    # Mars24 example 2000-01-06: Ls ≈ 277.19°
    dt = DateTime.new(2000, 1, 6, 0, 0, 0)
    ls = TS.ls_deg(TS.jd_tt(dt))
    TestUtil.assert_close(ls, 277.19, 0.05, 'Ls on 2000-01-06 ≈ 277.19°')
  end

  def year1_equinox_sol
    hint = DateTime.new(1, 1, 22, 12, 0, 0)
    eq = TS.vernal_equinox_jd_tt(hint.ajd.to_f)
    ls = TS.ls_deg(eq)
    # Ls should be ~0 (or ~360)
    dist = [ls, (ls - 360).abs].min
    TestUtil.assert(dist < 0.01, "year-1 Ls=0 search: Ls=#{ls} at JD_TT=#{eq}")
    m = TS.msd(jd_tt: eq)
    TestUtil.assert(m < 0, "year-1 MSD should be before 1873 (got #{m})")
    # Equinox falls on some hour of that sol, not necessarily near midnight
    frac = m % 1.0
    frac += 1 if frac < 0
    TestUtil.assert(frac >= 0 && frac < 1, 'equinox sol fraction in [0,1)')
  end
end

$ts_failures = 0
TimeScaleTests.run
if $ts_failures.zero?
  puts 'All timescale tests passed.'
  exit 0
else
  warn "#{$ts_failures} failure(s)"
  exit 1
end
