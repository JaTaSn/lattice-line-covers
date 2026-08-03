"""Checks the Steering Lemma's proof as written in article/lattice_line_covers_formal.tex
(eq:steering-p-choice through eq:steering-final-bound): the prime-choice condition
L0 < eps*mu*n1*p/n2 incorrectly carries a factor of mu (the target slope), which should
not be there. This script reproduces the proof's own construction literally and checks
whether the resulting (s,t) actually achieves the claimed eps-approximation.
"""
import math


def is_prime(n):
    if n < 2:
        return False
    for d in range(2, int(n**0.5) + 1):
        if n % d == 0:
            return False
    return True


def nextprime(n):
    n += 1
    while not is_prime(n):
        n += 1
    return n


def steering_constants(n1):
    r_divisors = [r for r in range(2, n1 + 1) if n1 % r == 0 and is_prime(r)]
    delta = 0.5
    for r in r_divisors:
        delta *= (1 - 1 / r)
    omega = len(r_divisors)
    E = 2 ** (omega + 1)
    L0 = math.ceil((E + 1) / delta)
    return delta, E, L0


def run(n1, n2, mu, eps, use_paper_threshold=True, label=""):
    delta, E, L0 = steering_constants(n1)
    if use_paper_threshold:
        # paper's literal eq:steering-p-choice: L0 < eps*mu*n1*p/n2
        if mu == 0:
            print(f"[{label}] mu=0: paper's condition L0 < eps*mu*n1*p/n2 reduces to "
                  f"{L0} < 0 -- UNSATISFIABLE for any p.")
            return
        threshold = L0 * n2 / (eps * mu * n1)
    else:
        # corrected, mu-independent threshold: p > n2*L0/(n1*eps)
        threshold = n2 * L0 / (n1 * eps)
    p = nextprime(int(threshold))
    s = p
    t0 = math.floor(mu * n1 * p / n2)
    window = range(t0, t0 + L0)
    candidates = [t for t in window if math.gcd(t, n1 * p) == 1]
    best = min(candidates, key=lambda t: abs(n2 * t / (n1 * s) - mu))
    slope = n2 * best / (n1 * s)
    diff = abs(slope - mu)
    ok = diff < eps
    print(f"[{label}] n1={n1} n2={n2} mu={mu} eps={eps} L0={L0} "
          f"threshold_p>{threshold:.3f} chosen_p={p} best_t={best} "
          f"slope={slope:.6f} |slope-mu|={diff:.6f} within_eps={ok}")


if __name__ == "__main__":
    print("=== paper's literal eq:steering-p-choice (buggy: has mu in threshold) ===")
    run(1, 1, mu=100, eps=0.01, use_paper_threshold=True, label="mu=100 (paper)")
    run(1, 1, mu=10, eps=0.5, use_paper_threshold=True, label="mu=10 (paper)")
    run(1, 1, mu=0, eps=0.01, use_paper_threshold=True, label="mu=0 (paper)")

    print()
    print("=== corrected, mu-independent threshold p > n2*L0/(n1*eps) ===")
    run(1, 1, mu=100, eps=0.01, use_paper_threshold=False, label="mu=100 (fixed)")
    run(1, 1, mu=10, eps=0.5, use_paper_threshold=False, label="mu=10 (fixed)")
