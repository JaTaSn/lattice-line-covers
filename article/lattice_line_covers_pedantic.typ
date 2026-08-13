// Changelog (reverse chronological):
// 2026-08-03 21:41 - Claude: `lattice_line_covers_arxiv.typ` created alongside
//   this file -- a clean arXiv-submission candidate, derived from this working
//   draft by stripping every `leanstatus`/`pedanticexample` block and the
//   "Formalization status" section. This file remains the actively maintained
//   working draft (Lean-guiding annotations included); re-derive the arXiv
//   file from this one after any further mathematical change, rather than
//   editing both by hand.
// 2026-08-02 22:24 - Claude: fixed a fragile "the guard at line 244" reference
//   (meaningless outside the specific .tex line numbering it was written
//   against) to a self-contained description, matching the same fix applied to
//   lattice_line_covers_pedantic.tex.
// 2026-08-02 22:08 - Claude: created. Faithful Typst port of
//   lattice_line_covers_pedantic.tex (amsart, a4paper/11pt) -- now the actively
//   maintained working draft, see that file's own `\thanks` for the
//   obsolescence note. Same content, same order, same shared theorem counter;
//   A4 with 1.7cm margins at 10pt, and the LaTeX version's diagonal DRAFT
//   watermark deliberately NOT reproduced. Hand-rolled theorem environments (no
//   @preview packages, so it compiles with no network access).
//   NOTE: Typst refuses to read files above the project root (= this file's
//   directory), so the figure is reached through the symlink `artefacts` ->
//   `../artefacts` in this directory. Without it, compile with
//   `typst compile --root .. lattice_line_covers_pedantic.typ` instead.
//   Compiled output committed as `lattice_line_covers_pedantic_typst.pdf`
//   (distinct name from `lattice_line_covers_pedantic.pdf`, the LaTeX build of
//   the now-obsolete sibling, to avoid collision): `/home/jan/.cargo/bin/typst
//   compile lattice_line_covers_pedantic.typ lattice_line_covers_pedantic_typst.pdf`
//   (`typst` is not on the default PATH in this environment).

#set page(paper: "a4", margin: 1.7cm, numbering: "1")
#set text(size: 10pt, lang: "en")
#set par(justify: true, leading: 0.58em, spacing: 0.72em, first-line-indent: 1.2em)
#set heading(numbering: "1.")
#show heading: set block(above: 1.4em, below: 0.75em)
#show heading: set text(size: 11pt)
#set math.equation(numbering: "(1)", supplement: none)
#set figure(numbering: "1")

// --- Shorthands for the source's \Z, \R, \RP macros -------------------------
// ZZ and RR are Typst built-ins rendering as blackboard-bold Z and R, so only
// \RP needs a definition of its own.
#let RP = $bb(R)bb(P)^1$

// --- Hand-rolled theorem environments --------------------------------------
// One shared counter across Definition/Example/Remark/Open problem/Theorem/
// Lemma/Proposition/Corollary, exactly as \newtheorem{...}[definition]{...}
// does in the LaTeX source.
#let thmcounter = counter("shared-theorem")

#let thmblock(kind, style, name, lbl, body) = {
  thmcounter.step()
  block(width: 100%, above: 1.0em, below: 1.0em, context {
    let n = thmcounter.get().first()
    let title = kind + " " + str(n) + (if name == none { "" } else { " (" + name + ")" }) + "."
    let head = if style == "remark" { emph(title) } else { strong(title) }
    let shown = if style == "plain" { emph(body) } else { body }
    if lbl != none { [#metadata(n)#lbl] }
    head
    h(0.45em)
    shown
  })
}

#let thmref(lbl) = context {
  let ms = query(lbl)
  if ms.len() == 0 { text(red)[??] } else { link(lbl, str(ms.first().value)) }
}

#let eqref(lbl) = [(#ref(lbl))]

#let definition(name: none, lbl: none, body) = thmblock("Definition", "definition", name, lbl, body)
#let example(name: none, lbl: none, body) = thmblock("Example", "definition", name, lbl, body)
#let remark(name: none, lbl: none, body) = thmblock("Remark", "remark", name, lbl, body)
#let openproblem(name: none, lbl: none, body) = thmblock("Open problem", "remark", name, lbl, body)
#let theorem(name: none, lbl: none, body) = thmblock("Theorem", "plain", name, lbl, body)
#let lemma(name: none, lbl: none, body) = thmblock("Lemma", "plain", name, lbl, body)
#let proposition(name: none, lbl: none, body) = thmblock("Proposition", "plain", name, lbl, body)
#let corollary(name: none, lbl: none, body) = thmblock("Corollary", "plain", name, lbl, body)

#let proof(name: [Proof], body) = block(width: 100%, above: 1.0em, below: 1.0em)[
  #emph(name + [.])#h(0.45em)#body#h(1fr)#sym.square.stroked
]

// A short, visually distinct paragraph recording formalization status, placed immediately
// after the lemma/theorem/proof it describes.
#let leanstatus(body) = block(width: 100%, above: 0.85em, below: 0.85em)[
  #text(size: 0.92em, style: "italic")[Lean formalization status: #body]
]

// Working-notes-only environment: a fully numeric instantiation placed right after a lemma's
// statement, showing (a) concrete input values for which the conclusion holds, and (b) concrete
// input values violating one of the hypotheses, showing concretely why that hypothesis is needed.
// Set in red and clearly labeled so it cannot be mistaken for article prose --- this environment,
// and every instance of it, is deliberately NOT meant to survive into the final article.
#let pedanticexample(body) = block(width: 100%, above: 0.9em, below: 0.9em)[
  #text(fill: red)[*Pedantic example (working notes only --- not for the final article).*#h(0.6em)#body]
]

// --- Manual bibliography helpers -------------------------------------------
#let bibnum = (
  CremonaKoymans2026: 1,
  Corzatt1985: 2,
  Erdos1950: 3,
  HardyWright2008: 4,
  Kiselman2022: 5,
  UsckaWehlou2009: 6,
)
#let bcite(key, detail: none) = {
  let n = bibnum.at(key)
  let l = label("bib-" + key)
  if detail == none { link(l)[[#n]] } else { link(l)[[#n, #detail]] }
}
#let bibentry(key, body) = block(width: 100%, above: 0.55em, below: 0.55em)[
  #grid(columns: (1.5em, 1fr), gutter: 0.3em, [#text(size: 0.95em)[[#bibnum.at(key)]]], body)
  #metadata(bibnum.at(key))#label("bib-" + key)
]

// ===========================================================================

#align(center)[
  #block(width: 88%)[
    #text(size: 15pt, weight: "bold")[
      On the directions occurring in lattice-line coverings of the integer plane
      #footnote[This is a working-notes variant of the formal draft `lattice_line_covers_formal.tex`
      (itself a more formal, more detailed sibling of the canonical short draft
      `lattice_line_covers.tex`; both are unchanged by this version). The only content added here
      is a red _Pedantic example_ environment immediately after each lemma's statement, giving fully
      numeric input values for which the conclusion holds, and fully numeric input values violating
      one of the lemma's hypotheses, to make concrete why that hypothesis cannot be dropped. These
      examples are for Jan Snellman's own benefit while reading the proofs and are deliberately
      _not_ intended to appear in any final version of this article. Separately, the statement,
      proof, and Lean-status note of the Rigidity lemma (Lemma #thmref(<lem-rigidity>)) have been
      reworded to index the two directions by $1,2$ rather than $i,j$: the original $i,j$ notation
      suggested, misleadingly, that the two directions range over some indexed family, when the
      lemma is really about an arbitrary fixed _pair_ of directions.]
    ]
  ]
  #v(0.8em)
  #text(size: 11pt)[Jan Snellman
    #h(0.25em)#link("https://orcid.org/0009-0002-6676-5068")[#text(size: 8pt, fill: rgb("#a6ce39"))[iD]
    #text(size: 8pt)[0009-0002-6676-5068]]]
  #v(0.35em)
  #text(size: 9pt)[Matematiska Institutionen, Linköpings Universitet, 581 83 Linköping, Sweden]
  #v(0.15em)
  #text(size: 9pt)[#link("mailto:jan.snellman@liu.se")[jan.snellman\@liu.se]]
]

#v(1.0em)

#pad(x: 1.6cm)[
  #text(size: 9.2pt)[
    #align(center)[*Abstract*]
    #v(0.25em)
    We consider families of lines that cover every point of the integer lattice $ZZ^2$, subject to
    the constraint that no two lines of different direction in the family meet at a lattice point.
    Restricting to _lattice lines_ (lines containing at least two, hence infinitely many,
    lattice points --- equivalently, of rational direction), we show that the set of directions
    occurring in such a covering can be made dense in the space of line directions. The construction
    is a recursive splitting of $ZZ^2$ into nested rank-2 sublattice cosets, each handed off to a
    freshly chosen direction; the key technical point is a steering lemma showing that at every
    stage of the recursion a new direction arbitrarily close to any prescribed target can still be
    realized, via an elementary sieve bound.
  ]
]

#v(0.8em)

= Introduction

Consider the integer lattice $ZZ^2 subset RR^2$. We wish to cover every point of $ZZ^2$ by a family
$cal(F)$ of lines, subject to: any two lines of $cal(F)$ may cross, but never at a point of
$ZZ^2$. Which sets of line-directions can occur across such a family?

