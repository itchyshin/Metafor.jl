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

- [x] G4: all three comparison pages match the Python checkout
  CHECK: cmp examples/bcg-comparison.html '/Users/z3437171/Dropbox/Github Local/metafor-py/examples/bcg-comparison.html' && cmp examples/phylogeny-comparison.html '/Users/z3437171/Dropbox/Github Local/metafor-py/examples/phylogeny-comparison.html' && cmp examples/dependent-comparison.html '/Users/z3437171/Dropbox/Github Local/metafor-py/examples/dependent-comparison.html' && echo HTML_MIRROR_OK
  EXPECT: HTML_MIRROR_OK
  EVIDENCE: exit=0; shell=/bin/sh; cwd=/Users/z3437171/Dropbox/Github Local/Metafor.jl; path=b12a711c1484/40 entries; output=HTML_MIRROR_OK
