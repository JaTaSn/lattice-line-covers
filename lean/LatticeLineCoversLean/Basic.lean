import Mathlib

/-!
# Rigidity lemma

Formalizes the "Rigidity" lemma from `lattice-line-covers/article/lattice_line_covers_extended.tex`
(`\S 2`, Lemma `rigidity`): for primitive directions `(p_i,q_i)`, `(p_j,q_j)` with
`Δ = p_i q_j - p_j q_i ≠ 0`, the lattice lines `φ_{(p_i,q_i)} = c_i` and
`φ_{(p_j,q_j)} = c_j` meet at a lattice point iff `Δ` divides both
`p_i c_j - p_j c_i` and `q_i c_j - q_j c_i` (the Cramer's-rule numerators).

## Which lemmas here are actually used downstream

`rigidity` and `coset` are the article's `\S 2` lemmas, and in the *article* they carry the
disjointness argument. **The formalization does not use either of them.** They have no call site;
`#print axioms LatticeLineCovers.main_theorem` does not reach them. They are kept because they are
genuine content of the paper and formalizing them is part of formalizing `\S 2` faithfully — not
because anything downstream depends on them.

What the formal proof of different-direction disjointness actually uses is the coset-partition
route further down this file and in `MainRecursion.lean`:

  `splitting_partition → RsubCoset_disjoint_of_ne → claims_disjoint`
                       `→ det_eq_zero_of_lline_eq → family_valid`

each stage of which is about *regions*, not about when two individual lines meet. So the article and
the formalization prove the same theorem by two different arguments; see `fidelity.divergences` in
`formalization.yaml`. Do not read a call to `rigidity` into the proof, and do not delete these two
lemmas on the grounds that nothing calls them.
-/

namespace LatticeLineCovers

/-- `φ_{(p,q)}(x,y) = q*x - p*y`, the linear functional whose level sets are the
lattice lines of primitive direction `(p,q)`. -/
def phi (p q x y : ℤ) : ℤ := q * x - p * y

/-- **Rigidity lemma.** (`\S 2` of the article. *Not used elsewhere in this development* — the
formal disjointness argument goes through `splitting_partition` instead; see the module docstring
above.) -/
theorem rigidity (p_i q_i p_j q_j c_i c_j : ℤ)
    (hΔ : p_i * q_j - p_j * q_i ≠ 0) :
    (∃ x y : ℤ, phi p_i q_i x y = c_i ∧ phi p_j q_j x y = c_j) ↔
      (p_i * q_j - p_j * q_i) ∣ (p_i * c_j - p_j * c_i) ∧
      (p_i * q_j - p_j * q_i) ∣ (q_i * c_j - q_j * c_i) := by
  constructor
  · rintro ⟨x, y, hx, hy⟩
    unfold phi at hx hy
    exact ⟨⟨x, by linear_combination p_j * hx - p_i * hy⟩,
           ⟨y, by linear_combination q_j * hx - q_i * hy⟩⟩
  · rintro ⟨⟨x, hx⟩, ⟨y, hy⟩⟩
    refine ⟨x, y, ?_, ?_⟩
    · unfold phi
      apply mul_left_cancel₀ hΔ
      linear_combination p_i * hy - q_i * hx
    · unfold phi
      apply mul_left_cancel₀ hΔ
      linear_combination p_j * hy - q_j * hx

/-- `ℓ_{(p,q),c}`, the lattice line of direction `(p,q)` at level `c`. -/
def lline (p q c : ℤ) : Set (ℤ × ℤ) := {pt | phi p q pt.1 pt.2 = c}

/-- **Coset lemma.** (`\S 2` of the article. *Not used elsewhere in this development* — the regions
the recursion actually manipulates are `Rcoset`/`RsubCoset` below, and it is `splitting` that
relates them to unions of lines; see the module docstring above.) -/
theorem coset (p q x₀ y₀ : ℤ) (hpq : IsCoprime p q) :
    ⋃ k : ℤ, lline p q (phi p q x₀ y₀ + p * q * k) =
      {pt : ℤ × ℤ | pt.1 ≡ x₀ [ZMOD p] ∧ pt.2 ≡ y₀ [ZMOD q]} := by
  ext ⟨x, y⟩
  simp only [Set.mem_iUnion, lline, Set.mem_setOf_eq, phi]
  constructor
  · rintro ⟨k, hk⟩
    -- `hk : q * x - p * y = q * x₀ - p * y₀ + p * q * k`
    refine ⟨?_, ?_⟩
    · -- `p ∣ q * (x₀ - x)` and `IsCoprime p q` give `p ∣ x₀ - x`, i.e. `x ≡ x₀ [ZMOD p]`.
      rw [Int.modEq_iff_dvd]
      refine hpq.dvd_of_dvd_mul_left ⟨y₀ - y - q * k, ?_⟩
      linear_combination -hk
    · -- symmetrically, `q ∣ p * (y₀ - y)` and `IsCoprime q p` give `q ∣ y₀ - y`.
      rw [Int.modEq_iff_dvd]
      refine hpq.symm.dvd_of_dvd_mul_left ⟨x₀ - x + p * k, ?_⟩
      linear_combination hk
  · rintro ⟨h₁, h₂⟩
    rw [Int.modEq_iff_dvd] at h₁ h₂
    obtain ⟨u, hu⟩ := h₁
    obtain ⟨v, hv⟩ := h₂
    -- `hu : x₀ - x = p * u`, `hv : y₀ - y = q * v`; take `k = v - u`.
    exact ⟨v - u, by linear_combination p * hv - q * hu⟩

/-- `R(n₁,n₂,x₀,y₀)`, the coset `{(x,y) : x≡x₀ mod n₁, y≡y₀ mod n₂}` (`\S 3`). -/
def Rcoset (n1 n2 x0 y0 : ℤ) : Set (ℤ × ℤ) :=
  {pt | pt.1 ≡ x0 [ZMOD n1] ∧ pt.2 ≡ y0 [ZMOD n2]}

/-- The finer sub-coset `R_{u₀,w₀}` of `R(n₁,n₂,x₀,y₀)`, using its own `(u,w)`
parametrization `x = x₀+n₁u`, `y = y₀+n₂w`. -/
def RsubCoset (n1 n2 x0 y0 s t u0 w0 : ℤ) : Set (ℤ × ℤ) :=
  {pt | ∃ u w : ℤ, pt.1 = x0 + n1 * u ∧ pt.2 = y0 + n2 * w ∧
    u ≡ u0 [ZMOD s] ∧ w ≡ w0 [ZMOD t]}

/-- **Splitting lemma** (statement only): `R_{u₀,w₀}` is itself a coset of the new
direction `(P,Q) = (n₁s, n₂t)`. Matching the paper exactly: `n₁,n₂` are positive
(the standing hypothesis on `R(n₁,n₂,x₀,y₀)` throughout `\S 3`) and `s,t` are
nonzero (the Splitting lemma's own stated hypothesis) -- both needed for the
cancellation steps in the proof, not just for fidelity to the paper's wording. -/
theorem splitting (n1 n2 x0 y0 s t u0 w0 : ℤ)
    (hn1 : 0 < n1) (hn2 : 0 < n2) (hs : s ≠ 0) (ht : t ≠ 0)
    (hn : IsCoprime n1 n2) (hsn2 : IsCoprime s n2) (htn1 : IsCoprime t n1) (hst : IsCoprime s t) :
    ⋃ k : ℤ, lline (n1 * s) (n2 * t)
        (phi (n1 * s) (n2 * t) (x0 + n1 * u0) (y0 + n2 * w0) + (n1 * s) * (n2 * t) * k) =
      RsubCoset n1 n2 x0 y0 s t u0 w0 := by
  have hn1ne : n1 ≠ 0 := hn1.ne'
  have hn2ne : n2 ≠ 0 := hn2.ne'
  ext ⟨x, y⟩
  simp only [Set.mem_iUnion, lline, Set.mem_setOf_eq, phi, RsubCoset]
  constructor
  · rintro ⟨k, hk⟩
    -- `hk : (n2*t)*x - (n1*s)*y = (n2*t)*(x0+n1*u0) - (n1*s)*(y0+n2*w0) + (n1*s)*(n2*t)*k`
    -- Rearranged: `(n2*t)*(x-x0-n1*u0) = (n1*s)*((y-y0-n2*w0) + (n2*t)*k)`.
    -- `n1` divides the right-hand side, and `IsCoprime n1 (n2*t)`, so `n1 ∣ x - x0`.
    have hcx : IsCoprime n1 (n2 * t) := hn.mul_right htn1.symm
    have hcy : IsCoprime n2 (n1 * s) := hn.symm.mul_right hsn2.symm
    have hdx : n1 ∣ (x - x0) :=
      hcx.dvd_of_dvd_mul_left
        ⟨s * (y - y0 - n2 * w0 + n2 * t * k) + n2 * t * u0, by linear_combination hk⟩
    have hdy : n2 ∣ (y - y0) :=
      hcy.dvd_of_dvd_mul_left
        ⟨t * (x - x0 - n1 * u0) - n1 * s * t * k + n1 * s * w0, by linear_combination -hk⟩
    obtain ⟨u, hu⟩ := hdx
    obtain ⟨w, hw⟩ := hdy
    -- `hu : x - x0 = n1 * u`, `hw : y - y0 = n2 * w`; these are the two witnesses.
    refine ⟨u, w, by linear_combination hu, by linear_combination hw, ?_, ?_⟩
    · -- Substituting `x - x0 = n1*u` and cancelling `n1 ≠ 0` turns the displayed identity into
      -- `(n2*t)*(u0-u) = s*(-(y-y0-n2*w0+n2*t*k))`, so `s ∣ (n2*t)*(u0-u)`; `IsCoprime s (n2*t)`.
      rw [Int.modEq_iff_dvd]
      refine (hsn2.mul_right hst).dvd_of_dvd_mul_left ⟨-(y - y0 - n2 * w0 + n2 * t * k), ?_⟩
      exact mul_left_cancel₀ hn1ne (by linear_combination -hk + n2 * t * hu)
    · -- Symmetrically, cancelling `n2 ≠ 0` gives `(n1*s)*(w0-w) = t*(-(x-x0-n1*u0-n1*s*k))`.
      rw [Int.modEq_iff_dvd]
      refine (htn1.mul_right hst.symm).dvd_of_dvd_mul_left
        ⟨-(x - x0 - n1 * u0 - n1 * s * k), ?_⟩
      exact mul_left_cancel₀ hn2ne (by linear_combination hk + n1 * s * hw)
  · rintro ⟨u, w, hx, hy, hu, hw⟩
    rw [Int.modEq_iff_dvd] at hu hw
    obtain ⟨a, ha⟩ := hu
    obtain ⟨b, hb⟩ := hw
    -- `ha : u0 - u = s * a`, `hb : w0 - w = t * b`; take `k = b - a`.
    exact ⟨b - a, by
      linear_combination n2 * t * hx - n1 * s * hy - n1 * n2 * t * ha + n1 * n2 * s * hb⟩

/-- **Splitting lemma, second half**: `R(n₁,n₂,x₀,y₀)` is the *disjoint* union of the
`R_{u₀,w₀}`, `0 ≤ u₀ < |s|`, `0 ≤ w₀ < |t|` — phrased as existence-and-uniqueness of
the residue pair for every point of `R`, which is exactly what "disjoint union" means. -/
theorem splitting_partition (n1 n2 x0 y0 s t : ℤ)
    (hn1 : 0 < n1) (hn2 : 0 < n2) (hs : s ≠ 0) (ht : t ≠ 0) :
    ∀ pt ∈ Rcoset n1 n2 x0 y0, ∃! p : ℤ × ℤ,
      (0 ≤ p.1 ∧ p.1 < |s| ∧ 0 ≤ p.2 ∧ p.2 < |t|) ∧
        pt ∈ RsubCoset n1 n2 x0 y0 s t p.1 p.2 := by
  -- Two representatives of the same class mod `m`, both in `[0,|m|)`, coincide.
  have key : ∀ m a b : ℤ, m ∣ a - b → 0 ≤ a → a < |m| → 0 ≤ b → b < |m| → a = b := by
    intro m a b h ha0 ha hb0 hb
    obtain ⟨c, hc⟩ := h
    rcases eq_or_ne c 0 with rfl | hc0
    · simp only [mul_zero] at hc; omega
    · exfalso
      have h1 : |m| ≤ |m| * |c| := le_mul_of_one_le_right (abs_nonneg m) (Int.one_le_abs hc0)
      have h2 : |a - b| = |m| * |c| := by rw [hc, abs_mul]
      have h3 : |a - b| < |m| := abs_lt.mpr ⟨by linarith, by linarith⟩
      linarith
  -- `a` and `a % m` are congruent mod `m` (idempotence of `%`).
  have hmodself : ∀ m a : ℤ, a ≡ a % m [ZMOD m] := fun m a => (Int.emod_emod_of_dvd _ dvd_rfl).symm
  rintro ⟨x, y⟩ ⟨hx, hy⟩
  rw [Int.modEq_iff_dvd] at hx hy
  obtain ⟨u0, hu0⟩ := hx
  obtain ⟨w0, hw0⟩ := hy
  -- `hu0 : x0 - x = n1 * u0`, `hw0 : y0 - y = n2 * w0`, so `x = x0 + n1*(-u0)` etc.
  refine ⟨((-u0) % s, (-w0) % t),
    ⟨⟨Int.emod_nonneg _ hs, Int.emod_lt_abs _ hs, Int.emod_nonneg _ ht, Int.emod_lt_abs _ ht⟩,
      ⟨-u0, -w0, by linear_combination -hu0, by linear_combination -hw0,
        hmodself s (-u0), hmodself t (-w0)⟩⟩, ?_⟩
  rintro ⟨a, b⟩ ⟨⟨ha0, ha, hb0, hb⟩, ⟨u, w, hxe, hye, hum, hwm⟩⟩
  -- The parametrizing witnesses are forced: `n1 ≠ 0`, `n2 ≠ 0` cancel.
  have hueq : u = -u0 := mul_left_cancel₀ hn1.ne' (by linear_combination -hxe - hu0)
  have hweq : w = -w0 := mul_left_cancel₀ hn2.ne' (by linear_combination -hye - hw0)
  rw [hueq] at hum
  rw [hweq] at hwm
  have hda : s ∣ a - (-u0) % s := Int.modEq_iff_dvd.mp (((hmodself s (-u0)).symm).trans hum)
  have hdb : t ∣ b - (-w0) % t := Int.modEq_iff_dvd.mp (((hmodself t (-w0)).symm).trans hwm)
  simp only [Prod.mk.injEq]
  exact ⟨key s a _ hda ha0 ha (Int.emod_nonneg _ hs) (Int.emod_lt_abs _ hs),
    key t b _ hdb hb0 hb (Int.emod_nonneg _ ht) (Int.emod_lt_abs _ ht)⟩

end LatticeLineCovers
