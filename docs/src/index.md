# Metafor.jl

**Meta-analysis methods in native Julia, with carefully bounded comparisons to R `metafor`.**

Metafor.jl is an experimental, independently developed port of selected methods from Wolfgang Viechtbauer's R package [`metafor`](https://www.metafor-project.org/). It is not the R package and does not reproduce its full API. The [compatibility reference](reference/index.md) states what has been checked and where support remains partial or absent.

### Start an analysis

Install the checkout, run a BCG example, and inspect the output in the [getting-started guide](getting-started.md).

### Browse the methods

Find exported functions, result fields, and supported options in the [reference](reference/index.md), or follow one of the [21 focused tutorials](tutorials/index.md).

### Inspect comparisons

The [R vs Julia comparison page](compare.md) links to the generated results for effect sizes, BCG models, dependent effects, phylogeny, and table inputs.

## Project and scope

The package follows a familiar workflow: calculate study effects, fit a model, interpret uncertainty, and inspect forest-plot data. Its core uses Julia arrays and structured result types; Tables.jl and StatsModels.jl adapters are available for tabular and formula inputs.

The current examples cover log risk ratios, odds ratios and risk differences from two-by-two counts; fixed-effect and REML models; meta-regression and predictions; supplied sampling covariance; nested scalar random effects; a two-outcome model; and supplied phylogenetic correlation. The [compatibility reference](reference/index.md) gives the specific limits. Passing one fixture does not establish broader compatibility.

**Project-intended maintainers:** Shinichi Nakagawa, Yefeng Yang, and Wolfgang Viechtbauer. This describes the intended project team and does not imply that anyone has accepted a role. Wolfgang Viechtbauer is the author of the upstream R package.

Metafor.jl is licensed under [GPL-2.0-or-later](https://github.com/itchyshin/Metafor.jl/blob/main/LICENSE). The [R `metafor` project](https://www.metafor-project.org/) and its [function documentation](https://wviechtb.github.io/metafor/) are separate projects.
