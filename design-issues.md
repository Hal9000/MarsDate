# Design decisions before MarsDateTime can be “fixed”

Some defects are ordinary bugs. The clock/calendar core is not: it
cannot be rewritten coherently until the object’s *meaning* is decided.

Related: `ai-notes.txt` (findings), `test/probe_marsdate.rb` (probes),
`conversation.md` (review thread).

Status key: **must decide** · **decide soon** · **can wait** · **no design needed**


## Established decisions

These are agreed. `MarsDateTime` 2.0 stores MSD and implements
them. Constructors: `mxt` / `mtc` / `at` / `new` (MXT civil).
Views: `md.mxt` / `md.mtc` (`strftime` `%H` is that clock).
Unmarked `strftime` `%H` is still MTC; `%P` is MXT. Formatter
rename (`format` / `format_mxt` / `format_mtc`) is a lean, not
coded — see below.

**Midnight and epoch**

- 00:00 is official **MTC**: Airy-0 mean solar midnight, from JD in
  Terrestrial Time via MSD (NASA/Allison). Not Earth UTC midnight
  of the overlapping civil date.
- Do **not** “fudge” the old epoch by ~11h 19m. That constant is a
  snapshot of a wrong definition; it drifts and is not MTC.
- Keep the **concept** of an MCE epoch: Year 1, the 1.88 year-number
  ratio, `epoch_sol`. The epoch instant is Mars 1/1/1 00:00:00 MTC
  (= the same instant as 1/1/1 00:00:00 MXT). Store it as an
  integer MSD (or that JD_TT). Do not parse
  `DateTime.new(1, 1, 22, 0, 0, 0)` as the converter’s zero.
- Publish Earth UTC (and TT if useful) of that midnight as a
  **caption**, like “Unix epoch = 1970-01-01 00:00:00 UTC.” Also
  publish Earth time of `Ls=0` on that sol (hours later). Neither
  Earth datetime is an input to the converter.
- **Year-1 ΔT: do not model it.** Before 1900, TT−UT = 0 (civil
  digits are TT). Captions today: 1/1/1 00:00 ≈ **0001-01-23
  13:40**, `Ls=0` ≈ **0001-01-24 05:53** (Julian, TT as UT).
  `MarsDateTime.epoch_caption` / `TimeScale.epoch_report`. A real
  1 CE ΔT is a few hours and would only slide these strings.
  Allison Ls is already out of sample (~1874–2127). `EPOCH_MSD`
  does not depend on ΔT.

**Clocks (one timeline)**

- Store **one** SI duration since that midnight (real ms into the
  sol, or the MSD fraction). Derive displays from it. Do not store
  two HMS triples.
- **MTC** (Coordinated Mars Time): stretched 24-hour labels; official
  interop (Mars24, MSD).
- **MXT** (Mars eXtended Time): SI hours/minutes/seconds; the day
  runs to ~24:39. MCE’s preferred *civil notation*. Same midnight
  as MTC — not a second timeline. Avoid the label “canonical.”
  Avoid MET (mission elapsed) and MST (already used).
- Arithmetic in seconds is SI (or whole sols), never “stretched
  seconds.” Round-trip each display through the store; do not
  convert via the other clock’s rounded HMS.
- Sol interval is half-open `[0, sol_length)` so the endpoint is
  one date only. Next instant after last MXT / 24:00:00 MTC is
  the next date 00:00:00.

**Calendar**

- **1/1/1** is the sol that **contains** the year-1 northern vernal
  equinox (`floor(MSD of Allison Ls=0)`). 00:00 of that sol is
  Airy-0 midnight, not the equinox instant. Where `Ls=0` falls
  *on* that sol is hours only (document it; ignore it for dating).
- Year numbering stays anchored near 1 CE so the ~1.88 ratio
  survives. Leap rules stay MCE for now (`/100` except `/1000`).
- MCE names the sol and prefers MXT on that sol. MTC is the
  imported standard view of the same instant.
- **`today`** is the current MCE sol at 00:00 (`mxt(now.year,
  now.month, now.sol)`). **`now`** is the current instant.
  `today` is not Earth `Date.today` at 00:00.

**API / compatibility**

- Breaking change: no compatibility flag or old-epoch constructor.
  Essentially no dependents.