#remark(name: "The lattice-line hypothesis", lbl: <rem-hypothesis>)[
  As posed, with no further restriction on the lines allowed, the question is trivial: for each
  $z in ZZ^2$ take the line $L_z$ through $z$ of irrational slope $alpha_z$. Then
  $ L_z inter ZZ^2 = {z} $ <eq-irrational-line>
  (a second lattice point on $L_z$ would force $alpha_z in QQ$), so distinct such lines never
  share a lattice point, and choosing the $alpha_z$ to range over a dense (indeed, all) set of
  irrational directions already realizes an uncountable dense set of directions. Everything of
  interest in this note therefore concerns the restriction to _lattice lines_: lines
  containing at least two (hence, by the same argument, infinitely many) points of $ZZ^2$,
  equivalently lines of rational direction. This restriction is in force throughout.
]

We now formalize the objects of study as explicit definitions, rather than leaving them as prose,
so that every later lemma statement can refer back to them unambiguously.

#definition(name: "Primitive direction", lbl: <def-direction>)[
  A _primitive direction_ is a pair $d = (p,q) in ZZ^2$ with $gcd(p,q) = 1$. Two primitive
  directions $d, d'$ are _equal as directions_ if $d' = plus.minus d$. Write
  $ phi_d (x,y) = q x - p y, $ <eq-phi-def>
  a surjective homomorphism $ZZ^2 -> ZZ$ depending only on $d$ up to sign of the whole map (in
  particular $ker phi_d = ker phi_(-d)$). The space of directions is $#RP = S^1 slash {plus.minus 1}$,
  parametrized by $theta in [0,pi)$; we metrize it by
  $ d(theta,theta') = min(abs(theta - theta'), pi - abs(theta - theta')), $ <eq-RP-metric>
  so "within $epsilon$ of $theta$" always means within $epsilon$ in this metric. Since
  $[0,pi) -> #RP$ is a continuous surjection, a set dense in $[0,pi)$ is automatically dense in
  $#RP$.
]

#definition(name: "Lattice lines", lbl: <def-lline>)[
  For a primitive direction $d = (p,q)$ and $c in ZZ$, the _lattice line_ $ell_(d,c)$ is the
  level set
  $ ell_(d,c) = phi_d^(-1)(c) = {(x,y) in ZZ^2 : q x - p y = c}. $ <eq-lline-def>
  Every line in $RR^2$ containing at least two points of $ZZ^2$ equals $ell_(d,c)$ for a unique
  primitive direction $d$ (up to sign) and a unique $c in ZZ$; we call such a line a lattice line of
  direction $d$.
]

#definition(name: "Covering family, valid family", lbl: <def-family>)[
  A _covering family_ is a set $cal(F)$ of lattice lines with $union.big cal(F) supset.eq ZZ^2$. A
  covering family $cal(F)$ is _valid_ if no two lines of $cal(F)$ of different
  direction share a point of $ZZ^2$; equivalently, for every pair of distinct primitive directions
  $d, d'$ occurring in $cal(F)$, and every $ell_(d,c), ell_(d',c') in cal(F)$, we have
  $ell_(d,c) inter ell_(d',c') inter ZZ^2 = nothing$.
]

One easily disposes of the variant where lines are required to be pairwise disjoint everywhere
(not merely off the lattice): two distinct lines in $RR^2$ are either parallel or meet at exactly
one point, so pairwise disjointness forces every line in the family to share a single direction,
and any one direction already suffices (Example #thmref(<ex-single-direction>) below). All the content
is in the "crossings allowed off the lattice" variant of Definition #thmref(<def-family>), which is
our subject here.

#example(lbl: <ex-single-direction>)[
  For a primitive direction $d = (p,q)$, the lines $ell_(d,c)$, $c in ZZ$, partition $ZZ^2$ (they are
  the fibers of the surjective homomorphism $phi_d$):
  $ ZZ^2 = union.sq.big_(c in ZZ) ell_(d,c). $ <eq-single-direction-partition>
  So a single direction always suffices to cover $ZZ^2$ by pairwise-disjoint (in particular
  lattice-point-disjoint) lattice lines.
]

Our main result:

#theorem(lbl: <thm-main>)[
  There is a valid covering family $cal(F)$ (Definition #thmref(<def-family>)) whose set of realized
  directions is dense in $#RP$.
]

#leanstatus[
  not yet formalized. This theorem is the final assembly of Lemmas #thmref(<lem-splitting-coset>),
  #thmref(<lem-splitting-partition>), and #thmref(<lem-steering>), via an infinite recursive/diagonal
  construction requiring well-founded recursion with an existential (choice-dependent) witness at
  each step. Formalizing this construction, and Lemma #thmref(<lem-steering>) itself, are the two
  pieces of work explicitly flagged as the hardest remaining parts of this formalization project
  before this session's work on Lemma #thmref(<lem-steering>) even began.
]

= Two lemmas on lattice lines

#lemma(name: "Rigidity", lbl: <lem-rigidity>)[
  Let $d_1 = (p_1,q_1)$, $d_2 = (p_2,q_2)$ be _two_ distinct primitive directions --- not members
  of an indexed family; there is no set that $1,2$ range over here, they are simply labels for
  "the first direction" and "the second direction" --- and set
  $ Delta = p_1 q_2 - p_2 q_1 != 0. $ <eq-Delta-def>
  The lines $ell_(d_1,c_1)$ and $ell_(d_2,c_2)$ meet at a lattice point if and only if
  $ Delta divides (p_1 c_2 - p_2 c_1) quad "and" quad Delta divides (q_1 c_2 - q_2 c_1). $ <eq-rigidity-conclusion>
  In particular, if $abs(Delta) = 1$, condition #eqref(<eq-rigidity-conclusion>) holds vacuously for
  _every_ choice of $c_1, c_2$, so $d_1, d_2$ can never both occur in a valid family
  (Definition #thmref(<def-family>)).
]

#pedanticexample[
  *(i) A unimodular pair ($abs(Delta) = 1$): forced for every $c_1,c_2$.* Take
  $d_1 = (1,0)$, $d_2 = (0,1)$, so $Delta = 1 dot.op 1 - 0 dot.op 0 = 1$. For _any_ $c_1,c_2$, say
  $c_1 = 17$, $c_2 = -4$: the system reads $-y = 17$, $x = -4$, giving the lattice point $(x,y) = (-4,-17)$
  regardless of what $c_1,c_2$ were --- this is why $(1,0)$ and $(0,1)$ (or any Farey-neighbor
  pair) can never both appear in a valid family, whatever levels are chosen. *(ii) A
  non-unimodular pair, divisibility holding (conclusion: they meet).* Take $d_1 = (1,0)$,
  $d_2 = (1,2)$, so $Delta = 1 dot.op 2 - 1 dot.op 0 = 2$. With $c_1 = 0$, $c_2 = 4$: $p_1 c_2 - p_2 c_1 = 4$ and
  $q_1 c_2 - q_2 c_1 = 0$, both divisible by $Delta = 2$, so the lemma predicts a lattice crossing; indeed
  the system $-y = 0$, $2x - y = 4$ gives $(x,y) = (2,0) in ZZ^2$. *(iii) Same pair, divisibility
  failing (conclusion: they do not meet).* Same $d_1,d_2$, but $c_1 = 0$, $c_2 = 3$:
  $p_1 c_2 - p_2 c_1 = 3$ is _not_ divisible by $Delta = 2$, so no lattice crossing should occur;
  indeed the system $-y = 0$, $2x - y = 3$ gives $x = 3 slash 2 in.not ZZ$. *(iv) Why $Delta != 0$ (i.e.
  $d_1 != d_2$) cannot be dropped.* Take $d_1 = d_2 = (1,0)$, so $Delta = 0$; equations
  #eqref(<eq-rigidity-elim-x>)--#eqref(<eq-rigidity-elim-y>) below would read $0 dot.op x = p_1 c_2 - p_2 c_1$,
  undefined as a formula for $x$ unless the right side is also $0$. Concretely, with $c_1 = 0 != c_2 = 1$
  the two lines $-y = 0$ and $-y = 1$ are parallel and distinct, hence never meet at all (not
  even off the lattice); with $c_1 = c_2 = 0$ the two lines coincide, sharing _every_ lattice
  point on the line, not a single isolated crossing --- either way the lemma's "if and only if a
  single congruence condition holds" shape breaks down, which is exactly why distinctness of the
  two directions is a standing hypothesis.
]

#proof[
  A lattice point $(x,y)$ lies on both lines exactly when the linear system
  $
    q_1 x - p_1 y &= c_1, \
    q_2 x - p_2 y &= c_2
  $ <eq-rigidity-system>
  holds. Eliminating $y$ (multiply the first equation by $p_2$, the second by $p_1$, and
  subtract) gives
  $ Delta x = p_1 c_2 - p_2 c_1, $ <eq-rigidity-elim-x>
  and eliminating $x$ symmetrically gives
  $ Delta y = q_1 c_2 - q_2 c_1. $ <eq-rigidity-elim-y>
  Since $Delta != 0$, equations #eqref(<eq-rigidity-elim-x>)--#eqref(<eq-rigidity-elim-y>) determine
  $x, y in QQ$ uniquely (this is exactly Cramer's rule applied to #eqref(<eq-rigidity-system>)),
  and $(x,y) in ZZ^2$ if and only if $Delta$ divides both right-hand sides, which is precisely
  #eqref(<eq-rigidity-conclusion>). Conversely, if #eqref(<eq-rigidity-conclusion>) holds, the
  quotients in #eqref(<eq-rigidity-elim-x>)--#eqref(<eq-rigidity-elim-y>) are integers and one checks
  directly, by substituting back into #eqref(<eq-rigidity-system>), that they solve the system: this
  is a direct algebraic identity, not merely a necessary condition. If $abs(Delta) = 1$, both
  divisibility conditions in #eqref(<eq-rigidity-conclusion>) hold automatically for every
  $c_1, c_2 in ZZ$.
]

