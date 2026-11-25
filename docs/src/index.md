# Metafor.jl: selected native Julia methods for meta-analysis

Metafor.jl is an experimental Julia port of selected methods from Wolfgang Viechtbauer's R package [`metafor`](https://www.metafor-project.org/). It is a separate implementation, not the R package or a complete replacement. The compatibility table records scope by function and option.

The project follows the R package's question-to-analysis path: calculate study effects, fit a model, interpret uncertainty, and inspect plots. Its core uses native Julia arrays and structured results, with table and formula adapters built around explicit design matrices.

The tutorials use pinned R reference inputs shared with [metafor-py](https://github.com/itchyshin/metafor-py). Their wording and plots are original. The [BCG](assets/generated/comparisons/bcg-comparison.html), [dependent-effects](assets/generated/comparisons/dependent-comparison.html), [phylogenetic](assets/generated/comparisons/phylogeny-comparison.html), and [effect-size](assets/generated/comparisons/effect-size-comparison.html) comparison pages show R, Julia, and Python results side by side. A separate [table-adapter comparison](assets/generated/comparisons/table-adapter-comparison.html) checks row alignment and numeric design matrices in Julia and Python.

## Start with an analysis

Follow 21 focused tutorials from raw study counts to effect sizes, pooled models, a latitude moderator, predictions, and forest-plot data. Continue to correlated and nested effects, two outcomes, and supplied-correlation phylogenetic examples. Each topic page includes a runnable command and interpretation. Start at the [tutorial overview](tutorials/index.md). Install dependencies from the checkout with `julia --project=. -e 'using Pkg; Pkg.instantiate()'`; the package remains experimental and unregistered.

## Choose a starting point

| If you want to… | Start here |
|---|---|
| Analyze two-group counts | [BCG effect sizes](tutorials/bcg-effects.md) |
| Model dependent outcomes | [Correlated sampling errors](tutorials/dependent-gls.md) |
| Use a species correlation | [Supplied phylogenetic correlation](tutorials/phylogeny.md) |
| Keep formula and matrix rows aligned | [Table and formula adapter](tutorials/table-adapter.md) |


!!! note "Experimental status"
    This package is unreleased and covers a selected subset. A passing example establishes parity only for its named fixture, options, and outputs.

## Current scope

- Log risk ratios from 2×2 counts, fixed-effect and REML models, and a latitude moderator.
- Mean and new-study prediction intervals, row-aligned forest data, and an original SVG.
- Supplied sampling covariance, nested scalar random effects, two-outcome covariance, and supplied phylogenetic correlation.
- Versioned R reference fixtures. Julia runs without R.

The package does not implement the full R API. See the [compatibility table](assets/generated/references/COMPATIBILITY.md) for verified, partial, unsupported, and intentional differences.

Project-intended maintainers are Shinichi Nakagawa, Yefeng Yang, and Wolfgang Viechtbauer. This records the intended project team; it does not imply that anyone has accepted a role.

The upstream R project is [metafor-project.org](https://www.metafor-project.org/); its manuals and function references are at [wviechtb.github.io/metafor](https://wviechtb.github.io/metafor/).

The [Metafor.jl source repository](https://github.com/itchyshin/Metafor.jl) contains the implementation, tests, fixtures, and this site's source. Its companion [Python site](https://itchyshin.github.io/metafor-py/) follows the same analysis stages.

```@contents
Pages = ["tutorials/index.md"]
Depth = 2
```
