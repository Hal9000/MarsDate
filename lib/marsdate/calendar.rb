# MCE civil calendar on the official Mars timeline.
# Does not change MarsDateTime constructors or fields.
#
#   integer MSD = EPOCH_MSD + sol_index(year, month, sol)
#
# EPOCH_MSD is the integer Mars Sol Date of 1/1/1 00:00 MTC: the
# Airy-0 midnight of the sol that contains the year-1 northern
# vernal equinox (Allison Ls=0). Provisional: Allison is fitted
# ~1874–2127; year 1 is an extrapolation. See TimeScale.epoch_report.

class MarsDateTime
  module Calendar
    EPOCH_MSD = -665_773
    SOLS_COMMON = 668
    SOLS_LEAP = 669
    MONTHS_OF_28 = 23
    MEAN_YEAR = 668.591

    module_function

    # Same intercalation as MarsDateTime.leap? (MCE: /100 except /1000).
    def leap?(year)
      return (year % 2 == 1) if (year % 10 != 0)
      return true if (year % 1000 == 0)
      return false if (year % 100 == 0)
      true
    end

    def sols_in_year(year)
      leap?(year) ? SOLS_LEAP : SOLS_COMMON
    end

    def sols_in_month(month, year)
      return 28 if month < 24
      leap?(year) ? 25 : 24
    end

    # Leap years in 1..n inclusive. Closed form of the MCE rule.
    def leaps_through(n)
      return 0 if n <= 0
      odds = (n + 1) / 2
      tens = n / 10
      centuries = n / 100
      millennia = n / 1000
      odds + tens - centuries + millennia
    end

    def leaps_before(year)
      year <= 1 ? 0 : leaps_through(year - 1)
    end

    # 0-based sol index of 1/1 of +year+ (1/1/1 → 0).
    def sols_before_year(year)
      (year - 1) * SOLS_COMMON + leaps_before(year)
    end

    def check_ymd!(year, month, sol)
      text = +""
      text << "year #{year} is not a positive integer\n" unless year.is_a?(Integer) && year >= 1
      text << "month #{month} is out of range\n" unless month.is_a?(Integer) && (1..24).include?(month)
      text << "sol #{sol} is out of range\n" unless sol.is_a?(Integer) && (1..28).include?(sol)
      if year.is_a?(Integer) && month == 24 && sol.is_a?(Integer)
        max = sols_in_month(24, year)
        text << "sol #{sol} is invalid in Taurus of year #{year}\n" if sol > max
      end
      raise ArgumentError, text unless text.empty?
    end

    # 0-based sols since 1/1/1.
    def sol_index(year, month, sol)
      check_ymd!(year, month, sol)
      sols_before_year(year) + (month - 1) * 28 + (sol - 1)
    end

    # Integer MSD of Airy-0 midnight of that MCE date.
    def msd_midnight(year, month, sol)
      EPOCH_MSD + sol_index(year, month, sol)
    end

    # Instant MSD: date + fraction of a sol in [0, 1).
    def msd_at(year, month, sol, frac = 0.0)
      unless frac.is_a?(Numeric) && frac >= 0.0 && frac < 1.0
        raise ArgumentError, "sol fraction must be in [0, 1) (got #{frac.inspect})"
      end
      msd_midnight(year, month, sol) + frac.to_f
    end

    def ymd(index)
      unless index.is_a?(Integer) && index >= 0
        raise ArgumentError,
              "sol index must be a non-negative integer (got #{index.inspect})"
      end
      year = (index / MEAN_YEAR).floor + 1
      year = 1 if year < 1
      16.times do
        start = sols_before_year(year)
        stop = start + sols_in_year(year)
        if index >= start && index < stop
          return ymd_in_year(year, index - start)
        end
        year += 1 if index >= stop
        year -= 1 if index < start
        year = 1 if year < 1
      end
      raise "year search failed for sol index #{index}"
    end

    def ymd_from_msd(msd)
      ymd(msd.to_f.floor - EPOCH_MSD)
    end

    # Sunday = 0, same as MarsDateTime#dow on 1/1/1.
    def dow(year, month, sol)
      sol_index(year, month, sol) % 7
    end

    def ymd_in_year(year, offset)
      if offset < MONTHS_OF_28 * 28
        month = offset / 28 + 1
        sol = offset % 28 + 1
      else
        month = 24
        sol = offset - MONTHS_OF_28 * 28 + 1
      end
      [year, month, sol]
    end
    private_class_method :ymd_in_year
  end
end