#leanstatus[
  *formally verified.* Theorem `LatticeLineCovers.rigidity` in
  `lattice-line-covers-lean/LatticeLineCoversLean/Basic.lean`. (The Lean source itself
  names its six integer parameters `p_i q_i p_j q_j c_i c_j` --- purely as
  identifier characters, with no indexed family behind them either; this note's renaming to
  $1,2$ is a presentational choice for this article, not a claim that the Lean statement
  disagrees with it.) Both directions are proved by
  `linear_combination` (an automated tactic verifying a claimed polynomial-ring identity),
  matching exactly the elimination computation in the proof above; the reverse direction needs one
  additional cancellation step (`mul_left_cancel`#sub[0]) since $Delta != 0$ must be used to
  recover $x,y$ from #eqref(<eq-rigidity-elim-x>)--#eqref(<eq-rigidity-elim-y>). Independently
  re-verified to depend only on Lean's three standard axioms
  (`propext`, `Classical.choice`, `Quot.sound`), i.e. on no unproved
  `sorry`. Notably, the Lean statement requires _no_ primitivity/coprimality hypothesis
  on $d_1, d_2$ at all --- confirmed by deliberately adding
  $gcd(p_1,q_1) = gcd(p_2,q_2) = 1$ as hypotheses and observing, via Lean's own unused-variable
  linter, that the existing proof never refers to them. Primitivity is needed only for
  Definition #thmref(<def-direction>)'s bijection between directions and pairs $(p,q)$, not for this
  lemma's algebraic content.
]

#lemma(name: "Coset", lbl: <lem-coset>)[
  Let $p,q$ be coprime integers, $x_0, y_0 in ZZ$, and set
  $ c_0 = q x_0 - p y_0. $ <eq-c0-def>
  Then
  $ union.big_(k in ZZ) ell_((p,q), c_0 + p q k) = {(x,y) in ZZ^2 : x equiv x_0 quad ("mod" thin abs(p)), space
    y equiv y_0 quad ("mod" thin abs(q))}. $ <eq-coset-conclusion>
]

#pedanticexample[
  *(i) Conclusion holds.* Take $p = 2$, $q = 3$ (coprime), $x_0 = y_0 = 1$, so
  $c_0 = 3 dot.op 1 - 2 dot.op 1 = 1$ and $p q = 6$. The claimed set is ${x " odd", space y equiv 1 thin ("mod" thin 3)}$.
  Level $k = 0$ ($c = 1$): the point $(1,1)$ satisfies $3 dot.op 1 - 2 dot.op 1 = 1$, and indeed $1$ is odd,
  $1 equiv 1 thin ("mod" thin 3)$. Level $k = 1$ ($c = 7$): the point $(3,1)$ satisfies $3 dot.op 3 - 2 dot.op 1 = 7$, and
  again $3$ is odd, $1 equiv 1 thin ("mod" thin 3)$. Both lie in $C$ as claimed, at the levels the formula
  predicts. *(ii) Why $gcd(p,q) = 1$ cannot be dropped.* Take the non-coprime pair
  $p = 2, q = 4$ ($gcd = 2$), $x_0 = y_0 = 0$, so $c_0 = 0$ and $p q = 8$. The point $(x,y) = (1,2)$ satisfies
  $q x - p y = 4 dot.op 1 - 2 dot.op 2 = 0 = c_0 + 8 dot.op 0$, i.e. it lies on the level-$0$ line, exactly as a point of
  the claimed union should --- but $x = 1$ is _odd_, so it violates $x equiv x_0 = 0 thin ("mod" thin p) = 2$,
  the very congruence the lemma claims the union equals. So with $p,q$ not coprime the conclusion
  is simply false, not just unproved: the union of levels is a strictly larger set than the claimed
  congruence class, because $phi_((2,4))$ is not surjective onto $ZZ$ in the way the coprime
  case relies on ($gcd(p,q)$ divides every value of $q x - p y$, so the "level $c_0 + p q k$" spacing
  no longer lines up with the individual mod-$p$, mod-$q$ congruences).
]

#proof[
  Write $C$ for the right-hand side of #eqref(<eq-coset-conclusion>). Since $gcd(p,q) = 1$ implies in
  particular $p,q != 0$, congruence modulo $p$ (resp. $q$) is well defined, and $C$ admits the
  parametrization
  $ C = {(x_0 + p u, space y_0 + q v) : u,v in ZZ}. $ <eq-coset-param>
  For a point of the form #eqref(<eq-coset-param>),
  $ phi_((p,q))(x_0 + p u, space y_0 + q v) = q(x_0 + p u) - p(y_0 + q v) = c_0 + p q (u - v), $ <eq-coset-phi-eval>
  using #eqref(<eq-c0-def>) and cancelling the $p q u$ terms. By #eqref(<eq-lline-def>), this point lies
  on $ell_((p,q), c_0 + p q k)$ if and only if $u - v = k$. As $u$ ranges over $ZZ$ (with $v = u - k$ then
  determined), every point of $C$ with that particular value of $u - v$ is visited exactly once, and
  #eqref(<eq-coset-phi-eval>) shows every point of $ell_((p,q), c_0 + p q k) inter C$ has $u - v = k$: hence
  $ ell_((p,q), c_0 + p q k) inter C = {(x_0 + p u, space y_0 + q(u - k)) : u in ZZ}, $ <eq-coset-single-level>
  and moreover every point of $ell_((p,q), c_0 + p q k)$ manifestly lies in $C$ (take $u,v$ with
  $u - v = k$ so that #eqref(<eq-coset-phi-eval>) matches $c_0 + p q k$; such $(x,y)$ automatically satisfies
  $x equiv x_0 thin ("mod" thin p)$, $y equiv y_0 thin ("mod" thin q)$). So $ell_((p,q), c_0 + p q k) subset.eq C$ for every $k$,
  with equality of the union to all of $C$ once $k$ ranges over $ZZ$, since every pair $(u,v) in ZZ^2$
  has _some_ value of $u - v$.
]

#leanstatus[
  *formally verified.* Theorem `LatticeLineCovers.coset`, same file. Stated using
  Mathlib's `IsCoprime` predicate (a Bézout-identity characterization,
  $exists a,b : a p + b q = 1$, rather than a computed $gcd$ value) for the hypothesis $gcd(p,q) = 1$,
  and Mathlib's `Int.ModEq` (notation `a` $equiv$ `b [ZMOD n]`) for the congruences --- the
  latter is convenient here because `Int.ModEq` does not depend on the sign of the modulus,
  so `[ZMOD p]` already means "modulo $abs(p)$" with no extra bookkeeping. The forward
  direction of the proof is a coprimality-transfer argument (from $p divides q(x_0 - x)$ and
  $gcd(p,q) = 1$, conclude $p divides (x_0 - x)$, via `IsCoprime.dvd_of_dvd_mul_left`); the
  reverse direction extracts explicit witnesses from the two congruences and computes $k$
  directly, matching #eqref(<eq-coset-phi-eval>). Independently re-verified axiom-clean. Proved by a
  subagent instance of Claude running on the Opus model, briefed with a written proof plan derived
  from the proof above; compiled successfully on the first attempt.
]

The rigidity lemma shows that a family realizing many directions cannot simply throw them
together: directions related by a determinant of $plus.minus 1$ ("unimodular pairs", e.g. any pair of
Farey neighbors read as slopes) are permanently incompatible. The coset lemma is the tool that lets
us build a family avoiding all bad pairs at once, applied recursively below.

= The construction

#definition(name: "Rank-2 coset", lbl: <def-Rcoset>)[
  For coprime positive integers $n_1, n_2$ and $x_0, y_0 in ZZ$, define
  $ R(n_1,n_2,x_0,y_0) = {(x,y) in ZZ^2 : x equiv x_0 quad ("mod" thin n_1), space y equiv y_0 quad ("mod" thin n_2)}. $ <eq-Rcoset-def>
  Since $n_1, n_2 > 0$, every $(x,y) in R(n_1,n_2,x_0,y_0)$ is of the form $x = x_0 + n_1 u$, $y = y_0 + n_2 w$
  for a _unique_ pair $(u,w) in ZZ^2$; call $(u,w)$ the _internal coordinates_ of the
  point.
]

We now state the two halves of the original Splitting lemma as two separate lemmas, matching a
corresponding split made when formalizing this argument in Lean (see the status notes below): the
first identifies each finer sub-coset with a plain coset of a new direction, and the second
records that these sub-cosets genuinely partition $R$.

