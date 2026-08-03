import Mathlib
import LatticeLineCoversLean.Basic

/-!
# The main theorem's recursive construction: coverage and disjointness

Formalizes the *coverage* and *disjointness* halves of the proof of the main theorem in
`lattice-line-covers/article/lattice_line_covers.tex` (`\S 4`, `Proof of Theorem~\ref{thm:main}`).

The paper's construction builds a nested sequence of cosets `ℤ² = R₀ ⊇ R₁ ⊇ R₂ ⊇ ⋯`: at stage
`k+1` the Steering lemma supplies an admissible pair `(s,t)`, the Splitting lemma
(`LatticeLineCovers.splitting`, `LatticeLineCovers.splitting_partition` in `Basic.lean`) cuts
`R_k` into `|s||t| ≥ 4` sub-cosets each fully coverable by lines of the new direction
`(n₁s, n₂t)`, one sub-coset is *reserved* to become `R_{k+1}`, and the rest are *claimed*.

**Scope.** The coverage and disjointness paragraphs of the paper's proof never use the Steering
lemma's *direction-closeness* conclusion — only the bare existence of an admissible `(s,t)` at
every stage. That existence is taken here as an abstract hypothesis, `Steering Extra` below, where
`Extra : ℕ → ℤ → ℤ → Prop` is an arbitrary further property of the achieved direction pair
`(P,Q) = (n₁s, n₂t)` at each stage, carried along but *never inspected* by anything in this file.
Taking `Extra = fun _ _ _ => True` gives exactly what `Steering.lean`'s `steering_slope` proves
(instantiate it at any fixed `μ`, `ε`, and drop the slope bound); `Density.lean` instead takes
`Extra k P Q := rpDist (direction P Q) (θ k) < 1/(k+1)`, which is what the paper's *density*
paragraph consumes. Consequently this file itself still mentions no `ℝP¹`, `arctan`, or topology
at all.

(2026-08-03: `Steering` was generalized from a stage-independent `Prop` to the stage-indexed
`Steering Extra`; `sOf`/`tOf`/`st_spec` gained a stage argument `k`. Every theorem below was
re-verified unchanged apart from that mechanical threading.)

The main results are:

* `Rstage_anti` — the regions are nested, `R_j ⊆ R_i` for `i ≤ j`;
* `coverage_invariant` — `ℤ² \ R_k = ⋃_{i<k} (R_i \ R_{i+1})`, the paper's coverage invariant;
* `coverage` — `⋃_k (R_k \ R_{k+1}) = ℤ²`, every lattice point is claimed at some stage;
* `claims_disjoint` — claims from different stages are disjoint;
* `line_subset_step_claims` — the line-level refinement: every individual line placed into the
  family at a stage has *all* of its lattice points inside that stage's claimed set.

The enumeration `z : ℕ → ℤ × ℤ` of `ℤ²` is a parameter; only `Function.Surjective z` is ever used
(such a `z` exists since `ℤ × ℤ` is denumerable, e.g. via `Denumerable.eqv (ℤ × ℤ)`).
-/

namespace LatticeLineCovers

/-! ## Sub-cosets as plain cosets -/

