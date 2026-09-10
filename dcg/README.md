# `dcg/` — submission copy for *Discrete and Computational Geometry*

Created 2026-09-09. A **flat** folder, deliberately: `lattice_line_covers_dcg.tex`, its compiled
`lattice_line_covers_dcg.pdf`, and the five figures the `.tex` includes, all at this level with no
`figures/` subdirectory. Journal upload forms are happier with a flat set of files, and the `.tex`
has been changed to match — every `\includegraphics` argument is a bare filename.

## How it differs from `article/lattice_line_covers_extended.tex`

It was copied from that file and then changed in eight ways, all at Jan's request:

1. **Flat figure paths** — `{figures/foo.png}` became `{foo.png}`.
2. **The page-1 note is gone.** The small centred *Note.* under the abstract, which said the work
   had appeared earlier as the technical report and pointed at `changes-wrt-report.md`, is removed.
3. **No self-versions in the bibliography.** The `\bibitem`s `gitrepo`, `report2026` and `zenodo`
   are deleted, so the reference list now contains only genuine external references.
4. **A new starred section, "Other versions of this work"**, placed after *Description of the work
   process*, listing all five in prose instead: the arXiv preprint, the LiTH-MAT-R report, the
   Zenodo deposit, the GitLab source repository, and the Palomar Registry entry. The three
   `\cite{}`s to the removed entries, all in what is now the *Methods* section, were reworded to
   point at that section.

Then three cheap conformances to DCG's submission guidelines. The manuscript is **not** otherwise
made to comply — it is still `amsart`, where the journal wants Springer's `svjour3` — because the
decision was to convert only if the paper is accepted.

5. **`\subjclass[2020]`**, which no version of this manuscript has ever carried. The codes are the
   corrected list agreed 2026-08-26, `Primary 05B40; Secondary 11H31, 52C15, 11B25, 11B57, 68V20`,
   justified per code in the "Classification" table of the repository README — **not** the
   `05B45 (Primary) 11431 (Secondary)` still live on arXiv, where `11431` is not a valid MSC code.
6. **`\keywords`**, six of them, DCG asking for 4–6.
7. **A "Data availability" section**, which DCG requires of all original research. It points at the
   repository and the Zenodo DOI already listed in change 4.
8. **"Description of the work process" is now headed "Methods"** — Jan's idea. Springer's policy
   says LLM use "should be properly documented in the Methods section", and a mathematics paper
   has no Methods section to put it in. That section already described exactly the verification
   methods used (brute-force simulation, adversarial re-reading, machine-checked formalization),
   so the rename makes the manuscript literally satisfy the policy without altering a word of its
   content.

The mathematics is untouched.

## Which file to edit

`article/lattice_line_covers_extended.tex` stays the working manuscript. **Do not hand-edit both.**
Make any mathematical change there and re-derive this copy; the four changes above are mechanical
enough to redo, and the `.tex`'s own changelog header records exactly what they are.

## Build

```
pdflatex lattice_line_covers_dcg.tex   # three passes
```

Verified 2026-09-09 on both `pdflatex` and `xelatex`: 21 pages, zero errors, zero unresolved
cross-references, zero overfull boxes. The warnings that remain — `amsart` noting the abstract
follows `\maketitle`, one `h` float specifier changed to `ht`, and under `pdflatex` three pdfTeX
duplicate-destination warnings for `equation.{7,16,18}` — were checked against a scratch build of
`article/lattice_line_covers_extended.tex` and are character-for-character the same set. Nothing
here introduced one.

## Known gaps against the DCG guidelines

- **The abstract is 128 words; DCG asks for 150–250.** Left as it stands rather than rewritten,
  since that is an authorial decision.
- **`amsart`, not `svjour3`.** Deliberate; convert on acceptance.
- **No DOIs on the eight remaining bibliography entries.** DCG wants DOIs given as full links.
(Springer's "document LLM use in the Methods section" was a gap here until change 8 closed it.)

## One correction to note

The DOI Jan gave for the report was `10.3384/LiTH-MAT-R-2026-0`; the full one, as carried by the
former `report2026` bibitem and by DiVA, is **`10.3384/LiTH-MAT-R-2026-02`**, and that is what the
list uses.