#lemma(name: "Splitting: coset identity", lbl: <lem-splitting-coset>)[
  Let $R = R(n_1,n_2,x_0,y_0)$, let $s,t$ be nonzero integers with
  $ gcd(s,n_2) = gcd(t,n_1) = gcd(s,t) = 1, $ <eq-splitting-hyps>
  and put
  $ P = n_1 s, quad Q = n_2 t. $ <eq-PQ-def>
  For $u_0, w_0 in ZZ$, let
  $ R_(u_0,w_0) = {(x,y) in R : &x = x_0 + n_1 u, space y = y_0 + n_2 w "for some" \
    &u equiv u_0 quad ("mod" thin abs(s)), space w equiv w_0 quad ("mod" thin abs(t))} $ <eq-Rsub-def>
  (a sub-coset of $R$, picked out via the internal coordinates of Definition #thmref(<def-Rcoset>)).
  Then
  $ union.big_(k in ZZ) ell_((P,Q), c_0 + P Q k) = R_(u_0,w_0), quad c_0 = Q(x_0 + n_1 u_0) - P(y_0 + n_2 w_0). $ <eq-splitting-coset-conclusion>
  In particular $(P,Q)$ is itself a primitive direction: $gcd(P,Q) = 1$.
]

#pedanticexample[
  *(i) Conclusion holds.* Take $n_1 = 2, n_2 = 3, x_0 = y_0 = 1$ (so $R = {x " odd", space
  y equiv 1 thin ("mod" thin 3)}$), $s = 2, t = 3$; one checks $gcd(s,n_2) = gcd(2,3) = 1$,
  $gcd(t,n_1) = gcd(3,2) = 1$, $gcd(s,t) = gcd(2,3) = 1$, so #eqref(<eq-splitting-hyps>) holds, and
  $P = 4, Q = 9$ with $gcd(4,9) = 1$ as claimed. (Full numeric trace with three explicit points:
  Example #thmref(<ex-splitting-worked>) below.) *(ii) Why $gcd(s,n_2) = 1$ cannot be dropped.*
  Same $n_1 = 2, n_2 = 3$, but take $s = 3, t = 1$: then $gcd(t,n_1) = gcd(1,2) = 1$ and
  $gcd(s,t) = gcd(3,1) = 1$ both still hold, but $gcd(s,n_2) = gcd(3,3) = 3 != 1$, a violation of just
  the _first_ condition of #eqref(<eq-splitting-hyps>) in isolation. Then $P = n_1 s = 6$,
  $Q = n_2 t = 3$, and $gcd(P,Q) = gcd(6,3) = 3 != 1$: $(P,Q)$ is _not_ a primitive direction ---
  exactly because the proof's "primitivity of $(P,Q)$" case analysis needs $gcd(s,n_2) = 1$ to
  rule out a prime (here $3$) dividing both $s$ and $n_2$ simultaneously, and hence dividing both
  $P = n_1 s$ and $Q = n_2 t$ at once.
]

#proof[
  _Primitivity of $(P,Q)$._ A prime dividing both $P = n_1 s$ and $Q = n_2 t$ would have to divide
  one of $n_1, n_2$ (excluded, as $gcd(n_1,n_2) = 1$), or $n_1$ and $t$ (excluded by $gcd(t,n_1) = 1$
  in #eqref(<eq-splitting-hyps>)), or $s$ and $n_2$ (excluded by $gcd(s,n_2) = 1$), or $s$ and $t$
  (excluded by $gcd(s,t) = 1$). These four cases are exhaustive, so no such prime exists.

  _The identity #eqref(<eq-splitting-coset-conclusion>)._ For $(x,y) = (x_0 + n_1 u, space y_0 + n_2 w)$,
  $ Q x - P y = Q(x_0 + n_1 u) - P(y_0 + n_2 w) = (Q x_0 - P y_0) + n_1 n_2 (t u - s w), $ <eq-splitting-phi-eval>
  using $Q = n_2 t$, $P = n_1 s$. By Lemma #thmref(<lem-coset>) applied to the coprime pair $(s,t)$ in the
  _internal_ coordinates $(u,w)$,
  $ union.big_(k in ZZ) {(u,w) : t u - s w = c_0^"loc" + s t k} &= {u equiv u_0 quad ("mod" thin abs(s)), space
    w equiv w_0 quad ("mod" thin abs(t))}, \
    quad c_0^"loc" &= t u_0 - s w_0. $ <eq-splitting-local-coset>
  Substituting the local level $c_0^"loc" + s t k$ into #eqref(<eq-splitting-phi-eval>) via
  $x_0, y_0$ translates it into the global level
  $ (Q x_0 - P y_0) + n_1 n_2 (c_0^"loc" + s t k) = c_0 + n_1 n_2 s t k = c_0 + P Q k, $ <eq-splitting-level-translate>
  where the first equality uses $c_0 = (Q x_0 - P y_0) + n_1 n_2 c_0^"loc"$ (a direct computation
  confirming this matches the formula for $c_0$ stated in #eqref(<eq-splitting-coset-conclusion>)),
  and the second uses $P Q = n_1 n_2 s t$. Combining #eqref(<eq-splitting-local-coset>) and
  #eqref(<eq-splitting-level-translate>) with #eqref(<eq-splitting-phi-eval>) gives exactly
  #eqref(<eq-splitting-coset-conclusion>).
]

#leanstatus[
  *formally verified.* Theorem `LatticeLineCovers.splitting`. Matching the paper's
  hypotheses exactly required adding $0 < n_1$, $0 < n_2$, $s != 0$, $t != 0$ (needed for
  `mul_left_cancel`#sub[0]-style cancellation in the proof, and genuinely present, if
  implicitly, in the informal statement above via "coprime _positive_ integers $n_1,n_2$"
  and "_nonzero_ integers $s,t$") --- this omission was caught and fixed _before_
  delegating the proof, not after. The Lean proof runs two parallel coprimality-transfer arguments
  (one per coordinate), the same technique as Lemma #thmref(<lem-coset>)'s proof. As with
  Lemma #thmref(<lem-rigidity>), `s`$!= 0$ and `t`$!= 0$ turned out to be unused by the actual
  Lean proof (only $n_1, n_2 != 0$ are load-bearing for the cancellations) --- again confirmed via
  the unused-variable linter, and again kept in the statement for fidelity to this paper's own
  hypotheses rather than removed. Independently re-verified axiom-clean.
]

#example(lbl: <ex-splitting-worked>)[
  Take $n_1 = 2$, $n_2 = 3$, $x_0 = y_0 = 1$, so $R = R(2,3,1,1) = {(x,y) : x " odd", space y equiv 1 thin ("mod" thin 3)}$.
  Take $s = 2$, $t = 3$; one checks directly that #eqref(<eq-splitting-hyps>) holds:
  $ gcd(s,n_2) = gcd(2,3) = 1, quad gcd(t,n_1) = gcd(3,2) = 1, quad gcd(s,t) = gcd(2,3) = 1. $
  Then $P = n_1 s = 4$, $Q = n_2 t = 9$ (and indeed $gcd(4,9) = 1$). Take the residue pair $(u_0,w_0) = (1,2)$;
  then
  $ c_0 = Q(x_0 + n_1 u_0) - P(y_0 + n_2 w_0) = 9 dot.op (1 + 2) - 4 dot.op (1 + 6) = 27 - 28 = -1. $
  Three points of $R_(1,2)$, at three different values of $k$ in
  #eqref(<eq-splitting-coset-conclusion>):
  $
    (u,w) = (1,2) &arrow.r.long.bar (x,y) = (3,7): & quad & phi_((4,9))(3,7) = 27 - 28 = -1 = c_0 + 36 dot.op 0, \
    (u,w) = (3,2) &arrow.r.long.bar (x,y) = (7,7): & quad & phi_((4,9))(7,7) = 63 - 28 = 35 = c_0 + 36 dot.op 1, \
    (u,w) = (1,5) &arrow.r.long.bar (x,y) = (3,16): & quad & phi_((4,9))(3,16) = 27 - 64 = -37 = c_0 + 36 dot.op (-1),
  $
  using $P Q = 36$ throughout.
]

#lemma(name: "Splitting: partition", lbl: <lem-splitting-partition>)[
  With $R$, $s$, $t$ as in Lemma #thmref(<lem-splitting-coset>),
  $ R = union.sq.big_(0 <= u_0 < abs(s) \ 0 <= w_0 < abs(t)) R_(u_0,w_0) $ <eq-splitting-partition-conclusion>
  (a disjoint union over the $abs(s) abs(t)$ residue pairs).
]

#pedanticexample[
  *(i) Conclusion holds.* With $n_1 = 2, n_2 = 3, x_0 = y_0 = 1, s = 2, t = 3$ as in
  Example #thmref(<ex-splitting-worked>), $R$ is partitioned into $abs(s) abs(t) = 6$ pieces $R_(u_0,w_0)$,
  $0 <= u_0 < 2$, $0 <= w_0 < 3$. The point $(x,y) = (7,7)$ has internal coordinates $(u,w) = (3,2)$
  (i.e. $7 = 1 + 2 dot.op 3$, $7 = 1 + 3 dot.op 2$), so its residue pair is $u_0 = 3 med "mod" med 2 = 1$,
  $w_0 = 2 med "mod" med 3 = 2$: it lies in $R_(1,2)$ and in _no other_ of the $6$ pieces, matching the
  "$exists !$" (exists-uniquely) content of the lemma. *(ii) Why $s != 0$ cannot be
  dropped.* With $s = 0$ (and, say, $t = 3$ as before), the index range $0 <= u_0 < abs(s) = 0$ is
  _empty_, so the right-hand side of #eqref(<eq-splitting-partition-conclusion>) is an empty
  union $union.sq.big_nothing = nothing$ --- yet $R$ itself is nonempty (e.g. $(1,1) in R$), so the
  claimed equality fails outright. (Concretely, $s = 0$ also makes $R_(u_0,w_0)$ from
  #eqref(<eq-Rsub-def>) ill-posed, since "$u equiv u_0 thin ("mod" thin abs(s))$" is congruence modulo $0$, i.e.
  $u = u_0$ exactly --- a single internal-coordinate value, not a residue class --- so the whole
  finite-partition statement, which relies on exactly $abs(s)$ residue classes covering all of $ZZ$,
  has no content left to state.) This is exactly why $s,t$ nonzero is carried over as a standing
  hypothesis from Lemma #thmref(<lem-splitting-coset>).
]