- Mark both clocks (no unmarked `hr` / `%H` that silently picks a
  scale). Formatter shape still open: clock views (`md.mtc` /
  `md.mxt`), two format methods, or `clock:`. `strftime` is a
  Time leftover; `%H` stays unmarked unless scoped.
- Constructors: reject invalid Y/M/D/H/M/S (Taurus past 24/25;
  MXT past the end of the sol). Arithmetic (`+`, from MSD) rolls
  into the next sol. Same pattern as Ruby `DateTime.new` vs `+`.

**Time scales**

- Convert Earth instants via **TT** (TT = TAI + 32.184 s; TAI−UTC
  from a vendored leap-second table; Mars24 polynomial before
  1972). No extra gem required. `iers` / `horologium` optional
  later if leaps resume and we do not want to bump a table.

**Computed (provisional)**

`MarsDateTime::TimeScale` (`lib/marsdate/timescale.rb`) implements
UTC→TT→MSD→MTC/MXT for 1972+ (IERS leaps) and matches Mars24
(2000-01-06 00:00 UTC → MTC 23:59:39.3). Tests:
`ruby test/timescale_test.rb` (Minitest).

`MarsDateTime::Calendar` (`lib/marsdate/calendar.rb`) maps MCE
year/month/sol onto that timeline. Leap rules are unchanged
(`/100` except `/1000`; closed-form `leaps_through`).
`MarsDateTime` constructors use this mapping. Tests:
`ruby test/calendar_test.rb` (Minitest).

Year-1 `Ls=0` from the same Allison series (out of sample; fitted
~1874–2127), seeding at 1 Jan 22:

- `Ls=0` MSD ≈ −665772.342 (MTC ~15:47 on that sol)
- **EPOCH_MSD = −665773** (`floor`) — `Calendar::EPOCH_MSD`
- Earth caption if JD_TT is read as UT: epoch midnight
  ≈ 0001-01-23 13:40, equinox ≈ 0001-01-24 05:53
  (Julian civil dates in Ruby). ΔT at 1 CE is a few hours; do
  not treat these captions as final.

**Still open**

- Earth `DateTime` with a non-zero offset: honor the instant, or
  treat the digits as UTC? (parked)
- Formatter rename (lean below; not coded). No `clock:` keyword.
- Leap `/500`, Darian, longitude/LMST (deferred)

**Formatter lean (not coded)**

`strftime` only approximates Ruby `Time#strftime` (`%P`/`%Q`/`%R`
are ours; `%s` is not Unix; unknown tokens pass through). Keep the
specifier table; drop the antique name as the primary API.

```
md.format(fmt)            # date tokens + MXT for %H/%M/%S/%X
md.format_mxt(fmt = nil)  # nil → HMS (what format_mxt is now)
md.format_mtc(fmt = nil)  # nil → HMS
md.mxt.format(fmt = nil)  # %H is this clock
md.mtc.format(fmt = nil)
md.strftime               # alias of format (parent and views)
```

Parent `format` uses **MXT** so it matches `new(y,m,sol,h)` (civil).
MTC is by name: `format_mtc` / `md.mtc`. No `clock:` keyword.
Invented `%P`/`%Q`/`%R` can die once views exist; until then they
stay as “the other clock.” `to_s` stays the labeled prose sentence.
Do not implement until this lean is accepted.


## Must decide before a real fix

### 1. What 00:00 is — decided: MTC

Official MTC (Airy-0 mean midnight, from JD in Terrestrial Time via
MSD), or keep the current zero: UTC midnight of the overlapping Earth
date (1 Jan 22 00:00 UTC = Mars 1/1/1 00:00)?

The latter is what the code does. It was not the intended design
(“Earth midnight = Mars midnight”). It produces the ~11h 19m gap
versus Coordinated Mars Time.

Honoring official Mars time means 00:00 is MTC. Do **not** bake the
11h 19m offset into a slid Year-1 Earth midnight; that would drift
and still not be MTC.

### 2. How clock and calendar relate — decided: one midnight; MXT is MCE’s face

Split:

- **Clock** — Earth instant → JD_TT → MSD → MTC (NASA/Allison).
  Time of day *is* MTC (24 stretched hours). MXT, if kept,
  is another readout of the same fraction of a sol.
- **Calendar** — integer MSD (which sol) → MCE year/month/sol with
  the existing leap rules.

MCE labels sols. It does not define midnight.

### 3. Which sol is 1/1/1 — decided: sol containing Ls=0

