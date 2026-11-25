# Metafor.jl: selected native Julia methods for meta-analysis

Metafor.jl is an experimental Julia port of selected methods from Wolfgang Viechtbauer's R package [`metafor`](https://www.metafor-project.org/). It is a separate implementation, not the R package or a complete replacement. The compatibility table records scope by function and option.

The project follows the R package's question-to-analysis path: calculate study effects, fit a model, interpret uncertainty, and inspect plots. Its core uses native Julia arrays and structured results, with table and formula adapters built around explicit design matrices.

The tutorials use pinned R reference inputs shared with [metafor-py](https://github.com/itchyshin/metafor-py). Their wording and plots are original. The [BCG](assets/generated/comparisons/bcg-comparison.html), [dependent-effects](assets/generated/comparisons/dependent-comparison.html), and [phylogenetic](assets/generated/comparisons/phylogeny-comparison.html) comparison pages show R, Julia, and Python results side by side.

## Start with an analysis

Follow the [tutorial overview](tutorials/index.md) from raw study counts to effect sizes, pooled models, a latitude moderator, predictions, and forest-plot data. Then continue to correlated and nested effects, two outcomes, and the supplied-correlation phylogenetic examples. Every page includes the runnable command and interpretation.

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

The [Metafor.jl source repository](https://github.com/itchyshin/Metafor.jl) contains the implementation, tests, fixtures, and this site's source.

```@contents
Pages = ["tutorials/index.md"]
Depth = 2
```

The [Metafor.jl source repository](https://github.com/itchyshin/Metafor.jl) contains the implementation and fixtures. The companion [Python documentation](https://itchyshin.github.io/metafor-py/) follows the same fixtures and analysis stages.
