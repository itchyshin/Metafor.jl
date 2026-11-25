# Metafor.jl

**Selected native Julia methods for meta-analysis, with carefully bounded comparisons to R `metafor`.**

Metafor.jl is an experimental, independently developed Julia port of selected methods from Wolfgang Viechtbauer's R package [`metafor`](https://www.metafor-project.org/). It is not the R package and does not reproduce its full API. See the [documentation site](https://itchyshin.github.io/Metafor.jl/), [getting-started guide](https://itchyshin.github.io/Metafor.jl/getting-started/), [method reference](https://itchyshin.github.io/Metafor.jl/reference/), and [compatibility table](COMPATIBILITY.md) for the current scope.

## Install and run

The package is experimental and is not registered. Clone the repository and instantiate its dependencies:

```sh
git clone https://github.com/itchyshin/Metafor.jl.git
cd Metafor.jl
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

Run a BCG model and generate its forest plot:

```sh
julia --project=. examples/bcg.jl --case=models
julia --project=. examples/bcg.jl --case=forest
```

The [tutorial overview](https://itchyshin.github.io/Metafor.jl/tutorials/) lists the 21 runnable topics and commands. The [comparison index](https://itchyshin.github.io/Metafor.jl/compare/) links to selected BCG, effect-size, dependent-effects, phylogeny, and table-adapter reports.

## Methods and limits

Current examples cover log risk ratios, odds ratios and risk differences from two-by-two counts; fixed-effect and REML models; moderator estimates, predictions, and forest-plot data; supplied sampling covariance; nested scalar random effects; a two-outcome model; a supplied phylogenetic correlation matrix; and table/formula adapters.

This is a small part of the R package. The compatibility table records verified fixture behavior, partial support, unsupported options, and intentional differences. One passing example establishes behavior only for its stated inputs and options.

## Project team and upstream credit

Project-intended maintainers are Shinichi Nakagawa, Yefeng Yang, and Wolfgang Viechtbauer. This describes the intended team and does not imply that anyone has accepted a role. Wolfgang Viechtbauer authored the separate upstream R package. This Julia port links to the [upstream project](https://www.metafor-project.org/), [R function reference](https://wviechtb.github.io/metafor/), and [BCG data documentation](https://wviechtb.github.io/metadat/reference/dat.bcg.html); its tutorial prose and plot are original.

Metafor.jl is licensed under [GPL-2.0-or-later](LICENSE). The package is experimental and unreleased.

## Documentation

Build the Documenter site from the repository root:

```sh
julia --project=docs docs/make.jl
```

Open `docs/build/index.html` after the build. Tutorial sources and package code live on `main`; the generated static site is served from the `gh-pages` branch.
