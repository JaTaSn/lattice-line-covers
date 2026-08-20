-- Changelog (reverse-chronological)
-- 2026-08-20 - Claude: created, for submission to the Palomar registry
--   (palomar-registry.org). Palomar's Comparator tool requires the advertised statement to be
--   held apart from its proof, in a standalone module importing only Lean core, Mathlib, and Tau
--   Ceti (no other files from this project). The five definitions below are extracted verbatim
--   from `LatticeLineCoversLean/Basic.lean` and `LatticeLineCoversLean/Direction.lean` for exactly
--   that reason -- `main_theorem`'s *statement* (not its proof) depends on nothing else from this
--   project. Deliberately declared in the `Palomar` namespace, not `LatticeLineCovers`: the real
--   project's `Basic.lean`/`Direction.lean` already define `lline`/`direction`/`rpDist` in
--   `LatticeLineCovers`, and `Solution.lean` needs to import both this file and the real project
--   without a duplicate-declaration clash. `Solution.lean` proves the identical statement using
--   the real project's full development; Comparator checks the two match.

import Mathlib

/-!
# Palomar challenge statement

The claim: there is a family of lattice lines covering `ℤ × ℤ`, no two of different direction
sharing a lattice point, whose realized directions are dense in `ℝP¹`. See
`../lean/PROOF.md` for the plain-language statement and `../article/` for the full paper.

This file states the claim only (`main_theorem` ends in `sorry`, Palomar's convention for a
challenge module). The actual zero-`sorry`, zero-custom-axiom proof lives in the main project
(`LatticeLineCoversLean/`) and is re-exported, unchanged, by `Solution.lean`.
-/

namespace Palomar

open Real

/-- `φ_{(p,q)}(x,y) = q*x - p*y`, the linear functional whose level sets are the lattice lines of
primitive direction `(p,q)`. Verbatim from `LatticeLineCoversLean/Basic.lean`
(`LatticeLineCovers.phi`). -/
def phi (p q x y : ℤ) : ℤ := q * x - p * y

/-- `ℓ_{(p,q),c}`, the lattice line of direction `(p,q)` at level `c`. Verbatim from
`LatticeLineCoversLean/Basic.lean` (`LatticeLineCovers.lline`). -/
def lline (p q c : ℤ) : Set (ℤ × ℤ) := {pt | phi p q pt.1 pt.2 = c}

/-- The point of `[0,π)` representing the direction of a line of slope `x`. Verbatim from
`LatticeLineCoversLean/Direction.lean` (`LatticeLineCovers.angleOfSlope`). -/
noncomputable def angleOfSlope (x : ℝ) : ℝ :=
  if 0 ≤ Real.arctan x then Real.arctan x else Real.arctan x + π

/-- The point of `[0,π)` representing the direction of the vector `(P,Q)`. Verbatim from
`LatticeLineCoversLean/Direction.lean` (`LatticeLineCovers.direction`). -/
noncomputable def direction (P Q : ℤ) : ℝ :=
  if P = 0 then π / 2 else angleOfSlope ((Q : ℝ) / (P : ℝ))

/-- The paper's metric on the space of directions `ℝP¹`, in the parametrization by `θ ∈ [0,π)`.
Verbatim from `LatticeLineCoversLean/Direction.lean` (`LatticeLineCovers.rpDist`). -/
noncomputable def rpDist (θ θ' : ℝ) : ℝ := min |θ - θ'| (π - |θ - θ'|)

/-- **Main theorem.** There is a family `𝓕` of lattice lines with `⋃𝓕 ⊇ ℤ²`, no two lines of `𝓕`
of different direction sharing a lattice point, whose set of realized directions is dense in
`ℝP¹`. Formalizes Theorem 1 of `../article/lattice_line_covers.tex`. -/
theorem main_theorem :
    ∃ 𝓕 : Set (Set (ℤ × ℤ)),
      (∀ L ∈ 𝓕, ∃ P Q c : ℤ, IsCoprime P Q ∧ L = lline P Q c ∧ L.Nonempty) ∧
      (Set.univ ⊆ ⋃₀ 𝓕) ∧
      (∀ L₁ ∈ 𝓕, ∀ L₂ ∈ 𝓕, ∀ P₁ Q₁ c₁ P₂ Q₂ c₂ : ℤ,
        L₁ = lline P₁ Q₁ c₁ → L₂ = lline P₂ Q₂ c₂ → P₁ * Q₂ - P₂ * Q₁ ≠ 0 →
          Disjoint L₁ L₂) ∧
      (∀ θ ∈ Set.Ico (0 : ℝ) π, ∀ ε > 0, ∃ L ∈ 𝓕, ∃ P Q c : ℤ,
        IsCoprime P Q ∧ L = lline P Q c ∧ rpDist (direction P Q) θ < ε) := by
  sorry

end Palomar
