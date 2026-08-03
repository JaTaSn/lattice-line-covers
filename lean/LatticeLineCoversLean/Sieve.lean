import Mathlib

/-!
# A short-interval coprimality sieve bound

This file contains the number-theoretic core of the "Steering" lemma from
`lattice-line-covers/article/lattice_line_covers.tex`: a Legendre-sieve lower bound for the
number of integers in a short interval `[a, a+L)` that are coprime to a fixed modulus `m`,
with an error term that depends only on `m` (not on the position `a` of the interval, nor on
its length `L`).

The main result is `card_coprime_Ico_ge`:
```
(L : ℚ) * ∏ p ∈ m.primeFactors, (1 - (p:ℚ)⁻¹) - 2 ^ #m.primeFactors
  ≤ #{t ∈ Finset.Ico a (a + L) | Nat.Coprime t.natAbs m}
```

The proof is the classical Legendre sieve / inclusion-exclusion:

* `sum_moebius_ite_dvd`: `[gcd(t,m) = 1] = ∑_{d ∣ m} μ(d) ⬝ [d ∣ t]` (Möbius inversion applied
  to `gcd (t, m)`);
* `card_coprime_Ico_eq`: summing over `t` and swapping the order of summation;
* `abs_card_dvd_Ico_sub_lt_one`: the exact count of multiples of `d` in `[a, a+L)` differs from
  `L/d` by less than `1` (via `Int.Ico_filter_dvd_card`);
* `sum_moebius_div`: `∑_{d ∣ m} μ(d)/d = ∏_{p ∣ m} (1 - 1/p)` (via `Nat.sum_totient` and
  Möbius inversion, combined with `Nat.totient_eq_mul_prod_factors`);
* `sum_abs_moebius_divisors`: `∑_{d ∣ m} |μ(d)| = 2 ^ ω(m)`, the number of squarefree divisors.
-/

namespace LatticeLineCovers

open Finset ArithmeticFunction
open scoped ArithmeticFunction.Moebius ArithmeticFunction.zeta

variable {m : ℕ}

/-- **Legendre sieve, pointwise step.** For `m ≠ 0` and any integer `t`,
`∑_{d ∣ m} μ(d) ⬝ [d ∣ t]` is the indicator of `gcd (t, m) = 1`. -/
theorem sum_moebius_ite_dvd (hm : m ≠ 0) (t : ℤ) :
    (∑ d ∈ m.divisors, if (d : ℤ) ∣ t then ((μ d : ℤ) : ℚ) else 0) =
      if Nat.Coprime t.natAbs m then (1 : ℚ) else 0 := by
  classical
  have hgne : Nat.gcd t.natAbs m ≠ 0 := fun h => hm (Nat.eq_zero_of_gcd_eq_zero_right h)
  have hfil : Finset.filter (fun d : ℕ => (d : ℤ) ∣ t) m.divisors
      = (Nat.gcd t.natAbs m).divisors := by
    ext d
    constructor
    · intro h
      rw [Finset.mem_filter, Nat.mem_divisors] at h
      rw [Nat.mem_divisors, Nat.dvd_gcd_iff]
      exact ⟨⟨Int.ofNat_dvd_left.mp h.2, h.1.1⟩, hgne⟩
    · intro h
      rw [Nat.mem_divisors, Nat.dvd_gcd_iff] at h
      rw [Finset.mem_filter, Nat.mem_divisors]
      exact ⟨⟨h.1.2, hm⟩, Int.ofNat_dvd_left.mpr h.1.1⟩
  rw [← Finset.sum_filter, hfil]
  have key : (∑ i ∈ (Nat.gcd t.natAbs m).divisors, ((μ i : ℤ) : ℚ)) =
      if Nat.gcd t.natAbs m = 1 then (1 : ℚ) else 0 := by
    have h1 : ((μ : ArithmeticFunction ℚ) * ζ) (Nat.gcd t.natAbs m) =
        ∑ i ∈ (Nat.gcd t.natAbs m).divisors, ((μ i : ℤ) : ℚ) := by
      rw [coe_mul_zeta_apply]; simp
    rw [← h1, coe_moebius_mul_coe_zeta, one_apply]
  rw [key]

