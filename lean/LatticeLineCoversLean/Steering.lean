import Mathlib
import LatticeLineCoversLean.Sieve

/-!
# Steering lemma (finite-slope case)

Formalizes the finite-slope content of the "Steering" lemma from
`lattice-line-covers/article/lattice_line_covers.tex` (`\S 3`, Lemma `lem:steering`): for coprime
positive `n₁, n₂`, every real target slope `μ` and every `ε > 0`, there are nonzero integers `s, t`
with `|s|,|t| ≥ 2`, `gcd(s,n₂) = gcd(t,n₁) = gcd(s,t) = 1`, and `|n₂t/(n₁s) - μ| < ε`.

The hypotheses on `(s,t)` are exactly those of `LatticeLineCovers.splitting`, so this feeds
directly into the Splitting lemma.

The `θ = π/2` (infinite-slope) case of the paper's lemma is treated in its own slope-free form,
`steering_reciprocal_slope` below — the *reciprocal* slope `n₁s/(n₂t)` made close to `0`, matching
the paper's own "by symmetry" one-line justification (swap the roles of `n₁,n₂` and of `s,t`). No
`ℝP¹`/angle machinery is introduced anywhere in this file; both theorems here are purely the
slope-approximation core, deferring the connection to the paper's literal direction-closeness
statement (which needs an arctan-Lipschitz argument) to when the main theorem's own density claim
needs it.

The proof follows the paper: with `δ = ½·φ(n₁)/n₁` and `E = 2^(ω(n₁)+1)` (the sieve constants from
`Sieve.lean`), a window of length `L = 2·n₁·(E+1)` guarantees `δL - E ≥ 1`, hence at least one
integer coprime to `n₁p` in the shifted window `[⌊μn₁p/n₂⌋ + 2, ⌊μn₁p/n₂⌋ + 2 + L)`. Choosing the
prime `p` large enough (`p > n₂(L+2)/(εn₁)`) makes any such `t` give a slope within `ε` of `μ`.
The `+2` shift is what forces `|t| ≥ 2` unconditionally.

Note `L` here avoids the paper's `⌈(E+1)/δ⌉`: since `φ(n₁) ≥ 1` we have `δ ≥ 1/(2n₁)`, so
`L·δ ≥ (E+1)·φ(n₁) ≥ E+1`, with no ceiling function needed.
-/

namespace LatticeLineCovers

open Finset