#proof[
  Fix $(x,y) in R$, with internal coordinates $(u,w)$ as in Definition #thmref(<def-Rcoset>). By the
  division algorithm, $u = s floor(u\/s) + u_0$ for a unique $u_0$ with $0 <= u_0 < abs(s)$ (interpreting
  the division algorithm with respect to $abs(s)$; concretely, $u_0$ is the unique representative of
  $u$ modulo $s$ lying in $[0,abs(s))$, and similarly $w_0 in [0,abs(t))$ for $w$ modulo $t$). By
  construction $u equiv u_0 thin ("mod" thin abs(s))$ and $w equiv w_0 thin ("mod" thin abs(t))$, so $(x,y) in R_(u_0,w_0)$ for
  this particular pair $(u_0,w_0)$, establishing $R subset.eq union.big_(u_0,w_0) R_(u_0,w_0)$; the
  reverse inclusion is immediate from #eqref(<eq-Rsub-def>). For disjointness (equivalently,
  uniqueness of $(u_0,w_0)$ for each point): suppose $(x,y) in R_(u_0,w_0) inter R_(u_0',w_0')$ via
  internal coordinates $(u,w)$ and $(u'',w'')$ respectively. Since internal coordinates are unique
  (Definition #thmref(<def-Rcoset>)), $u'' = u$ and $w'' = w$, so $u_0 equiv u equiv u_0' thin ("mod" thin abs(s))$; as both
  $u_0, u_0' in [0,abs(s))$, an interval of length $abs(s)$, and their difference is a multiple of $s$ of
  absolute value $< abs(s)$, we get $u_0 = u_0'$, and symmetrically $w_0 = w_0'$.
]

#leanstatus[
  *formally verified.* Theorem `LatticeLineCovers.splitting_partition`, phrased as
  existence-and-uniqueness of the residue pair $(u_0,w_0)$ for every point of $R$ (an
  `ExistsUnique` statement, Lean/Mathlib notation $exists !$), which is definitionally
  what a disjoint union means. This is pure
  Euclidean division together with the "two representatives of one residue class in the same
  length-$abs(m)$ window coincide" fact used in the last paragraph of the proof above; no
  coprimality is involved anywhere. A first, undelegated attempt at this lemma hit real friction
  --- a cited lemma that does not exist in the current Mathlib version, and several automated
  (`omega`) tactic calls given goals it cannot discharge, since `omega` handles only
  linear integer arithmetic and the "length-$abs(m)$ window" argument genuinely needs one
  multiplicative step. Reverted rather than continuing to guess lemma names, and delegated (with
  the specific failures included in the brief so they were not repeated) to a fresh Opus-model
  subagent, which closed the multiplicative step via `abs_mul` together with
  `le_mul_of_one_le_right` and `Int.one_le_abs`, keeping `omega` strictly
  to the resulting linear facts. Independently re-verified axiom-clean.
]

This is where the earlier, flawed version of this argument failed: it attempted to realize an
_arbitrary_ target direction by using a multiple of it known to lie in the current sublattice,
without checking that the multiple's own geometric line (which follows its _primitive_
direction, not the multiple used to construct it) stays confined to the intended coset.
Lemma #thmref(<lem-splitting-coset>) avoids this by construction, via the primitivity argument in its
own proof.

#lemma(name: "Steering", lbl: <lem-steering>)[
  Let $n_1, n_2$ be coprime positive integers. For every $theta in [0,pi)$ and every
  $epsilon > 0$ there exist nonzero integers $s,t$, $abs(s), abs(t) >= 2$, satisfying
  #eqref(<eq-splitting-hyps>), such that the direction of $(n_1 s, n_2 t)$ lies within $epsilon$ of
  $theta$.
]

#pedanticexample[
  *(i) Conclusion holds, fully numeric.* Take $n_1 = 2, n_2 = 3$ (coprime), target $mu = tan theta = 1$,
  tolerance $epsilon = 0.1$. From #eqref(<eq-steering-constants>):
  $delta = 1/2 (1 - 1/2) = 1/4$, $E = 2^(omega(2)+1) = 2^2 = 4$; from #eqref(<eq-steering-L0>):
  $L_0 = ceil((4+1) slash 1/4) = 20$. Condition #eqref(<eq-steering-p-choice>) needs
  $20 + 2 < 0.1 dot.op 2 dot.op p slash 3 = p slash 15$ (note: no $mu$ in this condition --- see the remark right after
  #eqref(<eq-steering-p-choice>) in the proof below), i.e. $p > 330$; take the prime $p = 331$
  ($331 divides.not n_1 n_2 = 6$),
  so $s = 331$. Then $t_0 = floor(1 dot.op 2 dot.op 331 slash 3) + 2 = floor(220.67) + 2 = 222$, and searching
  $I = [222,242)$ for $t$ coprime to $n_1 p = 662$: $t = 223$ (prime) works ($gcd(223,2) = 1$,
  $gcd(223,331) = 1$), and also $gcd(s,t) = gcd(331,223) = 1$, $gcd(s,n_2) = gcd(331,3) = 1$,
  $gcd(t,n_1) = gcd(223,2) = 1$, so #eqref(<eq-splitting-hyps>) holds; note $t = 223 >= 2$ automatically,
  by construction of the shifted window #eqref(<eq-steering-t0>), with no separate check needed. The
  resulting slope is $n_2 t slash (n_1 s) = 669 slash 662 approx 1.01057$, within $epsilon = 0.1$ of $mu = 1$ as
  promised.
  *(ii) A subtlety about $gcd(n_1,n_2) = 1$: not used inside _this_ proof, but still
  essential downstream.* Repeat the same computation with the non-coprime pair $n_1 = 4, n_2 = 6$
  ($gcd = 2$) --- note $4$ has the same radical (${2}$) as $n_1 = 2$ above, so $delta, E, L_0$ and
  even the threshold on $p$ are literally unchanged, and $p = 331, space t = 223$ still satisfy every step
  of the argument verbatim, giving slope $n_2 t slash (n_1 s) = 1338 slash 1324 approx 1.01057$, again within
  $epsilon$ of $mu$: #eqref(<eq-steering-sieve>)--#eqref(<eq-steering-final-bound>) never once
  refer to $gcd(n_1,n_2)$, so nothing in _this_ proof breaks. What _does_ break is
  downstream: $(P,Q) = (n_1 s, n_2 t) = (1324,1338)$ has $gcd(1324,1338) = 2$ --- not a primitive
  direction at all, so it could not legally be fed into Lemma #thmref(<lem-splitting-coset>) (which
  needs $gcd(n_1,n_2) = 1$ among its own standing hypotheses to guarantee $gcd(P,Q) = 1$) or used as
  a line direction under Definition #thmref(<def-direction>). So $gcd(n_1,n_2) = 1$ is carried by
  Lemma #thmref(<lem-steering>) as a hypothesis not because its own proof needs it, but because it is
  the invariant maintained by the surrounding recursive construction (Theorem #thmref(<thm-main>)'s
  proof) that every lemma along the way is entitled to assume. *(iii) A real bug this
  pedantic pass actually found, now fixed.* An earlier version of #eqref(<eq-steering-p-choice>)
  read $L_0 < epsilon mu n_1 p slash n_2$ (an extra, wrong factor of $mu$). Concretely, with
  $n_1 = n_2 = 1$, $mu = 100$, $epsilon = 0.01$: that wrong condition gives $delta = 1/2$, $E = 2$,
  $L_0 = 6$, threshold $p > 6$, so $p = 7$; the best $t$ in the resulting window
  ($t_0 = 700$, $I = [700,706)$) is $t = 701$, giving slope $701 slash 7 approx 100.142857$ --- off from
  $mu = 100$ by $approx 0.143$, over $14 times$ the claimed tolerance $epsilon = 0.01$, not a
  rounding-level near-miss. The wrong condition is even _unsatisfiable_ at $mu = 0$ (reduces to
  $L_0 < 0$). Both failures trace to the same algebra error: $L_0 < epsilon mu n_1 p slash n_2$ only
  implies $(n_2 L_0) slash (n_1 p) < epsilon mu$, not $< epsilon$, and these coincide only when
  $mu <= 1$. The corrected, $mu$-free condition #eqref(<eq-steering-p-choice>) used in the proof
  below fixes this: with the same $n_1, n_2, mu, epsilon$, it gives threshold $p > 800$, so
  $p = 809$; the best $t$ in $I = [80902,80908)$ is $t = 80902$, giving slope
  $80902 slash 809 approx 100.002472$, comfortably within $epsilon = 0.01$. (Script:
  `code/steering_bug_check.py`; log: `runs/2026-08-02_steering_bug_check.md`.)
  *(iv) A second, independent bug found on the next adversarial pass, now fixed: window
  frozen at $mu = 0$.* Reuse $n_1 = 2, n_2 = 3$ so $delta = 1/4, E = 4, L_0 = 20$ as in (i). At $mu = 0$,
  the _unshifted_ window used by an earlier version of this proof was
  $t_0 = floor(0 dot.op n_1 p slash n_2) = 0$ for every prime $p$, i.e. $I = [0,20)$ regardless of $p$:
  taking $p = 307$ gives $I = [0,20)$, and so does the much larger $p = 100003$ --- unlike the $mu = 1$
  case in (i), where a larger $p$ pushes $t_0$ further from the origin, at $mu = 0$ the window never
  moves. Since $gcd(1,n_1 p) = 1$ always, $t = 1 in I$ is always a valid witness of "$>= 1$ coprime
  integer in $I$," and is in fact the _closest-to-target_ candidate (it minimizes
  $abs(n_2 t slash (n_1 p) - 0)$ among positive $t$) --- yet $t = 1$ violates the lemma's own $abs(t) >= 2$
  requirement; the earlier proof's "(for $p$ large) $abs(t) >= 2$" was simply asserted, not derived,
  and at $mu = 0$ no amount of growing $p$ makes it true on its own. (For this particular $n_1 = 2$,
  other coprime witnesses with $abs(t) >= 2$ do also exist in $[0,20)$, e.g. $t = 3$ or $t = 5$, so the
  _lemma_ was never false here --- only the proof's justification for picking a witness was
  incomplete.) The shifted window #eqref(<eq-steering-t0>), $t_0 = floor(mu n_1 p slash n_2) + 2$, fixes
  this structurally: at $mu = 0$ it gives $t_0 = 2$ for every $p$, so $I = [2,22)$ contains only
  integers with $abs(t) >= 2$ from the outset, and the same sieve count $delta L_0 - E >= 1$ now
  guarantees a genuinely usable witness with no largeness argument needed. (Script:
  `code/steering_mu0_bug_check.py`; log:
  `runs/2026-08-02_steering_mu0_bug_check.md`.)
]

