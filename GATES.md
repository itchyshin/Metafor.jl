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

- [x] G5: ten tutorial pages build and the comparison pages are linked into the generated Julia site
  CHECK: python3 -c "from pathlib import Path; p=Path('docs/build/tutorials'); names=['bcg-effects','bcg-models','bcg-moderator','bcg-prediction','bcg-forest','dependent-gls','dependent-nested','dependent-bivariate','phylogeny','differences']; c=Path('docs/build/assets/generated/comparisons'); assert all((p/n/'index.html').is_file() for n in names); assert all((c/n).is_file() for n in ['bcg-comparison.html','dependent-comparison.html','phylogeny-comparison.html']); print('JULIA_TUTORIALS_AND_COMPARISONS_OK')"
  EXPECT: JULIA_TUTORIALS_AND_COMPARISONS_OK
  EVIDENCE: exit=0; shell=/bin/sh; cwd=/Users/z3437171/Dropbox/Github Local/Metafor.jl; path=b12a711c1484/40 entries; output=JULIA_TUTORIALS_AND_COMPARISONS_OK

- [x] G6: the Julia GitHub Pages workflow parses as YAML
  CHECK: ruby -e 'require "yaml"; YAML.load_file(".github/workflows/pages.yml"); puts "PAGES_WORKFLOW_YAML_OK"'
  EXPECT: PAGES_WORKFLOW_YAML_OK
  EVIDENCE: exit=0; shell=/bin/sh; cwd=/Users/z3437171/Dropbox/Github Local/Metafor.jl; path=b12a711c1484/40 entries; output=PAGES_WORKFLOW_YAML_OK
