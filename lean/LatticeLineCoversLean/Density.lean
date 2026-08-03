import Mathlib
import LatticeLineCoversLean.Direction
import LatticeLineCoversLean.MainRecursion

/-!
# Density of the realized directions

Changelog:
- 2026-08-03: created. `rpNorm` and the `rpDist` triangle inequality, the tail-density
  Remark (`dense_sdiff_finite`, `denseTargets_tail`), the concrete dense target sequence
  `thetaRat`, and the density theorems `density` / `density_concrete`.

Formalizes the *density* paragraph of the proof of the main theorem in
`lattice-line-covers/article/lattice_line_covers.tex` (`\S 4`), together with the tail-density
`Remark~\ref{rem:tail-density}` it relies on.

**Scope.** The family `𝓕` of lines is *not* assembled as a formal object here, and the literal
main theorem is not stated; that is a separate later step. What is proved here is the underlying
density fact: the directions achieved by the construction come arbitrarily close, in the `ℝP¹`
metric `rpDist`, to every target in `[0,π)` — and that each achieved direction is genuinely
realized by an actual nonempty lattice line lying inside that stage's claimed set
(`exists_line_in_claims`, from `MainRecursion.lean`'s `lline_subset_claims`).

The pieces:

* `rpNorm_add_le` / `rpDist_triangle_of_mem_Ico` — the triangle inequality for the paper's `ℝP¹`
  metric, which `Direction.lean` did not have. Proved by identifying `rpNorm x = min |x| (π-|x|)`
  with the distance from `x` to `πℤ` (for `|x| ≤ π`) and using that `πℤ` is a subgroup.
* `dense_sdiff_finite` — the paper's `Remark~\ref{rem:tail-density}` verbatim, for a general `T1`
  space without isolated points.
* `denseTargets_tail` — the concrete form actually consumed: every *tail* of a sequence with dense
  range in `[0,π)` still comes arbitrarily close to every point of `[0,π)`.
* `thetaRat` — a concrete such sequence (an enumeration of `ℚ ∩ [0,π)`), so that the final
  statement is not vacuous.
* `density` — the abstract density theorem, and `density_concrete` — its instantiation at
  `thetaRat` and `Direction.lean`'s `steering`, with no remaining hypotheses beyond the
  enumeration `z` of `ℤ²` and the target `θ ∈ [0,π)`, `ε > 0`.
-/

namespace LatticeLineCovers

open Real Topology

/-! ## The `ℝP¹` metric is a metric: the triangle inequality

`Direction.lean` defines `rpDist θ θ' = min |θ-θ'| (π - |θ-θ'|)` and proves the bounds the
Steering lemma needs, but not the triangle inequality. The proof here goes through the
observation that, for `|x| ≤ π`, `min |x| (π-|x|)` is exactly the distance from `x` to the
subgroup `πℤ`: it is `|x - nπ|` for a suitable `n ∈ {0, ±1}` (`exists_int_rpNorm_eq`) and is at
most `|x - nπ|` for *every* `n ∈ ℤ` (`rpNorm_le_abs_sub_int_mul_pi`, which needs no hypothesis on
`x` at all). The triangle inequality is then immediate from `|·|`'s, since `πℤ` is closed under
addition.

(An alternative route, relating `rpDist` to Mathlib's `AddCircle π` metric via
`AddCircle.norm_eq : ‖(x : AddCircle p)‖ = |x - round (p⁻¹ * x) * p|`, was investigated: it needs
exactly the same case analysis to evaluate `round (π⁻¹ * x)` on `|x| ≤ π`, and then additionally
has to transport statements across the quotient, so it is strictly more work than the direct
argument below.) -/

/-- `rpDist` in "norm" form: `rpNorm x = min |x| (π - |x|)`, so `rpDist θ θ' = rpNorm (θ - θ')`. -/
noncomputable def rpNorm (x : ℝ) : ℝ := min |x| (π - |x|)

theorem rpDist_eq_rpNorm (θ θ' : ℝ) : rpDist θ θ' = rpNorm (θ - θ') := rfl

theorem rpNorm_le_abs (x : ℝ) : rpNorm x ≤ |x| := min_le_left _ _

theorem rpNorm_le_pi_div_two (x : ℝ) : rpNorm x ≤ π / 2 := by
  rcases le_or_gt |x| (π / 2) with h | h
  · exact le_trans (min_le_left _ _) h
  · exact le_trans (min_le_right _ _) (by linarith)

/-- `rpNorm x` is at most the distance from `x` to *any* integer multiple of `π`. No hypothesis on
`x` is needed: when `|x| ≥ π` the left-hand side is `≤ 0`. -/
theorem rpNorm_le_abs_sub_int_mul_pi (x : ℝ) (n : ℤ) : rpNorm x ≤ |x - (n : ℝ) * π| := by
  have hπ := pi_pos
  rcases le_or_gt π |x| with hx | hx
  · exact le_trans (min_le_right _ _) (by linarith [abs_nonneg (x - (n : ℝ) * π)])
  · have hx1 : -π < x := by cases abs_lt.mp hx; linarith
    have hx2 : x < π := by cases abs_lt.mp hx; linarith
    have hcase : n = 0 ∨ n = 1 ∨ n = -1 ∨ n ≤ -2 ∨ 2 ≤ n := by omega
    rcases hcase with h | h | h | h | h
    · simpa [h] using rpNorm_le_abs x
    · subst h
      refine le_trans (min_le_right _ _) ?_
      have : |x - ((1 : ℤ) : ℝ) * π| = π - x := by
        rw [abs_of_nonpos (by push_cast; linarith)]; push_cast; ring
      rw [this]
      linarith [le_abs_self x]
    · subst h
      refine le_trans (min_le_right _ _) ?_
      have : |x - ((-1 : ℤ) : ℝ) * π| = x + π := by
        rw [abs_of_nonneg (by push_cast; linarith)]; push_cast; ring
      rw [this]
      linarith [neg_abs_le x]
    · -- `n ≤ -2`: then `x - nπ ≥ π`
      refine le_trans (rpNorm_le_pi_div_two x) ?_
      have hnR : (n : ℝ) ≤ -2 := by exact_mod_cast h
      have hnp : (n : ℝ) * π ≤ -2 * π := mul_le_mul_of_nonneg_right hnR hπ.le
      rw [abs_of_nonneg (by linarith)]
      linarith
    · -- `2 ≤ n`: then `nπ - x ≥ π`
      refine le_trans (rpNorm_le_pi_div_two x) ?_
      have hnR : (2 : ℝ) ≤ (n : ℝ) := by exact_mod_cast h
      have hnp : 2 * π ≤ (n : ℝ) * π := mul_le_mul_of_nonneg_right hnR hπ.le
      rw [abs_of_nonpos (by linarith)]
      linarith

/-- For `|x| ≤ π`, `rpNorm x` *is* the distance to some integer multiple of `π` (in fact with
`n ∈ {0, ±1}`). -/
theorem exists_int_rpNorm_eq {x : ℝ} (hx : |x| ≤ π) : ∃ n : ℤ, rpNorm x = |x - (n : ℝ) * π| := by
  have hx1 : -π ≤ x := by cases abs_le.mp hx; linarith
  have hx2 : x ≤ π := by cases abs_le.mp hx; linarith
  rcases le_or_gt 0 x with hs | hs
  · have habs : |x| = x := abs_of_nonneg hs
    rcases le_or_gt x (π - x) with h | h
    · exact ⟨0, by rw [rpNorm, habs, min_eq_left h]; simp [habs]⟩
    · refine ⟨1, ?_⟩
      rw [rpNorm, habs, min_eq_right h.le]
      rw [abs_of_nonpos (by push_cast; linarith)]
      push_cast; ring
  · have habs : |x| = -x := abs_of_neg hs
    rcases le_or_gt (-x) (π + x) with h | h
    · refine ⟨0, ?_⟩
      rw [rpNorm, habs, min_eq_left (by linarith)]
      simp [habs]
    · refine ⟨-1, ?_⟩
      rw [rpNorm, habs, min_eq_right (by linarith)]
      rw [abs_of_nonneg (by push_cast; linarith)]
      push_cast; ring

/-- **Triangle inequality for `rpNorm`.** -/
theorem rpNorm_add_le {u v : ℝ} (hu : |u| ≤ π) (hv : |v| ≤ π) :
    rpNorm (u + v) ≤ rpNorm u + rpNorm v := by
  obtain ⟨m, hm⟩ := exists_int_rpNorm_eq hu
  obtain ⟨n, hn⟩ := exists_int_rpNorm_eq hv
  calc rpNorm (u + v) ≤ |u + v - ((m + n : ℤ) : ℝ) * π| := rpNorm_le_abs_sub_int_mul_pi _ _
    _ = |(u - (m : ℝ) * π) + (v - (n : ℝ) * π)| := by push_cast; ring_nf
    _ ≤ |u - (m : ℝ) * π| + |v - (n : ℝ) * π| := abs_add_le _ _
    _ = rpNorm u + rpNorm v := by rw [hm, hn]

/-- **Triangle inequality for `rpDist`**, in the form needed: valid whenever the two increments
have absolute value at most `π`, which holds automatically inside `[0,π)`. -/
theorem rpDist_triangle {a b c : ℝ} (hab : |a - b| ≤ π) (hbc : |b - c| ≤ π) :
    rpDist a c ≤ rpDist a b + rpDist b c := by
  have h : a - c = (a - b) + (b - c) := by ring
  rw [rpDist_eq_rpNorm, rpDist_eq_rpNorm, rpDist_eq_rpNorm, h]
  exact rpNorm_add_le hab hbc

/-- The triangle inequality for points of `[0,π)`, the parametrization of `ℝP¹` used throughout. -/
theorem rpDist_triangle_of_mem_Ico {a b c : ℝ} (ha : a ∈ Set.Ico (0 : ℝ) π)
    (hb : b ∈ Set.Ico (0 : ℝ) π) (hc : c ∈ Set.Ico (0 : ℝ) π) :
    rpDist a c ≤ rpDist a b + rpDist b c := by
  obtain ⟨ha0, ha1⟩ := ha
  obtain ⟨hb0, hb1⟩ := hb
  obtain ⟨hc0, hc1⟩ := hc
  exact rpDist_triangle (abs_le.mpr ⟨by linarith, by linarith⟩)
    (abs_le.mpr ⟨by linarith, by linarith⟩)

/-! ## The tail-density remark

`Remark~\ref{rem:tail-density}` of the paper, in the generality it is stated there. It is applied
in the paper with `X = ℝP¹` and `F` an initial segment of the target sequence; the concrete
consequence actually consumed below is `denseTargets_tail`, proved directly in `ℝ` (working in the
subspace `[0,π)` rather than transporting this statement through a subtype topology).

Mathlib has this fact as `Dense.sdiff_finite`, proved by induction on the finite set via
`Dense.sdiff_singleton`; the proof below is the paper's own argument instead — a direct check on
an arbitrary nonempty open `U`, with the "no isolated points" hypothesis used exactly where the
paper uses it, to rule out `U ⊆ F`. -/

/-- **Tails of a dense set remain dense** (`Remark~\ref{rem:tail-density}`). If `X` is `T1` with
no isolated points, `D ⊆ X` is dense and `F ⊆ X` is finite, then `D \ F` is still dense. -/
theorem dense_sdiff_finite {X : Type*} [TopologicalSpace X] [T1Space X]
    [∀ x : X, (𝓝[≠] x).NeBot] {D : Set X} (hD : Dense D) {F : Set X} (hF : F.Finite) :
    Dense (D \ F) := by
  rw [dense_iff_inter_open]
  intro U hU hUne
  -- `U \ F` is open, and nonempty: otherwise `U ⊆ F` is finite and its points are isolated.
  have hUF : IsOpen (U \ F) := hU.sdiff hF.isClosed
  have hUFne : (U \ F).Nonempty := by
    by_contra hcon
    rw [Set.not_nonempty_iff_eq_empty, Set.sdiff_eq_empty] at hcon
    obtain ⟨x, hx⟩ := hUne
    -- `U \ (F \ {x}) = {x}` would be open, i.e. `x` isolated.
    have hFx : (F \ {x}).Finite := hF.sdiff
    have hopen : IsOpen (U \ (F \ {x})) := hU.sdiff hFx.isClosed
    have heq : U \ (F \ {x}) = {x} := by
      refine Set.eq_singleton_iff_unique_mem.mpr ⟨⟨hx, fun hc => hc.2 rfl⟩, fun y hy => ?_⟩
      by_contra hne
      exact hy.2 ⟨hcon hy.1, hne⟩
    rw [heq] at hopen
    have h1 : ({x} : Set X) ∈ 𝓝[≠] x := nhdsWithin_le_nhds (hopen.mem_nhds rfl)
    have h2 : ({x}ᶜ : Set X) ∈ 𝓝[≠] x := self_mem_nhdsWithin
    have h3 : (∅ : Set X) ∈ 𝓝[≠] x := by simpa using Filter.inter_mem h1 h2
    exact (inferInstance : (𝓝[≠] x).NeBot).ne (Filter.empty_mem_iff_bot.mp h3)
  obtain ⟨y, hy1, hy2⟩ := (dense_iff_inter_open.mp hD) (U \ F) hUF hUFne
  exact ⟨y, hy1.1, hy2, hy1.2⟩

/-! ## Target sequences in `[0,π)` -/

/-- The sequence of targets takes its values in `[0,π)`, the paper's parametrization of `ℝP¹`. -/
def TargetsIn (θ : ℕ → ℝ) : Prop := ∀ k, θ k ∈ Set.Ico (0 : ℝ) π

/-- The sequence of targets has dense range in `[0,π)`. -/
def DenseTargets (θ : ℕ → ℝ) : Prop :=
  ∀ x ∈ Set.Ico (0 : ℝ) π, ∀ δ > 0, ∃ k, |θ k - x| < δ

/-- **Every tail of a dense target sequence is still dense** — the concrete consequence of
`Remark~\ref{rem:tail-density}` that the density argument consumes. The `T1` + "no isolated
points" hypotheses of `dense_sdiff_finite` are supplied here by `ℝ` itself: finite sets are
closed, and a nondegenerate interval is infinite. -/
theorem denseTargets_tail {θ : ℕ → ℝ} (hd : DenseTargets θ) {x : ℝ}
    (hx : x ∈ Set.Ico (0 : ℝ) π) {δ : ℝ} (hδ : 0 < δ) (N : ℕ) :
    ∃ k, N ≤ k ∧ |θ k - x| < δ := by
  obtain ⟨hx0, hxπ⟩ := hx
  have hπ := pi_pos
  set F : Set ℝ := θ '' Set.Iio N with hFdef
  have hFfin : F.Finite := (Set.finite_Iio N).image θ
  -- A nondegenerate open window inside `[0,π)`, all of whose points are within `δ/2` of `x`.
  set a : ℝ := max (x - δ / 2) 0 with hadef
  set b : ℝ := min (x + δ / 2) π with hbdef
  have hab : a < b :=
    max_lt (lt_min (by linarith) (by linarith)) (lt_min (by linarith) (by linarith))
  -- The window is infinite, so it contains a point `y` missed by the finite initial segment `F`.
  obtain ⟨y, ⟨hya, hyb⟩, hyF⟩ := ((Set.Ioo_infinite hab).sdiff hFfin).nonempty
  have hy0 : 0 ≤ y := le_of_lt (lt_of_le_of_lt (le_max_right _ _) hya)
  have hyπ : y < π := lt_of_lt_of_le hyb (min_le_right _ _)
  have hyx : |y - x| < δ / 2 := by
    refine abs_lt.mpr ⟨?_, ?_⟩
    · have := le_max_left (x - δ / 2) 0; linarith
    · have := min_le_left (x + δ / 2) π; linarith
  -- A ball around `y` still missing `F`.
  obtain ⟨ρ, hρ0, hρ⟩ := Metric.isOpen_iff.mp hFfin.isClosed.isOpen_compl y hyF
  obtain ⟨k, hk⟩ := hd y ⟨hy0, hyπ⟩ (min ρ (δ / 2)) (lt_min hρ0 (by linarith))
  have hkρ : |θ k - y| < ρ := lt_of_lt_of_le hk (min_le_left _ _)
  have hkδ : |θ k - y| < δ / 2 := lt_of_lt_of_le hk (min_le_right _ _)
  refine ⟨k, ?_, ?_⟩
  · rcases le_or_gt N k with hle | hlt
    · exact hle
    · exact absurd (hρ (Metric.mem_ball.mpr (by rwa [Real.dist_eq]))) (by
        simp only [Set.mem_compl_iff, not_not]
        exact ⟨k, hlt, rfl⟩)
  · calc |θ k - x| ≤ |θ k - y| + |y - x| := abs_sub_le _ _ _
      _ < δ / 2 + δ / 2 := by linarith
      _ = δ := by ring

/-! ## A concrete dense target sequence

`ℚ ∩ [0,π)` is dense in `[0,π)` and countable; enumerating `ℚ` and clamping everything outside
`[0,π)` to `0` gives a concrete sequence, so the final density theorem is not vacuous. -/

/-- A fixed enumeration of `ℚ`. -/
noncomputable def ratSeq : ℕ → ℚ := (Denumerable.eqv ℚ).symm

theorem ratSeq_surjective : Function.Surjective ratSeq :=
  (Denumerable.eqv ℚ).symm.surjective

open Classical in
/-- A concrete sequence with values in `[0,π)` and dense range: the rationals, with everything
outside `[0,π)` sent to `0`. -/
noncomputable def thetaRat (n : ℕ) : ℝ :=
  if ((ratSeq n : ℝ) ∈ Set.Ico (0 : ℝ) π) then (ratSeq n : ℝ) else 0

theorem thetaRat_mem : TargetsIn thetaRat := by
  intro k
  unfold thetaRat
  split
  · assumption
  · exact ⟨le_rfl, pi_pos⟩

theorem thetaRat_dense : DenseTargets thetaRat := by
  rintro x ⟨hx0, hxπ⟩ δ hδ
  have hπ := pi_pos
  have hab : max (x - δ) 0 < min (x + δ) π :=
    max_lt (lt_min (by linarith) (by linarith)) (lt_min (by linarith) (by linarith))
  obtain ⟨q, hq1, hq2⟩ := exists_rat_btwn hab
  have hq0 : (0 : ℝ) ≤ (q : ℝ) := le_of_lt (lt_of_le_of_lt (le_max_right _ _) hq1)
  have hqπ : (q : ℝ) < π := lt_of_lt_of_le hq2 (min_le_right _ _)
  obtain ⟨k, hk⟩ := ratSeq_surjective q
  refine ⟨k, ?_⟩
  have hval : thetaRat k = (q : ℝ) := by
    unfold thetaRat
    rw [hk, if_pos ⟨hq0, hqπ⟩]
  rw [hval]
  refine abs_lt.mpr ⟨?_, ?_⟩
  · have := le_max_left (x - δ) 0; linarith
  · have := min_le_left (x + δ) π; linarith

/-! ## The achieved directions of the construction -/

variable {Extra : ℕ → ℤ → ℤ → Prop}

/-- `P_k = n₁^{(k)} s_k`, the first coordinate of the direction achieved at stage `k`. -/
noncomputable def Pstage (hs : Steering Extra) (z : ℕ → ℤ × ℤ) (k : ℕ) : ℤ :=
  (stateSeq hs z k).n1 * sOf hs k (stateSeq hs z k)

/-- `Q_k = n₂^{(k)} t_k`, the second coordinate of the direction achieved at stage `k`. -/
noncomputable def Qstage (hs : Steering Extra) (z : ℕ → ℤ × ℤ) (k : ℕ) : ℤ :=
  (stateSeq hs z k).n2 * tOf hs k (stateSeq hs z k)

/-- The direction of `ℝP¹` achieved at stage `k`. -/
noncomputable def achievedDir (hs : Steering Extra) (z : ℕ → ℤ × ℤ) (k : ℕ) : ℝ :=
  direction (Pstage hs z k) (Qstage hs z k)

theorem achievedDir_mem_Ico (hs : Steering Extra) (z : ℕ → ℤ × ℤ) (k : ℕ) :
    achievedDir hs z k ∈ Set.Ico (0 : ℝ) π := direction_mem_Ico _ _

/-- `gcd(P_k, Q_k) = 1`: the achieved direction is primitive. -/
theorem Pstage_coprime (hs : Steering Extra) (z : ℕ → ℤ × ℤ) (k : ℕ) :
    IsCoprime (Pstage hs z k) (Qstage hs z k) := by
  obtain ⟨-, -, -, -, hsn2, htn1, hst, -⟩ := st_spec hs k (stateSeq hs z k)
  exact IsCoprime.mul_left ((stateSeq hs z k).hcop.mul_right htn1.symm) (hsn2.mul_right hst)

/-- A lattice line of a primitive direction is nonempty (Bézout). -/
theorem lline_nonempty {P Q : ℤ} (h : IsCoprime P Q) (c : ℤ) : (lline P Q c).Nonempty := by
  obtain ⟨a, b, hab⟩ := h
  refine ⟨(b * c, -(a * c)), ?_⟩
  simp only [lline, Set.mem_setOf_eq, phi]
  linear_combination c * hab

/-- **The achieved direction at each stage is genuinely realized.** At every stage `k` there is a
nonempty lattice line of the achieved direction `(P_k,Q_k)` lying entirely inside the stage-`k`
claimed set `R_k \ R_{k+1}` — so the direction really does occur in the family the construction
builds, not merely as an abstract choice. -/
theorem exists_line_in_claims (hs : Steering Extra) (z : ℕ → ℤ × ℤ) (k : ℕ) :
    ∃ c : ℤ, (lline (Pstage hs z k) (Qstage hs z k) c).Nonempty ∧
      lline (Pstage hs z k) (Qstage hs z k) c ⊆ claims hs z k := by
  obtain ⟨⟨u0, w0⟩, hp1, hp2, hne⟩ := exists_claimed_index hs z k (stateSeq hs z k)
  refine ⟨phi (Pstage hs z k) (Qstage hs z k)
      ((stateSeq hs z k).x0 + (stateSeq hs z k).n1 * u0)
      ((stateSeq hs z k).y0 + (stateSeq hs z k).n2 * w0)
      + Pstage hs z k * Qstage hs z k * 0, lline_nonempty (Pstage_coprime hs z k) _, ?_⟩
  simpa only [Pstage, Qstage] using
    lline_subset_claims hs z k hp1.1 hp1.2 hp2.1 hp2.2 hne 0

/-- The stage-`k` steering guarantee, read off the stage-aware steering hypothesis: the direction
achieved at stage `k` is within `1/(k+1)` of the stage-`k` target. -/
theorem achievedDir_close {θseq : ℕ → ℝ}
    (hs : Steering fun k P Q => rpDist (direction P Q) (θseq k) < 1 / ((k : ℝ) + 1))
    (z : ℕ → ℤ × ℤ) (k : ℕ) :
    rpDist (achievedDir hs z k) (θseq k) < 1 / ((k : ℝ) + 1) :=
  (st_spec hs k (stateSeq hs z k)).2.2.2.2.2.2.2

/-! ## Density -/

/-- **Density of the achieved directions** (the paper's *Density* paragraph). Given a sequence of
targets with dense range in `[0,π)` and a stage-aware steering hypothesis achieving, at each stage
`k`, a direction within `1/(k+1)` of the stage-`k` target, every `θ ∈ [0,π)` is approximated to
within any `ε > 0` by the direction achieved at some stage — and that direction is realized by an
actual nonempty lattice line of the construction, inside that stage's claimed set.

The proof is the paper's: pick `N > 2/ε`; by tail density there is a stage `k ≥ N` whose target is
within `ε/2` of `θ`; the achieved direction at that stage is within `1/(k+1) < ε/2` of the target;
conclude by the triangle inequality for `rpDist`. -/
theorem density {θseq : ℕ → ℝ} (hmem : TargetsIn θseq) (hd : DenseTargets θseq)
    (hs : Steering fun k P Q => rpDist (direction P Q) (θseq k) < 1 / ((k : ℝ) + 1))
    (z : ℕ → ℤ × ℤ) {θ : ℝ} (hθ : θ ∈ Set.Ico (0 : ℝ) π) {ε : ℝ} (hε : 0 < ε) :
    ∃ k : ℕ, rpDist (achievedDir hs z k) θ < ε ∧
      ∃ c : ℤ, (lline (Pstage hs z k) (Qstage hs z k) c).Nonempty ∧
        lline (Pstage hs z k) (Qstage hs z k) c ⊆ claims hs z k := by
  obtain ⟨N, hN⟩ := exists_nat_ge (2 / ε)
  obtain ⟨k, hkN, hkθ⟩ := denseTargets_tail hd hθ (half_pos hε) N
  refine ⟨k, ?_, exists_line_in_claims hs z k⟩
  -- `1/(k+1) < ε/2`, since `k + 1 > N ≥ 2/ε`.
  have hk1 : (0 : ℝ) < (k : ℝ) + 1 := by positivity
  have hNk : (N : ℝ) ≤ (k : ℝ) := by exact_mod_cast hkN
  have hbound : 1 / ((k : ℝ) + 1) < ε / 2 := by
    have h2 : 2 / ε < (k : ℝ) + 1 := by linarith
    rw [div_lt_iff₀ hε] at h2
    rw [div_lt_iff₀ hk1]
    linarith
  -- Triangle inequality.
  have htri := rpDist_triangle_of_mem_Ico (achievedDir_mem_Ico hs z k) (hmem k) hθ
  have h1 := achievedDir_close hs z k
  have h2 : rpDist (θseq k) θ < ε / 2 :=
    lt_of_le_of_lt (rpDist_le_abs_sub _ _) hkθ
  linarith

/-! ## The concrete instantiation

Nothing above is vacuous: `Direction.lean`'s `steering` discharges the stage-aware steering
hypothesis for the concrete target sequence `thetaRat`. -/

/-- The stage-aware steering hypothesis, discharged concretely at the targets `thetaRat` with the
error bound `1/(k+1)` (the paper's `1/k`). -/
theorem steeringTo_thetaRat :
    Steering fun k P Q => rpDist (direction P Q) (thetaRat k) < 1 / ((k : ℝ) + 1) := by
  intro k n1 n2 hn1 hn2 hn
  obtain ⟨s, t, hs0, ht0, hs2, ht2, hsn2, htn1, hst, hbound⟩ :=
    steering n1 n2 hn1 hn2 hn (thetaRat k) (1 / ((k : ℝ) + 1)) (thetaRat_mem k)
      (by positivity)
  exact ⟨s, t, hs0, ht0, hs2, ht2, hsn2, htn1, hst, hbound⟩

/-- **Density, with no hypotheses left.** For every enumeration `z` of `ℤ²`, every direction
`θ ∈ [0,π)` and every `ε > 0`, the construction driven by `steeringTo_thetaRat` achieves, at some
stage, a direction within `ε` of `θ`, realized by a nonempty lattice line inside that stage's
claimed set. -/
theorem density_concrete (z : ℕ → ℤ × ℤ) {θ : ℝ} (hθ : θ ∈ Set.Ico (0 : ℝ) π) {ε : ℝ}
    (hε : 0 < ε) :
    ∃ k : ℕ, rpDist (achievedDir steeringTo_thetaRat z k) θ < ε ∧
      ∃ c : ℤ, (lline (Pstage steeringTo_thetaRat z k) (Qstage steeringTo_thetaRat z k) c).Nonempty
        ∧ lline (Pstage steeringTo_thetaRat z k) (Qstage steeringTo_thetaRat z k) c
            ⊆ claims steeringTo_thetaRat z k :=
  density thetaRat_mem thetaRat_dense steeringTo_thetaRat z hθ hε

end LatticeLineCovers
