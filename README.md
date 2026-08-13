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

## Repository layout

- **`article/`** — the publication-track write-up (LaTeX, for arXiv/HAL/LiTH-MAT-R). The
  submission-track `.tex` file is a polished, mechanically-derived descendant of a Typst working
  draft, `lattice_line_covers_pedantic.typ`, kept here unmodified in the form it was actually
  developed in (annotations, changelog comments, and all) — see [`lean/STRATEGY.md`](lean/STRATEGY.md)
  for how that draft doubled as the Lean formalization's guide.
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

## License

MIT — see [`LICENSE`](LICENSE).
