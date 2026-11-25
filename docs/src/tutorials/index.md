# Tutorials and comparisons

Each tutorial asks a question, introduces the fixture and model, then interprets the results. The examples use native Julia package functions. Matching Python cases are in the `metafor-py` checkout.

Run `julia --project=. -e 'using Pkg; Pkg.instantiate()'` once to install dependencies. Comparison artifacts are local files in `examples/` and have not been deployed.

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

Omit `--case` from the BCG or dependent command to regenerate the complete comparison outputs. The phylogenetic commands exercise separate zero-boundary and interior variance cases.

```@contents
Pages = ["bcg-effects.md", "bcg-models.md", "bcg-moderator.md", "bcg-prediction.md", "bcg-forest.md", "dependent-gls.md", "dependent-nested.md", "dependent-bivariate.md", "phylogeny.md", "differences.md"]
Depth = 1
```
