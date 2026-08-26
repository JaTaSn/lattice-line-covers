# lattice-line-covers

### 📖 Read this online: **<https://jansn19.gitlab-pages.liu.se/lattice-line-covers/>**
*The report, the extended write-up, and a browsable rendering of the Lean formalization.*

---

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
directions spread out steadily around the circle of directions.](verification-code/density_directions.png)

*About that figure.* It is an **illustration, not the formalized construction**: it comes from
`verification-code/`, which drives the recursion with an equidistributed golden-angle target
sequence, because that is what looks best on a plot. The formalized `mainFamily` steers toward
`thetaRat` instead — an enumeration of the rationals, clamped to `[0, π)`. The difference is not an
oversight. Theorem 1 claims only that the realized directions are **dense**, and density is exactly
what `thetaRat` is proved to have; equidistribution is a strictly stronger property than the
theorem needs, so the formalization does not pay for it.

## Mirrors

The canonical repository is on [gitlab.liu.se](https://gitlab.liu.se/jansn19/lattice-line-covers).
It is **push-mirrored automatically** to
[github.com/JaTaSn/lattice-line-covers](https://github.com/JaTaSn/lattice-line-covers), because the
[Palomar registry](https://palomar-registry.org/) can only fetch from a public GitHub repository.
Push to GitLab; GitHub follows within a minute. Do not commit to the GitHub copy — it is a mirror,
and divergent refs are discarded.

## The rendered site

<https://jansn19.gitlab-pages.liu.se/lattice-line-covers/> carries the report, the extended
write-up, and the Lean formalization rendered with
[doc-gen4](https://github.com/leanprover/doc-gen4). GitLab's file browser serves `.html` as source,
so the documentation under [`lean/docs/`](lean/docs/) is **only readable through Pages** — or by
cloning and opening `lean/docs/index.html` locally. Published by the `pages` job in
[`.gitlab-ci.yml`](.gitlab-ci.yml), which writes nothing back to the repository.

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

## arXiv preprint

Announced as **[arXiv:2608.22550](https://arxiv.org/abs/2608.22550)**
([PDF](https://arxiv.org/pdf/2608.22550), [HTML](https://arxiv.org/html/2608.22550)), submitted
2026-08-23:

> Jan Snellman, *On the directions occurring in lattice-line coverings of the integer plane*,
> 21 pages, 10 figures. Subjects: Combinatorics (math.CO); Number Theory (math.NT).
> MSC classes: 05B45 (Primary), 11431 (Secondary). Comments: Lean formalization of all results
> (due to llm agent) included in `anc` directory, and also available at the GitLab repository.
> License: CC BY 4.0.

This is `article/lattice_line_covers_extended.tex` above, extending the LiTH-MAT-R report per LiU's
own requested condition for arXiv submission — see `changes-wrt-report.md` for the full, dated
record of every difference from the report.

### A note on the MSC classes

The live record reads `05B45 (Primary) 11431 (Secondary)`. **`11431` is not a valid MSC code** —
verified against the official [MSC 2020 list](https://msc2020.org/MSC_2020.pdf), where it does not
occur, and it cannot be valid in any edition: MSC codes are always two digits, a letter, two digits.

An earlier note here guessed it was a typo for `11A41` (Primes). That guess was probably wrong on
both counts. **`11H31`** — *Lattice packing and covering (number-theoretic aspects)* — is a
**single**-character substitution (`H` → `4`) where `11A41` needs two, and it is a far better fit
for a paper about covering `Z^2` by lattice lines than "Primes" would be.

**The correct classification**, which the metadata should be revised to (agreed 2026-08-25); each
code checked against the official MSC 2020 list rather than recalled:

| | Code | | Why |
|---|---|---|---|
| **Primary** | **05B40** | Combinatorial aspects of packing and covering | The better primary than the current `05B45`: this is a *covering* result, not a tessellation or tiling one. |
| Secondary | **11H31** | Lattice packing and covering (number-theoretic aspects) | The number-theoretic mirror of 05B40, and almost certainly what `11431` was meant to be. |
| Secondary | **52C15** | Packing and covering in 2 dimensions (discrete geometry) | The discrete-geometry mirror; 05B40, 11H31 and 52C15 all cross-reference one another. |
| Secondary | **11B25** | Arithmetic progressions | Where the covering-systems-of-congruences literature sits, and §5 casts this construction as the two-dimensional analogue of exactly that. |
| Secondary | **11B57** | Farey sequences | The rigidity lemma is a statement about Farey neighbours and the Stern–Brocot tree. |
| Secondary | **68V20** | Formalization of mathematics in connection with theorem provers | The Lean formalization is a headline feature, and this is how a reader hunting formalized results finds it. |

Ready to paste into arXiv's MSC-class field:

```
05B40 (Primary) 11H31, 52C15, 11B25, 11B57, 68V20 (Secondary)
```

**`68V20` is on this list but deliberately *not* in `lean/formalization.yaml`, and that asymmetry
is intentional.** The two lists answer different questions. arXiv's MSC-class describes *the
document*, and the formalization is a prominent feature of it, so 68V20 earns its place. The
`classification` block in `formalization.yaml`, by the standard's own wording, "records what the
formalized result is *about* … for the mathematics rather than for the source document" — and
68V20 describes the use of a theorem prover, not any mathematics in the result or its proof.
Palomar's automated review objected to it there on exactly that ground, and was right to.
Don't reconcile the two lists by adding it back.

`11J71` / `11K06` (*distribution modulo one*) would have been defensible for the article's
equidistributed golden-angle target sequence, but are not adopted here — six codes is already
generous, the density argument is a means rather than the subject, and the formalization does not
use that sequence at all (it steers toward an enumeration of the rationals; see the note under the
figure above).

**How to fix it.** arXiv states only that *journal reference, DOI and report number* can be added
without generating a new version; MSC-class is not in that list, so changing it means either a
replacement (v2) or an email to arXiv admin. Since a stray secondary code is cosmetic, the
proportionate thing is to fold the correction into whatever v2 the paper gets anyway — unless the
Palomar submission or a journal makes accurate classification worth a version of its own.

## Palomar registry

The Lean formalization of Theorem 1 is registered in the
[Palomar registry](https://palomar-registry.org/) of Lean-verified mathematics:

> **[PALOMAR-2026-08-26-000003](https://palomar-registry.org/entry.html?id=PALOMAR-2026-08-26-000003&version=1)**,
> version 1, registered 2026-08-26.

Palomar re-checks the proof with its own [Comparator](https://github.com/leanprover/comparator)
harness at a pinned commit and publishes the exact statement, the libraries it depends on, and its
automated review. This entry registers commit `68f90ff9d90cb71af2c76eb1291a6ddf564cf4fb`, project
directory `lean`, Comparator configuration `lean/config.json`; the declaration verified is
`Palomar.main_theorem`, and the source it names is arXiv:2608.22550. The automated review — which
is part of the public record, and which no person read — reports **"No problems were identified"**.

A corrected or extended formalization goes in as a *new version of this same record*, not as a
fresh submission.

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
  - `lattice_line_covers_extended.tex`/`.pdf` — **the version on arXiv**, announced 2026-08-23 as
    [arXiv:2608.22550](https://arxiv.org/abs/2608.22550). It extends the frozen LiTH-MAT-R report
    with additional exposition, figures and remarks, at LiU's own requested condition for arXiv
    submission; no proof or numbered-statement content differs, and
    `changes-wrt-report.md` records every difference, dated. `arxiv/make-arxiv-package.sh`
    assembles the submission bundle (`.tex`, only the figures it uses, and an `anc/` directory
    carrying the Typst working draft and the full Lean formalization). HAL remains a possible
    further deposit; nothing has been submitted there.
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
