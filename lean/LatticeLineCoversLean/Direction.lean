import Mathlib
import LatticeLineCoversLean.Steering

/-!
# Directions in `ℝP¹` and the Steering lemma in its literal form

Changelog:
- 2026-08-02: created. `rpDist`, `angleOfSlope`, `direction`, the arctan-Lipschitz bridge, and
  `steering` (the paper's Lemma `lem:steering` verbatim).

`lattice-line-covers/article/lattice_line_covers.tex` fixes the space of directions to be
`ℝP¹ = S¹/{±1}`, parametrized by `θ ∈ [0,π)` and metrized by
`d(θ,θ') = min(|θ-θ'|, π - |θ-θ'|)`.  This file formalizes that metric (`rpDist`), the map sending
an integer vector to its direction (`direction`), and upgrades the purely slope-theoretic
`steering_slope` / `steering_reciprocal_slope` of `Steering.lean` into the paper's actual statement
(`steering`): for every `θ ∈ [0,π)` and `ε > 0` there are admissible `s,t` with the direction of
`(n₁s, n₂t)` within `ε` of `θ`.

The bridge is `rpDist_angleOfSlope_le`: the map "slope ↦ angle" is 1-Lipschitz from `ℝ` (with the
usual metric) to `[0,π)` (with `rpDist`).  This is *not* just `arctan` being 1-Lipschitz: the
representative jumps by `π` as the slope crosses `0`, and it is exactly the `min` in `rpDist` —
i.e. the fact that `[0,π)` is glued into a circle — that absorbs the jump.
-/

namespace LatticeLineCovers

open Real

/-! ## The metric on `ℝP¹` -/

/-- The paper's metric on the space of directions `ℝP¹`, in the parametrization by `θ ∈ [0,π)`:
`d(θ,θ') = min(|θ-θ'|, π - |θ-θ'|)`.  Defined on all of `ℝ` for convenience; it is a genuine
metric on `[0,π)` (which is all we use), where it computes the `ℝP¹` distance. -/
noncomputable def rpDist (θ θ' : ℝ) : ℝ := min |θ - θ'| (π - |θ - θ'|)

theorem rpDist_comm (θ θ' : ℝ) : rpDist θ θ' = rpDist θ' θ := by
  unfold rpDist; rw [abs_sub_comm]

theorem rpDist_le_abs_sub (θ θ' : ℝ) : rpDist θ θ' ≤ |θ - θ'| := min_le_left _ _

theorem rpDist_le_pi_sub_abs_sub (θ θ' : ℝ) : rpDist θ θ' ≤ π - |θ - θ'| := min_le_right _ _

theorem rpDist_self (θ : ℝ) : rpDist θ θ = 0 := by
  unfold rpDist
  simp [le_of_lt pi_pos]

/-! ## The direction of a slope, and of an integer vector -/

/-- The point of `[0,π)` representing the direction of a line of slope `x`.  `arctan` lands in
`(-π/2, π/2)`; negative values are shifted by `π` into `(π/2, π)`. -/
noncomputable def angleOfSlope (x : ℝ) : ℝ :=
  if 0 ≤ Real.arctan x then Real.arctan x else Real.arctan x + π

/-- The point of `[0,π)` representing the direction of the vector `(P,Q)`.  Junk-valued (`π/2`) at
`(0,0)`, which is not a direction; every statement below that mentions `direction P Q` carries
`P ≠ 0` or `Q ≠ 0`, so the junk value is never used. -/
noncomputable def direction (P Q : ℤ) : ℝ :=
  if P = 0 then π / 2 else angleOfSlope ((Q : ℝ) / (P : ℝ))

theorem angleOfSlope_of_nonneg {x : ℝ} (hx : 0 ≤ x) : angleOfSlope x = Real.arctan x := by
  unfold angleOfSlope
  rw [if_pos (Real.arctan_nonneg.mpr hx)]

theorem angleOfSlope_of_neg {x : ℝ} (hx : x < 0) : angleOfSlope x = Real.arctan x + π := by
  unfold angleOfSlope
  rw [if_neg (by simpa using Real.arctan_lt_zero.mpr hx)]

theorem angleOfSlope_nonneg (x : ℝ) : 0 ≤ angleOfSlope x := by
  rcases le_or_gt 0 x with hx | hx
  · rw [angleOfSlope_of_nonneg hx]; exact Real.arctan_nonneg.mpr hx
  · rw [angleOfSlope_of_neg hx]
    have := Real.neg_pi_div_two_lt_arctan x
    have := pi_pos
    linarith

theorem angleOfSlope_lt_pi (x : ℝ) : angleOfSlope x < π := by
  have hπ := pi_pos
  rcases le_or_gt 0 x with hx | hx
  · rw [angleOfSlope_of_nonneg hx]
    have := Real.arctan_lt_pi_div_two x
    linarith
  · rw [angleOfSlope_of_neg hx]
    have := Real.arctan_lt_zero.mpr hx
    linarith

theorem angleOfSlope_mem_Ico (x : ℝ) : angleOfSlope x ∈ Set.Ico (0 : ℝ) π :=
  ⟨angleOfSlope_nonneg x, angleOfSlope_lt_pi x⟩

theorem direction_mem_Ico (P Q : ℤ) : direction P Q ∈ Set.Ico (0 : ℝ) π := by
  unfold direction
  split
  · exact ⟨by positivity, by linarith [pi_pos]⟩
  · exact angleOfSlope_mem_Ico _

/-- `(P,Q)` and `(-P,-Q)` span the same line, hence have the same direction. -/
theorem direction_neg (P Q : ℤ) : direction (-P) (-Q) = direction P Q := by
  unfold direction
  by_cases hP : P = 0
  · simp [hP]
  · rw [if_neg (by simpa using hP), if_neg hP]
    congr 1
    push_cast
    rw [neg_div_neg_eq]

/-- The direction of `(P,Q)` with `P ≠ 0` is read off the slope `Q/P`. -/
theorem direction_eq_angleOfSlope {P Q : ℤ} (hP : P ≠ 0) :
    direction P Q = angleOfSlope ((Q : ℝ) / (P : ℝ)) := if_neg hP

/-! ### Sanity checks -/

example : direction 1 0 = 0 := by
  rw [direction_eq_angleOfSlope one_ne_zero]
  norm_num [angleOfSlope_of_nonneg (le_refl (0 : ℝ))]

example : direction 0 1 = π / 2 := by unfold direction; simp

example : direction 1 1 = π / 4 := by
  rw [direction_eq_angleOfSlope one_ne_zero]
  norm_num [angleOfSlope_of_nonneg (zero_le_one (α := ℝ)), Real.arctan_one]

example : direction 1 (-1) = 3 * π / 4 := by
  rw [direction_eq_angleOfSlope one_ne_zero]
  have h : ((-1 : ℤ) : ℝ) / ((1 : ℤ) : ℝ) = -1 := by norm_num
  rw [h, angleOfSlope_of_neg (by norm_num), show (-1 : ℝ) = -(1 : ℝ) by norm_num,
    Real.arctan_neg, Real.arctan_one]
  ring

example : direction (-1) 1 = direction 1 (-1) := by
  simpa using direction_neg 1 (-1)

/-! ## `arctan` is 1-Lipschitz -/

/-- `arctan` is 1-Lipschitz: its derivative is `1/(1+x²) ≤ 1` everywhere. -/
theorem abs_arctan_sub_arctan_le (x y : ℝ) :
    |Real.arctan x - Real.arctan y| ≤ |x - y| := by
  have hbound : ∀ z ∈ (Set.univ : Set ℝ), ‖deriv Real.arctan z‖ ≤ 1 := by
    intro z _
    rw [Real.deriv_arctan]
    have h1 : (0 : ℝ) < 1 + z ^ 2 := by positivity
    rw [Real.norm_eq_abs, abs_of_pos (by positivity)]
    rw [div_le_one h1]
    nlinarith [sq_nonneg z]
  have h := Convex.norm_image_sub_le_of_norm_deriv_le
    (f := Real.arctan) (s := (Set.univ : Set ℝ)) (C := 1)
    (fun z _ => Real.differentiable_arctan z) hbound convex_univ
    (Set.mem_univ y) (Set.mem_univ x)
  simpa [Real.norm_eq_abs] using h

/-- Corollary: `|arctan x| ≤ |x|`. -/
theorem abs_arctan_le (x : ℝ) : |Real.arctan x| ≤ |x| := by
  simpa [Real.arctan_zero] using abs_arctan_sub_arctan_le x 0

/-! ## The bridge: slope-closeness implies direction-closeness -/

/-- **The 1-Lipschitz bridge.**  In the `ℝP¹` metric, the angle of a line is a 1-Lipschitz
function of its slope.  Note that `angleOfSlope` is *not* 1-Lipschitz for the ordinary metric on
`ℝ` — it jumps by nearly `π` as the slope crosses `0` — but the `min` in `rpDist` (which encodes
that `0` and `π` are the same direction) absorbs exactly that jump. -/
theorem rpDist_angleOfSlope_le (x y : ℝ) :
    rpDist (angleOfSlope x) (angleOfSlope y) ≤ |x - y| := by
  have key := abs_arctan_sub_arctan_le x y
  have hax1 := Real.neg_pi_div_two_lt_arctan x
  have hax2 := Real.arctan_lt_pi_div_two x
  have hay1 := Real.neg_pi_div_two_lt_arctan y
  have hay2 := Real.arctan_lt_pi_div_two y
  rcases le_or_gt 0 x with hx | hx <;> rcases le_or_gt 0 y with hy | hy
  · -- both slopes nonnegative: no shift on either side
    rw [angleOfSlope_of_nonneg hx, angleOfSlope_of_nonneg hy]
    exact le_trans (rpDist_le_abs_sub _ _) key
  · -- `x ≥ 0 > y`: the representative of `y` is shifted by `π`; use the `π - |·|` branch
    rw [angleOfSlope_of_nonneg hx, angleOfSlope_of_neg hy]
    have hxa : 0 ≤ Real.arctan x := Real.arctan_nonneg.mpr hx
    have hya : Real.arctan y < 0 := Real.arctan_lt_zero.mpr hy
    have hD : Real.arctan x - (Real.arctan y + π) ≤ 0 := by linarith
    have habs : |Real.arctan x - (Real.arctan y + π)| =
        π - (Real.arctan x - Real.arctan y) := by
      rw [abs_of_nonpos hD]; ring
    refine le_trans (rpDist_le_pi_sub_abs_sub _ _) ?_
    rw [habs]
    have : Real.arctan x - Real.arctan y ≤ |x - y| := by
      calc Real.arctan x - Real.arctan y ≤ |Real.arctan x - Real.arctan y| := le_abs_self _
        _ ≤ |x - y| := key
    linarith
  · -- `y ≥ 0 > x`: mirror image of the previous case
    rw [angleOfSlope_of_neg hx, angleOfSlope_of_nonneg hy]
    have hya : 0 ≤ Real.arctan y := Real.arctan_nonneg.mpr hy
    have hxa : Real.arctan x < 0 := Real.arctan_lt_zero.mpr hx
    have hD : 0 ≤ Real.arctan x + π - Real.arctan y := by linarith
    have habs : |Real.arctan x + π - Real.arctan y| =
        π - (Real.arctan y - Real.arctan x) := by
      rw [abs_of_nonneg hD]; ring
    refine le_trans (rpDist_le_pi_sub_abs_sub _ _) ?_
    rw [habs]
    have : Real.arctan y - Real.arctan x ≤ |x - y| := by
      calc Real.arctan y - Real.arctan x ≤ |Real.arctan x - Real.arctan y| := by
            rw [abs_sub_comm]; exact le_abs_self _
        _ ≤ |x - y| := key
    linarith
  · -- both slopes negative: the `π` shifts cancel
    rw [angleOfSlope_of_neg hx, angleOfSlope_of_neg hy]
    refine le_trans (rpDist_le_abs_sub _ _) ?_
    have : Real.arctan x + π - (Real.arctan y + π) = Real.arctan x - Real.arctan y := by ring
    rw [this]
    exact key

/-- For `θ ∈ [0,π)` other than `π/2`, `θ` really is the angle of the slope `tan θ`. -/
theorem angleOfSlope_tan {θ : ℝ} (h0 : 0 ≤ θ) (hπ : θ < π) (hne : θ ≠ π / 2) :
    angleOfSlope (Real.tan θ) = θ := by
  have hπ2 : (0 : ℝ) < π / 2 := by linarith [pi_pos]
  rcases lt_or_gt_of_ne hne with h | h
  · -- `θ ∈ [0, π/2)`
    have harc : Real.arctan (Real.tan θ) = θ := Real.arctan_tan (by linarith) h
    have hnn : 0 ≤ Real.arctan (Real.tan θ) := by rw [harc]; exact h0
    unfold angleOfSlope
    rw [if_pos hnn, harc]
  · -- `θ ∈ (π/2, π)`: shift by `π` into `arctan`'s range
    have htan : Real.tan θ = Real.tan (θ - π) := (Real.tan_sub_pi θ).symm
    have harc : Real.arctan (Real.tan θ) = θ - π := by
      rw [htan]; exact Real.arctan_tan (by linarith) (by linarith)
    have hneg : ¬ (0 ≤ Real.arctan (Real.tan θ)) := by rw [harc]; linarith
    unfold angleOfSlope
    rw [if_neg hneg, harc]
    ring

/-- The angle of the slope `r⁻¹` is `π/2 - arctan r`; in particular it is close to `π/2` (vertical)
exactly when the *reciprocal* slope `r` is close to `0`. -/
theorem angleOfSlope_inv {r : ℝ} (hr : r ≠ 0) :
    angleOfSlope r⁻¹ = π / 2 - Real.arctan r := by
  have h1 := Real.neg_pi_div_two_lt_arctan r
  have h2 := Real.arctan_lt_pi_div_two r
  rcases lt_or_gt_of_ne hr with h | h
  · have hinv : r⁻¹ < 0 := inv_neg''.mpr h
    rw [angleOfSlope_of_neg hinv, Real.arctan_inv_of_neg h]
    ring
  · have hinv : 0 < r⁻¹ := inv_pos.mpr h
    rw [angleOfSlope_of_nonneg hinv.le, Real.arctan_inv_of_pos h]

/-- Reciprocal-slope closeness to `0` gives direction-closeness to vertical. -/
theorem rpDist_angleOfSlope_inv_pi_div_two {r : ℝ} (hr : r ≠ 0) :
    rpDist (angleOfSlope r⁻¹) (π / 2) ≤ |r| := by
  rw [angleOfSlope_inv hr]
  refine le_trans (rpDist_le_abs_sub _ _) ?_
  have h : π / 2 - Real.arctan r - π / 2 = -Real.arctan r := by ring
  rw [h, abs_neg]
  exact abs_arctan_le r

/-! ## The Steering lemma, in the paper's literal form -/

/-- **Steering lemma** (`lattice_line_covers.tex`, Lemma `lem:steering`).  Let `n₁,n₂` be coprime
positive integers.  For every direction `θ ∈ [0,π)` and every `ε > 0` there exist nonzero integers
`s,t` with `|s|,|t| ≥ 2` and `gcd(s,n₂) = gcd(t,n₁) = gcd(s,t) = 1` such that the direction of
`(n₁s, n₂t)` lies within `ε` of `θ` in the `ℝP¹` metric `rpDist`.

The `(s,t)` hypotheses are exactly those of `LatticeLineCovers.splitting`. -/
theorem steering (n1 n2 : ℤ) (hn1 : 0 < n1) (hn2 : 0 < n2) (hn : IsCoprime n1 n2)
    (θ ε : ℝ) (hθ : θ ∈ Set.Ico (0 : ℝ) π) (hε : 0 < ε) :
    ∃ s t : ℤ, s ≠ 0 ∧ t ≠ 0 ∧ 2 ≤ |s| ∧ 2 ≤ |t| ∧
      IsCoprime s n2 ∧ IsCoprime t n1 ∧ IsCoprime s t ∧
      rpDist (direction (n1 * s) (n2 * t)) θ < ε := by
  obtain ⟨hθ0, hθπ⟩ := hθ
  have hn1R : (0 : ℝ) < (n1 : ℝ) := by exact_mod_cast hn1
  have hn2R : (0 : ℝ) < (n2 : ℝ) := by exact_mod_cast hn2
  by_cases hmid : θ = π / 2
  · -- Vertical target: use the reciprocal-slope steering theorem.
    obtain ⟨s, t, hs0, ht0, hs2, ht2, hsn2, htn1, hst, hbound⟩ :=
      steering_reciprocal_slope n1 n2 hn1 hn2 hn ε hε
    refine ⟨s, t, hs0, ht0, hs2, ht2, hsn2, htn1, hst, ?_⟩
    have hsR : ((s : ℤ) : ℝ) ≠ 0 := Int.cast_ne_zero.mpr hs0
    have htR : ((t : ℤ) : ℝ) ≠ 0 := Int.cast_ne_zero.mpr ht0
    have hP : n1 * s ≠ 0 := mul_ne_zero hn1.ne' hs0
    have hr : ((n1 : ℝ) * (s : ℝ)) / ((n2 : ℝ) * (t : ℝ)) ≠ 0 :=
      div_ne_zero (mul_ne_zero hn1R.ne' hsR) (mul_ne_zero hn2R.ne' htR)
    have hslope : ((n2 * t : ℤ) : ℝ) / ((n1 * s : ℤ) : ℝ) =
        (((n1 : ℝ) * (s : ℝ)) / ((n2 : ℝ) * (t : ℝ)))⁻¹ := by
      push_cast
      rw [inv_div]
    rw [direction_eq_angleOfSlope hP, hslope, hmid]
    exact lt_of_le_of_lt (rpDist_angleOfSlope_inv_pi_div_two hr) hbound
  · -- Finite target slope `μ = tan θ`.
    obtain ⟨s, t, hs0, ht0, hs2, ht2, hsn2, htn1, hst, hbound⟩ :=
      steering_slope n1 n2 hn1 hn2 hn (Real.tan θ) ε hε
    refine ⟨s, t, hs0, ht0, hs2, ht2, hsn2, htn1, hst, ?_⟩
    have hP : n1 * s ≠ 0 := mul_ne_zero hn1.ne' hs0
    have hslope : ((n2 * t : ℤ) : ℝ) / ((n1 * s : ℤ) : ℝ) =
        ((n2 : ℝ) * (t : ℝ)) / ((n1 : ℝ) * (s : ℝ)) := by push_cast; ring
    rw [direction_eq_angleOfSlope hP, hslope, ← angleOfSlope_tan hθ0 hθπ hmid]
    exact lt_of_le_of_lt (rpDist_angleOfSlope_le _ _) hbound

end LatticeLineCovers
