"""Checks a second, independent Steering Lemma bug found 2026-08-02 (after the mu-factor
threshold bug already fixed in code/steering_bug_check.py): at mu=0 the *unshifted* window
I=[t0, t0+L0) with t0 = floor(mu*n1*p/n2) is I=[0, L0) for every p (t0 never moves), and
t=1 is always coprime to n1*p, so it is always a valid witness of "some t works" -- yet
t=1 violates the lemma's own |t|>=2 requirement, and nothing in the earlier proof text
ruled this out. This script demonstrates the failure mode directly (the *closest-to-target*
candidate, the natural one to pick, literally *is* t=1 at mu=0) and confirms the fix (shifting
the window to t0 = floor(mu*n1*p/n2) + 2, so every candidate satisfies |t|>=2 by construction).
"""
import math


def is_prime(n):
    if n < 2:
        return False
    for d in range(2, int(n**0.5) + 1):
        if n % d == 0:
            return False
    return True


def steering_constants(n1):
    r_divisors = [r for r in range(2, n1 + 1) if n1 % r == 0 and is_prime(r)]
    delta = 0.5
    for r in r_divisors:
        delta *= (1 - 1 / r)
    omega = len(r_divisors)
    E = 2 ** (omega + 1)
    L0 = math.ceil((E + 1) / delta)
    return delta, E, L0


def run(n1, n2, mu, eps, p, shifted, label=""):
    delta, E, L0 = steering_constants(n1)
    shift = 2 if shifted else 0
    t0 = math.floor(mu * n1 * p / n2) + shift
    window = list(range(t0, t0 + L0))
    candidates = [t for t in window if math.gcd(t, n1 * p) == 1]
    closest = min(candidates, key=lambda t: abs(n2 * t / (n1 * p) - mu))
    ok = abs(closest) >= 2
    print(f"[{label}] n1={n1} n2={n2} mu={mu} p={p} shifted={shifted} "
          f"window=[{t0},{t0+L0}) closest_candidate={closest} |t|>=2: {ok}")
    return window, closest


if __name__ == "__main__":
    print("=== unshifted window at mu=0: does NOT move as p grows ===")
    w1, _ = run(2, 3, mu=0, eps=0.1, p=307, shifted=False, label="p=307")
    w2, _ = run(2, 3, mu=0, eps=0.1, p=100003, shifted=False, label="p=100003")
    print(f"    windows identical across wildly different p: {w1 == w2}")

    print()
    print("=== the bug in action: closest-to-target candidate at mu=0 is literally t=1 ===")
    run(2, 3, mu=0, eps=0.1, p=307, shifted=False, label="unshifted, closest-to-mu pick")

    print()
    print("=== contrast: at mu=1 (example (i) in the pedantic draft) the window DOES move ===")
    run(2, 3, mu=1, eps=0.1, p=331, shifted=False, label="mu=1, p=331")

    print()
    print("=== fix: shifted window t0 = floor(mu*n1*p/n2)+2 guarantees |t|>=2 structurally ===")
    run(2, 3, mu=0, eps=0.1, p=307, shifted=True, label="shifted, p=307")
    run(2, 3, mu=0, eps=0.1, p=100003, shifted=True, label="shifted, p=100003")
    run(2, 3, mu=1, eps=0.1, p=331, shifted=True, label="shifted, p=331 (matches pedantic ex. (i))")
