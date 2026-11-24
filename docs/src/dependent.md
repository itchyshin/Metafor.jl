# How should we combine dependent effect estimates?

Several estimates from one study can share sampling error. Outcomes from the same study can also share a study-level effect. Treating all rows as independent can understate uncertainty. This tutorial asks how to fit those data when the sampling covariance is supplied.

The examples use original synthetic fixtures, not the Berkey dataset. The observations and covariance matrices are shared with metafor-py and were generated from a pinned R reference script. Their versions, seeds, checksum, and terms are recorded in `reference/dependent/v1/PROVENANCE.md`. The upstream [`rma.mv()` reference](https://wviechtb.github.io/metafor/reference/rma.mv.html) describes the corresponding R model family.

## Data

The fixture set contains three cases:

1. Eight estimates with a correlated sampling covariance matrix and an intercept plus moderator.
2. Thirty-six estimates nested in 12 studies and 36 study-specific effects. Local effect labels repeat across studies, so the nested key is `(study, effect)`.
3. Two outcomes from each of 20 studies, with correlated sampling errors and an unstructured study-level outcome covariance.

The third case is Berkey-style but synthetic. The rows, matrices, R outputs, package versions, and file checksums are stored under `reference/dependent/v1/`.

## Model

For retained rows, let `V` be the supplied sampling covariance, `X` the fixed-effect design, and `K_j` a known positive-semidefinite random-effect kernel. The marginal covariance and fitted coefficients are

```math
C = V + \sum_j \theta_j K_j,
\qquad
\hat\beta = (X^T C^{-1} X)^{-1} X^T C^{-1} y,
```

where every `theta_j` is nonnegative. The nested example uses indicator kernels `Z_study Z_study'` and `Z_effect Z_effect'`. The two-outcome example estimates a positive-semidefinite 2 × 2 covariance matrix within studies.

```julia
using Metafor, StatsModels: @formula

# Generalized least squares with the full known sampling covariance.
fit = fit_meta_cov(yi, V; X=X, method=:FE)

# Independent random intercepts. Encode nested identities as parent/local tuples.
groups = [study, collect(zip(study, effect_local))]
fit = fit_meta_nested(yi, V, groups; group_names=["study", "study/effect"],
                      X=X, method=:REML)

# Two outcomes with an unstructured study covariance.
fit = fit_meta_un(yi, V, study, outcome;
                  outcome_levels=["benefit", "harm"], method=:REML)
```

The table adapter uses StatsModels and Tables.jl: `fit_meta_cov_formula(table, @formula(yi ~ x), V; id=:row_id)`. It builds a matrix design, masks the same input rows on both axes of `V`, and returns the retained row IDs.

## Result type

The fitting functions return a `DependentMetaResult` with coefficient estimates and covariance, variance components, fitted marginal covariance, heterogeneity statistics, and retained row metadata.

```@docs
DependentMetaResult
```

## Interpretation

The pinned R reference estimates the nested intercept at 0.6034 and its moderator slope at 0.2770. The study and nested-effect variances are 0.1133 and 0.0221. In the bivariate case, the estimated benefit and harm means are 0.4856 and 0.2422; the estimated between-outcome covariance is 0.2316. These values describe only generated fixtures.

Run `julia --project examples/dependent.jl` from this repository to write the Julia estimates. From the Python checkout, `python tools/compare-dependent.py` runs both ports and writes `examples/dependent-comparison.html`. The current gate checks 42 estimates and 12 coefficient-covariance entries against the R reference.

## Differences from R metafor

The current implementation covers supplied positive-definite sampling covariance matrices, normal-normal GLS/REML, independent scalar PSD kernels, nested random intercepts, and a two-outcome unstructured study covariance. The listed fixtures match coefficients, standard errors, intervals, heterogeneity statistics, variance/covariance components, and coefficient covariance within the recorded tolerances.

This remains partial `rma.mv()` coverage. AR/CAR, spatial, GEN, phylogenetic tree estimation, estimated sampling correlations, unstructured models with three or more outcomes, small-sample inference, profile intervals, and the full diagnostic suite are unsupported. Warning categories and error text can differ from R. See `COMPATIBILITY.md` for the function-by-function status table.
