import Mathlib
import LatticeLineCoversLean.Density

/-!
# The family `𝓕` of lines, and the main theorem

Changelog:
- 2026-08-03: created. `stageLevel`, `claims_eq_biUnion` / `mem_claims_exists_line` (the
  *reverse* of `lline_subset_claims`: every claimed point actually lies on one of the lines
  placed at that stage), the family `family`, its three properties `family_coverage`,
  `family_valid`, `family_density`, and the capstone `main_theorem`.

Formalizes `Theorem~\ref{thm:main}` of `lattice-line-covers/article/lattice_line_covers.tex`:

> There is a family `𝓕` of lattice lines with `⋃𝓕 ⊇ ℤ²`, no two lines of `𝓕` of different
> direction sharing a lattice point, whose set of realized directions is dense in `ℝP¹`.

Everything mathematical is already in place before this file: `Basic.lean` has the Rigidity,
Coset and Splitting lemmas; `Sieve.lean`/`Steering.lean`/`Direction.lean` have the Steering
lemma in its `ℝP¹` form; `MainRecursion.lean` has the recursive construction with its coverage
and disjointness invariants; `Density.lean` has the density of the achieved directions. What is
done here is the assembly: turning the construction into an actual *set of lines* and reading the
paper's three claims off it.

The one genuinely new ingredient is the **reverse** of `MainRecursion.lean`'s
`lline_subset_claims`. That lemma says each line placed at stage `k` lies inside
`claims hs z k = R_k \ R_{k+1}`; coverage needs the opposite, that those lines *exhaust*
`claims hs z k`. This is `mem_claims_exists_line`, obtained by running `splitting_partition`
(existence half) to locate the sub-coset of a claimed point, ruling out the reserved one, and then
using the full *equality* in `splitting` (rather than the one-directional
`lline_subset_RsubCoset` used elsewhere) to place the point on an actual line.

**On the statement of validity.** The paper's condition is about pairs of *lines*: no two lines of
`𝓕` of different direction share a lattice point. `family_valid` and the corresponding conjunct of
`main_theorem` say exactly that, quantifying over two members `L₁, L₂` of the family and over
representations `Lᵢ = ℓ_{(Pᵢ,Qᵢ),cᵢ}` whose direction vectors are non-proportional
(`P₁Q₂ - P₂Q₁ ≠ 0`, the `Δ` of the Rigidity lemma). Nothing is assumed about *which* stage a line
came from, so this is not a weaker per-stage statement; the same-stage case is handled by
`det_eq_zero_of_lline_eq`, which recovers the direction of a nonempty lattice line from its point
set.
-/

namespace LatticeLineCovers

open Real

variable {Extra : ℕ → ℤ → ℤ → Prop}

/-! ## The lines placed at a stage -/

/-- The level `c` of the line of direction `(P_k,Q_k)` placed at stage `k` over the sub-coset with
residue pair `p = (u₀,w₀)`, at index `m` inside that sub-coset's residue class of levels. This is
the `c₀ + PQm` of the Splitting lemma, with `c₀ = φ_{(P,Q)}(x₀+n₁u₀, y₀+n₂w₀)`. -/
noncomputable def stageLevel (hs : Steering Extra) (z : ℕ → ℤ × ℤ) (k : ℕ) (p : ℤ × ℤ) (m : ℤ) :
    ℤ :=
  phi (Pstage hs z k) (Qstage hs z k)
      ((stateSeq hs z k).x0 + (stateSeq hs z k).n1 * p.1)
      ((stateSeq hs z k).y0 + (stateSeq hs z k).n2 * p.2)
    + Pstage hs z k * Qstage hs z k * m

/-- **Every line placed at stage `k` lies inside that stage's claimed set** — `MainRecursion.lean`'s
`lline_subset_claims`, restated in terms of `stageLevel` and a residue pair in the fundamental box.
-/
theorem stageLine_subset_claims (hs : Steering Extra) (z : ℕ → ℤ × ℤ) (k : ℕ) {p : ℤ × ℤ}
    (hp : p ∈ box (sOf hs k (stateSeq hs z k)) (tOf hs k (stateSeq hs z k)))
    (hne : p ≠ resIdx hs z k (stateSeq hs z k)) (m : ℤ) :
    lline (Pstage hs z k) (Qstage hs z k) (stageLevel hs z k p m) ⊆ claims hs z k := by
  obtain ⟨⟨hp1, hp2⟩, ⟨hp3, hp4⟩⟩ := mem_box.mp hp
  exact lline_subset_claims hs z k hp1 hp2 hp3 hp4 (by rw [Prod.mk.eta]; exact hne) m

