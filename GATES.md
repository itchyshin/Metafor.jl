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

- [x] G5: twenty-one tutorial pages build and five comparison pages are linked into the generated Julia site
  CHECK: python3 -c "from pathlib import Path; p=Path('docs/build/tutorials'); names=[x for x in Path('docs/src/tutorials').glob('*.md') if x.stem!='index']; c=Path('docs/build/assets/generated/comparisons'); assert len(names)==21 and all((p/x.stem/'index.html').is_file() for x in names); assert all((c/n).is_file() for n in ['bcg-comparison.html','dependent-comparison.html','phylogeny-comparison.html','effect-size-comparison.html','table-adapter-comparison.html']); print('JULIA_21_TUTORIALS_AND_FIVE_PARITY_ARTIFACTS_OK')"
  EXPECT: JULIA_21_TUTORIALS_AND_FIVE_PARITY_ARTIFACTS_OK
  EVIDENCE: exit=0; shell=/bin/sh; cwd=/Users/z3437171/Dropbox/Github Local/Metafor.jl; path=b12a711c1484/40 entries; output=JULIA_21_TUTORIALS_AND_FIVE_PARITY_ARTIFACTS_OK

- [x] G6: the Julia documentation-check workflow parses as YAML
  CHECK: ruby -e 'require "yaml"; YAML.load_file(".github/workflows/docs.yml"); puts "PAGES_WORKFLOW_YAML_OK"'
  EXPECT: PAGES_WORKFLOW_YAML_OK
  EVIDENCE: exit=0; shell=/bin/sh; cwd=/Users/z3437171/Dropbox/Github Local/Metafor.jl; path=b12a711c1484/40 entries; output=PAGES_WORKFLOW_YAML_OK

- [x] G7: the native table/formula adapter test group passes
  CHECK: OPENBLAS_NUM_THREADS=1 JULIA_NUM_THREADS=1 julia --project test/runtests.jl bcg-adapters
  EXPECT: VERIFY_BCG_ADAPTERS_OK
  EVIDENCE: exit=0; shell=/bin/sh; cwd=/Users/z3437171/Dropbox/Github Local/Metafor.jl; path=b12a711c1484/40 entries; output=BCG table and forest adapters |   16     16  7.1s | VERIFY_BCG_ADAPTERS_OK

- [x] G8: pinned effect-size comparison artifact is mirrored byte-for-byte
  CHECK: cmp examples/effect-size-comparison.html '/Users/z3437171/Dropbox/Github Local/metafor-py/examples/effect-size-comparison.html' && echo EFFECT_SIZE_HTML_MIRROR_OK
  EXPECT: EFFECT_SIZE_HTML_MIRROR_OK
  EVIDENCE: exit=0; shell=/bin/sh; cwd=/Users/z3437171/Dropbox/Github Local/Metafor.jl; path=b12a711c1484/40 entries; output=EFFECT_SIZE_HTML_MIRROR_OK

- [x] G9: three BCG effect scales and correction policies agree with pinned R output
  CHECK: julia --project examples/effect-sizes.jl --case=all && julia --project examples/effect-sizes.jl --case=scale && julia --project examples/effect-sizes.jl --case=zero-correction && (cd ../metafor-py && PYTHONPATH=src python examples/effect-sizes.py --case=all && PYTHONPATH=src python examples/effect-sizes.py --case=scale && PYTHONPATH=src python examples/effect-sizes.py --case=zero-correction && python tools/compare_effect_sizes.py)
  EXPECT: EFFECT_SIZE_PARITY_OK checks=316
  EVIDENCE: exit=0; shell=/bin/sh; cwd=/Users/z3437171/Dropbox/Github Local/Metafor.jl; path=b12a711c1484/40 entries; output=EFFECT_SIZE_EXAMPLE_OK case=zero-correction rows=16 /Users/z3437171/Dropbox/Github Local/metafor-py/examples/generated/effect-sizes/python-zero-correction.csv | EFFECT_SIZE_PARITY_OK checks=316 max={'effect': 3.9968028886505635e-15, 'model'


- [x] G10: the Julia table/formula comparison artifact matches the Python checkout
  CHECK: cmp examples/table-adapter-comparison.html '../metafor-py/examples/table-adapter-comparison.html' && echo TABLE_ADAPTER_HTML_MIRROR_OK
  EXPECT: TABLE_ADAPTER_HTML_MIRROR_OK
  EVIDENCE: exit=0; shell=/bin/sh; cwd=/Users/z3437171/Dropbox/Github Local/Metafor.jl; path=b12a711c1484/40 entries; output=TABLE_ADAPTER_HTML_MIRROR_OK
