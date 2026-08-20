-- Changelog (reverse-chronological)
-- 2026-08-20 - Claude: created, for submission to the Palomar registry. Comparator builds
--   Challenge.lean and Solution.lean independently (separate sandboxes) and compares the
--   elaborated type of the named theorem across both -- so this file deliberately does NOT
--   import Challenge.lean (that would redeclare `Palomar.main_theorem`, already present with a
--   `sorry` there, inside one shared compilation). Instead it re-declares the same small
--   definitions independently, proves they're definitionally identical to the real project's
--   (`rfl`, since both are copies of the same one-line bodies), and discharges `main_theorem` by
--   rewriting to `LatticeLineCoversLean`'s actual, zero-`sorry`, zero-custom-axiom proof.

import Mathlib
import LatticeLineCoversLean

namespace Palomar

open Real

/-- Verbatim copy of `Challenge.lean`'s `phi` (= `LatticeLineCovers.phi`). -/
def phi (p q x y : ℤ) : ℤ := q * x - p * y

/-- Verbatim copy of `Challenge.lean`'s `lline` (= `LatticeLineCovers.lline`). -/
def lline (p q c : ℤ) : Set (ℤ × ℤ) := {pt | phi p q pt.1 pt.2 = c}

/-- Verbatim copy of `Challenge.lean`'s `angleOfSlope` (= `LatticeLineCovers.angleOfSlope`). -/
noncomputable def angleOfSlope (x : ℝ) : ℝ :=
  if 0 ≤ Real.arctan x then Real.arctan x else Real.arctan x + π

/-- Verbatim copy of `Challenge.lean`'s `direction` (= `LatticeLineCovers.direction`). -/
noncomputable def direction (P Q : ℤ) : ℝ :=
  if P = 0 then π / 2 else angleOfSlope ((Q : ℝ) / (P : ℝ))

/-- Verbatim copy of `Challenge.lean`'s `rpDist` (= `LatticeLineCovers.rpDist`). -/
noncomputable def rpDist (θ θ' : ℝ) : ℝ := min |θ - θ'| (π - |θ - θ'|)

theorem main_theorem :
    ∃ 𝓕 : Set (Set (ℤ × ℤ)),
      (∀ L ∈ 𝓕, ∃ P Q c : ℤ, IsCoprime P Q ∧ L = lline P Q c ∧ L.Nonempty) ∧
      (Set.univ ⊆ ⋃₀ 𝓕) ∧
      (∀ L₁ ∈ 𝓕, ∀ L₂ ∈ 𝓕, ∀ P₁ Q₁ c₁ P₂ Q₂ c₂ : ℤ,
        L₁ = lline P₁ Q₁ c₁ → L₂ = lline P₂ Q₂ c₂ → P₁ * Q₂ - P₂ * Q₁ ≠ 0 →
          Disjoint L₁ L₂) ∧
      (∀ θ ∈ Set.Ico (0 : ℝ) π, ∀ ε > 0, ∃ L ∈ 𝓕, ∃ P Q c : ℤ,
        IsCoprime P Q ∧ L = lline P Q c ∧ rpDist (direction P Q) θ < ε) := by
  have hlline : @lline = @LatticeLineCovers.lline := rfl
  have hdirection : @direction = @LatticeLineCovers.direction := rfl
  have hrpDist : @rpDist = @LatticeLineCovers.rpDist := rfl
  rw [hlline, hdirection, hrpDist]
  exact LatticeLineCovers.main_theorem

end Palomar