/-- **The lines placed at stage `k` exhaust that stage's claimed set** — the converse of
`stageLine_subset_claims`, and the one genuinely new ingredient needed for the coverage half of the
main theorem. Every point of `R_k \ R_{k+1}` lies on a line of the stage-`k` direction sitting over
a *non-reserved* sub-coset. -/
theorem mem_claims_exists_line (hs : Steering Extra) (z : ℕ → ℤ × ℤ) (k : ℕ) {pt : ℤ × ℤ}
    (hpt : pt ∈ claims hs z k) :
    ∃ p ∈ box (sOf hs k (stateSeq hs z k)) (tOf hs k (stateSeq hs z k)),
      p ≠ resIdx hs z k (stateSeq hs z k) ∧
        ∃ m : ℤ, pt ∈ lline (Pstage hs z k) (Qstage hs z k) (stageLevel hs z k p m) := by
  obtain ⟨hs0, ht0, -, -, hsn2, htn1, hst, -⟩ := st_spec hs k (stateSeq hs z k)
  have hpt' : pt ∈ Rstage hs z k ∧ pt ∉ Rstage hs z (k + 1) := hpt
  -- Locate the sub-coset of `pt` inside `R_k` (existence half of `splitting_partition`).
  obtain ⟨p, ⟨hbox, hin⟩, -⟩ :=
    splitting_partition (stateSeq hs z k).n1 (stateSeq hs z k).n2 (stateSeq hs z k).x0
      (stateSeq hs z k).y0 (sOf hs k (stateSeq hs z k)) (tOf hs k (stateSeq hs z k))
      (stateSeq hs z k).hn1 (stateSeq hs z k).hn2 hs0 ht0 pt hpt'.1
  -- It is not the reserved one: the reserved sub-coset *is* `R_{k+1}`, which `pt` avoids.
  have hne : p ≠ resIdx hs z k (stateSeq hs z k) := by
    intro h
    refine hpt'.2 ?_
    rw [Rstage_succ, stepState_region]
    rw [h] at hin
    exact hin
  refine ⟨p, mem_box.mpr ⟨⟨hbox.1, hbox.2.1⟩, ⟨hbox.2.2.1, hbox.2.2.2⟩⟩, hne, ?_⟩
  -- The sub-coset *is* the union of the lines (the full equality in `splitting`, not just `⊆`).
  rw [← splitting (stateSeq hs z k).n1 (stateSeq hs z k).n2 (stateSeq hs z k).x0
      (stateSeq hs z k).y0 (sOf hs k (stateSeq hs z k)) (tOf hs k (stateSeq hs z k)) p.1 p.2
      (stateSeq hs z k).hn1 (stateSeq hs z k).hn2 hs0 ht0 (stateSeq hs z k).hcop hsn2 htn1
      hst] at hin
  obtain ⟨m, hm⟩ := Set.mem_iUnion.mp hin
  exact ⟨m, hm⟩

/-! ## The family `𝓕` -/

/-- **The family `𝓕`.** All the lines the construction places: at every stage `k`, over every
sub-coset of `R_k` other than the reserved one, the whole residue class of levels of the achieved
direction `(P_k,Q_k)` that covers that sub-coset.

`stageLine_subset_claims` shows every member really is contained in `claims hs z k = R_k \ R_{k+1}`
for its stage, and `mem_claims_exists_line` that these lines collectively cover `claims hs z k`. -/
noncomputable def family (hs : Steering Extra) (z : ℕ → ℤ × ℤ) : Set (Set (ℤ × ℤ)) :=
  {L | ∃ (k : ℕ) (p : ℤ × ℤ) (m : ℤ),
      p ∈ box (sOf hs k (stateSeq hs z k)) (tOf hs k (stateSeq hs z k)) ∧
        p ≠ resIdx hs z k (stateSeq hs z k) ∧
          L = lline (Pstage hs z k) (Qstage hs z k) (stageLevel hs z k p m)}