Keep year 1 near the 1 CE northern vernal equinox so year numbers
keep the ~1.88 ratio.

Then pick the sol:

- the sol **containing** that equinox, or
- the first Airy-0 midnight **after** it, or
- the first Airy-0 midnight **before** it.

**1/1/1 00:00** should be that sol’s Airy-0 mean midnight, **not**
the equinox instant. If 00:00 is the equinox, the clock is no longer
MTC (the equinox is not at Airy-0 midnight). Civil midnight first;
equinox as the *date*.

### 4. Compatibility — decided: break; keep epoch as a Mars instant

Fixing midnight will change `now`, `earth_date`, weekdays, and
README examples. Is a breaking change acceptable, or is a
compatibility flag / old-epoch constructor required?


## Decide soon (not blocking a first MTC-based rewrite)

### 5. Second clock — decided: MXT as a view

Keep both clocks. Store one SI quantity (real ms since MTC midnight,
or the fractional part of MSD). Print/retrieve as MTC (stretched
24h) or MXT (SI hours/minutes/seconds, day to ~24:39).

These are not two midnights. They are two rulers from the same 00:00.
No physical inconsistency if both are derived on demand from the
store. Do not persist `@mhrs/@mmin/@msec` and `@shr/@smin/@ssec`
separately (that is how they can disagree today).

**Open (API):** `MarsDateTime.new(y, m, d, h, min, s)` is then
ambiguous. A keyword with a default is enough, e.g.
`clock: :mtc` or `clock: :mxt`, rather than a 7th positional
argument.

That does not finish the job. Unmarked accessors (`hr` / `min` /
`sec`) and `strftime` `%H:%M:%S` still have to mean one scale —
unless **both** scales are marked and there is no default `hr`/`%H`.
Library has essentially no dependents, so dropping unmarked names
is acceptable (not a serious compatibility concern).

Leaning: mark both. Accessors like `mtc_hour` / `mxt_hour`.
`to_s` prints both, labeled.

`strftime` is a C/Ruby Time leftover; `%H` is unmarked. Current
code: parent `%H` = MTC, `%P` = MXT; views scope `%H`. Proposed
rename is in **Formatter lean** above (not coded).

Arithmetic in seconds should stay SI (or sols), not “stretched
seconds.” Round-trip each display through the store without going
through the other display’s rounded HMS.

### 6. Earth DateTime with a non-zero offset

Honor `offset` (treat the value as a real instant), or document that
the Y/M/D/h/m/s numbers are taken as UTC? Today the code ignores
offset and uses the wall clock, so the same instant converts two
ways.

### 7. Precision (TT vs UTC) — decided: TT, vendored table, no gem required

True MTC needs TT−UTC (leap-second table; ~69.184 s now, Mars24
polynomial before 1972). Ignore it and MTC is about a minute off,
not 11 hours. How close is “honor official time”?

### 8. Invalid Y/M/D/H/M/S — decided: reject on construct; roll on arithmetic

Reject (Taurus sols 26–28 in a leap year; 24:40–24:59) or roll into
the next sol? Today they are stored as written while `@mems` has
already overflowed, so accessors and arithmetic disagree.


## Can wait

### 9. Leap intercalation

Keep MCE (`/100` except `/1000`, mean year 668.591) or adopt Darian’s
`/500` (tighter to the vernal-equinox year)? This is millennial
seasonal drift, not the 11h clock bug.

### 10. Darian conversions

Which Darian (epoch, intercalation era, month names)? Convert via a
sol index / MSD, not field-by-field. Date-only conversion is
ambiguous until MCE sol boundaries match Airy-0 midnight. MSD/MTC
*instant* converters can be added earlier.

### 11. Later API

Longitude / LMST (`MTC − λ/15°`). YAML ivar names. `strftime` nits
(`%s`, trailing `%`) until the formatter rename. CLI calendar year
and `m2e` time are done.


## No design needed (ordinary bugs)

These do not define Mars time and can be fixed anytime:

- `check_ymshms` allows Taurus 26–28 in leap years
- Stretched seconds can round to 60
- `Date` is rejected by `-` and `<=>` even though the constructor accepts it
- CLI calendar arity; `m2e` ignores `hh:mm:ss`
- `to_yaml_properties` names `@myear` / `@msme` (actual: `@year` / `@mems`)
- Sub-second truncation on Earth↔Mars round-trips (once the clock
  definition is fixed, do this in the same rewrite)
