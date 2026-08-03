# 2026-08-02 — Steering Lemma proof check: confirmed bug in the prime-choice step

Code: `../code/steering_bug_check.py`. Cheap to recompute (milliseconds) — brief result log, not a
data archive. Full narrative: `../LOGBOOK.md` 2026-08-02 15:18 entry.

## What was checked

`article/lattice_line_covers_formal.tex`'s Steering Lemma proof chooses a prime $p$ via
eq:steering-p-choice, $L_0 < \varepsilon\mu n_1 p/n_2$ ($\mu=\tan\theta$ the target slope), then
claims (via eq:steering-final-bound, "using eq:steering-p-choice for the last step") that this
choice of $p$ makes $(n_2t/(n_1s)) $ land within $\varepsilon$ of $\mu$. Re-derived the algebra
directly: the p-choice inequality only implies $(n_2L_0)/(n_1p) < \varepsilon\mu$, not
$<\varepsilon$ — the two coincide only when $\mu\le1$.

## Result

**FAIL for $\mu=0$**: paper's condition reduces to $L_0<0$, unsatisfiable — no valid $p$ exists.

**FAIL for $\mu>1$**: reproduced the proof's own construction literally.
- $n_1=n_2=1$, $\mu=100$, $\varepsilon=0.01$: paper's condition gives $p>6$, chosen $p=7$; best
  available $t$ in the sieve-guaranteed window gives $|{\rm slope}-\mu|=0.142857$ — over $14\times$
  the claimed tolerance.
- Same setup, $\mu=10$, $\varepsilon=0.5$: paper's condition gives $p>1.2$, chosen $p=2$; best $t$
  gives $|{\rm slope}-\mu|=0.5$ — exactly at (not under) the claimed tolerance.

**PASS once the threshold is corrected** to be $\mu$-independent, $p>n_2L_0/(n_1\varepsilon)$
(directly implied by, and the actual content of, the true requirement
$(n_2L_0)/(n_1p)<\varepsilon$): re-ran both $\mu=100,\varepsilon=0.01$ and $\mu=10,\varepsilon=0.5$
with this threshold — both land comfortably within $\varepsilon$ ($0.0017$ and $0.077$
respectively).

## Bottom line

Confirmed, reproducible bug in the Steering Lemma's proof as written: eq:steering-p-choice should
not contain $\mu$ at all. Fix: replace with $L_0<\varepsilon n_1p/n_2$ (equivalently
$p>n_2L_0/(n_1\varepsilon)$). Not yet applied to any article draft — reported to Jan first.