/-- A sub-coset `R_{u₀,w₀}` of `R(n₁,n₂,x₀,y₀)` *is* the plain coset
`R(n₁|s|, n₂|t|, x₀+n₁u₀, y₀+n₂w₀)`, on the nose — the identity the paper checks directly from
the definition of `R_{u₀,w₀}` (writing `u = u₀+|s|u'`, `w = w₀+|t|w'`). This is what lets the
reserved sub-coset serve as the next stage's input `R(n₁',n₂',x₀',y₀')`. -/
theorem RsubCoset_eq_Rcoset (n1 n2 x0 y0 s t u0 w0 : ℤ) :
    RsubCoset n1 n2 x0 y0 s t u0 w0 =
      Rcoset (n1 * |s|) (n2 * |t|) (x0 + n1 * u0) (y0 + n2 * w0) := by
  ext ⟨x, y⟩
  simp only [RsubCoset, Rcoset, Set.mem_setOf_eq]
  constructor
  · rintro ⟨u, w, hx, hy, hu, hw⟩
    rw [Int.modEq_iff_dvd] at hu hw
    obtain ⟨a, ha⟩ := (abs_dvd s (u0 - u)).mpr hu
    obtain ⟨b, hb⟩ := (abs_dvd t (w0 - w)).mpr hw
    refine ⟨Int.modEq_iff_dvd.mpr ⟨a, ?_⟩, Int.modEq_iff_dvd.mpr ⟨b, ?_⟩⟩
    · rw [hx]; linear_combination n1 * ha
    · rw [hy]; linear_combination n2 * hb
  · rintro ⟨hx, hy⟩
    rw [Int.modEq_iff_dvd] at hx hy
    obtain ⟨a, ha⟩ := hx
    obtain ⟨b, hb⟩ := hy
    refine ⟨u0 - |s| * a, w0 - |t| * b, by linear_combination -ha, by linear_combination -hb,
      Int.modEq_iff_dvd.mpr ?_, Int.modEq_iff_dvd.mpr ?_⟩
    · have h : u0 - (u0 - |s| * a) = |s| * a := by ring
      rw [h]
      exact (self_dvd_abs s).mul_right a
    · have h : w0 - (w0 - |t| * b) = |t| * b := by ring
      rw [h]
      exact (self_dvd_abs t).mul_right b

/-- A sub-coset is contained in the coset it refines. -/
theorem RsubCoset_subset (n1 n2 x0 y0 s t u0 w0 : ℤ) :
    RsubCoset n1 n2 x0 y0 s t u0 w0 ⊆ Rcoset n1 n2 x0 y0 := by
  rintro ⟨x, y⟩ ⟨u, w, hx, hy, -, -⟩
  exact ⟨Int.modEq_iff_dvd.mpr ⟨-u, by rw [hx]; ring⟩,
    Int.modEq_iff_dvd.mpr ⟨-w, by rw [hy]; ring⟩⟩

/-- Distinct sub-cosets (with residue pairs in the fundamental box) are disjoint — the
"disjoint union" half of the Splitting lemma, restated as pairwise disjointness. -/
theorem RsubCoset_disjoint_of_ne (n1 n2 x0 y0 s t : ℤ)
    (hn1 : 0 < n1) (hn2 : 0 < n2) (hs : s ≠ 0) (ht : t ≠ 0) {p q : ℤ × ℤ}
    (hp : 0 ≤ p.1 ∧ p.1 < |s| ∧ 0 ≤ p.2 ∧ p.2 < |t|)
    (hq : 0 ≤ q.1 ∧ q.1 < |s| ∧ 0 ≤ q.2 ∧ q.2 < |t|) (hne : p ≠ q) :
    Disjoint (RsubCoset n1 n2 x0 y0 s t p.1 p.2) (RsubCoset n1 n2 x0 y0 s t q.1 q.2) := by
  refine Set.disjoint_left.mpr fun pt hpp hqq => hne ?_
  obtain ⟨r, -, huniq⟩ :=
    splitting_partition n1 n2 x0 y0 s t hn1 hn2 hs ht pt (RsubCoset_subset _ _ _ _ _ _ _ _ hpp)
  exact (huniq p ⟨hp, hpp⟩).trans (huniq q ⟨hq, hqq⟩).symm

/-- Every individual line of the new direction placed at a stage has all of its lattice points
inside the sub-coset it came from — immediate from `splitting`'s exact-union identity. -/
theorem lline_subset_RsubCoset (n1 n2 x0 y0 s t u0 w0 : ℤ)
    (hn1 : 0 < n1) (hn2 : 0 < n2) (hs : s ≠ 0) (ht : t ≠ 0)
    (hn : IsCoprime n1 n2) (hsn2 : IsCoprime s n2) (htn1 : IsCoprime t n1)
    (hst : IsCoprime s t) (m : ℤ) :
    lline (n1 * s) (n2 * t)
        (phi (n1 * s) (n2 * t) (x0 + n1 * u0) (y0 + n2 * w0) + (n1 * s) * (n2 * t) * m)
      ⊆ RsubCoset n1 n2 x0 y0 s t u0 w0 := by
  rw [← splitting n1 n2 x0 y0 s t u0 w0 hn1 hn2 hs ht hn hsn2 htn1 hst]
  exact Set.subset_iUnion (fun k : ℤ => lline (n1 * s) (n2 * t)
    (phi (n1 * s) (n2 * t) (x0 + n1 * u0) (y0 + n2 * w0) + (n1 * s) * (n2 * t) * k)) m

