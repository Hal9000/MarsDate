# Martian timezones (theory only)

**Parked.** Largely irrelevant for the foreseeable future. 2.0 is
Airy-0 only: one MSD, **MTC** (official) and **MXT** (SI ruler, same
midnight). `%Z` is the clock name (`MXT` / `MTC`), not a zone.
Longitude / LMST / `Airy+N` are not implemented. Do not build this
until someone off the prime meridian needs a wall clock.

Related: `design-issues.md` (deferred longitude/LMST), README
article (Airy-0 as Greenwich; zones optional; no DST).


## What a “zone” is

Geography on top of MTC, not a new epoch. One instant, one MSD. A
timezone only answers: *whose midnight is 00:00 on the wall clock?*

Missions today: **MTC** to coordinate, **LMST at the site** to live.
One base can do the same. Named planet-wide offsets matter when
several civil communities want noon near 12:00 and still to talk.


## 15° slices and Airy+N

On **MTC**, 15° is exactly one hour.

`Airy+3` = mean solar time 45° east of Airy-0 = `MTC + 3h`
(same idea as `UTC+3`).

**Do not define `Airy+N` in MXT hours.** MXT’s day is ~24h 39m SI,
so 15° is ~1h 01m 39s SI, not 1 MXT hour. `Airy+N` means **N MTC
hours = 15° × N**. Local MXT, if wanted later, is SI hours since
*that zone’s* (or that site’s) mean midnight.

A rover is a **point**, not a zone. Spirit, Opportunity, Curiosity,
Perseverance each had their own LMST. “Jezero time” / “Gale time” /
“Airy time” are good colloquial names for a settlement’s meridian.

Civil law wants a **shared** clock: everyone in a slice agrees, even
if the crater is at 47°E and the zone is Airy+3 (45°E). Earth does
that (Spain ≠ solar noon).

- **Official:** `Airy−11` … `Airy+12` (or whatever range we pick)
- **Nickname:** Hellas, Jezero, Olympus — alias for one offset or
  one longitude
- **Science site:** exact λ, not a slice

Same math (`λ/15`), different rounding.


## LMST vs LTST

| | What | Civil timezone? |
|---|---|---|
| **LMST** | Mean sun, 24 equal MTC-length hours | **Yes.** This *is* a timezone. |
| **LTST** | True sun; noon when the sun transits | **No.** |

`Airy+N` = **LMST of the zone meridian.**

LTST is instant + longitude (Allison series already in
`TimeScale`) — sun hour angle, not a zone, not `%Z`. Mars’s
equation of time is ~±50 minutes (e ≈ 0.09), much larger than
Earth’s ~16 min. If zones used LTST, `Airy+3` would drift through
the year. Landers want LTST for panels and shadows. Calendars and
trains want LMST.

**Sign.** IAU east-positive: `LMST = MTC + λ_east/15`. Older
west-positive Mars maps flip that. Prefer east-positive and
document it. The old note `MTC − λ/15` assumed west longitude.


## Dateline

Only if the **MCE date is local**. Then 180° from Airy-0 is the
default line: west of it one sol, east the other, at the same MSD.

`Airy+12` and `Airy−12` are the **same meridian**. You cannot have
both as civil dates. Pick one owner of 180° (Earth’s +12/+13 mess
is politics). Zigzags wait for cities.

If the civil date is **always Airy-0’s sol** and locals only offset
the clock, there is **no dateline** — and “Tuesday 23:00” MTC can
be “Wednesday 11:00” on the wall at Airy+12. That is the README’s
“dispense with zones” option. Fine for a handful of bases; hostile
for a planet-wide newspaper.

Define the line in theory (antimeridian, `Airy+12` owns it). Do
not implement until local dates exist.


## If this is ever coded

A view of the same MSD, not a second store:

```ruby
md.lmst(lambda_east)     # or md.at_longitude(...)
# same instant; HMS (and maybe the civil sol) at that meridian
```

`%Z` stays `MXT` / `MTC`. A local label is a **different** token —
do not reuse `%Z` for `Airy+3`.

DST: no.


## Lock in prose (still not code)

- Official time: **MTC** (MXT = SI ruler at the same Airy-0 midnight).
- Local civil time, if any: **LMST**, optionally snapped to `Airy+N`.
- Nicknames are aliases, not a third math.
- Dateline = 180° only if dates are local; otherwise omit.
- LTST = astronomy helper, never a zone.
