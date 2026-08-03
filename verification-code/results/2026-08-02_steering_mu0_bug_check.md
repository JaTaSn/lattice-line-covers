# 2026-08-02 — Steering Lemma proof check: confirmed second bug, at $\mu=0$

Code: `../code/steering_mu0_bug_check.py`. Cheap to recompute (milliseconds) — brief result log,
not a data archive. Full narrative: `../LOGBOOK.md` 2026-08-02 20:36 entry. Found by an independent
Opus-backed review agent, triggered by a first-pass suspicion raised inline before delegating.

## What was checked

The Steering Lemma's proof (post the earlier $\mu$-factor threshold fix, `2026-08-02_steering_bug_
check.md`) picks $s=p$ (a growing prime) and searches for $t$ in the window $I=[t_0,t_0+L_0)$,
$t_0=\lfloor\mu n_1p/n_2\rfloor$, $L_0$ a constant depending only on $n_1$. The proof asserts
"(for $p$ large) $|t|\ge2$" without justification. Checked directly whether this window structurally
guarantees a witness with $|t|\ge2$.

## Result

**FAIL at $\mu=0$**: $t_0=\lfloor0\rfloor=0$ for every $p$, so $I=[0,L_0)$ never moves as $p$ grows
— confirmed identical windows for $p=307$ and $p=100003$. Since $\gcd(1,n_1p)=1$ always, $t=1$ is
always a valid coprime witness; in fact it is the *closest-to-target* candidate (the natural one to
pick), since it minimizes $|n_2t/(n_1p)-0|$ among positive $t$. So the construction's most natural
witness-selection literally returns $t=1$, violating the lemma's own $|t|\ge2$ requirement.

**Contrast, $\mu=1$**: window does move with $p$ ($t_0=220$ at $p=331$), so this particular case
was never broken — the failure is specific to $\mu$ exactly $0$ (and, by the symmetric "swap $s,t$"
branch, to $\theta=\pi/2$).

**PASS once the window is shifted** to $t_0=\lfloor\mu n_1p/n_2\rfloor+2$: at $\mu=0$ this gives
$t_0=2$ for every $p$ (windows $[2,22)$ at both $p=307$ and $p=100003$), so every candidate
satisfies $|t|\ge2$ by construction, no largeness argument needed. Re-checked $\mu=1,p=331$ under
the shift too (window $[222,242)$, closest candidate $t=223$) — matches the corresponding worked
numeric example in `article/lattice_line_covers_pedantic.tex`.

## Bottom line

Confirmed, reproducible gap in the Steering Lemma's proof, distinct from (though same root
degeneracy as) the earlier $\mu$-factor bug: the "$|t|\ge2$ for $p$ large" step was never actually
established at $\mu=0$. The *lemma statement* was never false (a direct ad hoc argument works fine
at $\mu=0$), only this proof's mechanism for producing a witness. Fixed in all four `article/*.tex`
drafts by shifting the search window by $+2$ (and the threshold accordingly, still $\mu$-independent);
also fixed an unrelated wrong displayed equality in the same proof ($|t-t_0|$ should have been
$|t-\mu n_1p/n_2|$, since $t_0$ is a floor of the target, not the target itself) and added the
missing $\arctan$-Lipschitz sentence bridging slope-closeness to $\mathbb{RP}^1$ direction-closeness.
