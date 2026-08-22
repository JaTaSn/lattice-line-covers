# lattice-line-covers

A family of straight lines, each passing through at least two points of the integer lattice
$\mathbb{Z}^2$ (so each has a well-defined, rational *direction*), that covers every point of the
lattice, such that

- every lattice point lies on at least one line in the family,
- no two lines of *different* direction ever cross at a lattice point (they may cross elsewhere),
  and
- the set of directions used by the family is dense in the space of all line directions
  ($\mathbb{RP}^1$) — it comes arbitrarily close to every possible direction, even though only
  countably many (rational) directions are ever actually realized.

The construction and proof are formalized end-to-end in [Lean 4](https://lean-lang.org/) +
[Mathlib](https://leanprover-community.github.io/): zero `sorry`, zero custom axioms, resting only
on Lean's three standard foundational axioms. See [`lean/PROOF.md`](lean/PROOF.md) for the exact
theorem statement and a non-expert guide to checking this yourself.

![Realized line-directions of the density construction, plotted after 10, 20, and 100 steps — the
directions spread out steadily around the circle of directions, steered toward golden-angle
equidistribution.](verification-code/density_directions.png)

## Published version

The write-up is published, open access, as a technical report in Linköping University's
mathematics report series:

> Jan Snellman, *On the directions occurring in lattice-line coverings of the integer plane*.
> LiTH-MAT-R, ISSN 0348-2960, No. 2026:02. Linköping University Electronic Press, 2026, 13 pp.
> DOI: [10.3384/LiTH-MAT-R-2026-02](https://doi.org/10.3384/LiTH-MAT-R-2026-02)

Full text (CC BY) via the DiVA record:
[urn:nbn:se:liu:diva-226766](https://urn.kb.se/resolve?urn=urn:nbn:se:liu:diva-226766)
(DiVA id `diva2:2093039`).

This repository — the Lean formalization, verification scripts, and reference certificate — is
archived as the report's supplementary software deposit on Zenodo, in the Linköping University
community:

- **This snapshot** (tag
  [`lith-mat-r-2026-02`](https://gitlab.liu.se/jansn19/lattice-line-covers/-/tags/lith-mat-r-2026-02)):
  [10.5281/zenodo.21916622](https://doi.org/10.5281/zenodo.21916622)
- **All versions** — cite this one for the evolving project, rather than any single snapshot:
  [10.5281/zenodo.21916621](https://doi.org/10.5281/zenodo.21916621)

The report is licensed CC BY; the code in this repository is MIT (see [`LICENSE`](LICENSE)).

## Repository layout

- **`article/`** — three versions of the write-up, at different stages:
  - `lattice_line_covers_pedantic.typ`/`.pdf` — the Typst working draft that guided the Lean
    formalization, kept here unmodified in the form it was actually developed in (annotations,
    changelog comments, `#leanstatus` blocks marking which claims are formally verified, and all) —
    see [`lean/STRATEGY.md`](lean/STRATEGY.md) for how it doubled as the formalization's guide.
  - `lattice_line_covers_lith-mat-r-2026-02.tex`/`.pdf` — the version actually published as
    LiTH-MAT-R 2026:02 (see [Published version](#published-version) above); the `.pdf` here is the
    exact file hosted on DiVA, not a local rebuild. A polished, mechanically-derived descendant of
    the Typst draft above, in LaTeX for proper bibliography/TikZ support.
  - `lattice_line_covers_extended.tex`/`.pdf` — the pre-submission working draft heading toward
    arXiv/HAL, diverging from the frozen report as review adds exposition, figures and remarks
    (no proof or numbered-statement content has changed as of this writing) — see
    `changes-wrt-report.md` for the full, dated record of every difference. Not yet submitted or
    accepted anywhere; `arxiv/make-arxiv-package.sh` assembles the actual submission bundle
    (`.tex`, only the figures it uses, and an `anc/` directory with the Typst working draft and
    the full Lean formalization) once it's ready to go.
- **`lean/`** — the complete Lean 4 formalization of the main theorem.
  - [`PROOF.md`](lean/PROOF.md) — the theorem statement in plain language, and step-by-step
    instructions to independently verify the proof yourself.
  - [`STRATEGY.md`](lean/STRATEGY.md) — how the formalization was approached: the order lemmas were
    tackled in, and the plan/delegate/verify methodology used throughout.
  - `HISTORY.md` (forthcoming) — a condensed, narrated history of how the formalization
    progressed, back and forth, from the first lemma to the finished proof.
- **`references/`** — [`REFERENCES.md`](references/REFERENCES.md), a "certificate of existence"
  for every reference cited in the article: a verbatim, source-checked quotation of the claim being
  cited, or an explicit note when no primary source could be located. Built to guard against
  hallucinated or misremembered references.
- **`verification-code/`** — small numerical scripts (Python) used while developing the informal
  proof, to sanity-check the construction and its density claim before formalizing them, plus their
  result logs under `results/` and the `density_directions.png` plot shown above.

## Origin

The problem originated from a recreational observation about a chessboard's grid, discussed among
mathematicians, then developed into the theorem above with the help of an AI coding assistant
(Claude, Anthropic) — see the article's Introduction and Acknowledgements for the full story.

![Two lattice lines over an 8×8 chessboard set in the integer grid. The blue line runs through
(1,1) in direction (3,2), the red through (3,3) in direction (2,−3); filled dots mark the lattice
points each passes through. They do cross — at the black diamond — but at (43/13, 33/13), which is
not a lattice point, exactly as the covering condition requires. The dashed lines through the
origin carry the same two directions, and the filled squares where they meet the dotted circle are
those directions as antipodal pairs of points of the direction space
RP¹.](article/figures/chessboard-figure.png)

## License

MIT — see [`LICENSE`](LICENSE).
