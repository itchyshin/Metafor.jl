# Metafor.jl

**Native Julia methods inspired by the R package [`metafor`](https://www.metafor-project.org/).**

**Tutorials and examples:** [Metafor.jl documentation](https://itchyshin.github.io/Metafor.jl/) · [source repository](https://github.com/itchyshin/Metafor.jl)

Metafor.jl is an experimental, independently developed Julia port of selected meta-analysis methods. It is not the R package and does not reproduce its full API. The [compatibility table](COMPATIBILITY.md) records what is verified, partial, unsupported, or intentionally different.

The project follows the analysis structure familiar to R `metafor` users: calculate study effects, fit models, interpret uncertainty, and inspect plots. The core uses Julia arrays and structured result types, with table and formula adapters built around native design matrices.

## Start with the tutorials

The [documentation site](https://itchyshin.github.io/Metafor.jl/) contains 21 topic-focused tutorials and a differences guide. Start with the [BCG example](https://itchyshin.github.io/Metafor.jl/tutorials/bcg-effects/), then explore fixed and random effects, meta-regression, predictions, forest data, correlated effects, nested effects, a two-outcome model, phylogenetic boundary and interior fits, and table/formula adapter checks.

```sh
julia --project=. examples/bcg.jl
julia --project=. examples/dependent.jl
julia --project=. examples/phylogeny.jl
```

The tutorial overview lists the focused `--case` commands. Running these scripts without a selector rebuilds each complete comparison result. Install Julia dependencies first with `julia --project=. -e 'using Pkg; Pkg.instantiate()'`.

The [BCG comparison](https://itchyshin.github.io/Metafor.jl/assets/generated/comparisons/bcg-comparison.html), [dependent-effects comparison](https://itchyshin.github.io/Metafor.jl/assets/generated/comparisons/dependent-comparison.html), [phylogenetic comparison](https://itchyshin.github.io/Metafor.jl/assets/generated/comparisons/phylogeny-comparison.html), [effect-size comparison](https://itchyshin.github.io/Metafor.jl/assets/generated/comparisons/effect-size-comparison.html), and [table-adapter comparison](https://itchyshin.github.io/Metafor.jl/assets/generated/comparisons/table-adapter-comparison.html) show results across the supported fixtures. Fixture provenance and checksums live under [`reference/`](reference/).

GitHub Actions checks documentation builds from `main`. GitHub Pages serves the generated static site from the `gh-pages` branch; tutorial sources and package code remain on `main`.

Build the documentation locally:

```sh
julia --project=docs docs/make.jl
```

Open `docs/build/index.html` after the build. The published site is generated from this build and served from the repository's `gh-pages` branch.

## What the project covers

- Log risk ratios from 2×2 study counts, fixed-effect and REML models, and a latitude moderator.
- Mean and prediction intervals, row-aligned forest data, and an original SVG plot.
- Supplied sampling covariance matrices, nested scalar random effects, a two-outcome covariance model, and a supplied phylogenetic correlation matrix.
- Versioned R reference fixtures used for parity checks. Julia runs without R.

These methods cover a small part of the R package. See [`COMPATIBILITY.md`](COMPATIBILITY.md) before relying on a function or option. One passing example does not establish broader support.

## Relationship to R `metafor`

The upstream R package was written by Wolfgang Viechtbauer and provides a much broader collection of meta-analysis methods. This repository credits and links to the [official project site](https://www.metafor-project.org/), [R documentation](https://wviechtb.github.io/metafor/), and the [BCG dataset documentation](https://wviechtb.github.io/metadat/reference/dat.bcg.html). The tutorial pages use original prose and distinguish synthetic fixtures from published data. GPL notices are retained where derivative code or data require them.

Project-intended maintainers: Shinichi Nakagawa, Yefeng Yang, and Wolfgang Viechtbauer. This records the project's intended team and does not imply that anyone has accepted a role.

## License and status

This repository is experimental and unreleased. See [`LICENSE`](LICENSE) and each fixture's provenance record for license and data terms. The documentation site is served from `gh-pages`; no package release has been made.
