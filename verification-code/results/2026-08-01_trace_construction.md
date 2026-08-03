# 2026-08-01 — numerical trace of the density construction

Code: `../code/trace_construction.py`. Cheap to recompute (seconds) — this is a brief result log,
not a data archive. Full narrative/derivation: `../LOGBOOK.md` 19:53 entry.

## Lemma check

200 random coprime $(p,q)$ pairs ($1\le p,q\le12$), each checked exhaustively against a $\pm40$
box: "on a level $\equiv c_0 \bmod pq$" and "in the target congruence class mod $(p,q)$" agree at
every point. **PASS.**

## Construction check, v1 (buggy)

Arbitrary target directions, realized via $M\cdot\rho$ inside index-$M$ sublattices.
$N=12$ box (625 points): **FAIL** — 519/625 points show illegal crossings. Root cause: conflated
"some multiple of the target lies in the sublattice" with "the target is cleanly realizable
there" (a line's footprint follows its primitive direction, not the multiple used to build it).

## Construction check, v2 (fixed: targets restricted to exactly $(n_1s, n_2t)$ form)

- $N=12$ (625 pts), naive target search (defaults to smallest valid $s$ first): **PASS**, but only
  realized 4 directions, all $(1,n)$ — search degenerated to the single-axis case (not a
  correctness bug, just an uninteresting target schedule).
- $N=40$ (6561 pts), same naive search: **PASS**, 6 directions, still $(2^k,3^k)$-degenerate.
- $N=40$ (6561 pts), target search forced to prefer large/varied diagonal $s$ (rotating start
  point, hitting $s\in\{15,29,41,7,21,33,47,\dots\}$ — genuine primes/near-primes, not small toy
  values): **PASS** — 0 bad crossings, full coverage, 7 genuinely diagonal directions realized.
  This is the run that actually stress-tests the fixed mechanism under non-degenerate conditions.

## Bottom line (before the 20:04 review)

The fixed construction's mechanism (coset lemma + disjointness argument, applied recursively) is
numerically sound on every instance tried, including deliberately adversarial diagonal jumps. Not
covered by numerics: the infinite/asymptotic claim that a dense target *schedule* achieves true
density of directions in the limit — that part is under independent review (see `LOGBOOK.md`).

## Update: sign fix, re-verified independently (post 20:04 review)

Independent Opus review found `s,t>=2` forces every realized direction to strictly positive slope
(only half of $S^1$ reachable) — fixed in `pick_target` by allowing `|s|,|t|>=2` with free signs,
residue/modulus arithmetic done on magnitudes throughout. Re-ran independently (not just trusting
the review's own check):

- Default search (tries negative `t` before positive by construction order): still 0 crossings,
  full coverage, $81\times81$ box.
- Explicit sign-alternating schedule
  ($(s,t)=(2,-3),(2,3),(-2,-3),(2,3),(2,-3),(-2,3)$, monkey-patching `pick_target` for the test):
  0 crossings, full coverage, 6 directions realized — 3 positive-slope, 3 negative-slope, within
  the *same* family. Confirms the fix directly, not just "no crash."

Not independently re-verified here (trusted from the review, since it's a finite/checkable claim
they already exhibited numerically): the density-*steering* argument (hitting an arbitrary target
ratio within a window, not just finding some admissible move) — see `LOGBOOK.md` 20:04 entry for
the argument and their reported numerical check against 8 target ratios.