/-! ## The abstract steering hypothesis -/

/-- **The abstract input to the construction.** At every stage `k` and every admissible state
there exists a pair `(s,t)` satisfying exactly the hypotheses of `splitting` together with
`|s|,|t| ≥ 2`, *and* an arbitrary further property `Extra k (n₁s) (n₂t)` of the resulting achieved
direction pair `(P,Q) = (n₁s, n₂t)`.

Coverage and disjointness use *only* the seven bare properties and never inspect `Extra`, so this
file stays free of `ℝP¹`/`arctan`/topology; the density argument (`Density.lean`) instantiates
`Extra k P Q` with "the direction of `(P,Q)` is within `1/(k+1)` of the stage-`k` target `θ k`",
which is exactly what `Direction.lean`'s `steering` supplies. Taking
`Extra = fun _ _ _ => True` recovers the plain stage-independent existence statement, which
`Steering.lean`'s `steering_slope` proves at any fixed `μ, ε`. -/
def Steering (Extra : ℕ → ℤ → ℤ → Prop) : Prop :=
  ∀ (k : ℕ) (n1 n2 : ℤ), 0 < n1 → 0 < n2 → IsCoprime n1 n2 →
    ∃ s t : ℤ, s ≠ 0 ∧ t ≠ 0 ∧ 2 ≤ |s| ∧ 2 ≤ |t| ∧
      IsCoprime s n2 ∧ IsCoprime t n1 ∧ IsCoprime s t ∧ Extra k (n1 * s) (n2 * t)

variable {Extra : ℕ → ℤ → ℤ → Prop}

/-- Any stage-aware steering hypothesis weakens to the trivial one: nothing below depends on
`Extra`. -/
theorem Steering.weaken (hs : Steering Extra) : Steering (fun _ _ _ => True) := by
  intro k n1 n2 h1 h2 h3
  obtain ⟨s, t, h⟩ := hs k n1 n2 h1 h2 h3
  exact ⟨s, t, h.1, h.2.1, h.2.2.1, h.2.2.2.1, h.2.2.2.2.1, h.2.2.2.2.2.1, h.2.2.2.2.2.2.1,
    trivial⟩

/-! ## The recursive state -/

/-- The state of the recursion at one stage: the data `(n₁,n₂,x₀,y₀)` of the current region
`R(n₁,n₂,x₀,y₀)`, bundled with the standing invariants `0 < n₁`, `0 < n₂`, `gcd(n₁,n₂)=1`. -/
structure State : Type where
  n1 : ℤ
  n2 : ℤ
  x0 : ℤ
  y0 : ℤ
  hn1 : 0 < n1
  hn2 : 0 < n2
  hcop : IsCoprime n1 n2

/-- The region `R(n₁,n₂,x₀,y₀)` described by a state. -/
def State.region (S : State) : Set (ℤ × ℤ) := Rcoset S.n1 S.n2 S.x0 S.y0

/-- The base state `(n₁,n₂,x₀,y₀) = (1,1,0,0)`, whose region is all of `ℤ²`. -/
def baseState : State := ⟨1, 1, 0, 0, one_pos, one_pos, isCoprime_one_left⟩

@[simp] theorem baseState_region : baseState.region = Set.univ := by
  ext ⟨x, y⟩
  simp only [State.region, baseState, Rcoset, Set.mem_setOf_eq, Set.mem_univ, iff_true]
  exact ⟨Int.modEq_one, Int.modEq_one⟩