/-- **Legendre sieve, exact inclusion-exclusion identity.** -/
theorem card_coprime_Ico_eq (hm : m ≠ 0) (a : ℤ) (L : ℕ) :
    ((#{t ∈ Finset.Ico a (a + L) | Nat.Coprime t.natAbs m} : ℕ) : ℚ) =
      ∑ d ∈ m.divisors,
        ((μ d : ℤ) : ℚ) * ((#{t ∈ Finset.Ico a (a + L) | (d : ℤ) ∣ t} : ℕ) : ℚ) := by
  classical
  rw [← Finset.sum_boole]
  simp only [← sum_moebius_ite_dvd hm]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun d _ => ?_
  rw [← Finset.sum_filter, Finset.sum_const, nsmul_eq_mul, mul_comm]

/-- The number of multiples of `d` in `[a, a+L)` differs from `L/d` by less than `1`. -/
theorem abs_card_dvd_Ico_sub_lt_one (a : ℤ) (L : ℕ) {d : ℕ} (hd : 0 < d) :
    |((#{t ∈ Finset.Ico a (a + L) | (d : ℤ) ∣ t} : ℕ) : ℚ) - (L : ℚ) / (d : ℚ)| < 1 := by
  have hd' : (0 : ℤ) < (d : ℤ) := by exact_mod_cast hd
  have hdQ : (0 : ℚ) < (d : ℚ) := by exact_mod_cast hd
  have hcard := Int.Ico_filter_dvd_card a (a + (L : ℤ)) hd'
  push_cast at hcard
  have hL0 : (0 : ℚ) ≤ (L : ℚ) := Nat.cast_nonneg L
  have hdiff : ((a : ℚ) + (L : ℚ)) / (d : ℚ) - (a : ℚ) / (d : ℚ) = (L : ℚ) / (d : ℚ) := by
    field_simp
    ring
  have hxy : (a : ℚ) / (d : ℚ) ≤ ((a : ℚ) + (L : ℚ)) / (d : ℚ) := by
    have : (0 : ℚ) ≤ (L : ℚ) / (d : ℚ) := div_nonneg hL0 hdQ.le
    linarith
  have hceil : (0 : ℤ) ≤ ⌈((a : ℚ) + (L : ℚ)) / (d : ℚ)⌉ - ⌈(a : ℚ) / (d : ℚ)⌉ := by
    have := Int.ceil_le_ceil hxy
    omega
  rw [max_eq_left hceil] at hcard
  have hQ : ((#{t ∈ Finset.Ico a (a + (L : ℤ)) | (d : ℤ) ∣ t} : ℕ) : ℚ) =
      ((⌈((a : ℚ) + (L : ℚ)) / (d : ℚ)⌉ : ℤ) : ℚ) - ((⌈(a : ℚ) / (d : ℚ)⌉ : ℤ) : ℚ) := by
    exact_mod_cast congrArg (fun z : ℤ => (z : ℚ)) hcard
  rw [hQ]
  have h1 : (a : ℚ) / (d : ℚ) ≤ ((⌈(a : ℚ) / (d : ℚ)⌉ : ℤ) : ℚ) := Int.le_ceil _
  have h2 : ((⌈(a : ℚ) / (d : ℚ)⌉ : ℤ) : ℚ) < (a : ℚ) / (d : ℚ) + 1 := Int.ceil_lt_add_one _
  have h3 : ((a : ℚ) + (L : ℚ)) / (d : ℚ) ≤ ((⌈((a : ℚ) + (L : ℚ)) / (d : ℚ)⌉ : ℤ) : ℚ) :=
    Int.le_ceil _
  have h4 : ((⌈((a : ℚ) + (L : ℚ)) / (d : ℚ)⌉ : ℤ) : ℚ) < ((a : ℚ) + (L : ℚ)) / (d : ℚ) + 1 :=
    Int.ceil_lt_add_one _
  rw [abs_lt]
  constructor <;> linarith

/-- `∑_{d ∣ m} μ(d)/d = ∏_{p ∣ m} (1 - 1/p)`. -/
theorem sum_moebius_div (hm : m ≠ 0) :
    (∑ d ∈ m.divisors, ((μ d : ℤ) : ℚ) / (d : ℚ)) =
      ∏ p ∈ m.primeFactors, (1 - (p : ℚ)⁻¹) := by
  have hmQ : ((m : ℚ)) ≠ 0 := Nat.cast_ne_zero.mpr hm
  -- Möbius inversion applied to `∑_{d ∣ n} φ d = n`.
  have hinv : ∀ n > 0, ∑ x ∈ n.divisorsAntidiagonal, ((μ x.1 : ℤ) : ℚ) * ((x.2 : ℕ) : ℚ) =
      ((n.totient : ℕ) : ℚ) := by
    rw [← ArithmeticFunction.sum_eq_iff_sum_mul_moebius_eq
      (f := fun n => ((n.totient : ℕ) : ℚ)) (g := fun n => ((n : ℕ) : ℚ))]
    intro n _
    exact_mod_cast congrArg (Nat.cast : ℕ → ℚ) (Nat.sum_totient n)
  have h1 := hinv m (Nat.pos_of_ne_zero hm)
  rw [Nat.sum_divisorsAntidiagonal (f := fun i j => ((μ i : ℤ) : ℚ) * ((j : ℕ) : ℚ))] at h1
  have h2 : ∀ i ∈ m.divisors, ((μ i : ℤ) : ℚ) * (((m / i : ℕ) : ℕ) : ℚ) =
      (m : ℚ) * (((μ i : ℤ) : ℚ) / (i : ℚ)) := by
    intro i hi
    have hidvd : i ∣ m := Nat.dvd_of_mem_divisors hi
    have hi0 : (i : ℚ) ≠ 0 := Nat.cast_ne_zero.mpr (Nat.pos_of_mem_divisors hi).ne'
    rw [Nat.cast_div hidvd hi0]
    field_simp
  rw [Finset.sum_congr rfl h2, ← Finset.mul_sum] at h1
  have h3 := Nat.totient_eq_mul_prod_factors m
  rw [h3] at h1
  exact mul_left_cancel₀ hmQ h1

/-- The number of squarefree divisors of `m` is `2 ^ ω(m)`. -/
theorem sum_abs_moebius_divisors (hm : m ≠ 0) :
    (∑ d ∈ m.divisors, |((μ d : ℤ) : ℚ)|) = 2 ^ (#m.primeFactors) := by
  classical
  have hstep : ∀ d : ℕ, |((μ d : ℤ) : ℚ)| = if Squarefree d then (1 : ℚ) else 0 := by
    intro d
    rw [← Int.cast_abs, abs_moebius]
    split <;> simp
  have hpf : (UniqueFactorizationMonoid.normalizedFactors m).toFinset = m.primeFactors := by
    rw [Nat.factors_eq]; rfl
  simp only [hstep]
  rw [← Finset.sum_filter, Nat.sum_divisors_filter_squarefree hm (f := fun _ => (1 : ℚ)),
    Finset.sum_const, Finset.card_powerset, hpf, nsmul_eq_mul, mul_one]
  norm_cast

/-- **Short-interval coprimality sieve bound.**

For `m ≠ 0`, any integer `a` and any length `L : ℕ`, the number of `t ∈ [a, a+L)` with
`gcd (t, m) = 1` is at least `L ⬝ ∏_{p ∣ m} (1 - 1/p) - 2 ^ ω(m)`.

The error term `2 ^ ω(m)` depends only on `m`, not on the position `a` or the length `L` of
the interval. -/
theorem card_coprime_Ico_ge (hm : m ≠ 0) (a : ℤ) (L : ℕ) :
    (L : ℚ) * (∏ p ∈ m.primeFactors, (1 - (p : ℚ)⁻¹)) - 2 ^ (#m.primeFactors) ≤
      ((#{t ∈ Finset.Ico a (a + L) | Nat.Coprime t.natAbs m} : ℕ) : ℚ) := by
  classical
  set N : ℕ → ℚ := fun d => ((#{t ∈ Finset.Ico a (a + L) | (d : ℤ) ∣ t} : ℕ) : ℚ) with hN
  -- split the sieve sum into main term and error term
  have hsplit : ((#{t ∈ Finset.Ico a (a + L) | Nat.Coprime t.natAbs m} : ℕ) : ℚ) =
      (L : ℚ) * (∑ d ∈ m.divisors, ((μ d : ℤ) : ℚ) / (d : ℚ)) +
        ∑ d ∈ m.divisors, ((μ d : ℤ) : ℚ) * (N d - (L : ℚ) / (d : ℚ)) := by
    rw [card_coprime_Ico_eq hm a L, Finset.mul_sum, ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun d _ => by rw [hN]; ring
  -- bound the error term
  have herr : |∑ d ∈ m.divisors, ((μ d : ℤ) : ℚ) * (N d - (L : ℚ) / (d : ℚ))| ≤
      2 ^ (#m.primeFactors) := by
    refine le_trans (Finset.abs_sum_le_sum_abs _ _) ?_
    rw [← sum_abs_moebius_divisors hm]
    refine Finset.sum_le_sum fun d hd => ?_
    have hdpos : 0 < d := Nat.pos_of_mem_divisors hd
    have := (abs_card_dvd_Ico_sub_lt_one a L hdpos).le
    calc |((μ d : ℤ) : ℚ) * (N d - (L : ℚ) / (d : ℚ))|
        = |((μ d : ℤ) : ℚ)| * |N d - (L : ℚ) / (d : ℚ)| := abs_mul _ _
      _ ≤ |((μ d : ℤ) : ℚ)| * 1 := by
          exact mul_le_mul_of_nonneg_left this (abs_nonneg _)
      _ = |((μ d : ℤ) : ℚ)| := mul_one _
  rw [hsplit, sum_moebius_div hm]
  have := abs_le.mp herr
  linarith [this.1]

/-- **Specialization to the modulus needed by the Steering lemma.**

For a fixed `n ≠ 0` and a prime `p` not dividing `n`, the number of `t ∈ [a, a+L)` coprime to
`n * p` is at least `δ ⬝ L - E` with `δ = (1/2) ⬝ φ(n)/n` and `E = 2 ^ (ω(n) + 1)`; crucially
both `δ` and `E` are independent of `p`, so the bound is uniform as `p → ∞`. -/
theorem card_coprime_Ico_mul_prime_ge {n p : ℕ} (hn : n ≠ 0) (hp : p.Prime) (hpn : ¬p ∣ n)
    (a : ℤ) (L : ℕ) :
    (L : ℚ) * ((1 / 2 : ℚ) * (n.totient : ℚ) / (n : ℚ)) - 2 ^ (#n.primeFactors + 1) ≤
      ((#{t ∈ Finset.Ico a (a + L) | Nat.Coprime t.natAbs (n * p)} : ℕ) : ℚ) := by
  have hp0 : p ≠ 0 := hp.pos.ne'
  have hm : n * p ≠ 0 := Nat.mul_ne_zero hn hp0
  have hnQ : (n : ℚ) ≠ 0 := Nat.cast_ne_zero.mpr hn
  have hdisj : Disjoint n.primeFactors p.primeFactors := by
    rw [hp.primeFactors, Finset.disjoint_singleton_right, Nat.mem_primeFactors]
    tauto
  have hpf : (n * p).primeFactors = n.primeFactors ∪ p.primeFactors :=
    Nat.primeFactors_mul hn hp0
  have hcard : #(n * p).primeFactors = #n.primeFactors + 1 := by
    rw [hpf, Finset.card_union_of_disjoint hdisj, hp.primeFactors, Finset.card_singleton]
  have hprod : ∏ q ∈ (n * p).primeFactors, (1 - (q : ℚ)⁻¹) =
      (∏ q ∈ n.primeFactors, (1 - (q : ℚ)⁻¹)) * (1 - (p : ℚ)⁻¹) := by
    rw [hpf, Finset.prod_union hdisj, hp.primeFactors, Finset.prod_singleton]
  -- `P = φ(n)/n` and `0 ≤ P`
  set P : ℚ := ∏ q ∈ n.primeFactors, (1 - (q : ℚ)⁻¹) with hP
  have hP0 : 0 ≤ P := by
    refine Finset.prod_nonneg fun q hq => ?_
    have hq2 : (2 : ℚ) ≤ (q : ℚ) := by
      exact_mod_cast (Nat.prime_of_mem_primeFactors hq).two_le
    have : (q : ℚ)⁻¹ ≤ 1 := by
      rw [inv_le_one_iff₀]; right; linarith
    linarith
  have hPtot : (n.totient : ℚ) = (n : ℚ) * P := Nat.totient_eq_mul_prod_factors n
  -- `1 - 1/p ≥ 1/2` since `p ≥ 2`
  have hp2 : (2 : ℚ) ≤ (p : ℚ) := by exact_mod_cast hp.two_le
  have hphalf : (1 / 2 : ℚ) ≤ 1 - (p : ℚ)⁻¹ := by
    have hppos : (0 : ℚ) < (p : ℚ) := by linarith
    have hnn : (0 : ℚ) ≤ (p : ℚ)⁻¹ * ((p : ℚ) - 2) :=
      mul_nonneg (inv_nonneg.mpr hppos.le) (by linarith)
    have hpi : (p : ℚ)⁻¹ * (p : ℚ) = 1 := inv_mul_cancel₀ (by linarith)
    nlinarith [hnn, hpi]
  have hLQ : (0 : ℚ) ≤ (L : ℚ) := Nat.cast_nonneg L
  have hmain := card_coprime_Ico_ge hm a L
  rw [hcard, hprod] at hmain
  refine le_trans ?_ hmain
  have : (1 / 2 : ℚ) * (n.totient : ℚ) / (n : ℚ) = P * (1 / 2 : ℚ) := by
    rw [hPtot]; field_simp
  rw [this]
  have : P * (1 / 2 : ℚ) ≤ P * (1 - (p : ℚ)⁻¹) := by nlinarith
  nlinarith

end LatticeLineCovers
