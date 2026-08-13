# Certificate of Existence — references in `lattice_line_covers_extended_refs.tex`

## Purpose

arXiv's 2026 enforcement policy imposes a one-year submission ban on authors for whom there is
"incontrovertible evidence" of unchecked large-language-model (LLM) output in a paper, and
explicitly names hallucinated or fabricated references as a trigger for that finding. This note
was written with substantial AI assistance (see the article's own Acknowledgements section), so it
is worth being able to show, plainly and checkably, that this did not happen here: every reference
the article cites is a real, locatable publication, and every substantive claim attributed to a
reference is backed by text the author (or a reviewer) can go and read for themselves.

This manuscript may also be deposited on HAL (the French national open archive). As of this
writing, HAL has no explicit, binding policy on AI/LLM-assisted content comparable to arXiv's —
only general, non-binding commentary from CCSD (HAL's operator) framing the area as still needing
new legal and ethical frameworks. The author will inquire directly with HAL before any such
deposit, applying the same disclosure standard as above regardless of the answer.

This document is that check. For each of the five `\cite{...}` references in the "Related work"
section of `lattice_line_covers_extended_refs.tex`, it records: the full bibliographic citation;
which sentence of the article the reference supports (quoted or closely paraphrased, with a line
number in the `.tex` source); and then either a verbatim quotation of the relevant passage from the
source PDF, with a precise page/section locator, or — where no PDF of the primary source could be
obtained — an explicit statement to that effect plus whatever secondary corroboration exists. A
sixth entry is included for a closely related paper (Kiselman 2011) that is not currently cited but
is discussed below.

**Update, 2026-08-13: all five citations now have a primary-source PDF available in this
repository.** `Corzatt1985` was the last holdout — an old, largely undigitized
conference-proceedings venue with no open-access copy found, until an interlibrary loan copy
arrived 2026-08-13. (Similarly, an earlier draft of this certificate had no primary source for
`Erdos1950`; a legitimate open-access copy was located shortly after that draft was written — see
entry 1 below, and `ai-workspace/lattice-line-covers/literature/REFERENCES.md` for the discovery
note.)

Every quotation below was copied from the plain-text extraction (`pdftotext -layout`) of the PDF
files actually present in `ai-workspace/lattice-line-covers/literature/`, read during the
preparation of this certificate — none were reconstructed from prior familiarity with these papers.
Each quotation was re-checked against the source text a second time before this file was finalized.

---

## 1. Erdős (1950) — `\cite{Erdos1950}`

**Citation:** P. Erdős, *On integers of the form $2^k+p$ and some related problems*, Summa
Brasiliensis Mathematicae **2** (1950), 113–123.

**Claim supported:** `lattice_line_covers_extended_refs.tex`, lines 359–362 — the article calls
covering systems of congruences a classical theory "introduced by Erdős `\cite{Erdos1950}` to show
that a positive proportion of the integers are not of the form $2^k+p$ for $p$ prime."

**Primary source: available**, found and added by Jan, 2026-08-03 (after the first draft of this
certificate, which had marked this reference unavailable) —
`ai-workspace/lattice-line-covers/literature/erdos1950_2k-plus-p.pdf`, a scanned copy from the
Rényi Institute's open Erdős archive (`https://www.renyi.hu/~p_erdos/`, paper at
`https://www.renyi.hu/~p_erdos/1950-07.pdf`), matched by exact title, journal, volume and page
range against the citation used in the article. Content and PDF metadata (an OCR scan dated
2004–2006, well before this project existed) are both consistent with a genuine period scan, not a
fabrication.

**Verified quotation** (Theorem 3, p. 113 — exactly the positive-density claim the article
attributes to this paper). Quoted as extracted by `pdftotext`, OCR artifacts and all, since that is
what is mechanically checkable against the source file; a clean reading follows in brackets:

> "THEOREM 3. There exists an arithmetic progression consisting only of . odd numbers, no term of
> which i s of the form 2 1-'+ p."
>
> [clean reading: "There exists an arithmetic progression consisting only of odd numbers, no term
> of which is of the form $2^k+p$."]

**Secondary corroboration** (kept from the first draft, now redundant with the primary-source quote
above but left in as independent confirmation): the Cremona–Koymans (2026) preprint (entry 2 below)
independently cites the same paper with identical bibliographic details (References, p. 32) and
independently characterizes the same substantive claim in its own Introduction (p. 2): "Their first
use was in 1950 to show that a positive proportion of the integers are not of the shape $2^k + p$,
see [6]."

---

## 2. Cremona & Koymans (2026) — `\cite{CremonaKoymans2026}`

**Citation:** J. E. Cremona and P. Koymans, *Lattice Coverings and Homogeneous Covering
Congruences*, arXiv:2601.03212v2 [math.NT], 14 Jan 2026.

**PDF:**
`ai-workspace/lattice-line-covers/literature/cremona-koymans_lattice-coverings-homogeneous-covering-congruences_arXiv-2601.03212.pdf`
— read in full for this certificate.

**Claim supported:** `lattice_line_covers_extended_refs.tex`, lines 363–367 — the article says this
paper studies covering $\mathbb Z^2$ by finite-index sublattices, "who give it the same
'projective/homogeneous covering congruences' framing; their refinement machinery (splitting one
lattice into several of prime-power relative index) is structurally reminiscent of the splitting
used here, one rank up."

**Verified quotations:**

- The "projective/homogeneous covering congruences" framing — Abstract, p. 1:

  > "We show how this problem may be viewed as a projective (or homogeneous) version of the
  > well-known problem of covering systems of congruences."

  restated in the Introduction, p. 1:

  > "This problem may be viewed as a projective (or homogeneous) version of the well-known problem
  > of covering Z with residue classes or "covering systems"."

- The refinement machinery ("splitting one lattice into several ... of prime-power relative
  index") — Definition 5.2 ("Definition of $p$-refinement"), Section 5, p. 17:

  > "Given a covering C, a lattice L ∈ C, and a prime p, we can form a new covering by replacing L
  > by all of its p-descendants Lj, for 1 ≤ j ≤ m, where m is either p or p + 1 depending on whether
  > or not the index of L is divisible by p. This new covering C′ = C ∪ {Lj | 1 ≤ j ≤ m} \ {L} is
  > called a p-refinement of C."

  Note for precision: a single refinement step splits a lattice into descendants of relative index
  exactly $p$ (a prime, not a prime power); iterating refinement steps (as the paper does throughout
  Section 5–7) is what produces indices that are prime powers overall. The article's phrase "several
  of prime-power relative index" is consistent with this — it describes the cumulative effect of the
  construction, not a single step — but a careful reader comparing the two should note the single
  step is per-prime, not per-prime-power.

---

## 3. Corzatt (1985) — `\cite{Corzatt1985}`

**Citation:** C. E. Corzatt, *Covering convex sets of lattice points with straight lines*, in
Proceedings of the Sundance Conference on Combinatorics and Related Topics (Sundance, Utah, 1985),
Congressus Numerantium **50**, 129–135.

**Claim supported:** the current preprint (`article/lattice_line_covers_preprint.tex`, line 688)
says "Corzatt `\cite{Corzatt1985}` **conjectured** that if a *finite, convex* set of lattice points
is covered by $n$ lines (with no constraint on where the lines may cross), the lines can always be
chosen to use at most four distinct slopes." (An earlier, now-obsolete draft,
`lattice_line_covers_extended_refs.tex`, had instead said Corzatt "showed" this — see the resolved
flag below.)

**Primary source: now available.** An interlibrary loan copy arrived 2026-08-13 (`subito e.V.`,
licensed copy supplied for Linköping University Library), local copy at
`ai-workspace/lattice-line-covers/literature/corzatt1985_congressus-numerantium-50.pdf`. Quoting
directly from p. 131 of Corzatt's own paper:

> "The following conjecture appears to be an appropriate analogue to Bang's Theorem in
> 2-dimensions. At the present time there is little indication as to how to prove the conjecture,
> but in what follows we will give evidence which supports it.
> **Conjecture:** If S is a convex set of lattice points and v(S) = n then S can [be covered using
> at most four distinct slopes]."

This is Corzatt's own explicit labeling — a conjecture, not a theorem.

**Secondary corroboration** (kept for record), from Verreault, *Plank theorems and their
applications: a survey*, arXiv:2203.05540
(`ai-workspace/lattice-line-covers/literature/plank-theorems-survey_arXiv-2203.05540.pdf`):

- Bibliographic details, References, p. 44:

  > "[39] C. E. Corzatt. Covering convex sets of lattice points with straight lines. In Proceedings
  > of the Sundance conference on combinatorics and related topics (Sundance, Utah, 1985), volume
  > 50, pages 129–135, 1985."

  This matches the citation used in the article exactly.

- Content, p. 24 (discussing "a discrete plank problem"):

  > "A long-standing and shockingly simple to state conjecture in the area, due to Corzatt [39],
  > states that if a convex set of lattice points can be covered by n lines, then these lines can be
  > taken to have at most four different slopes (see Fig. 7 for an example)."

**Flag — resolved 2026-08-13.** An earlier draft (`lattice_line_covers_extended_refs.tex`, now
obsolete) said Corzatt "showed" this result, which would have read as a proven theorem; the survey
called it a "conjecture," and the primary source now confirms the survey's reading exactly —
Corzatt's own paper explicitly labels it "Conjecture." The current preprint already uses the
correct wording ("conjectured"), so **no article change was needed**, only this certificate update.

---

## 4. Kiselman (2022) — `\cite{Kiselman2022}`

**Citation:** C. O. Kiselman, *Elements of Digital Geometry, Mathematical Morphology, and Discrete
Optimization*, World Scientific, 2022.

**Claim supported:** `lattice_line_covers_extended_refs.tex`, lines 379–384 — cited (together with
Uscka-Wehlou's dissertation) for the digital-geometry literature in which "continued-fraction and
Farey-tree techniques describe digital approximations to a line of given (rational or irrational)
slope."

**Primary source:** **not available in this repository.** This is a commercially published book
(World Scientific, 2022); per `REFERENCES.md` item 7, a copy of unclear provenance is self-hosted on
the author's page but was deliberately not downloaded, to avoid reproducing possibly-copyrighted
material without clarity on its status. No text is quoted below.

No secondary corroboration was independently sought for this specific book beyond what
`REFERENCES.md` already records; its existence and scope (a broad monograph covering digital
straightness/convexity among many other topics) is not in doubt, but its content is not verified
here.

---

## 4b. Kiselman (2011) — not currently cited in the article, but available as a verified, on-topic alternative/supplement to the 2022 book citation, per `literature/REFERENCES.md`'s own recommendation

**Citation:** C. O. Kiselman, *Characterizing digital straightness and digital convexity by means of
difference operators*, Mathematika **57** (2011), 355–380.

**PDF:** `ai-workspace/lattice-line-covers/literature/kiselman2011_digital_straightness.pdf` — read
in full for this certificate.

**Why included here:** `REFERENCES.md` item 2 recommends swapping the article's `Kiselman2022`
citation for this 2011 paper (or citing both), on the grounds that it is "a much more precise
citation for 'Kiselman' than the general book," being specifically about digital straightness. This
entry is prepared so it is ready to use if that swap is made; **no swap has been made in the article
itself**, and that decision is left to the author.

**Verified quotations**, directly on point for the article's claim that Kiselman-literature
"continued-fraction ... techniques describe digital approximations to a line of given ... slope":

- Introduction, p. 356 (§1):

  > "There is also a relation between continued fractions and the digitizations of a straight line
  > in the plane."

- Introduction, p. 357 (§1), introducing the specific classical result underlying this connection:

  > "The relation between digital straight lines and continued fractions is given by a theorem of
  > Felix Klein (1895)."

  (The paper goes on, same page, to state Klein's theorem precisely: the vertices of the convex
  hull of lattice points above/below the line $y=\alpha x$ are given by the even-/odd-indexed
  convergents of the continued fraction of $\alpha$ — the same Klein's-theorem connection also
  appears, cited to the same source, in the Uscka-Wehlou dissertation quoted in entry 5 below.)

---

## 5. Uscka-Wehlou (2009) — `\cite{UsckaWehlou2009}`

**Citation:** H. Uscka-Wehlou, *Digital Lines, Sturmian Words, and Continued Fractions*, Ph.D.
thesis (kappa/summary), Uppsala Dissertations in Mathematics 65, Uppsala University, 2009.

**PDF:** `ai-workspace/lattice-line-covers/literature/uscka-wehlou2009_dissertation.pdf` — read in
full for this certificate. (Note: this PDF file is at absolute PDF-page 14 for the passage quoted
below, one page later than the dissertation's own printed page number "13", because of unnumbered
front matter — title page, dedication, list of papers, etc. — preceding the numbered body of the
kappa.)

**Claim supported:** `lattice_line_covers_extended_refs.tex`, lines 382–384 — "for the
continued-fraction approach specifically, Uscka-Wehlou's dissertation `\cite{UsckaWehlou2009}`,
written under Kiselman's supervision at Uppsala University."

**Verified quotations:**

- The continued-fraction/digital-line connection itself — §1.1.1, printed p. 13:

  > "In our work we use CFs to describe digital straight lines in the plane (see Section 1.2)."

  (immediately preceded, same page, by a statement of Klein's 1895 theorem connecting continued-
  fraction convergents to convex hulls of lattice points under/over a line — the same result quoted
  from Kiselman (2011) in entry 4b above.)

- Confirmation that the work was done under Kiselman's supervision — Acknowledgments (§4), printed
  p. 50:

  > "I would like to express my deepest gratitude towards my main advisor, Professor Christer
  > Kiselman, for generously sharing his knowledge, wisdom, and time with me and other members of
  > our research group..."

  (The same section, p. 50, notes Kiselman's official retirement partway through and Maciej Klimek
  taking over as supervisor of record — a minor nuance the article's blanket "written under
  Kiselman's supervision" glosses over but does not misstate in substance.)

---

## Summary

| # | Reference | Cited in article? | Primary PDF available? | Quote verified? |
|---|---|---|---|---|
| 1 | Erdős (1950) | yes | yes (found 2026-08-03) | yes — verbatim Theorem 3, p. 113 |
| 2 | Cremona & Koymans (2026) | yes | yes | yes — two verbatim quotes, pp. 1 and 17 |
| 3 | Corzatt (1985) | yes | yes (arrived 2026-08-13) | yes — verbatim "Conjecture:" statement, p. 131 |
| 4 | Kiselman (2022) | yes | no | no — no quote, no secondary corroboration sought |
| 4b | Kiselman (2011) | not currently (candidate swap) | yes | yes — two verbatim quotes, pp. 356–357 |
| 5 | Uscka-Wehlou (2009) | yes | yes | yes — two verbatim quotes, pp. 13 and 50 |