#proof[
  By symmetry (swap the roles of $s$ and $t$ to treat $theta = pi\/2$, which targets reciprocal
  slope $0$ and is handled by the same argument below with the roles of $n_1, n_2$ exchanged,
  subject to the same window shift introduced at #eqref(<eq-steering-t0>)) it suffices to treat
  $theta != pi\/2$, i.e. a finite target slope $mu = tan theta$; the case $mu < 0$ is identical
  with $t arrow.r.bar -t$, so assume $mu >= 0$.

  Set
  $ delta = 1/2 product_(r divides n_1) (1 - 1/r) > 0, quad E = 2^(omega(n_1)+1), $ <eq-steering-constants>
  both depending only on $n_1$, where $omega(n_1)$ is the number of distinct prime divisors of
  $n_1$. For a prime $p divides.not n_1 n_2$ and any interval $I subset ZZ$ of length $L$,
  inclusion--exclusion over the divisors of $n_1 p$ gives
  $ \#{t in I : gcd(t, n_1 p) = 1} >= L product_(r divides n_1) (1 - 1/r) (1 - 1/p) - 2^(omega(n_1)+1) >= delta L - E, $ <eq-steering-sieve>
  using $p >= 2$ for the last factor. Fix
  $ L_0 = ceil((E+1)/delta), $ <eq-steering-L0>
  independent of $p$ --- and, crucially, independent of $mu$ as well. Choose a prime $p divides.not n_1 n_2$
  large enough that
  $ L_0 + 2 < (epsilon n_1 p)/n_2 $ <eq-steering-p-choice>
  (possible since the right side $-> infinity$ as $p -> infinity$, for fixed $epsilon, n_1, n_2$; note
  #eqref(<eq-steering-p-choice>) does not involve $mu$ at all, unlike $t_0$ below), set $s = p$ and
  $ t_0 = floor((mu n_1 p)/n_2) + 2. $ <eq-steering-t0>
  The $+2$ shift in #eqref(<eq-steering-t0>), absent from an earlier version of this proof, is what
  makes the forthcoming $abs(t) >= 2$ requirement hold _unconditionally_ rather than only "for $p$
  large": since $mu >= 0$, already $t_0 >= 2$ by #eqref(<eq-steering-t0>), so every integer in the
  window $I$ below inherits $abs(t) >= 2$ directly, with no degenerate behaviour at $mu = 0$ (where,
  without the shift, $t_0 = 0$ for _every_ $p$, the window never moves away from the origin as
  $p -> infinity$, and $t = 1$ --- always coprime to $n_1 p$ --- is a witness that nothing rules out being
  the _only_ one, violating $abs(t) >= 2$). The interval $I = [t_0, t_0 + L_0)$ then contains, by
  #eqref(<eq-steering-sieve>) with $L = L_0$ and #eqref(<eq-steering-L0>), at least $delta L_0 - E >= 1$
  integer $t$ with $gcd(t, n_1 p) = 1$ --- equivalently $gcd(t,n_1) = gcd(t,s) = 1$, as $s = p$ is prime
  --- and, as just noted, $abs(t) >= 2$ automatically. For any such $t$,
  $ abs((n_2 t)/(n_1 s) - mu) = n_2/(n_1 p) abs(t - (mu n_1 p)/n_2) < (n_2 (L_0 + 2))/(n_1 p) < epsilon, $ <eq-steering-final-bound>
  using #eqref(<eq-steering-p-choice>) for the last step (and $abs(t - mu n_1 p slash n_2) < L_0 + 2$, which
  follows from $t in [t_0, t_0 + L_0)$ and $t_0 - mu n_1 p slash n_2 in (1,2]$ by #eqref(<eq-steering-t0>)), so
  $(P,Q) = (n_1 s, n_2 t)$ has slope within $epsilon$ of $mu$, hence (as $arctan$ is
  $1$-Lipschitz, and $arctan mu = theta - pi$ when $theta > pi\/2$ identifies the same point of
  $#RP$) direction within $epsilon$ of $theta$.
]

#leanstatus[
  *not yet formalized.* Flagged, before any Lean work on this project began, as the single
  hardest piece of the whole formalization: it is a genuine (if elementary) analytic-number-theory
  argument, not pure algebra like Lemmas #thmref(<lem-rigidity>)--#thmref(<lem-splitting-partition>). Worth
  checking, before attempting to reprove #eqref(<eq-steering-sieve>) from scratch in Lean, whether
  Mathlib's existing sieve-theory development (e.g. `Mathlib.NumberTheory.SelbergSieve` or
  similar) already covers a bound of this shape.
]

The point of Lemma #thmref(<lem-steering>) is that it is _not_ enough to know that _some_
admissible $(s,t)$ exists at every stage: repeatedly reusing, say, $(s,t) = (2,3)$ is admissible
forever (all three coprimality conditions of #eqref(<eq-splitting-hyps>) hold trivially against the
resulting $n_1 = 2^k, n_2 = 3^k$), yet gives directions converging to a single point of $#RP$, not a
dense set. What is needed, and what Lemma #thmref(<lem-steering>) provides, is the ability to steer
toward an _arbitrary prescribed_ target at every stage.

#remark(name: "Tails of a dense sequence remain dense", lbl: <rem-tail-density>)[
  If $X$ is a $T_1$ topological space with no isolated points, $D subset.eq X$ is dense, and
  $F subset X$ is finite, then $D without F$ is still dense in $X$. (Any nonempty open $U$ is
  itself infinite, since no point of $X$ is isolated; so $U without F$ is nonempty and open,
  hence meets $D$, giving a point of $D without F$ in $U$.) Applied with $X = #RP$ (compact,
  metric, hence $T_1$, and with no isolated points as a circle) and $D = {theta_k}_(k >= 1)$:
  every tail ${theta_k}_(k >= N)$ is dense, since it contains $D without {theta_1,dots,theta_(N-1)}$.
  This is the fact the density argument below needs beyond mere density of ${theta_k}$ itself ---
  without "no isolated points" it can fail (e.g. a sequence dense in ${0} union [1,2]$ that
  visits $0$ only once).
]

