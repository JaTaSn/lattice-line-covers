# Ancillary files

Supplementary material for *On the directions occurring in lattice-line coverings of the integer
plane* (Jan Snellman). These files are not part of the compiled paper; arXiv offers them for
download alongside it.

## `lean/` — the formalization

A complete Lean 4 / Mathlib formalization of the paper's main theorem: **zero `sorry`, zero custom
axioms**, resting only on Lean's three standard foundational axioms.

- `PROOF.md` — the theorem statement in plain language, and step-by-step instructions to verify the
  proof yourself.
- `STRATEGY.md` — how the formalization was approached: the order lemmas were tackled in, and the
  methodology used.
- `LatticeLineCoversLean/` — the proof proper: `Basic`, `Direction`, `Family`, `Sieve`,
  `Steering`, `Density`, `MainRecursion`.
- `lakefile.toml`, `lake-manifest.json`, `lean-toolchain` — pinned build configuration. Run
  `lake exe cache get` then `lake build` to check it; Mathlib is fetched, not vendored, so the
  first build downloads several GB.

## `lattice_line_covers_pedantic.typ` — the working draft

A Typst document, and **the source of truth against which the Lean proof was actually written** —
not the published article. It is deliberately more pedantic than the paper: every step spelled out
at the level of detail formalization demands, with annotations and a changelog left in place.

Included because the correspondence between formal proof and prose is easier to follow here than
against the article, whose exposition is compressed for publication. If you are reading the Lean
and wondering *why* a lemma is stated the way it is, this is where to look. See `lean/STRATEGY.md`
for how the two were kept in step.

## Canonical, citable homes

These copies are a convenience snapshot. The versioned originals:

- **Repository** — `https://gitlab.liu.se/jansn19/lattice-line-covers`
- **Software deposit (Zenodo, Linköping University community)**
  - this snapshot: [10.5281/zenodo.21916622](https://doi.org/10.5281/zenodo.21916622)
  - all versions (cite this one for the evolving project):
    [10.5281/zenodo.21916621](https://doi.org/10.5281/zenodo.21916621)
- **The paper as a technical report** — LiTH-MAT-R, ISSN 0348-2960, No. 2026:02, Linköping
  University Electronic Press, [10.3384/LiTH-MAT-R-2026-02](https://doi.org/10.3384/LiTH-MAT-R-2026-02),
  open access via DiVA `urn:nbn:se:liu:diva-226766`.

The repository also holds numerical verification scripts and a reference-certificate document, both
omitted here to keep the ancillary bundle small.

## Licence

Code and documentation: MIT, as in the repository's `LICENSE`.
