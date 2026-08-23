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

## 2026-08-23 — submitted to arXiv

Jan submitted `article/lattice_line_covers_extended.tex` to arXiv (submission
`arXiv:submit/7983754`; public arXiv id pending the next announcement). Not a content change —
noted here as a milestone, since everything above this point in the log describes how the
submitted version diverges from the frozen LiTH-MAT-R report. See the repository README's own
[arXiv preprint](README.md#arxiv-preprint) section for the full submission metadata.

## 2026-08-21

### Order-type clarifications: why the recursion is ω, and what that costs

Prompted by Jan's question of whether the construction hides an `ω²` (metasteps) rather than being
a single `ω`-sequence, and by his Gröbner-basis instinct that "lexicographically least" invites the
`lex` vs `deglex` order-type distinction (Robbiano's classification: term orders on `ℕⁿ` have order
types exactly `ω¹,…,ωⁿ`). **No mathematical content changed** — all three additions make explicit
what the proof already did implicitly.

**Coverage restated as `⋂ₖ Rₖ = ∅`** (proof of Theorem 7). Since the stage-`k` claims are exactly
`R_{k−1} ∖ R_k` and `R₀ = ℤ²`, coverage *is* the emptiness of the intersection: every point leaves
the chain at a finite stage, which is what makes the recursion self-contained at order type `ω`
with no step past `k ∈ ℕ`. Added with a non-example showing this is not automatic — "always reserve
the sub-coset containing the origin" gives a strictly decreasing chain with the same densities
`1/(n₁n₂) → 0` that nevertheless keeps `(0,0)` in every `Rₖ`. So it is the reservation rule's
dependence on the enumeration that forces the intersection empty, and only because every point of
`ℤ²` carries a finite index.

**Remark 16 extended** with the order-type reason why exactly one of the two selection rules is
computable. The reservation minimises over the *finite* box `[0,|s|) × [0,|t|)`, so "lexicographically
least" commits to nothing — every total order on a finite set has finite order type, and a graded
order would reserve a different sub-coset with no effect on the proof. The steering pair is drawn
from an *infinite* subset of `ℤ²`, and there the order matters: lex on `ℤ²` has order type `ω²`, so a
least element exists (the selection is well defined) but finding it can require deciding whether an
entire infinite column meets the set — not a terminating search. A **graded** order (`|s|+|t|`, lex
tie-break) has order type `ω`, every pair has finitely many predecessors, and the least admissible
pair is the first candidate passing the coprimality tests and Lemma 15's strict inequality.

The consequence is worth having on record: **classical choice in the steering rule is a convenience,
not a necessity.** Taking the graded-least admissible pair makes it computable, and the whole
recursion with it — which is a concrete route to removing `Classical.choose` from `sOf`/`tOf` in the
Lean formalization, should that ever be wanted. New bibliography entry `Robbiano1985`.

**New Remark 17 (Sequence order against angular order)**, after Figure 7. The dots there are indexed
by the stage that produced them, not by position on `ℝP¹`, and the two orders are *necessarily*
different: an enumeration of a dense subset of `[0,π)` cannot be monotone, since if
`θ₁ < θ₂ < ⋯` then no term lies in `(θ₁, θ₂)` and the term set misses an open set. Density forces the
enumeration to jump; the equidistributed target makes it jump evenly. The scatter in the figure is
order type `ω` lying transverse to the geometry of `ℝP¹`, not an artifact of the run.

### Two errors found while checking Figure 7 against its generator

Both in the paragraph introducing Figure 7; neither affects any statement or proof.

- **The target sequence was stated wrong.** Text had `θₖ = kπ(√5−1) mod π`; `verification-code/density_sequence.py`
  computes `θₖ = kπ(√5−1)/2 mod π` (`phi = (sqrt(5)-1)/2`). A factor of two — both are irrational
  rotations and hence equidistributed, so the figure is unaffected, but a reader recomputing it would
  have got a different sequence. The script's **own docstring carried the same error** and was the
  source of it; fixed in both.
- **Wrong directory.** "code in `code/`" — the directory is `verification-code/`. There is no `code/`.

### New Figure 6: the nested chain, and a Remark on the two selection rules

**No mathematical content changed**; the proof's argument is untouched. Three related edits:

**Section renamed** "A picture of the construction" → **"Pictures of the construction"**, since it
now has company.

**Figure 6** draws `ℤ² = R₀ ⊃ R₁ ⊃ R₂` from the proof of Theorem 7 — three nesting levels in the
house style, with the enumeration point `z₁ = (0,0)` crossed to show *why* stage 1 reserves the
residue pair `(0,1)` and not `(0,0)`. Verified that `R₂ ⊆ R₁` and that `z₁ ∉ R₁`.

**The reservation rule drawn is exactly the one the Lean formalization computes** (`resIdx =
lexLeast resCandidates` in `MainRecursion.lean`). The pairs `(s,t) = (2,3)` are illustrative only,
and the caption says so — because the formalization does **not** fix them: `sOf`/`tOf` are
`Classical.choose` applied to the steering existence statement.

**Remark 16 (The two selection rules)** replaces three sentences of methodological aside that sat
mid-proof:

> *"A concrete rule is needed for the recursion to be a well-defined function, as is a concrete
> choice among the (s,t) that Lemma 14 only asserts to exist. Both are choice functions to be
> supplied explicitly in a Lean formalization, not just existence claims."*

The proof now states its rule and moves on, pointing forward. The Remark makes the point properly:
that a recursion is a function only once both choices are fixed, that neither affects the
conclusion, and — the part the original did not say — that **the two are settled in genuinely
different ways**. The reservation is computable (lexicographically least eligible pair, from a set
that is nonempty because `|s||t| ≥ 4` and Lemma 13 puts `z_k` in exactly one class); the steering
pair is classical choice, since Lemma 14 singles out no canonical `(s,t)`. That asymmetry is
visible in the Lean and was worth stating.


### Symbolic tags on the three most-cited equations

Ranked by how often each numbered equation is actually cited, three stood out and now carry
mnemonic tags instead of numbers:

| was | now | label | cited | content |
|---|---|---|---|---|
| (7)  | **(R)** | `eq:rigidity-conclusion`        | 4x | the rigidity divisibility criterion |
| (17) | **(H)** | `eq:splitting-hyps`            | 4x | `gcd(s,n₂)=gcd(t,n₁)=gcd(s,t)=1` |
| (20) | **(S)** | `eq:splitting-coset-conclusion`| 5x | the splitting identity |

`\eqref` prints the tag automatically, so no call site changed. "One checks directly that (H)
holds" reads as mathematics; "that (17) holds" reads as bookkeeping.

**`eq:steering-t0` was deliberately left numbered** despite also being cited 4x: all four citations
sit within 20 lines of it, inside one proof, so the reader can see it on the same page. Tags earn
their keep when a reference arrives far from its definition, and a fourth tag would dilute the
other three.

**Renumbering, and it affects comparison with the report.** A tagged equation leaves the automatic
sequence, so everything after it shifts down by three. Notably the steering window origin `t₀` is
**(33) here, (36) in the report**. All internal cross-references are symbolic and therefore
unaffected, but anyone reading the two documents side by side will see different equation numbers
from (7) onward.

### Change of voice: removed references to drafts the reader cannot see

The manuscript now addresses a general reader rather than the author, so passages referring to
"an earlier version" of itself have gone. These were vestiges of its working history.

| where | was | now |
|---|---|---|
| proof of Lemma 14 | "The +2 shift in (33), *absent from an earlier version of this proof*, is what makes…" | clause deleted — the parenthetical that follows already gives the counterfactual, so nothing is lost |
| Remark on verification | "*an earlier version of* the splitting step, without the primitivity safeguard…, was found this way to be flawed" | "a splitting step without the primitivity safeguard … was found this way to be flawed" — now a claim about the mathematics rather than about a draft |
| Remark on verification | "found a real gap in *an earlier version of the density argument* (restricting …)" | "found a real gap: restricting `s,t` to be positive only reaches half of `ℝP¹` …" |
| methodology section | "the additional references collected in the *extended-references version of this note*" | "collected in the repository's extended-reference list [gitrepo]" — the old wording cited a document the reader has no way to obtain |

Also **"this note" → "this manuscript"** in the two places the document refers to itself. "Note"
read modestly for a 15-page paper with a formalization attached. Ordinary uses of the word ("note
that…") are untouched, as is the *Note.* heading of the version notice, which points at a published
document the reader *can* fetch.


### New Figures 4 and 5, for Example 12 and Lemma 13

**No mathematical content changed** — statements, proofs and numbering are untouched; both figures
are exposition, in the style of Figure 3.

**Figure 4 (Example 12)** draws the worked splitting: the coarse coset `R = R(2,3,1,1) = {x odd,
y ≡ 1 mod 3}` as medium dots, the fine sub-coset `R_{1,2} = {x ≡ 3 mod 4, y ≡ 7 mod 9}` as large
dots, and the lines `ℓ_{(4,9),r_k}`, `r_k = −1 + 36k`, through them. The arrow marks
`(3,7) ↦ (7,16)`, two of the three points the example computes. The caption emphasises the point
the algebra states but does not show: the lines meet **no** point of `R` outside `R_{1,2}` — that
confinement is what makes the recursion safe.

**Figure 5 (Lemma 13)** draws the partition itself: every point of `R` carries exactly one of the
`|s||t| = 6` residue pairs, with **shape encoding `u₀`** and **colour encoding `w₀`**, so the
product structure of the splitting is visible rather than merely asserted. The class `R_{1,2}` of
Figure 4 is ringed, showing it as one of six — one handed to a new direction, five left for later
steps.

Both verified programmatically before drawing: that the six classes partition `R` exactly, that
class `(1,2)` really is `R_{1,2}`, and that the four drawn levels are exactly those meeting the
window.

*Figure numbering note:* what were Figures 4 and 5 (after Figure 3 was added) are now Figures 6
and 7. Theorem, lemma, definition and example numbers are unchanged.


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
