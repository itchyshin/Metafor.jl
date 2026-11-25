# Tutorials and comparisons

Each tutorial asks a question, introduces the fixture and model, then interprets the results. The examples use native Julia package functions. Matching Python cases are in the `metafor-py` checkout.

Run `julia --project=. -e 'using Pkg; Pkg.instantiate()'` once to install dependencies. Comparison artifacts are generated in `examples/` and copied into the built site.

| Page | Question | Runnable Julia command | Comparison |
|---|---|---|---|
| [BCG effect sizes](bcg-effects.md) | How do raw counts become log risk ratios? | `julia --project=. examples/bcg.jl --case=effects` | [R, Julia, Python](../assets/generated/comparisons/bcg-comparison.html) |
| [Fixed and random effects](bcg-models.md) | How do FE and REML pooled estimates differ? | `julia --project=. examples/bcg.jl --case=models` | [R, Julia, Python](../assets/generated/comparisons/bcg-comparison.html) |
| [Meta-regression](bcg-moderator.md) | How does latitude relate to the estimated effect? | `julia --project=. examples/bcg.jl --case=moderator` | [R, Julia, Python](../assets/generated/comparisons/bcg-comparison.html) |
| [Predictions](bcg-prediction.md) | What are the fitted means and intervals at selected latitudes? | `julia --project=. examples/bcg.jl --case=prediction` | [R, Julia, Python](../assets/generated/comparisons/bcg-comparison.html) |
| [Forest plot data](bcg-forest.md) | Which quantities feed the forest plot? | `julia --project=. examples/bcg.jl --case=forest` | [R, Julia, Python](../assets/generated/comparisons/bcg-comparison.html) |
| [Correlated sampling errors](dependent-gls.md) | How does a supplied covariance matrix change GLS inference? | `julia --project=. examples/dependent.jl --case=gls` | [R, Julia, Python](../assets/generated/comparisons/dependent-comparison.html) |
| [Nested effects](dependent-nested.md) | How are study and effect-level variances represented? | `julia --project=. examples/dependent.jl --case=nested` | [R, Julia, Python](../assets/generated/comparisons/dependent-comparison.html) |
| [Two outcomes](dependent-bivariate.md) | How are correlated outcomes modeled within studies? | `julia --project=. examples/dependent.jl --case=bivariate` | [R, Julia, Python](../assets/generated/comparisons/dependent-comparison.html) |
| [Phylogenetic boundary and interior cases](phylogeny.md) | What changes when species share a supplied correlation? | `julia --project=. examples/phylogeny.jl --case=boundary`<br>`julia --project=. examples/phylogeny.jl --case=interior` | [R, Julia, Python](../assets/generated/comparisons/phylogeny-comparison.html) |
| [Differences from R metafor](differences.md) | Which functions and options are verified or differ? | See the tutorials | `COMPATIBILITY.md` |

| [Odds ratios](odds-ratio.md) | How do counts become a log odds ratio? | `julia --project=. examples/effect-sizes.jl --case=odds-ratio` | [R, Julia, Python](../assets/generated/comparisons/effect-size-comparison.html) |
| [Risk differences](risk-difference.md) | How do counts become an absolute probability contrast? | `julia --project=. examples/effect-sizes.jl --case=risk-difference` | [R, Julia, Python](../assets/generated/comparisons/effect-size-comparison.html) |
| [Choosing a scale](effect-scale.md) | Why do effect magnitudes differ by scale? | `julia --project=. examples/effect-sizes.jl --case=scale` | [R, Julia, Python](../assets/generated/comparisons/effect-size-comparison.html) |
| [Zero-cell policies](zero-cell-policies.md) | How do correction choices change results? | `julia --project=. examples/effect-sizes.jl --case=zero-correction` | [R, Julia, Python](../assets/generated/comparisons/effect-size-comparison.html) |
| [Missing observations](missing-rows.md) | Are incomplete studies kept aligned? | `julia --project=. examples/effect-sizes.jl --case=missing` | [R, Julia, Python](../assets/generated/comparisons/effect-size-comparison.html) |
| [Table and formula adapter](table-adapter.md) | Does a missing moderator row stay aligned across inputs? | `julia --project=. examples/bcg.jl --case=table-adapter` | [Python, Julia](../assets/generated/comparisons/table-adapter-comparison.html) |
| [Pooling log odds ratios](odds-ratio-models.md) | How do FE and REML summaries differ? | `julia --project=. examples/effect-sizes.jl --case=odds-ratio` | [R, Julia, Python](../assets/generated/comparisons/effect-size-comparison.html) |
| [Pooling risk differences](risk-difference-models.md) | How does heterogeneity look on an absolute scale? | `julia --project=. examples/effect-sizes.jl --case=risk-difference` | [R, Julia, Python](../assets/generated/comparisons/effect-size-comparison.html) |
| [Phylogenetic boundary](phylo-boundary.md) | What does a zero variance boundary mean? | `julia --project=. examples/phylogeny.jl --case=boundary` | [R, Julia, Python](../assets/generated/comparisons/phylogeny-comparison.html) |
| [Phylogenetic interior fit](phylo-interior.md) | What changes when phylogenetic variance is positive? | `julia --project=. examples/phylogeny.jl --case=interior` | [R, Julia, Python](../assets/generated/comparisons/phylogeny-comparison.html) |
| [Phylogenetic matrix labels](phylo-labels.md) | Why check species labels and order? | `julia --project=. examples/phylogeny.jl --case=interior` | [R, Julia, Python](../assets/generated/comparisons/phylogeny-comparison.html) |
Omit `--case` from the BCG or dependent command to regenerate the complete comparison outputs. The phylogenetic commands exercise separate zero-boundary and interior variance cases.

```@contents
Pages = ["bcg-effects.md", "bcg-models.md", "bcg-moderator.md", "bcg-prediction.md", "bcg-forest.md", "dependent-gls.md", "dependent-nested.md", "dependent-bivariate.md", "phylogeny.md", "differences.md", "odds-ratio.md", "risk-difference.md", "effect-scale.md", "zero-cell-policies.md", "missing-rows.md", "odds-ratio-models.md", "risk-difference-models.md", "phylo-boundary.md", "phylo-interior.md", "phylo-labels.md", "table-adapter.md"]
Depth = 1
```