/-- **Steering lemma, finite slope, nonnegative target.** The `μ ≥ 0` half of `steering_slope`;
the general case follows by `t ↦ -t`. -/
theorem steering_slope_nonneg (n1 n2 : ℤ) (hn1 : 0 < n1) (hn2 : 0 < n2) (hn : IsCoprime n1 n2)
    (μ ε : ℝ) (hμ : 0 ≤ μ) (hε : 0 < ε) :
    ∃ s t : ℤ, s ≠ 0 ∧ t ≠ 0 ∧ 2 ≤ |s| ∧ 2 ≤ |t| ∧
      IsCoprime s n2 ∧ IsCoprime t n1 ∧ IsCoprime s t ∧
      |((n2 : ℝ) * (t : ℝ)) / ((n1 : ℝ) * (s : ℝ)) - μ| < ε := by
  -- Step 1: natural-number avatars of `n1`, `n2`.
  obtain ⟨n1', hn1c⟩ : ∃ m : ℕ, (m : ℤ) = n1 := ⟨n1.toNat, Int.toNat_of_nonneg hn1.le⟩
  obtain ⟨n2', hn2c⟩ : ∃ m : ℕ, (m : ℤ) = n2 := ⟨n2.toNat, Int.toNat_of_nonneg hn2.le⟩
  have hn1pos : 0 < n1' := by omega
  have hn2pos : 0 < n2' := by omega
  have hn1ne : n1' ≠ 0 := hn1pos.ne'
  have hn1R : (0 : ℝ) < (n1 : ℝ) := by exact_mod_cast hn1
  have hn2R : (0 : ℝ) < (n2 : ℝ) := by exact_mod_cast hn2
  have hn1Rne : ((n1 : ℝ)) ≠ 0 := hn1R.ne'
  have hn2Rne : ((n2 : ℝ)) ≠ 0 := hn2R.ne'
  -- Step 2: the window length `L`, chosen so that `δ·L - E ≥ 1` with no ceiling function.
  obtain ⟨L, hLdef⟩ : ∃ L : ℕ, L = 2 * n1' * (2 ^ (#n1'.primeFactors + 1) + 1) := ⟨_, rfl⟩
  -- Step 3: a prime `p` beyond `n1'`, `n2'` and the `ε`-threshold.
  obtain ⟨N, hN⟩ := exists_nat_gt
    (max ((n2 : ℝ) * ((L : ℝ) + 2) / (ε * (n1 : ℝ))) (max ((n1' : ℕ) : ℝ) ((n2' : ℕ) : ℝ)))
  obtain ⟨p, hpN, hp⟩ := Nat.exists_infinite_primes (N + 1)
  obtain ⟨hNthr, hNn⟩ := max_lt_iff.mp hN
  obtain ⟨hNn1, hNn2⟩ := max_lt_iff.mp hNn
  have hNp : ((N : ℕ) : ℝ) < ((p : ℕ) : ℝ) := by
    have : N < p := by omega
    exact_mod_cast this
  have hppos : (0 : ℝ) < ((p : ℕ) : ℝ) := lt_of_le_of_lt (Nat.cast_nonneg N) hNp
  have hpRne : ((p : ℕ) : ℝ) ≠ 0 := hppos.ne'
  have hn1ltp : n1' < p := by
    have h : n1' < N := by exact_mod_cast hNn1
    omega
  have hn2ltp : n2' < p := by
    have h : n2' < N := by exact_mod_cast hNn2
    omega
  have hpdvd1 : ¬ p ∣ n1' := fun h => absurd (Nat.le_of_dvd hn1pos h) (by omega)
  have hpdvd2 : ¬ p ∣ n2' := fun h => absurd (Nat.le_of_dvd hn2pos h) (by omega)
  have hthr : (n2 : ℝ) * ((L : ℝ) + 2) < ε * ((n1 : ℝ) * ((p : ℕ) : ℝ)) := by
    have h0 : (n2 : ℝ) * ((L : ℝ) + 2) / (ε * (n1 : ℝ)) < ((p : ℕ) : ℝ) := lt_trans hNthr hNp
    have hd : (0 : ℝ) < ε * (n1 : ℝ) := mul_pos hε hn1R
    rw [div_lt_iff₀ hd] at h0
    have hcomm : ((p : ℕ) : ℝ) * (ε * (n1 : ℝ)) = ε * ((n1 : ℝ) * ((p : ℕ) : ℝ)) := by ring
    linarith
  -- Step 4: the (shifted) window start.
  obtain ⟨T, hTdef⟩ : ∃ T : ℝ, T = μ * (n1 : ℝ) * ((p : ℕ) : ℝ) / (n2 : ℝ) := ⟨_, rfl⟩
  have hT0 : 0 ≤ T := by
    rw [hTdef]
    exact div_nonneg (mul_nonneg (mul_nonneg hμ hn1R.le) hppos.le) hn2R.le
  have hfl0 : 0 ≤ ⌊T⌋ := Int.floor_nonneg.mpr hT0
  obtain ⟨a, hadef⟩ : ∃ a : ℤ, a = ⌊T⌋ + 2 := ⟨_, rfl⟩
  -- Step 5: the sieve produces a witness `t` in the window.
  have hcard := card_coprime_Ico_mul_prime_ge hn1ne hp hpdvd1 a L
  have hphi : (1 : ℚ) ≤ ((n1'.totient : ℕ) : ℚ) := by
    exact_mod_cast Nat.totient_pos.mpr hn1pos
  have hn1Q : (0 : ℚ) < ((n1' : ℕ) : ℚ) := by exact_mod_cast hn1pos
  have hX0 : (0 : ℚ) ≤ (2 : ℚ) ^ (#n1'.primeFactors + 1) := by positivity
  have hLQ : ((L : ℕ) : ℚ) = 2 * ((n1' : ℕ) : ℚ) * ((2 : ℚ) ^ (#n1'.primeFactors + 1) + 1) := by
    rw [hLdef]; push_cast; ring
  have hmain : (1 : ℚ) ≤
      ((L : ℕ) : ℚ) * ((1 / 2 : ℚ) * ((n1'.totient : ℕ) : ℚ) / ((n1' : ℕ) : ℚ)) -
        2 ^ (#n1'.primeFactors + 1) := by
    have hx : ((L : ℕ) : ℚ) * ((1 / 2 : ℚ) * ((n1'.totient : ℕ) : ℚ) / ((n1' : ℕ) : ℚ)) =
        ((2 : ℚ) ^ (#n1'.primeFactors + 1) + 1) * ((n1'.totient : ℕ) : ℚ) := by
      rw [hLQ]; field_simp
    rw [hx]
    nlinarith [hphi, hX0, mul_le_mul_of_nonneg_left hphi hX0]
  have hge1 := le_trans hmain hcard
  have hSpos : 0 < #{u ∈ Finset.Ico a (a + (L : ℤ)) | Nat.Coprime u.natAbs (n1' * p)} := by
    have h := lt_of_lt_of_le zero_lt_one hge1
    exact_mod_cast h
  obtain ⟨t, htS⟩ := Finset.card_pos.mp hSpos
  simp only [Finset.mem_filter, Finset.mem_Ico] at htS
  obtain ⟨⟨hta, htL⟩, htcop⟩ := htS
  -- Step 6: coprimality.
  have hc1 : Nat.Coprime t.natAbs n1' :=
    Nat.Coprime.coprime_dvd_right (dvd_mul_right n1' p) htcop
  have hc2 : Nat.Coprime t.natAbs p :=
    Nat.Coprime.coprime_dvd_right (dvd_mul_left p n1') htcop
  have hnat1 : n1.natAbs = n1' := by rw [← hn1c]; simp
  have hnat2 : n2.natAbs = n2' := by rw [← hn2c]; simp
  have htn1 : IsCoprime t n1 := by
    rw [Int.isCoprime_iff_nat_coprime, hnat1]; exact hc1
  have hst : IsCoprime ((p : ℕ) : ℤ) t := by
    rw [Int.isCoprime_iff_nat_coprime]
    simpa using hc2.symm
  have hsn2 : IsCoprime ((p : ℕ) : ℤ) n2 := by
    rw [Int.isCoprime_iff_nat_coprime, hnat2]
    simpa using hp.coprime_iff_not_dvd.mpr hpdvd2
  have hp2 : 2 ≤ p := hp.two_le
  have ht2 : 2 ≤ t := by omega
  refine ⟨((p : ℕ) : ℤ), t, by omega, by omega, ?_, ?_, hsn2, htn1, hst, ?_⟩
  · rw [abs_of_nonneg (Int.natCast_nonneg p)]; exact_mod_cast hp2
  · rw [abs_of_pos (by omega : (0 : ℤ) < t)]; omega
  -- Step 7: the slope bound.
  · have hL0 : (0 : ℝ) ≤ (L : ℝ) := Nat.cast_nonneg L
    have htR1 : ((⌊T⌋ : ℤ) : ℝ) + 2 ≤ (t : ℝ) := by
      have h : (⌊T⌋ + 2 : ℤ) ≤ t := by omega
      exact_mod_cast h
    have htR2 : (t : ℝ) < ((⌊T⌋ : ℤ) : ℝ) + 2 + (L : ℝ) := by
      have h : t < ⌊T⌋ + 2 + (L : ℤ) := by omega
      exact_mod_cast h
    have hfl1 : ((⌊T⌋ : ℤ) : ℝ) ≤ T := Int.floor_le T
    have hfl2 : T < ((⌊T⌋ : ℤ) : ℝ) + 1 := Int.lt_floor_add_one T
    have habs : |(t : ℝ) - T| < (L : ℝ) + 2 := by
      rw [abs_lt]; constructor <;> linarith
    have hd : (0 : ℝ) < (n1 : ℝ) * ((p : ℕ) : ℝ) := mul_pos hn1R hppos
    have heq : ((n2 : ℝ) * (t : ℝ)) / ((n1 : ℝ) * (((p : ℕ) : ℤ) : ℝ)) - μ =
        ((n2 : ℝ) / ((n1 : ℝ) * ((p : ℕ) : ℝ))) * ((t : ℝ) - T) := by
      rw [hTdef]; push_cast; field_simp
    rw [heq, abs_mul, abs_of_pos (div_pos hn2R hd)]
    calc (n2 : ℝ) / ((n1 : ℝ) * ((p : ℕ) : ℝ)) * |(t : ℝ) - T|
        < (n2 : ℝ) / ((n1 : ℝ) * ((p : ℕ) : ℝ)) * ((L : ℝ) + 2) :=
          mul_lt_mul_of_pos_left habs (div_pos hn2R hd)
      _ < ε := by
          rw [div_mul_eq_mul_div, div_lt_iff₀ hd]
          linarith

/-- **Steering lemma, finite slope.** For coprime positive `n₁,n₂`, any real target slope `μ` and
any `ε > 0`, there are nonzero `s,t` with `|s|,|t| ≥ 2`, satisfying the three coprimality
conditions of `splitting`, such that the slope `n₂t/(n₁s)` of `(n₁s, n₂t)` is within `ε` of `μ`. -/
theorem steering_slope (n1 n2 : ℤ) (hn1 : 0 < n1) (hn2 : 0 < n2) (hn : IsCoprime n1 n2)
    (μ ε : ℝ) (hε : 0 < ε) :
    ∃ s t : ℤ, s ≠ 0 ∧ t ≠ 0 ∧ 2 ≤ |s| ∧ 2 ≤ |t| ∧
      IsCoprime s n2 ∧ IsCoprime t n1 ∧ IsCoprime s t ∧
      |((n2 : ℝ) * (t : ℝ)) / ((n1 : ℝ) * (s : ℝ)) - μ| < ε := by
  rcases le_or_gt 0 μ with hμ | hμ
  · exact steering_slope_nonneg n1 n2 hn1 hn2 hn μ ε hμ hε
  · obtain ⟨s, t, hs0, ht0, hs2, ht2, hsn2, htn1, hst, hslope⟩ :=
      steering_slope_nonneg n1 n2 hn1 hn2 hn (-μ) ε (by linarith) hε
    refine ⟨s, -t, hs0, neg_ne_zero.mpr ht0, hs2, by rwa [abs_neg], hsn2, htn1.neg_left,
      hst.neg_right, ?_⟩
    have hrw : ((n2 : ℝ) * ((-t : ℤ) : ℝ)) / ((n1 : ℝ) * (s : ℝ)) - μ =
        -(((n2 : ℝ) * (t : ℝ)) / ((n1 : ℝ) * (s : ℝ)) - -μ) := by push_cast; ring
    rw [hrw, abs_neg]
    exact hslope

/-- **Steering lemma, `θ = π/2` (vertical) case.** By symmetry with `steering_slope` — swap the
roles of `n₁,n₂` and of `s,t` — applying `steering_slope` to target slope `0` for the pair
`(n₂,n₁)` gives, for any `ε > 0`, nonzero `s,t` with `|s|,|t| ≥ 2` satisfying the same three
coprimality conditions as `splitting`, such that the *reciprocal* slope `n₁s/(n₂t)` of `(n₁s,n₂t)`
is within `ε` of `0` — i.e. the direction of `(n₁s,n₂t)` is nearly vertical, the paper's `θ = π/2`
case. -/
theorem steering_reciprocal_slope (n1 n2 : ℤ) (hn1 : 0 < n1) (hn2 : 0 < n2)
    (hn : IsCoprime n1 n2) (ε : ℝ) (hε : 0 < ε) :
    ∃ s t : ℤ, s ≠ 0 ∧ t ≠ 0 ∧ 2 ≤ |s| ∧ 2 ≤ |t| ∧
      IsCoprime s n2 ∧ IsCoprime t n1 ∧ IsCoprime s t ∧
      |((n1 : ℝ) * (s : ℝ)) / ((n2 : ℝ) * (t : ℝ))| < ε := by
  obtain ⟨s1, t1, hs10, ht10, hs12, ht12, hs1n1, ht1n2, hst1, hbound⟩ :=
    steering_slope n2 n1 hn2 hn1 hn.symm 0 ε hε
  refine ⟨t1, s1, ht10, hs10, ht12, hs12, ht1n2, hs1n1, hst1.symm, ?_⟩
  simpa using hbound

end LatticeLineCovers
