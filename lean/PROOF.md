# The Lean formalization, explained for a non-expert reader

This directory contains a complete, machine-checked proof of the paper's main theorem, written in
[Lean 4](https://lean-lang.org/) using the [Mathlib](https://leanprover-community.github.io/)
mathematical library. You do not need to know Lean to understand this document, and the last
section gives you exact, copy-pasteable steps to check the proof yourself without trusting anyone's
word for it — including ours.

## What "machine-checked" actually buys you

A Lean proof is checked by a small program (the Lean *kernel*) that verifies every logical step
follows from the ones before it, all the way down to a handful of foundational axioms. It cannot be
fooled by a step that "looks right" but isn't — every inference is checked mechanically. This is a
different, stronger kind of confidence than a human read-through, though it comes with its own
caveat, explained at the end of this document.

## What was proved

Informally: there is a family of straight lines in the plane, each passing through infinitely many
points of the integer lattice \(\mathbb{Z}^2\), such that

- every lattice point is covered by at least one line in the family,
- no two lines of *different* direction ever cross at a lattice point (they may cross elsewhere),
  and
- the set of directions used by the family comes arbitrarily close to *every* possible direction —
  it is dense in the space of line directions.

The Lean statement of this (`LatticeLineCovers.main_theorem` in `LatticeLineCoversLean/Family.lean`)
is the precise, formal version of the theorem stated in the article (`../article/`). See that
article for the full mathematical context and motivation.

## How the proof is organized

The paper's argument splits into five pieces, each building on the last. The Lean development
mirrors this, in seven files (two of the five pieces needed a bit more machinery underneath them
than the others):

| File | What it proves, informally |
|---|---|
| `Basic.lean` | Two small lemmas about when lines of different directions are forced to cross at a lattice point, plus the key mechanism for splitting a family of lattice points into a finer, similarly-structured piece under a new direction. |
| `Sieve.lean` | A number-theoretic counting bound (in the spirit of the classical Legendre sieve): a short interval of integers always contains one coprime to a given modulus, with an error term that doesn't grow with that modulus. |
| `Steering.lean` | Using the bound above: given any target slope and any tolerance, a new admissible direction can always be found within that tolerance. |
| `Direction.lean` | Translates "within a tolerance of a target slope" into the geometrically correct notion — direction as a point on the real projective line \(\mathbb{RP}^1\), with its own natural (circular) notion of distance. |
| `MainRecursion.lean` | The heart of the construction: an infinite recursive process that repeatedly splits the plane and hands off a fresh, unclaimed piece to a new direction. Proves this process covers every lattice point exactly once and never lets two different-direction lines cross on the lattice. |
| `Density.lean` | Proves the directions produced by the recursion above really do get arbitrarily close to every target direction. |
| `Family.lean` | Assembles everything above into an actual, formal family of lines, and states and proves the main theorem itself. |

Every one of these files compiles with **zero** `sorry` (Lean's placeholder for "trust me, skip
this step") and **zero** custom axioms — every theorem, all the way up to the main theorem itself,
rests only on Lean's three standard foundational axioms (`propext`, `Classical.choice`,
`Quot.sound`), the same three that essentially all of modern Mathlib rests on. This was checked
mechanically (see below), not just asserted.

## How to independently verify this yourself

You do not need to know any Lean syntax to run these checks — just a terminal.

**1. Install the Lean toolchain**, if you don't already have it:

```sh
curl https://elan.lean-lang.org/elan-init.sh -sSf | sh
```

Follow the prompts, then restart your shell (or `source` your shell's profile) so `lake` and `lean`
are on your `PATH`.

**2. Build the project.** From this directory (`lean/`):

```sh
lake build
```

The first run will download a pinned, pre-built copy of Mathlib (a few gigabytes; this is normal
and only happens once). If this command finishes with `Build completed successfully`, every file
above has compiled — the Lean kernel has checked every proof step in the whole development.

**3. Confirm there are no placeholder proofs.** From this directory:

```sh
grep -rn "sorry\|admit\b" LatticeLineCoversLean/
```

This should print nothing. If it printed anything, some part of the proof would be an unfinished
placeholder rather than a real proof — it doesn't, but check for yourself rather than trusting this
sentence.

**4. Confirm the main theorem rests only on standard axioms.** Create a small scratch file, e.g.
`check.lean`, containing:

```lean
import LatticeLineCoversLean

#print axioms LatticeLineCovers.main_theorem
```

and run:

```sh
lake env lean check.lean
```

The output should be exactly:

```
'LatticeLineCovers.main_theorem' depends on axioms: [propext, Classical.choice, Quot.sound]
```

This is the strongest single check available: it is not merely "no `sorry` in this file" but a
*transitive* check of the entire proof term behind `main_theorem`, across every file it depends on.
If anything anywhere in that dependency chain had relied on an unproven step, `sorryAx` would
appear in this list. It does not.

## What this does *not* guarantee

Formal verification checks that the Lean *statements* are true, given Lean's kernel and Mathlib's
definitions — it cannot check that those statements correctly capture what the paper's theorem
*means*. Whether `main_theorem`'s four conjuncts faithfully formalize "no two lines of different
direction share a lattice point" and "dense in \(\mathbb{RP}^1\)" as the article states them is a
translation question, checkable by reading the Lean statement in `Family.lean` side by side with
the article's Theorem statement — which we encourage you to do, rather than take on faith. See
`STRATEGY.md` in this directory for more on how the development was organized, and `../HISTORY.md`
for the narrative of how it was built, including the real mistakes found and fixed along the way.