theorem isCoprime_abs_right {a b : ℤ} (h : IsCoprime a b) : IsCoprime a |b| := by
  rcases abs_choice b with hb | hb <;> rw [hb]
  · exact h
  · exact h.neg_right

theorem isCoprime_abs_left {a b : ℤ} (h : IsCoprime a b) : IsCoprime |a| b :=
  (isCoprime_abs_right h.symm).symm

/-! ## One step of the recursion -/

/-- The `s` supplied by the steering hypothesis at stage `k`, state `S`. -/
noncomputable def sOf (hs : Steering Extra) (k : ℕ) (S : State) : ℤ :=
  (hs k S.n1 S.n2 S.hn1 S.hn2 S.hcop).choose

/-- The `t` supplied by the steering hypothesis at stage `k`, state `S`. -/
noncomputable def tOf (hs : Steering Extra) (k : ℕ) (S : State) : ℤ :=
  (hs k S.n1 S.n2 S.hn1 S.hn2 S.hcop).choose_spec.choose

theorem st_spec (hs : Steering Extra) (k : ℕ) (S : State) :
    sOf hs k S ≠ 0 ∧ tOf hs k S ≠ 0 ∧ 2 ≤ |sOf hs k S| ∧ 2 ≤ |tOf hs k S| ∧
      IsCoprime (sOf hs k S) S.n2 ∧ IsCoprime (tOf hs k S) S.n1 ∧
      IsCoprime (sOf hs k S) (tOf hs k S) ∧
      Extra k (S.n1 * sOf hs k S) (S.n2 * tOf hs k S) :=
  (hs k S.n1 S.n2 S.hn1 S.hn2 S.hcop).choose_spec.choose_spec

/-- The fundamental box `{0,…,|s|-1} × {0,…,|t|-1}` of residue pairs indexing the sub-cosets. -/
noncomputable def box (s t : ℤ) : Finset (ℤ × ℤ) := Finset.Ico 0 |s| ×ˢ Finset.Ico 0 |t|

theorem mem_box {s t : ℤ} {p : ℤ × ℤ} :
    p ∈ box s t ↔ (0 ≤ p.1 ∧ p.1 < |s|) ∧ (0 ≤ p.2 ∧ p.2 < |t|) := by
  simp [box, Finset.mem_product, Finset.mem_Ico]

