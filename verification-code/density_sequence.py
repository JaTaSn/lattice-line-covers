"""Generate the actual sequence of realized directions from the (fixed, reviewed) density
construction, steering toward a genuinely equidistributed target-angle sequence, and plot the
first N of them on the unit circle -- a visual argument for density, complementing the
crossing/coverage checks in trace_construction.py.

Target angles: golden-angle equidistribution theta_k = k * pi * (sqrt(5)-1)/2 (mod pi) -- a classical
low-discrepancy sequence on the (mod-pi) circle of line-directions, dense and well-spread from the
first few terms on. Direction is a LINE's direction (mod pi, not mod 2pi), matching this project's
actual objects.

At each stage k, current accumulated (n1,n2) pins down the achievable direction as (n1*s, n2*t)
for the next (s,t). We steer toward theta_k by the window argument from the 2026-08-01 20:04
independent review: pick s a prime not dividing n2 (increasing over a search), then search t in a
window around the value that makes atan2(n2*t, n1*s) close to theta_k, subject to
gcd(t,n1)=gcd(s,t)=1.
"""

import math
from fractions import Fraction


def golden_angle_targets(n):
    phi = (math.sqrt(5) - 1) / 2  # ~0.618
    return [(k * phi * math.pi) % math.pi for k in range(1, n + 1)]


def first_prime_not_dividing(start, n):
    def is_prime(x):
        if x < 2:
            return False
        if x % 2 == 0:
            return x == 2
        i = 3
        while i * i <= x:
            if x % i == 0:
                return False
            i += 2
        return True

    p = start
    while True:
        if is_prime(p) and (n % p != 0):
            return p
        p += 1


def steer(n1, n2, theta_target, window=2000):
    """Find (s,t), gcd(s,n2)=1, gcd(t,n1)=1, gcd(s,t)=1, s,t possibly negative, such that the
    resulting global direction (n1*s, n2*t) has angle close to theta_target (mod pi)."""
    target_slope = math.tan(theta_target)  # may be +-inf near pi/2

    best = None
    for s_base in (101, 211, 307, 401, 503, 601, 701, 809, 907, 1009):
        p = first_prime_not_dividing(s_base, n2)
        for s_sign in (1, -1):
            s = s_sign * p
            # want (n2*t)/(n1*s) ~= target_slope  =>  t ~= target_slope * n1 * s / n2
            if math.isinf(target_slope):
                t_center = 0  # direction ~ vertical-ish in local sense; handled by search below
                search_around_zero = True
            else:
                t_center = target_slope * n1 * s / n2
                search_around_zero = False
            t_center_int = int(round(t_center)) if not search_around_zero else window // 2
            for dt in range(0, window):
                for sign in (1, -1) if dt != 0 else (1,):
                    t_try = t_center_int + sign * dt
                    if t_try == 0:
                        continue
                    at = abs(t_try)
                    if math.gcd(at, n1) != 1:
                        continue
                    if math.gcd(p, at) != 1:
                        continue
                    P, Q = n1 * s, n2 * t_try
                    ang = math.atan2(Q, P) % math.pi
                    err = min(abs(ang - theta_target), math.pi - abs(ang - theta_target))
                    if best is None or err < best[0]:
                        best = (err, s, t_try, P, Q)
                if best is not None and best[0] < 1e-4:
                    break
            if best is not None and best[0] < 1e-4:
                break
        if best is not None and best[0] < 1e-4:
            break
    assert best is not None, (n1, n2, theta_target)
    return best[1], best[2]


def build_sequence(n_terms=100):
    n1, n2 = 1, 1
    targets = golden_angle_targets(n_terms)
    directions = []
    for theta in targets:
        s, t = steer(n1, n2, theta)
        P, Q = n1 * s, n2 * t
        directions.append((P, Q))
        ap, aq = abs(s), abs(t)
        n1, n2 = n1 * ap, n2 * aq
    return directions


if __name__ == "__main__":
    dirs = build_sequence(100)
    for i, (P, Q) in enumerate(dirs[:15], 1):
        ang = math.degrees(math.atan2(Q, P) % math.pi)
        print(f"{i:3d}: (P,Q) has {len(str(P))+len(str(Q))} digits, angle={ang:7.3f} deg")
    with open("density_sequence_output.txt", "w") as f:
        for P, Q in dirs:
            f.write(f"{P} {Q}\n")
    print("wrote density_sequence_output.txt")
