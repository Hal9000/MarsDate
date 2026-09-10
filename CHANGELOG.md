# Changelog

## 2.0.0

Breaking rewrite. `MarsDateTime` stores one MSD. 00:00 is Airy-0
mean midnight (MTC). MXT is the same instant in SI hours.

- Civil constructors: `mxt` / `new(y,m,sol,…)` (MXT), `mtc`, `at(msd)`
- Views: `md.mxt` / `md.mtc`; `format` (not `strftime`); `%Z` is the clock name
- `today` is the current MCE sol at 00:00; `now` is the current instant
- Year-1 Earth times are TT-as-UT captions (`epoch_caption`)
- See `README.md` and `design-issues.md`
