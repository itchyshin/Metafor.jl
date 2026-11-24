# Metafor.jl

A native Julia implementation of selected methods from Wolfgang Viechtbauer's R package **metafor**.

## Run the BCG example

From the repository root, run:

```sh
julia --project=. examples/bcg.jl
```

The example reads the shared raw-count fixture, computes log risk ratios, fits fixed-effect and REML models, fits an absolute-latitude moderator, calculates confidence and prediction intervals, and writes forest data plus an SVG plot under `examples/`.

The raw data are from `metadat::dat.bcg`, distributed under GPL (>= 2), with source and terms recorded in `reference/v1/PROVENANCE.md`. The upstream example is linked there. Tutorial prose and plots in this repository are original.

The intended maintainers are Shinichi Nakagawa, Yefeng Yang, and Wolfgang Viechtbauer. This records the project’s intended team; it does not imply that any person has accepted a role.

## Differences from R metafor

The package currently supports matrix-first univariate models, a StatsModels formula adapter for Tables.jl inputs, forest data, and an initial supplied-correlation phylogenetic model. It does not implement all effect sizes, all multivariate structures, small-sample inference, or the complete diagnostic suite. See `COMPATIBILITY.md` for the supported and unsupported options.