#proof(name: [Proof of Theorem #thmref(<thm-main>)])[
  Fix an enumeration $(z_k)_(k >= 1)$ of $ZZ^2$ and a sequence $(theta_k)_(k >= 1)$ dense in
  $[0,pi)$ (e.g. $theta_k = k alpha med "mod" med pi$ for $alpha\/pi$ irrational, by equidistribution of
  the irrational rotation). Set $R_0 = ZZ^2$, i.e. $(n_1,n_2,x_0,y_0) = (1,1,0,0)$.

  Given $R_(k-1) = R(n_1,n_2,x_0,y_0)$, apply Lemma #thmref(<lem-steering>) to find $s,t$ (possibly
  negative --- Lemma #thmref(<lem-steering>) allows this, needed to reach both signs of slope) realizing
  a direction within $1\/k$ of $theta_k$, and apply
  Lemmas #thmref(<lem-splitting-coset>)--#thmref(<lem-splitting-partition>) to split $R_(k-1)$ into its
  $abs(s) abs(t) >= 4$ sub-cosets, each fully coverable by direction $(P_k,Q_k) = (n_1 s, n_2 t)$ restricted
  to one residue class of levels. Put into $cal(F)$ all such lines for every sub-coset except
  one, reserved as follows: if $z_k in R_(k-1)$, reserve the lexicographically-least $(u_0,w_0)$
  whose sub-coset does not contain $z_k$ (possible since there are $>= 4$ sub-cosets and only one
  need be avoided); otherwise reserve the lexicographically-least $(u_0,w_0)$ outright --- a
  concrete rule is needed for the recursion to be a well-defined function, as is a concrete choice
  among the $(s,t)$ that Lemma #thmref(<lem-steering>) only asserts to exist --- both are choice
  functions to be supplied explicitly in a Lean formalization, not just existence claims. Let
  $R_k = R_(u_0,w_0)$ be that reserved sub-coset. The two quantities that matter going forward are
  genuinely different: the _achieved direction_ recorded for the density argument below is
  the (possibly signed) pair $(P_k,Q_k) = (n_1 s, n_2 t)$, while $R_k$ itself, to serve as the input
  $R(n_1',n_2',x_0',y_0')$ to the _next_ stage's application of Lemma #thmref(<lem-steering>)
  (whose hypotheses require positive $n_1', n_2'$, as does Definition #thmref(<def-Rcoset>)), must use
  the _positive_ pair $n_1' = n_1 abs(s)$, $n_2' = n_2 abs(t)$, $x_0' = x_0 + n_1 u_0$, $y_0' = y_0 + n_2 w_0$: a
  direct check from the definition of $R_(u_0,w_0)$ #eqref(<eq-Rsub-def>) (writing $u = u_0 + abs(s) u'$,
  $w = w_0 + abs(t) w'$ for the internal coordinates, since "$u equiv u_0 thin ("mod" thin abs(s))$" means exactly this)
  shows $R_(u_0,w_0) = R(n_1 abs(s), n_2 abs(t), x_0', y_0')$ on the nose. Write
  $R_k = R(n_1^((k)), n_2^((k)), x_0^((k)), y_0^((k)))$ for this representation, i.e.
  $n_1^((k)) = n_1 abs(s)$, $n_2^((k)) = n_2 abs(t)$ (with $n_1^((0)) = n_2^((0)) = 1$ from the base
  case), the notation used below. This keeps
  $gcd(n_1^((k)),n_2^((k))) = gcd(n_1 abs(s), n_2 abs(t)) = gcd(P_k,Q_k) = 1$ (Lemma #thmref(<lem-splitting-coset>)), so the
  invariant needed for the next iteration is preserved.

  #pedanticexample[
    *Another real gap this pedantic pass found, now fixed above.* An earlier version of this
    proof used $(P_k,Q_k) = (n_1 s, n_2 t)$ directly, unmodified, as the next stage's $(n_1,n_2)$ pair ---
    silent, because it never mattered until $s$ or $t$ was actually negative. Concretely: start from
    $R_0 = R(1,1,0,0) = ZZ^2$, and suppose stage $1$ picks $s = -3, t = 2$ (both satisfy $abs(s), abs(t) >= 2$;
    $gcd(s,n_2) = gcd(-3,1) = 1$, $gcd(t,n_1) = gcd(2,1) = 1$, $gcd(s,t) = gcd(-3,2) = 1$, so
    #eqref(<eq-splitting-hyps>) holds), giving $(P_1,Q_1) = (-3,2)$ --- a perfectly good, primitive,
    achieved direction ($gcd(-3,2) = 1$) to record for density purposes. But
    Definition #thmref(<def-Rcoset>) and Lemma #thmref(<lem-steering>) both require their $n_1, n_2$
    _positive_; feeding $n_1' = -3$ into either is simply outside what they're stated for, not
    merely inconvenient. The fix used above --- $n_1' = abs(-3) = 3$, $n_2' = abs(2) = 2$ --- is not a different
    choice, just the _correct name_ for the same set: taking $(u_0,w_0) = (0,0)$ for concreteness,
    $R_(0,0) = {(x,y) : x equiv 0 thin ("mod" thin 3), space y equiv 0 thin ("mod" thin 2)} = R(3,2,0,0)$, exactly matching $(n_1 abs(s), n_2 abs(t)) = (3,2)$
    and manifestly _not_ matching $(P_1,Q_1) = (-3,2)$ read literally as a positive pair.
  ]

  _Coverage invariant._ Stage $i$ claims exactly $R_(i-1) without R_i$, and $R_i subset.eq R_(i-1)$
  for every $i >= 1$. Telescoping from $R_0 = ZZ^2$ gives, for every $k$,
  $ ZZ^2 without R_(k-1) = union.big_(i < k) (R_(i-1) without R_i) = union.big_(i < k) ("stage-" i " claims"), $ <eq-main-coverage-invariant>
  i.e. a point lies outside the current region $R_(k-1)$ exactly when some earlier stage already
  claimed it. This is what justifies the reservation rule above only ever needing to avoid $z_k$
  when $z_k in R_(k-1)$: whenever $z_k in.not R_(k-1)$, #eqref(<eq-main-coverage-invariant>) shows
  $z_k$ was already claimed by an earlier stage, so no action is needed for it at stage $k$.

  #pedanticexample[
    *Why the coverage argument needs the invariant #eqref(<eq-main-coverage-invariant>), fully
    numeric.* Take $z_5 = (0,0) in ZZ^2$, and suppose (hypothetically) $R_4 = R(4,3,1,0)$, so
    $z_5 = (0,0) in.not R_4$ (since $0 not equiv 1 med ("mod" med 4)$). The reservation rule at
    stage $5$ only ever looks at membership in $R_4$ --- since $z_5 in.not R_4$, stage $5$ does
    nothing to claim $z_5$ specifically. For the overall coverage claim
    $union.big_k ("stage-" k " claims") = ZZ^2$ to hold, $z_5$ must therefore already have been
    claimed at some _earlier_ stage; #eqref(<eq-main-coverage-invariant>) is exactly what proves
    this: $z_5 in.not R_4$ forces $z_5 in R_(i-1) without R_i$ for some $i <= 4$. Without the
    invariant, the Coverage paragraph's "if $z_k in.not R_(k-1)$, it was already claimed at some
    earlier stage" step would be an unjustified assertion rather than a proven fact.
  ]

  _Coverage._ By #eqref(<eq-main-coverage-invariant>), every $z_k$ is eventually claimed: if
  $z_k in R_(k-1)$, the reservation rule ensures $z_k$ lies in one of the claimed sub-cosets at
  stage $k$ (not the reserved $R_k$); if $z_k in.not R_(k-1)$, it was already claimed at some
  earlier stage. So
  $ union.big_k ("stage-" k " claims") = ZZ^2. $ <eq-main-coverage>

  _Disjointness._ Every individual line placed into $cal(F)$ at stage $k$ has all of its
  lattice points inside the sub-coset $R_(u_0,w_0)$ it came from (a subset of $R_(k-1) without R_k$,
  since $R_(u_0,w_0) != R_k$): this is exactly #eqref(<eq-splitting-coset-conclusion>) of
  Lemma #thmref(<lem-splitting-coset>) (each line on the left is a subset of the union), the step the
  earlier, flawed version of this construction got wrong (see the remark following
  Lemma #thmref(<lem-splitting-coset>)). So stage $k$'s claimed points lie in $R_(k-1) without R_k subset R_(k-1)$.
  For $j > k$, $R_(j-1) subset.eq R_k$ (as $R_i subset.eq R_(i-1)$ for every $i$),
  so stage $j$'s points, lying in $R_(j-1)$, are disjoint from stage $k$'s. Hence distinct lines
  from different stages never share a lattice point, and distinct lines of the same direction from
  the same stage are disjoint level sets of the same $phi_((P_k,Q_k))$, so never share one
  either. (Different stages in fact always realize different directions --- $abs(P_k) = n_1^((k))$ is
  strictly increasing in $k$, since $n_1^((k)) = n_1^((k-1)) abs(s_k) >= 2 n_1^((k-1))$ --- though the
  argument above does not need this.)

  _Density._ Fix $theta in #RP$ and $epsilon > 0$. By #thmref(<rem-tail-density>), every tail
  ${theta_k}_(k >= N)$ is dense in $#RP$; so for
  any $N$ there is some $k >= N$ with $theta_k$ within $epsilon\/2$ of $theta$. Taking
  $N > 2\/epsilon$, the corresponding achieved direction $(P_k,Q_k)$ --- within $1\/k < epsilon\/2$
  of $theta_k$ --- then lies within $epsilon$ of $theta$. (Each $(P_k,Q_k)$ is genuinely
  realized in $cal(F)$: at least $abs(s) abs(t) - 1 >= 3$ of the $>= 4$ sub-cosets at stage $k$ are
  claimed, all nonempty, each contributing lines of that direction.) So every $theta in #RP$ is a
  limit of directions realized in $cal(F)$: the realized direction set is dense.

  #pedanticexample[
    *Why the density argument needs a second use of density, fully numeric.* A closure
    inference of the shape "$d(a_k,b_k) <= 1\/k$ for all $k$, so $overline({a_k}) supset.eq
    overline({b_k})$" is false in general: take $b_1 = 0$, $b_k = 1$ for $k >= 2$, and $a_k = 1$ for all
    $k$ (legal, since $d(a_1,b_1) = 1 <= 1\/1$). Then $overline({b_k}) = {0,1}$ but
    $overline({a_k}) = {1} in.rev.not 0$: the value $0$ is only ever shadowed at the one index where
    the tolerance $1\/k$ is too coarse to matter. The fix used above blocks exactly this: instead of
    using _every_ index $k$ once, it selects, for each target $theta$ and tolerance
    $epsilon$, an index $k$ chosen _after_ $epsilon$ is fixed and large enough that both
    $theta_k$ is already close to $theta$ (using #thmref(<rem-tail-density>), which needs $#RP$
    to have no isolated points) and $1\/k$ is small. Applied to the toy example:
    there is no tail of ${theta_k}$ avoiding the value $theta = 0$ forever, so this style of
    argument could never reach the toy example's false conclusion.
  ]
]

