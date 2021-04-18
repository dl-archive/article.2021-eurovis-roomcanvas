#!/usr/bin/env bash
# Reproducible build matching the original Overleaf compiles (2021).
# Requires podman (or docker: export ENGINE=docker).
#   ./build.sh          → build/main-cr.pdf                                    (paper)
#   ./build.sh slides   → build/slides/eurovis-2021-roomcanvas-presentation.pdf (talk slides)
# Paper: TeX Live 2019 (microtype 2.7d) reproduces koenig2021-roomcanvas-as-submitted.pdf pixel-identically;
#        TL2020/2021 (microtype >= 2.8) reflow three paragraphs.
# Slides: TeX Live 2020 (pdfTeX 1.40.21, as the original koenig2021-roomcanvas-slides.pdf).
# openout_any=a: let bibtex write into the absolute output directory /out.
set -euo pipefail
cd "$(dirname "$0")"
ENGINE=${ENGINE:-podman}
if [[ ${1:-} == slides ]]; then
  IMAGE=docker.io/texlive/texlive:TL2020-historic dir=slides out=build/slides main=eurovis-2021-roomcanvas-presentation.tex
else
  IMAGE=docker.io/texlive/texlive:TL2019-historic dir=src out=build main=main-cr.tex
fi
mkdir -p "$out"
"$ENGINE" run --rm -e openout_any=a -v "$PWD/$dir:/src:ro,Z" -v "$PWD/$out:/out:Z" -w /src "$IMAGE" \
  latexmk -pdf -interaction=nonstopmode -outdir=/out "$main"
