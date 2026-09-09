# Design decisions before MarsDateTime can be “fixed”

Some defects are ordinary bugs. The clock/calendar core is not: it
cannot be rewritten coherently until the object’s *meaning* is decided.

Related: `ai-notes.txt` (findings), `test/probe_marsdate.rb` (probes),
`conversation.md` (review thread).

Status key: **must decide** · **decide soon** · **can wait** · **no design needed**


## Decisions so far

- **1.** 00:00 is official MTC (Airy-0 mean midnight). Not a slid
  Earth-midnight epoch.
- **5.** Keep both clocks as *views* of one SI duration since MTC
  midnight. Do not store two parallel HMS fields. Naming undecided:
  stretched/MTC vs SI, unstretched, or **extended** (24:39 clock:
  extend the *day*, not the units). “Canonical” is a poor label.
  Wanted: a 3-letter complement to MTC. Candidates: **MXT** (Mars
  eXtended Time), **MTE** (Mars Time Extended). Avoid **MET** (NASA
  Mission Elapsed Time) and **MST** (Airy Mean Time / Earth MST).


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

### 2. How clock and calendar relate

Split:

- **Clock** — Earth instant → JD_TT → MSD → MTC (NASA/Allison).
  Time of day *is* MTC (24 stretched hours). Canonical 24:39, if kept,
  is another readout of the same fraction of a sol.
- **Calendar** — integer MSD (which sol) → MCE year/month/sol with
  the existing leap rules.

MCE labels sols. It does not define midnight.

### 3. Which sol is 1/1/1

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

### 4. Compatibility

Fixing midnight will change `now`, `earth_date`, weekdays, and
README examples. Is a breaking change acceptable, or is a
compatibility flag / old-epoch constructor required?


## Decide soon (not blocking a first MTC-based rewrite)

### 5. Canonical 24:39 clock — decided: keep as a view

Keep both clocks. Store one SI quantity (real ms since MTC midnight,
or the fractional part of MSD). Print/retrieve as stretched 24h
(MTC) or as canonical 24:39 (SI hours/minutes/seconds).

These are not two midnights. They are two rulers from the same 00:00.
No physical inconsistency if both are derived on demand from the
store. Do not persist `@mhrs/@mmin/@msec` and `@shr/@smin/@ssec`
separately (that is how they can disagree today).

**Open (API):** `MarsDateTime.new(y, m, d, h, min, s)` is then
ambiguous. A keyword with a default is enough, e.g.
`clock: :stretched` (MTC) or `clock: :canonical`, rather than a
7th positional argument.

That does not finish the job. Unmarked accessors (`hr` / `min` /
`sec`) and `strftime` `%H:%M:%S` still have to mean one scale —
unless **both** scales are marked and there is no default `hr`/`%H`.
Library has essentially no dependents, so dropping unmarked names
is acceptable (not a serious compatibility concern).

Leaning: mark both. Accessors like `mtc_hour` / `canonical_hour`
(and minutes/seconds). `to_s` prints both, labeled.

`strftime` is a C/Ruby Time leftover; `%H` is unmarked. Options
(see discussion): two methods (`format_mtc` / `format_canonical`);
one method plus `clock:`; clock-view objects (`mtc.strftime`);
or drop format strings and return HMS / ISO-like strings.

Arithmetic in seconds should stay SI (or sols), not “stretched
seconds.” Round-trip each display through the store without going
through the other display’s rounded HMS.

### 6. Earth DateTime with a non-zero offset

Honor `offset` (treat the value as a real instant), or document that
the Y/M/D/h/m/s numbers are taken as UTC? Today the code ignores
offset and uses the wall clock, so the same instant converts two
ways.

### 7. Precision (TT vs UTC)

True MTC needs TT−UTC (leap-second table; ~69.184 s now, Mars24
polynomial before 1972). Ignore it and MTC is about a minute off,
not 11 hours. How close is “honor official time”?

### 8. Invalid Y/M/D/H/M/S

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

Longitude / LMST (`MTC − λ/15°`). What `today` vs `now` means.
YAML ivar names, `strftime` nits (`%s`, trailing `%`). CLI (`m2e`
drops time; `calendar yyyy` ignores the year).


## No design needed (ordinary bugs)

These do not define Mars time and can be fixed anytime:

- `check_ymshms` allows Taurus 26–28 in leap years
- Stretched seconds can round to 60
- `Date` is rejected by `-` and `<=>` even though the constructor accepts it
- CLI calendar arity; `m2e` ignores `hh:mm:ss`
- `to_yaml_properties` names `@myear` / `@msme` (actual: `@year` / `@mems`)
- Sub-second truncation on Earth↔Mars round-trips (once the clock
  definition is fixed, do this in the same rewrite)