theorem mem_family (hs : Steering Extra) (z : ℕ → ℤ × ℤ) (k : ℕ) {p : ℤ × ℤ}
    (hp : p ∈ box (sOf hs k (stateSeq hs z k)) (tOf hs k (stateSeq hs z k)))
    (hne : p ≠ resIdx hs z k (stateSeq hs z k)) (m : ℤ) :
    lline (Pstage hs z k) (Qstage hs z k) (stageLevel hs z k p m) ∈ family hs z :=
  ⟨k, p, m, hp, hne, rfl⟩

/-- Every member of `𝓕` is a genuine lattice line: a nonempty level set of `φ_d` for a *primitive*
direction `d = (P,Q)`. (Nonempty + primitive forces infinitely many lattice points, the paper's
definition of a lattice line.) -/
theorem family_isLine (hs : Steering Extra) (z : ℕ → ℤ × ℤ) {L : Set (ℤ × ℤ)}
    (hL : L ∈ family hs z) :
    ∃ P Q c : ℤ, IsCoprime P Q ∧ L = lline P Q c ∧ L.Nonempty := by
  obtain ⟨k, p, m, -, -, rfl⟩ := hL
  exact ⟨Pstage hs z k, Qstage hs z k, stageLevel hs z k p m, Pstage_coprime hs z k, rfl,
    lline_nonempty (Pstage_coprime hs z k) _⟩

/-- Every member of `𝓕` lies inside the claimed set of the stage that placed it. -/
theorem family_subset_claims (hs : Steering Extra) (z : ℕ → ℤ × ℤ) {L : Set (ℤ × ℤ)}
    (hL : L ∈ family hs z) : ∃ k : ℕ, L ⊆ claims hs z k := by
  obtain ⟨k, p, m, hp, hne, rfl⟩ := hL
  exact ⟨k, stageLine_subset_claims hs z k hp hne m⟩

/-! ## Coverage -/

/-- **Coverage**: `⋃𝓕 = ℤ²`; in particular `⋃𝓕 ⊇ ℤ²`, the paper's claim. -/
theorem family_coverage (hs : Steering Extra) (z : ℕ → ℤ × ℤ) (hz : Function.Surjective z) :
    ⋃₀ family hs z = Set.univ := by
  refine Set.eq_univ_of_forall fun pt => ?_
  have hmem : pt ∈ ⋃ k, claims hs z k := by rw [coverage hs z hz]; trivial
  obtain ⟨k, hk⟩ := Set.mem_iUnion.mp hmem
  obtain ⟨p, hp, hne, m, hm⟩ := mem_claims_exists_line hs z k hk
  exact Set.mem_sUnion.mpr ⟨_, mem_family hs z k hp hne m, hm⟩

/-! ## Validity: no two lines of different direction share a lattice point -/

/-- A nonempty lattice line determines its direction, up to proportionality: if one and the same
set of lattice points is the line `ℓ_{(P₁,Q₁),c₁}` and also the line `ℓ_{(P₂,Q₂),c₂}`, then the two
direction vectors are proportional, `P₁Q₂ - P₂Q₁ = 0`.

The proof is the observation that `ℓ_{(P,Q),c}` is invariant under translation by `(P,Q)`. No
coprimality is needed. -/
theorem det_eq_zero_of_lline_eq {P₁ Q₁ c₁ P₂ Q₂ c₂ : ℤ}
    (h : lline P₁ Q₁ c₁ = lline P₂ Q₂ c₂) (hne : (lline P₁ Q₁ c₁).Nonempty) :
    P₁ * Q₂ - P₂ * Q₁ = 0 := by
  obtain ⟨⟨x, y⟩, hxy⟩ := hne
  have hxy' : phi P₁ Q₁ x y = c₁ := hxy
  have h2 : ((x + P₁, y + Q₁) : ℤ × ℤ) ∈ lline P₁ Q₁ c₁ := by
    change phi P₁ Q₁ (x + P₁) (y + Q₁) = c₁
    simp only [phi] at hxy' ⊢
    linear_combination hxy'
  rw [h] at hxy h2
  have e1 : phi P₂ Q₂ x y = c₂ := hxy
  have e2 : phi P₂ Q₂ (x + P₁) (y + Q₁) = c₂ := h2
  simp only [phi] at e1 e2
  linear_combination e2 - e1

