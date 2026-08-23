#!/bin/bash
# Assemble an arXiv submission folder (and tarball) for this paper.
#
#     ./arxiv/make-arxiv-package.sh
#
# Produces arxiv/lattice-line-covers-arxiv-<date>.tar.gz (upload this) AND a plain,
# browsable directory arxiv/lattice-line-covers-arxiv-<date>/ with the same contents
# (look at this). Both are gitignored: derived from the repository, so committing
# either would duplicate the .tex/figures and let the copies drift apart. Rebuild
# instead -- that is the whole point of this script.
#
# WHAT GOES IN, AND WHY
# ---------------------
# arXiv compiles what it finds at the top level and leaves anything under anc/
# strictly alone (ancillary files: offered for download beside the paper, never
# compiled, never rendered). So:
#
#   lattice_line_covers_extended.tex   the manuscript -- arXiv wants LaTeX
#   lattice_line_covers_extended.bib   companion BibTeX database, Jan's explicit
#                                      request (2026-08-23) -- NOT wired into the
#                                      compile (see DELIBERATELY EXCLUDED below for
#                                      why); arXiv ignores files the .tex doesn't
#                                      reference, so this just rides along for
#                                      reference/reuse
#   figures/*.png                      every figure the .tex actually includes
#                                      (auto-detected below, not a fixed list)
#   anc/lattice_line_covers_pedantic.typ
#                                      the Typst working draft that was the real
#                                      source of truth while the Lean proof was
#                                      being written -- included because the
#                                      formalization follows ITS structure, not
#                                      the published article's
#   anc/lean/                          the complete formalization, 18 files, 168K
#   anc/README.md                      explains the above to a reader who has
#                                      only the arXiv page
#
# The Lean tree is included in full because it is small. Had it been large, the
# right move would have been a pointer to the GitLab repo and the Zenodo DOI
# instead -- both are cited in anc/README.md regardless, since they are the
# citable, versioned homes.
#
# DELIBERATELY EXCLUDED
#   .bbl        not needed: the paper uses an inline thebibliography, so there is
#               no BibTeX pass for arXiv to fail to run -- the .bib above rides
#               along as a reference copy only, never \bibliography{}-included
#   .aux .log .out .synctex.gz   build droppings; arXiv rejects some outright
#   figures/chessboard-figure.*  not referenced by the .tex (it illustrates the
#               README, not the paper)
#   verification-code/, references/  not part of the paper; they live in the
#               GitLab repo and the Zenodo deposit
set -euo pipefail
cd "$(dirname "$0")/.."

STAMP=$(date +%Y-%m-%d)
OUT="arxiv/lattice-line-covers-arxiv-${STAMP}.tar.gz"
FOLDER="arxiv/lattice-line-covers-arxiv-${STAMP}"
BUILD=$(mktemp -d)
trap 'rm -rf "$BUILD"' EXIT

echo "==> assembling"
mkdir -p "$BUILD/figures" "$BUILD/anc"

cp article/lattice_line_covers_extended.tex "$BUILD/"
cp arxiv/lattice_line_covers_extended.bib "$BUILD/"

# Copy exactly the figures the .tex includes -- not the whole directory, so an
# unused figure can never silently bloat the upload.
grep -oE '\\includegraphics(\[[^]]*\])?\{[^}]*\}' article/lattice_line_covers_extended.tex \
  | sed -E 's/.*\{(.*)\}/\1/' | sort -u | while read -r fig; do
      src="article/$fig"
      [ -f "$src" ] || { echo "MISSING figure: $src" >&2; exit 1; }
      cp "$src" "$BUILD/$fig"
      echo "    figure: $fig"
    done

cp article/lattice_line_covers_pedantic.typ "$BUILD/anc/"
mkdir -p "$BUILD/anc/lean"
git ls-files lean/ | while read -r f; do
  mkdir -p "$BUILD/anc/$(dirname "$f")"
  cp "$f" "$BUILD/anc/$f"
done
cp arxiv/anc-README.md "$BUILD/anc/README.md"

echo "==> test-compiling (3 passes, exactly as arXiv would need)"
( cd "$BUILD" && for i in 1 2 3; do
    pdflatex -interaction=batchmode -halt-on-error lattice_line_covers_extended.tex >/dev/null 2>&1 \
      || { echo "PASS $i FAILED -- see $BUILD/lattice_line_covers_extended.log" >&2; trap - EXIT; exit 1; }
  done )

if grep -q "Rerun to get cross-references right" "$BUILD/lattice_line_covers_extended.log"; then
  echo "WARNING: LaTeX still wants another pass after three" >&2
fi

n=$(pdftotext "$BUILD/lattice_line_covers_extended.pdf" - 2>/dev/null | grep -c '??' || true)
if [ "$n" -gt 0 ]; then
  echo "FAILED: compiled PDF has $n unresolved cross-reference(s)" >&2
  exit 1
fi
echo "    compiled clean, 0 unresolved cross-references"

# Strip build products -- arXiv wants sources, and rejects some of these.
rm -f "$BUILD"/*.aux "$BUILD"/*.log "$BUILD"/*.out "$BUILD"/*.synctex.gz "$BUILD"/*.pdf

echo "==> packing"
tar czf "$OUT" -C "$BUILD" .

echo "==> leaving a browsable copy"
rm -rf "$FOLDER"
mkdir -p "$FOLDER"
cp -r "$BUILD"/. "$FOLDER"/

echo
echo "    $OUT  ($(du -h "$OUT" | cut -f1))"
echo "    $FOLDER/  (same contents, unpacked)"
echo
tar tzf "$OUT" | sed 's/^/      /'
echo
echo "Upload the tarball to arXiv -- it will compile the .tex and offer everything"
echo "under anc/ as ancillary downloads. Browse the folder for a quick look first."