#leanstatus[
  *not yet formalized*; see the status note under Theorem #thmref(<thm-main>) above. Two write-up
  gaps found and fixed by adversarial review, 2026-08-02 (not affecting the truth of the theorem,
  only the rigor of this proof): the coverage argument originally left the case $z_k in.not R_(k-1)$
  undischarged (fixed by #eqref(<eq-main-coverage-invariant>)); the density argument's closure
  inference was a non-sequitur as originally stated (fixed by the explicit arbitrarily-large-$k$
  argument above). Before formalizing: the reservation and the Steering witness are existential
  choices, not yet functions --- will need `Classical.choice`-style witnesses or an explicit
  deterministic rule (e.g. lexicographically-least valid choice) for the recursion to type-check
  as a definition.
]

= Formalization status: summary

#align(center)[
  #table(
    columns: 3,
    stroke: none,
    align: left,
    inset: (x: 0.7em, y: 0.35em),
    table.hline(stroke: 0.9pt),
    table.header([Statement above], [Lean theorem], [Status]),
    table.hline(stroke: 0.5pt),
    [Lemma #thmref(<lem-rigidity>) (Rigidity)], [`LatticeLineCovers.rigidity`], [proved],
    [Lemma #thmref(<lem-coset>) (Coset)], [`LatticeLineCovers.coset`], [proved],
    [Lemma #thmref(<lem-splitting-coset>) (Splitting, coset identity)], [`LatticeLineCovers.splitting`], [proved],
    [Lemma #thmref(<lem-splitting-partition>) (Splitting, partition)], [`LatticeLineCovers.splitting_partition`], [proved],
    [Lemma #thmref(<lem-steering>) (Steering)], [---], [not started],
    [Theorem #thmref(<thm-main>) (main theorem)], [---], [not started],
    table.hline(stroke: 0.9pt),
  )
]

#v(0.5em)

All four proved theorems are independently checked, via `#print axioms`, to depend only on
Lean's three standard axioms (`propext`, `Classical.choice`, `Quot.sound`) ---
i.e. none of them rest on an unproved `sorry` anywhere in their dependency chain. The Lean
source lives at `lattice-line-covers-lean/LatticeLineCoversLean/Basic.lean` in the same
workspace as this note; that project's own `STATE.md`/`TODO.md`/`LOGBOOK.md`
carry the full session-by-session history of the formalization effort.

= A picture

@fig-directions plots the first $10$, $20$, and $100$ directions realized by an actual
run of the construction (code in `code/`, targeting the golden-angle equidistributed
sequence $theta_k = k pi (sqrt(5) - 1) med "mod" med pi$), each direction shown as an antipodal pair of points
on the unit circle (a line's direction is unsigned) and colored by its position in the sequence.

#figure(
  image("artefacts/density_directions.png", width: 100%),
  caption: [Realized directions after $10$, $20$, and $100$ steps of the construction, colored by
  order (dark = early, light = late), with a thin path tracing consecutive jumps. The steering
  argument scatters rather than sweeps around the circle, since each target angle is chosen from an
  equidistributed sequence rather than visited in angular order.],
) <fig-directions>

#remark(name: "Verification, informal")[
  Both the splitting mechanism (Lemmas #thmref(<lem-splitting-coset>)--#thmref(<lem-splitting-partition>))
  and the sign-generality of Lemma #thmref(<lem-steering>) were checked by direct brute-force simulation
  (exhaustive crossing and coverage checks on finite windows up to $81 times 81$, including
  adversarial diagonal and sign-alternating schedules) before being trusted; an earlier version of
  the splitting step, without the primitivity safeguard built into
  Lemma #thmref(<lem-splitting-coset>), was found this way to be genuinely flawed rather than merely
  under-justified. The full argument was also read independently by a second reader working from
  the statement of the lemmas alone, who found a real gap in an earlier version of the density
  argument (restricting $s,t$ to be positive only reaches half of $#RP$, and existence of
  _some_ admissible move at each stage does not imply the ability to steer toward an
  _arbitrary_ target --- both addressed in the versions of
  Lemmas #thmref(<lem-splitting-coset>)--#thmref(<lem-splitting-partition>) and #thmref(<lem-steering>) given
  here). See the project logbook for the full history. This remark records the note's
  _informal_ verification history, predating and independent of the formal Lean verification
  recorded in the status notes above; the two are complementary, not redundant --- brute-force
  simulation and independent reading catch different classes of error than a machine-checked proof
  does, and vice versa.
]

= Related work

The reformulation via $phi_d$ and the resulting rigidity phenomenon (Lemma #thmref(<lem-rigidity>))
is the natural two-dimensional analogue of the classical theory of _covering systems of
congruences_, introduced by Erdős #bcite("Erdos1950") to show that a positive proportion of the
integers are not of the form $2^k + p$ for $p$ prime. A very close relative of our covering problem
--- covering $ZZ^2$ by finitely many finite-index _sublattices_ (necessarily containing the
origin, unlike the general affine cosets considered here) --- is studied by Cremona and Koymans
#bcite("CremonaKoymans2026"), who give it the same "projective/homogeneous covering congruences"
framing; their refinement machinery (splitting one lattice into several of prime-power relative
index) is structurally reminiscent of the splitting used here, one rank up.

A different classical result addresses a related but distinct question about how many directions a
covering needs. Corzatt #bcite("Corzatt1985") conjectured that if a _finite, convex_ set of lattice
points is covered by $n$ lines (with no constraint on where the lines may cross), the lines can
always be chosen to use at most four distinct slopes. Our setting is the opposite regime --- an
infinite, unbounded point set, with a crossing-avoidance constraint standing in for a bound on the
number of lines --- and correspondingly the answer is qualitatively different: densely many
directions are both necessary to consider and available.

The forbidden unimodular pairs of Lemma #thmref(<lem-rigidity>) are exactly the Farey-neighbor pairs of
slopes; see e.g. Hardy and Wright #bcite("HardyWright2008", detail: [Ch. III]) for the classical theory of
Farey sequences and the closely related Stern--Brocot tree. This is precisely the toolkit used in
the digital-geometry literature on digitized straight lines, where continued-fraction and
Farey-tree techniques describe digital approximations to a line of given (rational or irrational)
slope; see Kiselman #bcite("Kiselman2022"), and, for the continued-fraction approach specifically,
Uscka-Wehlou's dissertation #bcite("UsckaWehlou2009"), written under Kiselman's supervision at
Uppsala University.

#openproblem[
  Generalize Theorem #thmref(<thm-main>) to $ZZ^n$, $n >= 3$: cover $ZZ^n$ by hyperplanes (or lines, or
  general $k$-flats) such that no two of different direction meet at a lattice point, and determine
  which sets of directions can occur.
]

#heading(numbering: none)[Acknowledgements]

The results in this note --- the reformulation, the rigidity and coset lemmas, the recursive
construction, and both rounds of error-correction (one caught by numerical simulation, one by an
independent review) --- were found by Claude (Anthropic), working with Jan Snellman in an
interactive session, in the course of an idle conversation about covering the lattice by lines.
The additional references collected in the extended-references version of this note were located
and verified by Claude via web search. This more formal, Lean-status-annotated version was likewise
prepared by Claude, at Jan Snellman's request, once part of the argument had been formally verified.

#heading(numbering: none)[References]

#bibentry("CremonaKoymans2026")[
  J. E. Cremona and P. Koymans, _Lattice Coverings and Homogeneous Covering Congruences_,
  arXiv:2601.03212v2 (2026).
]

#bibentry("Corzatt1985")[
  C. E. Corzatt, _Covering convex sets of lattice points with straight lines_, Congressus
  Numerantium *50* (1985), 129--135.
]

#bibentry("Erdos1950")[
  P. Erdős, _On integers of the form $2^k + p$ and some related problems_, Summa Brasil.
  Math. *2* (1950), 113--123.
]

#bibentry("HardyWright2008")[
  G. H. Hardy and E. M. Wright, _An Introduction to the Theory of Numbers_, 6th ed., revised
  by D. R. Heath-Brown and J. H. Silverman, Oxford University Press, Oxford, 2008.
]

#bibentry("Kiselman2022")[
  C. O. Kiselman, _Elements of Digital Geometry, Mathematical Morphology, and Discrete
  Optimization_, World Scientific, Singapore, 2022.
]

#bibentry("UsckaWehlou2009")[
  H. Uscka-Wehlou, _Digital Lines, Sturmian Words, and Continued Fractions_, Ph.D. thesis,
  Uppsala Dissertations in Mathematics *65*, Uppsala University, 2009.
]