open Classical in
/-- The lexicographically least element of a finite set of integer pairs (junk value `(0,0)` on
the empty set). -/
noncomputable def lexLeast (G : Finset (ℤ × ℤ)) : ℤ × ℤ :=
  if h : G.Nonempty then ofLex ((G.image toLex).min' (h.image _)) else (0, 0)

theorem lexLeast_mem {G : Finset (ℤ × ℤ)} (h : G.Nonempty) : lexLeast G ∈ G := by
  rw [lexLeast, dif_pos h]
  have hm := Finset.min'_mem (G.image toLex) (h.image _)
  rw [Finset.mem_image] at hm
  obtain ⟨p, hp, hpe⟩ := hm
  rw [← hpe]
  simpa using hp

open Classical in
/-- The set of residue pairs eligible for reservation at stage `k`: those in the fundamental box
whose sub-coset avoids `z k` (a vacuous condition when `z k` is not even in the current region —
the paper's "otherwise reserve the lexicographically-least `(u₀,w₀)` outright"). -/
noncomputable def resCandidates (hs : Steering Extra) (z : ℕ → ℤ × ℤ) (k : ℕ) (S : State) :
    Finset (ℤ × ℤ) :=
  (box (sOf hs k S) (tOf hs k S)).filter fun p =>
    z k ∈ S.region → z k ∉ RsubCoset S.n1 S.n2 S.x0 S.y0 (sOf hs k S) (tOf hs k S) p.1 p.2

theorem resCandidates_nonempty (hs : Steering Extra) (z : ℕ → ℤ × ℤ) (k : ℕ) (S : State) :
    (resCandidates hs z k S).Nonempty := by
  obtain ⟨hs0, ht0, hs2, ht2, -, -, -, -⟩ := st_spec hs k S
  by_cases hz : z k ∈ S.region
  · -- `z k` lies in exactly one sub-coset; any other of the `≥ 4` sub-cosets avoids it.
    obtain ⟨p, -, huniq⟩ :=
      splitting_partition S.n1 S.n2 S.x0 S.y0 (sOf hs k S) (tOf hs k S) S.hn1 S.hn2 hs0 ht0 (z k) hz
    have key : ∀ q : ℤ × ℤ, 0 ≤ q.1 → q.1 < |sOf hs k S| → 0 ≤ q.2 → q.2 < |tOf hs k S| →
        q ≠ p → q ∈ resCandidates hs z k S := by
      intro q h1 h2 h3 h4 hne
      simp only [resCandidates, Finset.mem_filter]
      exact ⟨mem_box.mpr ⟨⟨h1, h2⟩, ⟨h3, h4⟩⟩,
        fun _ hmem => hne (huniq q ⟨⟨h1, h2, h3, h4⟩, hmem⟩)⟩
    by_cases hp : p = (0, 0)
    · exact ⟨(1, 0), key _ (by norm_num) (show (1 : ℤ) < |sOf hs k S| by linarith) le_rfl
        (show (0 : ℤ) < |tOf hs k S| by linarith) (by simp [hp])⟩
    · exact ⟨(0, 0), key _ le_rfl (show (0 : ℤ) < |sOf hs k S| by linarith) le_rfl
        (show (0 : ℤ) < |tOf hs k S| by linarith) fun h => hp h.symm⟩
  · refine ⟨(0, 0), ?_⟩
    simp only [resCandidates, Finset.mem_filter]
    exact ⟨mem_box.mpr ⟨⟨le_rfl, show (0 : ℤ) < |sOf hs k S| by linarith⟩,
      ⟨le_rfl, show (0 : ℤ) < |tOf hs k S| by linarith⟩⟩, fun h => absurd h hz⟩

/-- The reserved residue pair at stage `k`: the paper's rule, "if `z_k ∈ R_{k-1}`, reserve the
lexicographically-least `(u₀,w₀)` whose sub-coset does not contain `z_k`; otherwise reserve the
lexicographically-least `(u₀,w₀)` outright." -/
noncomputable def resIdx (hs : Steering Extra) (z : ℕ → ℤ × ℤ) (k : ℕ) (S : State) : ℤ × ℤ :=
  lexLeast (resCandidates hs z k S)

theorem resIdx_mem_box (hs : Steering Extra) (z : ℕ → ℤ × ℤ) (k : ℕ) (S : State) :
    resIdx hs z k S ∈ box (sOf hs k S) (tOf hs k S) := by
  have h := lexLeast_mem (resCandidates_nonempty hs z k S)
  simp only [resCandidates, Finset.mem_filter] at h
  exact h.1

theorem resIdx_avoids (hs : Steering Extra) (z : ℕ → ℤ × ℤ) (k : ℕ) (S : State)
    (hz : z k ∈ S.region) :
    z k ∉ RsubCoset S.n1 S.n2 S.x0 S.y0 (sOf hs k S) (tOf hs k S)
      (resIdx hs z k S).1 (resIdx hs z k S).2 := by
  have h := lexLeast_mem (resCandidates_nonempty hs z k S)
  simp only [resCandidates, Finset.mem_filter] at h
  exact h.2 hz

/-- One step of the recursion: split the current region using the steering pair `(s,t)` and
reserve the sub-coset selected by `resIdx`, whose data is `(n₁|s|, n₂|t|, x₀+n₁u₀, y₀+n₂w₀)`. -/
noncomputable def stepState (hs : Steering Extra) (z : ℕ → ℤ × ℤ) (k : ℕ) (S : State) : State where
  n1 := S.n1 * |sOf hs k S|
  n2 := S.n2 * |tOf hs k S|
  x0 := S.x0 + S.n1 * (resIdx hs z k S).1
  y0 := S.y0 + S.n2 * (resIdx hs z k S).2
  hn1 := mul_pos S.hn1 (abs_pos.mpr (st_spec hs k S).1)
  hn2 := mul_pos S.hn2 (abs_pos.mpr (st_spec hs k S).2.1)
  hcop := by
    obtain ⟨-, -, -, -, hsn2, htn1, hst, -⟩ := st_spec hs k S
    exact IsCoprime.mul_left
      (S.hcop.mul_right (isCoprime_abs_right htn1.symm))
      ((isCoprime_abs_left hsn2).mul_right (isCoprime_abs_right (isCoprime_abs_left hst)))

/-- The stepped region is exactly the reserved sub-coset. -/
theorem stepState_region (hs : Steering Extra) (z : ℕ → ℤ × ℤ) (k : ℕ) (S : State) :
    (stepState hs z k S).region =
      RsubCoset S.n1 S.n2 S.x0 S.y0 (sOf hs k S) (tOf hs k S)
        (resIdx hs z k S).1 (resIdx hs z k S).2 := by
  rw [RsubCoset_eq_Rcoset]
  rfl

theorem stepState_region_subset (hs : Steering Extra) (z : ℕ → ℤ × ℤ) (k : ℕ) (S : State) :
    (stepState hs z k S).region ⊆ S.region := by
  rw [stepState_region]
  exact RsubCoset_subset _ _ _ _ _ _ _ _

/-- The reservation rule works: a point of the current region that the enumeration hands us at
this stage is *not* in the reserved sub-coset, hence is claimed here. -/
theorem zk_not_mem_stepState (hs : Steering Extra) (z : ℕ → ℤ × ℤ) (k : ℕ) (S : State)
    (hz : z k ∈ S.region) : z k ∉ (stepState hs z k S).region := by
  rw [stepState_region]
  exact resIdx_avoids hs z k S hz

/-! ## The sequence of regions -/

/-- The sequence of states, `R₀ = ℤ²` and `R_{k+1}` the sub-coset reserved at stage `k`. -/
noncomputable def stateSeq (hs : Steering Extra) (z : ℕ → ℤ × ℤ) : ℕ → State
  | 0 => baseState
  | k + 1 => stepState hs z k (stateSeq hs z k)

/-- `R_k`, the region at stage `k`. -/
noncomputable def Rstage (hs : Steering Extra) (z : ℕ → ℤ × ℤ) (k : ℕ) : Set (ℤ × ℤ) :=
  (stateSeq hs z k).region

/-- The lattice points *claimed* at stage `k`, namely `R_k \ R_{k+1}` — the union of the
sub-cosets that were not reserved. -/
noncomputable def claims (hs : Steering Extra) (z : ℕ → ℤ × ℤ) (k : ℕ) : Set (ℤ × ℤ) :=
  Rstage hs z k \ Rstage hs z (k + 1)

@[simp] theorem Rstage_zero (hs : Steering Extra) (z : ℕ → ℤ × ℤ) :
    Rstage hs z 0 = Set.univ := by
  rw [Rstage, stateSeq, baseState_region]

theorem Rstage_succ (hs : Steering Extra) (z : ℕ → ℤ × ℤ) (k : ℕ) :
    Rstage hs z (k + 1) = (stepState hs z k (stateSeq hs z k)).region := rfl

/-- `R_{k+1} ⊆ R_k`. -/
theorem Rstage_succ_subset (hs : Steering Extra) (z : ℕ → ℤ × ℤ) (k : ℕ) :
    Rstage hs z (k + 1) ⊆ Rstage hs z k :=
  stepState_region_subset hs z k (stateSeq hs z k)

/-- The regions are nested: `R_j ⊆ R_i` whenever `i ≤ j`. -/
theorem Rstage_anti (hs : Steering Extra) (z : ℕ → ℤ × ℤ) {i j : ℕ} (h : i ≤ j) :
    Rstage hs z j ⊆ Rstage hs z i := by
  induction h with
  | refl => exact subset_rfl
  | step _ ih => exact (Rstage_succ_subset hs z _).trans ih

/-! ## Coverage -/

/-- **Coverage invariant** (the paper's key lemma): a point lies outside the current region `R_k`
exactly when some earlier stage already claimed it,
`ℤ² \ R_k = ⋃_{i<k} (R_i \ R_{i+1})`. -/
theorem coverage_invariant (hs : Steering Extra) (z : ℕ → ℤ × ℤ) (k : ℕ) :
    (Set.univ : Set (ℤ × ℤ)) \ Rstage hs z k = ⋃ i ∈ Finset.range k, claims hs z i := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [Finset.range_add_one, Finset.set_biUnion_insert, ← ih]
    have hsub : Rstage hs z (k + 1) ⊆ Rstage hs z k := Rstage_succ_subset hs z k
    ext q
    have h2 : q ∈ Rstage hs z (k + 1) → q ∈ Rstage hs z k := fun h => hsub h
    simp only [claims, Set.mem_sdiff, Set.mem_univ, true_and, Set.mem_union]
    tauto

/-- **Coverage**: every lattice point is claimed at some stage. -/
theorem coverage (hs : Steering Extra) (z : ℕ → ℤ × ℤ) (hz : Function.Surjective z) :
    (⋃ k, claims hs z k) = Set.univ := by
  refine Set.eq_univ_of_forall fun q => ?_
  obtain ⟨m, rfl⟩ := hz q
  by_cases hmem : z m ∈ Rstage hs z m
  · refine Set.mem_iUnion.mpr ⟨m, hmem, ?_⟩
    rw [Rstage_succ]
    exact zk_not_mem_stepState hs z m (stateSeq hs z m) hmem
  · have hq : z m ∈ (Set.univ : Set (ℤ × ℤ)) \ Rstage hs z m := ⟨trivial, hmem⟩
    rw [coverage_invariant hs z m] at hq
    simp only [Set.mem_iUnion] at hq
    obtain ⟨i, -, hi⟩ := hq
    exact Set.mem_iUnion.mpr ⟨i, hi⟩

/-! ## Disjointness -/

/-- **Disjointness, region level**: points claimed at different stages are never the same. -/
theorem claims_disjoint (hs : Steering Extra) (z : ℕ → ℤ × ℤ) {k j : ℕ} (h : k < j) :
    Disjoint (claims hs z k) (claims hs z j) := by
  refine Set.disjoint_left.mpr fun q hq hq' => hq.2 ?_
  exact Rstage_anti hs z h hq'.1

/-- **Disjointness, line level**: every individual line placed into the family at a stage — a line
of the new direction `(n₁s, n₂t)` at a level in the residue class of a *non-reserved* sub-coset —
has all of its lattice points inside that stage's claimed set `R_k \ R_{k+1}`. Combined with
`claims_disjoint`, lines from different stages never share a lattice point; lines from the same
stage are distinct level sets of the same `φ_{(P,Q)}`, hence trivially disjoint. -/
theorem line_subset_step_claims (hs : Steering Extra) (z : ℕ → ℤ × ℤ) (k : ℕ) (S : State)
    {u0 w0 : ℤ} (hu : 0 ≤ u0) (hu' : u0 < |sOf hs k S|) (hw : 0 ≤ w0) (hw' : w0 < |tOf hs k S|)
    (hne : (u0, w0) ≠ resIdx hs z k S) (m : ℤ) :
    lline (S.n1 * sOf hs k S) (S.n2 * tOf hs k S)
        (phi (S.n1 * sOf hs k S) (S.n2 * tOf hs k S) (S.x0 + S.n1 * u0) (S.y0 + S.n2 * w0)
          + (S.n1 * sOf hs k S) * (S.n2 * tOf hs k S) * m)
      ⊆ S.region \ (stepState hs z k S).region := by
  obtain ⟨hs0, ht0, -, -, hsn2, htn1, hst, -⟩ := st_spec hs k S
  have hline := lline_subset_RsubCoset S.n1 S.n2 S.x0 S.y0 (sOf hs k S) (tOf hs k S) u0 w0
    S.hn1 S.hn2 hs0 ht0 S.hcop hsn2 htn1 hst m
  have hbox := mem_box.mp (resIdx_mem_box hs z k S)
  have hdisj := RsubCoset_disjoint_of_ne S.n1 S.n2 S.x0 S.y0 (sOf hs k S) (tOf hs k S)
    S.hn1 S.hn2 hs0 ht0 (p := (u0, w0)) (q := resIdx hs z k S)
    ⟨hu, hu', hw, hw'⟩ ⟨hbox.1.1, hbox.1.2, hbox.2.1, hbox.2.2⟩ hne
  intro pt hpt
  refine ⟨RsubCoset_subset _ _ _ _ _ _ _ _ (hline hpt), ?_⟩
  rw [stepState_region]
  exact Set.disjoint_left.mp hdisj (hline hpt)

theorem claims_eq (hs : Steering Extra) (z : ℕ → ℤ × ℤ) (k : ℕ) :
    claims hs z k =
      (stateSeq hs z k).region \ (stepState hs z k (stateSeq hs z k)).region := rfl

/-- `line_subset_step_claims` specialized to the actual sequence of stages: every line of the
stage-`k` direction `(P_k,Q_k) = (n₁s, n₂t)` sitting over a non-reserved sub-coset lies entirely
inside `claims hs z k = R_k \ R_{k+1}`. -/
theorem lline_subset_claims (hs : Steering Extra) (z : ℕ → ℤ × ℤ) (k : ℕ) {u0 w0 : ℤ}
    (hu : 0 ≤ u0) (hu' : u0 < |sOf hs k (stateSeq hs z k)|)
    (hw : 0 ≤ w0) (hw' : w0 < |tOf hs k (stateSeq hs z k)|)
    (hne : (u0, w0) ≠ resIdx hs z k (stateSeq hs z k)) (m : ℤ) :
    lline ((stateSeq hs z k).n1 * sOf hs k (stateSeq hs z k))
        ((stateSeq hs z k).n2 * tOf hs k (stateSeq hs z k))
        (phi ((stateSeq hs z k).n1 * sOf hs k (stateSeq hs z k))
             ((stateSeq hs z k).n2 * tOf hs k (stateSeq hs z k))
          ((stateSeq hs z k).x0 + (stateSeq hs z k).n1 * u0)
          ((stateSeq hs z k).y0 + (stateSeq hs z k).n2 * w0)
          + ((stateSeq hs z k).n1 * sOf hs k (stateSeq hs z k)) *
              ((stateSeq hs z k).n2 * tOf hs k (stateSeq hs z k)) * m)
      ⊆ claims hs z k :=
  line_subset_step_claims hs z k (stateSeq hs z k) hu hu' hw hw' hne m

/-- **Non-vacuity**: at every stage at least one sub-coset is *not* reserved, so
`lline_subset_claims` has content (there are `|s||t| ≥ 4` residue pairs and only one is
reserved). -/
theorem exists_claimed_index (hs : Steering Extra) (z : ℕ → ℤ × ℤ) (k : ℕ) (S : State) :
    ∃ p : ℤ × ℤ, (0 ≤ p.1 ∧ p.1 < |sOf hs k S|) ∧ (0 ≤ p.2 ∧ p.2 < |tOf hs k S|) ∧
      p ≠ resIdx hs z k S := by
  obtain ⟨-, -, hs2, ht2, -, -, -, -⟩ := st_spec hs k S
  by_cases hp : resIdx hs z k S = (0, 0)
  · exact ⟨(1, 0), ⟨by norm_num, show (1 : ℤ) < |sOf hs k S| by linarith⟩,
      ⟨le_rfl, show (0 : ℤ) < |tOf hs k S| by linarith⟩, by simp [hp]⟩
  · exact ⟨(0, 0), ⟨le_rfl, show (0 : ℤ) < |sOf hs k S| by linarith⟩,
      ⟨le_rfl, show (0 : ℤ) < |tOf hs k S| by linarith⟩, fun h => hp h.symm⟩

end LatticeLineCovers
