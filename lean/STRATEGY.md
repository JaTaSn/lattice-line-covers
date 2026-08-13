# Formalization strategy

This document describes *how* the proof in this directory was built — the architectural decisions
and working methodology — as distinct from `PROOF.md` (what was proved) and `../HISTORY.md` (the
narrative of how the process actually unfolded, including the mistakes found along the way).

## The paper draft as the formalization's working guide

The mathematics was not developed directly in the eventual LaTeX submission file. It was worked out
in a [Typst](https://typst.app/) working draft, `../article/lattice_line_covers_pedantic.typ`, kept
in this repository unmodified from its state during active development — the same file used to
guide the Lean formalization, not a separate specification written after the fact. Two custom
annotation environments ran throughout that draft:

- **`leanstatus` blocks** — a short note placed directly under each lemma/theorem recording its
  formalization status as work progressed (not yet started, in progress, proved and independently
  verified), so the state of the Lean development was always visible in the same document as the
  mathematical statement it corresponded to, rather than tracked separately.
- **`pedanticexample` blocks** — working notes only, never intended to survive into the final
  article (set in red and explicitly labeled as such in the draft itself): a concrete numeric
  instantiation of a lemma's hypotheses and conclusion, showing both a case where it holds and a
  case violating one hypothesis, to make abstract statements checkable by eye before — or instead
  of — formalizing them.

Once the formalization was complete, the submission-track article was produced by mechanically
stripping every `leanstatus`/`pedanticexample` block and the "Formalization status" section from
this working draft (see the changelog comment at the top of the `.typ` file itself for the exact
history of that split). The working draft is kept here as-is — warts, annotations, changelog
comments and all — as a transparent record of how the proof was actually built, in the same spirit
as `references/REFERENCES.md`'s certificate-of-existence approach to citations: showing the actual
process rather than only asserting a clean result. It is not maintained further and may not compile
standalone in this location (it depends on figure assets from the working repository's own
directory layout) — it is included for documentation, not as a build target.

## Bottom-up, matching the paper's own dependency order

The paper's proof splits into five pieces, each depending on the ones before it. The formalization
followed the same order: two elementary lemmas about lattice-line crossings, a lemma about
splitting a lattice coset under a new direction, a number-theoretic bound underlying a "steering"
lemma (given any target direction, an admissible new direction close to it can always be found),
and finally an infinite recursive construction combining all of the above. Each piece was proved,
independently verified, and committed before starting the next, rather than attempting the whole
development at once.

## Decoupling by dependency, not just by paper section

Two scoping decisions were not forced by the paper's own structure, but made once it became clear
they would let independent pieces of work proceed genuinely in parallel:

- The recursive construction's *coverage* and *disjointness* properties (every point gets covered
  exactly once, no two different-direction lines cross on the lattice) never actually use the fact
  that the construction can steer toward a *specific* target direction — they only need that *some*
  admissible direction exists at every step. This was formalized against an abstract "some
  admissible direction exists" hypothesis, deferring the harder question of direction-*closeness*
  (needed only for the paper's density claim) to a separate file built independently.
- The direction-closeness machinery itself — representing a direction as a point of the real
  projective line \(\mathbb{RP}^1\) with its natural metric, and proving the relevant
  Lipschitz/triangle-inequality facts — was likewise built as its own self-contained piece, with no
  dependency on the recursion's own internals.

Both pieces were later combined by a single, small, backward-compatible generalization (the
recursion's abstract hypothesis was extended to optionally carry a target direction per step,
rather than rewritten), confirmed not to have disturbed anything already proved by re-checking every
pre-existing theorem, not only the new ones.

## Working method: plan by hand, delegate the mechanics, verify independently

For each piece: the mathematical proof was worked out in full by hand first — not just "here is a
true statement, go prove it," but the actual sequence of steps, matching (and where necessary,
correcting) the paper's own argument. Only then was the Lean tactic-level engineering delegated,
worked from that hand-derived plan rather than from the bare statement alone. Every result was
independently re-verified afterward — a clean rebuild from a clean state, an explicit check for
placeholder proofs, and an axiom check on the resulting theorem (see `PROOF.md` for exactly what
that means and how to reproduce it) — rather than trusted from a report of success. This caught
nothing wrong in the end for the Lean code itself, but it was not a formality: several pieces (the
sieve bound's exact constants, a Lipschitz bound's case analysis, a metric's triangle inequality)
had genuine content worth checking rather than accepting on faith, and the discipline of checking
anyway is what makes that confidence meaningful rather than assumed.

## Checking Mathlib before building anything new

Before writing any substantial new mathematical content, the existing Mathlib library was searched
for relevant machinery already available — sometimes successfully (an exact-count lemma for
integers in an interval satisfying a divisibility condition, used as the core building block of the
sieve bound), sometimes not (no ready-made Lipschitz bound for `arctan`, which had to be derived
from a standard derivative-bound argument; no existing formalization of the real projective line's
natural metric, built from scratch instead of adapting Mathlib's `AddCircle` type, which turned out
to need just as much case-analysis work to connect to this problem's specific parametrization).
Both outcomes are recorded, with reasoning, in `../HISTORY.md`.
