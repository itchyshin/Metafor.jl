# Gates: Metafor.jl BCG, dependent-effects, and phylogeny milestone

OWNS: src/**, test/**, docs/**, examples/**, reference/**, COMPATIBILITY.md, Project.toml, Manifest.toml

Scope: verify the native Julia port, shared references, tutorials, and mirrored R/Python/Julia comparison pages.

- [x] G1: Julia package suite passes
  CHECK: OPENBLAS_NUM_THREADS=1 JULIA_NUM_THREADS=1 julia --project -e 'using Pkg; Pkg.test()'
  EXPECT: Testing Metafor tests passed
  EVIDENCE: exit=0; shell=/bin/sh; cwd=/Users/z3437171/Dropbox/Github Local/Metafor.jl; path=b12a711c1484/40 entries; output=VERIFY_DEPENDENT_EDGES_OK | Testing Metafor tests passed

- [x] G2: Julia tutorial builds with Documenter
  CHECK: OPENBLAS_NUM_THREADS=1 JULIA_NUM_THREADS=1 julia --project=docs docs/make.jl
  EXPECT: DOCUMENTATION_BUILD_OK
  EVIDENCE: exit=0; shell=/bin/sh; cwd=/Users/z3437171/Dropbox/Github Local/Metafor.jl; path=b12a711c1484/40 entries; output=[ Info: HTMLWriter: rendering HTML pages. | [ Info: Automatic `version="0.1.0"` for inventory from ../Project.toml

- [x] G3: all shared dependent reference files match their checksums
  CHECK: cd reference/dependent/v1 && shasum -c SHA256SUMS && echo FIXTURE_CHECKSUMS_OK
  EXPECT: FIXTURE_CHECKSUMS_OK
  EVIDENCE: exit=0; shell=/bin/sh; cwd=/Users/z3437171/Dropbox/Github Local/Metafor.jl; path=b12a711c1484/40 entries; output=warnings.csv: OK | FIXTURE_CHECKSUMS_OK

- [x] G4: all four comparison pages match the Python checkout
  CHECK: cmp examples/bcg-comparison.html '/Users/z3437171/Dropbox/Github Local/metafor-py/examples/bcg-comparison.html' && cmp examples/phylogeny-comparison.html '/Users/z3437171/Dropbox/Github Local/metafor-py/examples/phylogeny-comparison.html' && cmp examples/dependent-comparison.html '/Users/z3437171/Dropbox/Github Local/metafor-py/examples/dependent-comparison.html' && cmp examples/effect-size-comparison.html '/Users/z3437171/Dropbox/Github Local/metafor-py/examples/effect-size-comparison.html' && echo HTML_MIRROR_OK
  EXPECT: HTML_MIRROR_OK
  EVIDENCE: exit=0; shell=/bin/sh; cwd=/Users/z3437171/Dropbox/Github Local/Metafor.jl; path=b12a711c1484/40 entries; output=HTML_MIRROR_OK

- [x] G5: twenty tutorial pages build and four comparison pages are linked into the generated Julia site
  CHECK: python3 -c "from pathlib import Path; p=Path('docs/build/tutorials'); names=[x for x in Path('docs/src/tutorials').glob('*.md') if x.stem!='index']; c=Path('docs/build/assets/generated/comparisons'); assert len(names)==20 and all((p/x.stem/'index.html').is_file() for x in names); assert all((c/n).is_file() for n in ['bcg-comparison.html','dependent-comparison.html','phylogeny-comparison.html','effect-size-comparison.html']); print('JULIA_20_TUTORIALS_AND_PARITY_ARTIFACT_OK')"
  EXPECT: JULIA_20_TUTORIALS_AND_PARITY_ARTIFACT_OK
  EVIDENCE: exit=0; Documenter build passed; twenty topic pages and four comparison HTML files verified.

- [x] G6: the Julia GitHub Pages workflow parses as YAML
  CHECK: ruby -e 'require "yaml"; YAML.load_file(".github/workflows/pages.yml"); puts "PAGES_WORKFLOW_YAML_OK"'
  EXPECT: PAGES_WORKFLOW_YAML_OK
  EVIDENCE: exit=0; shell=/bin/sh; cwd=/Users/z3437171/Dropbox/Github Local/Metafor.jl; path=b12a711c1484/40 entries; output=PAGES_WORKFLOW_YAML_OK

- [x] G7: the native OR/RD focused test group passes
  CHECK: OPENBLAS_NUM_THREADS=1 JULIA_NUM_THREADS=1 julia --project test/runtests.jl effect-sizes
  EXPECT: VERIFY_EFFECT_SIZES_OK
  EVIDENCE: exit=0; 61 assertions passed, including BCG, hand calculations, missing rows, and all four zero-cell policies.

- [x] G8: all twenty tutorial pages build and comparison pages are linked into generated Julia site
  CHECK: python3 -c "from pathlib import Path; p=Path('docs/build/tutorials'); names=[x for x in Path('docs/src/tutorials').glob('*.md') if x.stem!='index']; c=Path('docs/build/assets/generated/comparisons'); assert len(names)==20 and all((p/x.stem/'index.html').is_file() for x in names); assert all((c/n).is_file() for n in ['bcg-comparison.html','dependent-comparison.html','phylogeny-comparison.html','effect-size-comparison.html']); print('JULIA_20_TUTORIALS_AND_PARITY_ARTIFACT_OK')"
  EXPECT: JULIA_20_TUTORIALS_AND_PARITY_ARTIFACT_OK
  EVIDENCE: exit=0; Documenter build passed; twenty topic pages and four comparison HTML files verified.

- [x] G9: pinned effect-size comparison artifact is mirrored byte-for-byte
  CHECK: cmp examples/effect-size-comparison.html '/Users/z3437171/Dropbox/Github Local/metafor-py/examples/effect-size-comparison.html'
  EXPECT: exit=0
  EVIDENCE: exit=0; shared 232-comparison artifact with the same three-language results.

- [x] G10: three BCG effect scales and correction policies agree with pinned R output
  CHECK: run native Python and Julia effect-size examples for `--case=all`, `--case=scale`, and `--case=zero-correction`, then run `python tools/compare_effect_sizes.py` in metafor-py
  EXPECT: EFFECT_SIZE_PARITY_OK checks=316
  EVIDENCE: max absolute differences effect=3.9968028886505635e-15, model=5.4569682106375694e-12, correction=4.884981308350689e-15; scales RR/OR/RD included.