/-- **Validity** (the paper's condition on `𝓕`): no two lines of `𝓕` of different direction share a
lattice point. "Different direction" is `P₁Q₂ - P₂Q₁ ≠ 0` — the `Δ` of the Rigidity lemma — for any
representations `Lᵢ = ℓ_{(Pᵢ,Qᵢ),cᵢ}` of the two lines.

Two cases: lines from different stages are separated by `claims_disjoint`; lines from the same
stage share the stage's direction `(P_k,Q_k)`, so they are either disjoint level sets of the same
`φ_{(P_k,Q_k)}` or literally the same line, and in the latter case
`det_eq_zero_of_lline_eq` contradicts the different-direction hypothesis. -/
theorem family_valid (hs : Steering Extra) (z : ℕ → ℤ × ℤ) {L₁ L₂ : Set (ℤ × ℤ)}
    (h₁ : L₁ ∈ family hs z) (h₂ : L₂ ∈ family hs z) {P₁ Q₁ c₁ P₂ Q₂ c₂ : ℤ}
    (hL₁ : L₁ = lline P₁ Q₁ c₁) (hL₂ : L₂ = lline P₂ Q₂ c₂)
    (hdir : P₁ * Q₂ - P₂ * Q₁ ≠ 0) :
    Disjoint L₁ L₂ := by
  obtain ⟨k, p, m, hp, hpne, rfl⟩ := h₁
  obtain ⟨j, q, m', hq, hqne, rfl⟩ := h₂
  rcases lt_trichotomy k j with hkj | rfl | hkj
  · exact Disjoint.mono (stageLine_subset_claims hs z k hp hpne m)
      (stageLine_subset_claims hs z j hq hqne m') (claims_disjoint hs z hkj)
  · by_cases hc : stageLevel hs z k p m = stageLevel hs z k q m'
    · -- Same stage, same level: the two "lines" are the same set, so the direction is the same.
      exfalso
      refine hdir (det_eq_zero_of_lline_eq (by rw [← hL₁, ← hL₂, hc]) ?_)
      rw [← hL₁]
      exact lline_nonempty (Pstage_coprime hs z k) _
    · -- Same stage, different levels: disjoint level sets of the same `φ`.
      refine Set.disjoint_left.mpr fun pt hpt1 hpt2 => hc ?_
      exact (hpt1 : phi _ _ _ _ = _).symm.trans hpt2
  · exact (Disjoint.mono (stageLine_subset_claims hs z j hq hqne m')
      (stageLine_subset_claims hs z k hp hpne m) (claims_disjoint hs z hkj)).symm

/-! ## Density of the realized directions -/

/-- **Density** (the paper's third claim): the set of directions realized by lines of `𝓕` is dense
in `ℝP¹`. Concretely: every `θ ∈ [0,π)` is within `rpDist`-distance `ε` of the direction of an
actual member of `𝓕`, for every `ε > 0`.

`Density.lean`'s `density` already supplies the stage `k` whose achieved direction is that close;
the work here is only to exhibit a line of that direction which is genuinely a *member of `𝓕`*
(`exists_claimed_index` gives a non-reserved sub-coset; take the line at index `m = 0` over it). -/
theorem family_density {θseq : ℕ → ℝ} (hmem : TargetsIn θseq) (hd : DenseTargets θseq)
    (hs : Steering fun k P Q => rpDist (direction P Q) (θseq k) < 1 / ((k : ℝ) + 1))
    (z : ℕ → ℤ × ℤ) {θ : ℝ} (hθ : θ ∈ Set.Ico (0 : ℝ) π) {ε : ℝ} (hε : 0 < ε) :
    ∃ L ∈ family hs z, ∃ P Q c : ℤ,
      IsCoprime P Q ∧ L = lline P Q c ∧ L.Nonempty ∧ rpDist (direction P Q) θ < ε := by
  obtain ⟨k, hk, -⟩ := density hmem hd hs z hθ hε
  obtain ⟨p, hp1, hp2, hpne⟩ := exists_claimed_index hs z k (stateSeq hs z k)
  exact ⟨_, mem_family hs z k (mem_box.mpr ⟨hp1, hp2⟩) hpne 0, Pstage hs z k, Qstage hs z k,
    stageLevel hs z k p 0, Pstage_coprime hs z k, rfl,
    lline_nonempty (Pstage_coprime hs z k) _, hk⟩

/-! ## The main theorem

A concrete enumeration of `ℤ²` (`ℤ × ℤ` is denumerable) and `Density.lean`'s `steeringTo_thetaRat`
discharge the two remaining parameters, leaving a statement with no hypotheses. -/

/-- A concrete enumeration of `ℤ²`. -/
noncomputable def zEnum : ℕ → ℤ × ℤ := (Denumerable.eqv (ℤ × ℤ)).symm

theorem zEnum_surjective : Function.Surjective zEnum :=
  (Denumerable.eqv (ℤ × ℤ)).symm.surjective

/-- The concrete family `𝓕` produced by the construction, driven by the target sequence
`thetaRat` and the enumeration `zEnum`. -/
noncomputable def mainFamily : Set (Set (ℤ × ℤ)) := family steeringTo_thetaRat zEnum

/-- **Main theorem** (`Theorem~\ref{thm:main}` of the paper). There is a family `𝓕` of lattice
lines such that

* every member of `𝓕` is a lattice line: a nonempty level set `ℓ_{(P,Q),c}` of a *primitive*
  direction `(P,Q)`;
* `⋃𝓕 ⊇ ℤ²` — the family covers the whole lattice;
* no two lines of `𝓕` of *different direction* (`P₁Q₂ - P₂Q₁ ≠ 0`) share a lattice point;
* the set of directions realized in `𝓕` is dense in `ℝP¹`: every `θ ∈ [0,π)` is approximated to
  within any `ε > 0`, in the paper's `ℝP¹` metric `rpDist`, by the direction of a member of `𝓕`.
-/
theorem main_theorem :
    ∃ 𝓕 : Set (Set (ℤ × ℤ)),
      (∀ L ∈ 𝓕, ∃ P Q c : ℤ, IsCoprime P Q ∧ L = lline P Q c ∧ L.Nonempty) ∧
      (Set.univ ⊆ ⋃₀ 𝓕) ∧
      (∀ L₁ ∈ 𝓕, ∀ L₂ ∈ 𝓕, ∀ P₁ Q₁ c₁ P₂ Q₂ c₂ : ℤ,
        L₁ = lline P₁ Q₁ c₁ → L₂ = lline P₂ Q₂ c₂ → P₁ * Q₂ - P₂ * Q₁ ≠ 0 →
          Disjoint L₁ L₂) ∧
      (∀ θ ∈ Set.Ico (0 : ℝ) π, ∀ ε > 0, ∃ L ∈ 𝓕, ∃ P Q c : ℤ,
        IsCoprime P Q ∧ L = lline P Q c ∧ rpDist (direction P Q) θ < ε) := by
  refine ⟨mainFamily, ?_, ?_, ?_, ?_⟩
  · exact fun L hL => family_isLine steeringTo_thetaRat zEnum hL
  · rw [mainFamily, family_coverage steeringTo_thetaRat zEnum zEnum_surjective]
  · exact fun L₁ h₁ L₂ h₂ P₁ Q₁ c₁ P₂ Q₂ c₂ hL₁ hL₂ hdir =>
      family_valid steeringTo_thetaRat zEnum h₁ h₂ hL₁ hL₂ hdir
  · intro θ hθ ε hε
    obtain ⟨L, hL, P, Q, c, hcop, hLe, -, hd⟩ :=
      family_density thetaRat_mem thetaRat_dense steeringTo_thetaRat zEnum hθ hε
    exact ⟨L, hL, P, Q, c, hcop, hLe, hd⟩

end LatticeLineCovers
