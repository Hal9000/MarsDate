# Official Mars time scales (NASA/Allison / Mars24).
#
#   Earth instant → JD (UT) → JD (TT) → MSD → MTC / MXT
#
# MTC = Coordinated Mars Time (24 stretched hours, Airy-0 mean midnight)
# MXT = Mars eXtended Time (SI hours, same midnight, day to ~24:39)

require 'date'

class MarsDateTime
  module TimeScale
    SOL_DAYS = 1.0274912517
    SECONDS_PER_DAY = 86_400.0
    SOL_SI_SECONDS = SOL_DAYS * SECONDS_PER_DAY # ~88775.244147
    TT_MINUS_TAI = 32.184

    # Mars24 C-2
    MSD_JDTT_OFFSET = 2_451_549.5
    MSD_EPOCH_SHIFT = 44_796.0
    MSD_FINE = 0.0009626

    J2000_JDTT = 2_451_545.0

    # IERS Leap_Second.dat (Bulletin 72, July 2026). Each row is the
    # UTC calendar date when TAI−UTC becomes that many seconds.
    TAI_UTC_STEPS = [
      [Date.new(1972, 1, 1), 10],
      [Date.new(1972, 7, 1), 11],
      [Date.new(1973, 1, 1), 12],
      [Date.new(1974, 1, 1), 13],
      [Date.new(1975, 1, 1), 14],
      [Date.new(1976, 1, 1), 15],
      [Date.new(1977, 1, 1), 16],
      [Date.new(1978, 1, 1), 17],
      [Date.new(1979, 1, 1), 18],
      [Date.new(1980, 1, 1), 19],
      [Date.new(1981, 7, 1), 20],
      [Date.new(1982, 7, 1), 21],
      [Date.new(1983, 7, 1), 22],
      [Date.new(1985, 7, 1), 23],
      [Date.new(1988, 1, 1), 24],
      [Date.new(1990, 1, 1), 25],
      [Date.new(1991, 1, 1), 26],
      [Date.new(1992, 7, 1), 27],
      [Date.new(1993, 7, 1), 28],
      [Date.new(1994, 7, 1), 29],
      [Date.new(1996, 1, 1), 30],
      [Date.new(1997, 7, 1), 31],
      [Date.new(1999, 1, 1), 32],
      [Date.new(2006, 1, 1), 33],
      [Date.new(2009, 1, 1), 34],
      [Date.new(2012, 7, 1), 35],
      [Date.new(2015, 7, 1), 36],
      [Date.new(2017, 1, 1), 37]
    ].freeze

    module_function

    # Astronomical Julian Date of the instant (offset-independent).
    def jd_ut(earth)
      earth.to_datetime.ajd.to_f
    end

    # TAI−UTC in seconds. Leap table from 1972-01-01; Mars24 polynomial
    # for 1900-01-01...1972-01-01. Earlier dates raise (no UTC).
    def tai_utc(earth)
      dt = earth.to_datetime
      date = dt.to_date
      if date >= TAI_UTC_STEPS.first[0]
        tai_utc_from_table(date)
      elsif date >= Date.new(1900, 1, 1)
        tt_utc_polynomial(jd_ut(dt)) - TT_MINUS_TAI
      else
        raise ArgumentError,
              "TAI−UTC is undefined before 1900-01-01 (got #{date}); " \
              "pass jd_tt: for antiquity"
      end
    end

    def tt_utc(earth)
      tai_utc(earth) + TT_MINUS_TAI
    end

    def jd_tt(earth, jd_tt: nil)
      return jd_tt.to_f if jd_tt
      jd_ut(earth) + tt_minus_ut(earth) / SECONDS_PER_DAY
    end

    # TT−UT in seconds. Leap table / polynomial from 1900; before
    # that, 0 (treat the civil digits as TT). Year-1 captions are
    # not a real ΔT model.
    def tt_minus_ut(earth)
      dt = earth.to_datetime
      return 0.0 if dt.to_date < Date.new(1900, 1, 1)
      tt_utc(dt)
    end

    # Mars Sol Date (Mars24 C-2).
    def msd(earth = nil, jd_tt: nil)
      j = jd_tt(earth, jd_tt: jd_tt)
      (j - MSD_JDTT_OFFSET) / SOL_DAYS + MSD_EPOCH_SHIFT - MSD_FINE
    end

    # Fractional sol in [0, 1).
    def sol_fraction(earth = nil, jd_tt: nil)
      frac = msd(earth, jd_tt: jd_tt) % 1.0
      frac += 1.0 if frac < 0
      frac
    end

    # MTC as hours in [0, 24).
    def mtc_hours(earth = nil, jd_tt: nil)
      sol_fraction(earth, jd_tt: jd_tt) * 24.0
    end

    def mtc_hms(earth = nil, jd_tt: nil)
      hours_to_hms(mtc_hours(earth, jd_tt: jd_tt))
    end

    # SI seconds since Airy-0 mean midnight (0 ... SOL_SI_SECONDS).
    def mxt_si_seconds(earth = nil, jd_tt: nil)
      sol_fraction(earth, jd_tt: jd_tt) * SOL_SI_SECONDS
    end

    def mxt_hms(earth = nil, jd_tt: nil)
      hours_to_hms(mxt_si_seconds(earth, jd_tt: jd_tt) / 3600.0)
    end

    def format_hms(h, m, s)
      format('%02d:%02d:%06.3f', h, m, s)
    end

    # Areocentric solar longitude Ls (degrees), Mars24 B-1…B-5.
    def ls_deg(jd_tt)
      dt = jd_tt.to_f - J2000_JDTT
      mean_anom = 19.3871 + 0.52402073 * dt
      alpha_fms = 270.3871 + 0.524038496 * dt
      pbs = mars_pbs(dt)
      nu_m = (10.691 + 3.0e-7 * dt) * sind(mean_anom) +
             0.623 * sind(2 * mean_anom) +
             0.050 * sind(3 * mean_anom) +
             0.005 * sind(4 * mean_anom) +
             0.0005 * sind(5 * mean_anom) + pbs
      wrap360(alpha_fms + nu_m)
    end

    # JD_TT of the northern vernal equinox (Ls = 0) nearest +around_jd_tt+.
    def vernal_equinox_jd_tt(around_jd_tt)
      year_days = 686.98 # Earth days per Mars tropical year, rough
      lo = around_jd_tt - year_days * 0.6
      hi = around_jd_tt + year_days * 0.6
      # Bracket a rising-through-0 crossing of Ls.
      step = 2.0
      t = lo
      prev = wrap180(ls_deg(t))
      pair = nil
      while t <= hi
        t += step
        cur = wrap180(ls_deg(t))
        if prev < 0 && cur >= 0
          pair = [t - step, t]
          break
        end
        prev = cur
      end
      raise "no Ls=0 crossing near JD_TT #{around_jd_tt}" unless pair
      a, b = pair
      60.times do
        mid = (a + b) / 2.0
        if wrap180(ls_deg(mid)) < 0
          a = mid
        else
          b = mid
        end
      end
      (a + b) / 2.0
    end

    # Civil DateTime corresponding to an astronomical JD, treated as UT.
    def datetime_from_ajd(ajd)
      DateTime.jd(ajd + 0.5)
    end

    def epoch_report
      # Allison Ls is fitted for ~1874–2127; year 1 is an extrapolation.
      # Seed the search at the article’s “late January of Year 1.”
      # Calendar::EPOCH_MSD is the frozen floor of this search.
      hint = DateTime.new(1, 1, 22, 12, 0, 0)
      around = hint.ajd.to_f
      eq_tt = vernal_equinox_jd_tt(around)
      eq_msd = msd(jd_tt: eq_tt)
      epoch_msd = eq_msd.floor.to_i
      midnight_tt = jd_tt_from_msd(epoch_msd)
      frac = eq_msd - epoch_msd
      {
        caveat: 'Allison Ls extrapolated to 1 CE; Earth times treat JD_TT as UT',
        ls0_jd_tt: eq_tt,
        ls0_msd: eq_msd,
        ls0_mtc: format_hms(*hours_to_hms(frac * 24.0)),
        ls0_earth_if_tt_were_ut: datetime_from_ajd(eq_tt),
        epoch_msd: epoch_msd,
        epoch_jd_tt: midnight_tt,
        epoch_earth_if_tt_were_ut: datetime_from_ajd(midnight_tt)
      }
    end

    def jd_tt_from_msd(msd)
      # invert Mars24 C-2
      ((msd - MSD_EPOCH_SHIFT + MSD_FINE) * SOL_DAYS) + MSD_JDTT_OFFSET
    end

    # Invert jd_tt: TT → UT. Before 1900, treat TT as UT.
    def jd_ut_from_jd_tt(jd_tt)
      j = jd_tt.to_f
      guess = j - 69.184 / SECONDS_PER_DAY
      8.times do
        earth = datetime_from_ajd(guess)
        if earth.to_date < Date.new(1900, 1, 1)
          return j
        end
        nxt = j - tt_utc(earth) / SECONDS_PER_DAY
        return nxt if (nxt - guess).abs < 1e-14
        guess = nxt
      end
      guess
    end

    def earth_from_msd(msd)
      datetime_from_ajd(jd_ut_from_jd_tt(jd_tt_from_msd(msd)))
    end

    def sol_fraction_of(msd)
      frac = msd.to_f % 1.0
      frac += 1.0 if frac < 0
      frac = 0.0 if frac >= 1.0
      frac
    end

    def tai_utc_from_table(date)
      value = TAI_UTC_STEPS.first[1]
      TAI_UTC_STEPS.each do |d, v|
        break if date < d
        value = v
      end
      value.to_f
    end

    # Mars24 A-4, dates before 1972 (used here only back to 1900).
    def tt_utc_polynomial(jd_ut)
      t = (jd_ut - J2000_JDTT) / 36_525.0
      64.184 + 59.0 * t - 51.2 * t**2 - 67.1 * t**3 - 16.4 * t**4
    end

    def mars_pbs(dt)
      terms = [
        [0.0071, 2.2353, 49.409],
        [0.0057, 2.7543, 168.173],
        [0.0039, 1.1177, 191.837],
        [0.0037, 15.7866, 21.736],
        [0.0021, 2.1354, 15.704],
        [0.0020, 2.4694, 95.528],
        [0.0018, 32.8493, 49.095]
      ]
      terms.sum do |amp, tau, phase|
        amp * cosd(0.985626 * dt / tau + phase)
      end
    end

    def hours_to_hms(hours)
      h = hours.floor
      minf = (hours - h) * 60.0
      m = minf.floor
      s = ((minf - m) * 60.0).round(4)
      if s >= 59.9995
        s = 0.0
        m += 1
      end
      if m >= 60
        m = 0
        h += 1
      end
      [h, m, s]
    end

    def sind(deg)
      Math.sin(deg * Math::PI / 180.0)
    end

    def cosd(deg)
      Math.cos(deg * Math::PI / 180.0)
    end

    def wrap360(deg)
      d = deg % 360.0
      d += 360.0 if d < 0
      d
    end

    def wrap180(deg)
      d = wrap360(deg)
      d -= 360.0 if d > 180.0
      d
    end
  end
end
