"""Plot the first 10 / 20 / 100 realized line-directions from density_sequence_output.txt on the
unit circle. A line's direction is mod pi (undirected), so each entry is plotted as an antipodal
pair of points -- this also makes the growing coverage of the FULL circle visually obvious.

Order in the sequence is encoded as color (sequential colormap, early->dark late->light -- an
ordinal/magnitude quantity, so one hue ramp, never a rainbow -- plus a colorbar as the legend),
and as a thin trajectory path connecting consecutive terms (drawn through one canonical
representative per line, theta reduced to [0,pi), to avoid doubling the path)."""

import math
import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.cm import ScalarMappable
from matplotlib.colors import Normalize

with open("density_sequence_output.txt") as f:
    dirs = [tuple(map(int, line.split())) for line in f]

CMAP = "viridis"  # perceptually uniform, colorblind-safe sequential ramp -- not a rainbow

fig, axes = plt.subplots(1, 3, figsize=(16, 5.6), subplot_kw={"aspect": "equal"})

for ax, n in zip(axes, (10, 20, 100)):
    theta = [math.atan2(Q, P) % math.pi for (P, Q) in dirs[:n]]  # canonical rep, one per line
    idx = list(range(1, n + 1))
    cmap = plt.get_cmap(CMAP)
    norm = Normalize(vmin=1, vmax=n)
    colors = [cmap(norm(i)) for i in idx]

    circle = plt.Circle((0, 0), 1, fill=False, color="#888", linewidth=1)
    ax.add_patch(circle)

    # trajectory: connect consecutive terms in sequence order (canonical points only)
    px = [math.cos(t) for t in theta]
    py = [math.sin(t) for t in theta]
    for i in range(n - 1):
        ax.plot([px[i], px[i + 1]], [py[i], py[i + 1]], color="#999999", linewidth=0.5, alpha=0.5, zorder=1)

    # antipodal pairs, colored by order
    for t, c in zip(theta, colors):
        for sign in (0, math.pi):
            x, y = math.cos(t + sign), math.sin(t + sign)
            ax.plot([0, x], [0, y], color=c, linewidth=0.5, alpha=0.35, zorder=1)
            ax.scatter([x], [y], color=[c], s=22, zorder=3, edgecolors="white", linewidths=0.4)

    ax.set_xlim(-1.15, 1.15)
    ax.set_ylim(-1.15, 1.15)
    ax.set_title(f"first {n} directions")
    ax.axis("off")

    cbar = fig.colorbar(ScalarMappable(norm=norm, cmap=cmap), ax=ax, fraction=0.046, pad=0.04, orientation="horizontal")
    cbar.set_label("order in sequence", fontsize=8)
    cbar.ax.tick_params(labelsize=7)

fig.suptitle("Realized line-directions of the lattice-line-covers density construction\n(steered toward golden-angle equidistribution; color = order, gray path = consecutive jumps)")
fig.tight_layout()
fig.savefig("../artefacts/density_directions.png", dpi=160)
print("wrote ../artefacts/density_directions.png")
