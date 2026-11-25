# Reference

This reference describes the exported API and the scope currently represented in the package. Function-level support is experimental: consult the notes below and the [compatibility table](../assets/generated/references/COMPATIBILITY.md) before relying on an option.

| Topic | Main entry points | Coverage |
|---|---|---|
| [Effect sizes](effect-sizes.md) | `escalc_rr`, `escalc_or`, `escalc_rd` | Selected two-by-two measures and correction policies |
| [Univariate models](univariate.md) | `fit_meta`, `fit_meta_formula` | Fixed-effect and REML fits; matrix and formula input |
| [Prediction and forest data](prediction.md) | `predict`, `forest_plot_data` | Normal mean and REML new-study intervals; plot data |
| [Dependent effects](dependent.md) | `fit_meta_cov`, `fit_meta_nested`, `fit_meta_un` | Supplied covariance and named fixture structures |
| [Phylogeny](phylogeny.md) | `fit_phylo` | Supplied, labelled correlation matrices on checked fixtures |

## Result objects

`MetaResult` stores coefficients (`beta`), their covariance matrix, heterogeneity summaries (`tau2`, `q`, `i2`, `h2`), convergence status, method, and retained row indices. `PredictionResult` stores predictions, standard errors, confidence limits, and (for REML) prediction limits. Formula/table fits return `TableMetaResult`, which wraps the model result and retains row IDs, row indices, design-column names, and formula.

## Scope and attribution

Metafor.jl is an independent Julia implementation of selected methods inspired by R [`metafor`](https://www.metafor-project.org/). Wolfgang Viechtbauer authored the upstream R package. Project-intended maintainers for this Julia port are Shinichi Nakagawa, Yefeng Yang, and Wolfgang Viechtbauer; this does not state that any person has accepted a role.
