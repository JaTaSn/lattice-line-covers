"""Numerical trace of the density construction for lattice-line-covers (see LOGBOOK.md).

Version 2, after the 2026-08-01 numerical trace caught a real bug in version 1: targets must be
chosen as EXACT elements of the current remaining sublattice, not just some multiple of them
(a multiple's line has extra lattice points, at its true primitive spacing, that leak outside the
sublattice). Fixed here by keeping the remaining coset always of the simple axis-aligned form
{x === x0 (mod n1), y === y0 (mod n2)} (true by induction) and only choosing targets of the form
(n1*s, n2*t).

Two independent checks:
1. The key lemma: direction (p,q) restricted to levels === c0 (mod p*q) covers exactly the
   coset {x === x0 (mod p), y === y0 (mod q)} -- checked against many random coprime (p,q).
2. A full run of the (fixed) recursive construction over a bounded window, verifying by brute
   force that no two lines of different direction share a lattice point in the window, and that
   the window is fully covered.
"""

import math
import random
from fractions import Fraction


def check_lemma(trials=200, box=40, seed=0):
    rng = random.Random(seed)
    for _ in range(trials):
        p = rng.randint(1, 12)
        q = rng.randint(1, 12)
        if math.gcd(p, q) != 1:
            continue
        x0 = rng.randint(0, p - 1)
        y0 = rng.randint(0, q - 1)
        c0 = (q * x0 - p * y0) % (p * q)
        for x in range(-box, box + 1):
            for y in range(-box, box + 1):
                level_cond = (q * x - p * y) % (p * q) == c0
                congruence_cond = (x % p == x0) and (y % q == y0)
                if level_cond != congruence_cond:
                    return False, (p, q, x0, y0, x, y)
    return True, None


def pick_target(n1, n2, stage, search_range=60, allow_negative=True):
    """Actively search for a DIAGONAL (s,t), |s|,|t|>=2, coprime (in absolute value) to the
    current n1,n2 -- rather than passively enumerating and defaulting to s=1 whenever it's
    first-to-pass (degenerates to a single-axis construction), and -- per the 2026-08-01 20:04
    independent-review finding -- allowing NEGATIVE s,t, since s,t>=2 only forces strictly
    positive slopes forever (only half of S^1 reachable). Rotates the search starting point by
    stage so consecutive stages try visibly different target ratios."""
    start = 2 + (stage * 13) % 47
    s_signs = (1, -1) if allow_negative else (1,)
    t_signs = (-1, 1) if allow_negative else (1,)
    for s_sign in s_signs:
        for s_mag in range(start, start + search_range):
            s = s_sign * s_mag
            if math.gcd(s_mag, n2) != 1:
                continue
            for t_sign in t_signs:
                for t_mag in range(2, search_range):
                    t = t_sign * t_mag
                    if math.gcd(t_mag, n1) == 1 and math.gcd(s_mag, t_mag) == 1:
                        return s, t
    for t in range(2, search_range):
        if math.gcd(t, n1) == 1:
            return 1, t
    raise RuntimeError("no valid target found in search range")


def run_construction(N=12, max_stages=5000):
    box_points = [(x, y) for x in range(-N, N + 1) for y in range(-N, N + 1)]
    box_points.sort(key=lambda p: (max(abs(p[0]), abs(p[1])), p))

    assignment = {}  # (x,y) -> (P,Q,c)
    lines_used = set()

    # remaining coset, always of the form {x===x0 (mod n1), y===y0 (mod n2)}
    n1, n2, x0, y0 = 1, 1, 0, 0

    stage = 0
    trace = []

    for z in box_points:
        if z in assignment:
            continue
        zx, zy = z
        # z's local coords in current coset: u=(zx-x0)/n1, w=(zy-y0)/n2
        assert (zx - x0) % n1 == 0 and (zy - y0) % n2 == 0, "point not in remaining coset"
        u_star, w_star = (zx - x0) // n1, (zy - y0) // n2

        stage += 1
        if stage > max_stages:
            raise RuntimeError("exceeded max_stages before covering the box")

        s, t = pick_target(n1, n2, stage)
        P, Q = n1 * s, n2 * t
        assert math.gcd(P, Q) == 1, (n1, n2, s, t, P, Q)
        p0, q0 = s, t  # local direction (possibly negative), matches (s,t), no scaling mismatch
        ap0, aq0 = abs(p0), abs(q0)  # residue/modulus arithmetic always uses magnitudes
        trace.append((stage, n1, n2, s, t, P, Q))

        u0_star, w0_star = u_star % ap0, w_star % aq0
        reserved = None
        for uu in range(ap0):
            for ww in range(aq0):
                if (uu, ww) != (u0_star, w0_star):
                    reserved = (uu, ww)
                    break
            if reserved is not None:
                break
        assert reserved is not None

        newly_claimed = []
        for zz in box_points:
            if zz in assignment:
                continue
            zzx, zzy = zz
            if (zzx - x0) % n1 != 0 or (zzy - y0) % n2 != 0:
                continue
            uu = ((zzx - x0) // n1) % ap0
            ww = ((zzy - y0) // n2) % aq0
            if (uu, ww) == reserved:
                continue
            c = Q * zzx - P * zzy
            assignment[zz] = (P, Q, c)
            newly_claimed.append((P, Q, c))
        lines_used.update(newly_claimed)

        # new remaining coset = reserved local residue class (n1,n2 stay positive: magnitudes)
        ru, rw = reserved
        x0, y0 = x0 + n1 * ru, y0 + n2 * rw
        n1, n2 = n1 * ap0, n2 * aq0

    return assignment, lines_used, stage, trace


def reduce_dir(P, Q):
    g = math.gcd(abs(P), abs(Q))
    P, Q = P // g, Q // g
    if P < 0 or (P == 0 and Q < 0):
        P, Q = -P, -Q
    return (P, Q)


def verify(assignment, lines_used, N):
    box_points = [(x, y) for x in range(-N, N + 1) for y in range(-N, N + 1)]
    missing = [z for z in box_points if z not in assignment]
    if missing:
        return False, f"uncovered points: {missing[:10]} (total {len(missing)})"

    distinct_lines = list(lines_used)
    bad = []
    for z in box_points:
        own_P, own_Q, own_c = assignment[z]
        for (P, Q, c) in distinct_lines:
            if (P, Q) == (own_P, own_Q):
                continue
            if Q * own_P - P * own_Q == 0:
                continue  # parallel
            if Q * z[0] - P * z[1] == c:
                bad.append((z, (P, Q, c), (own_P, own_Q, own_c)))
    if bad:
        return False, f"bad crossings found: {bad[:5]} (total {len(bad)})"

    n_dirs = len(set(reduce_dir(P, Q) for (P, Q, c) in distinct_lines))
    return True, f"OK: {len(box_points)} points covered, {len(distinct_lines)} lines, {n_dirs} distinct directions, no bad crossings"


if __name__ == "__main__":
    ok, counterexample = check_lemma()
    print("Lemma check:", "PASS" if ok else f"FAIL {counterexample}")

    N = 12
    assignment, lines_used, stages, trace = run_construction(N=N)
    ok, msg = verify(assignment, lines_used, N)
    print(f"Construction check (N={N}, stages={stages}):", "PASS" if ok else "FAIL", "-", msg)
    print("Stage trace (stage, n1, n2, s, t, P, Q):")
    for row in trace:
        print(" ", row)

    dirs = sorted(set(reduce_dir(P, Q) for (P, Q, c) in lines_used), key=lambda d: (d[0] ** 2 + d[1] ** 2))
    print(f"Directions realized ({len(dirs)} total):", dirs)
