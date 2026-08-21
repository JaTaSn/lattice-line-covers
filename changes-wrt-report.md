# Changes with respect to LiTH-MAT-R 2026:02

A running record of how `article/lattice_line_covers_extended.tex` has diverged from the published
technical report:

> J. Snellman, *On the directions occurring in lattice-line coverings of the integer plane*,
> LiTH-MAT-R, ISSN 0348-2960, No. 2026:02, Linköping University Electronic Press, 2026.
> [doi:10.3384/LiTH-MAT-R-2026-02](https://doi.org/10.3384/LiTH-MAT-R-2026-02) · open access via
> DiVA `urn:nbn:se:liu:diva-226766`.

**The report is frozen and citable; this manuscript is not.** The published version is what anyone
citing "the paper" is citing. Once the two differ by more than presentation, that difference has to
be visible, or a reader who has one will silently assume things about the other.

**Add an entry here whenever the manuscript changes.** Newest first, dated. If a change alters a
numbered statement or its meaning — as opposed to adding exposition around it — say so explicitly,
because that is what breaks cross-references from other work.

---

## 2026-08-21

### Renamed the manuscript

`lattice_line_covers_preprint.tex` → **`lattice_line_covers_extended.tex`** (and likewise the PDF).
The old name suggested it *was* the report; it no longer is. Renamed via `git mv`, so history
follows the file.

### Added a version note

A short note after the abstract stating that an earlier version appeared as the technical report,
citing it, and pointing here. So a reader who reaches only the PDF — from arXiv, say — learns that
a frozen published version exists and that this one has moved on.

### Added references to the report, the repository and the Zenodo deposit

New bibliography entries `report2026` and `zenodo`, alongside the existing `gitrepo`. The Zenodo
entry gives **both** DOIs and says which is which: the concept DOI
[10.5281/zenodo.21916621](https://doi.org/10.5281/zenodo.21916621) for the evolving project, and
[10.5281/zenodo.21916622](https://doi.org/10.5281/zenodo.21916622) for this snapshot. Citing the
snapshot when you meant the project is the usual mistake, so the distinction is stated rather than
left implicit.

Also added a small `\doi{}` macro — the preamble had none, and bare DOI strings are not clickable.

### New Figure 3, illustrating Lemma 9 (Coset)

**No mathematical content changed.** The lemma, its proof and its numbering are untouched; the
figure is exposition only.

It draws the lemma for the concrete case `d = (p,q) = (3,2)`, `(x₀,y₀) = (1,1)`, so `c₀ = qx₀ − py₀
= −1` and `r_k = −1 + 6k`. Small grey dots are `ℤ²`; large dots are the coset

    C = {(x,y) : x ≡ 1 (mod 3), y ≡ 1 (mod 2)},

a translate of the sublattice `3ℤ × 2ℤ`. Seven lines `ℓ_{(3,2),r_k}` are drawn, and every coset
point in the visible window lies on one of them — checked programmatically, not by eye, since a
coset point without a line would visually contradict the lemma it is illustrating.

The caption makes two points the algebra states but does not show: that each line meets `ℤ²` *only*
inside `C` (so the lines never stray onto the rest of the lattice), and that the level gap is
exactly `pq = 6` — smaller would give lines missing `ℤ²` altogether, larger would leave points of
`C` uncovered.

Drawn inline with TikZ, which the preamble already loads, so it needs no external figure file and
travels with the `.tex` to arXiv.

*Figure numbering note:* the new figure is **Figure 3**; what were Figures 3 and 4 in the report
are now Figures 4 and 5. Theorem, lemma and definition numbers are unchanged.

---

## Infrastructure, not manuscript content

Recorded here because it affects how the manuscript is built and checked, though it changes no text:

- **`arxiv/make-arxiv-package.sh`** assembles the arXiv submission: the `.tex`, only the figures it
  actually includes, and an `anc/` directory holding the Typst working draft and the full Lean
  formalization. It test-compiles (three passes) and refuses to package a PDF with unresolved
  cross-references.
- **`.gitlab-ci.yml`** fails the pipeline if any committed PDF contains `??`. The report's own PDF
  sat in this repository for eleven days with 76 of them, from a single-pass compile.
