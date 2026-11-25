# Dependent effects

The dependent-effects functions accept supplied sampling covariance and covariance kernels. Their coverage is limited to the structures and fixtures named here; this is not general support for all `rma.mv()` models.

- `fit_meta_cov(yi, V; X=nothing, components=nothing, method=:REML, design_columns=nothing)` fits with a supplied sampling covariance and optional scalar variance-component kernels.
- `fit_meta_nested(yi, V, groups; group_names=nothing, X=nothing, method=:REML, design_columns=nothing)` constructs nested indicator kernels from grouping vectors. `group_names` labels the grouping levels, while `design_columns` supplies coefficient names for `X`; inner labels should include parent identity (for example tuples) where labels repeat between groups.
- `fit_meta_un(yi, V, study, outcome; outcome_levels, method=:REML)` fits the checked two-outcome unstructured within-study covariance case.
- `fit_meta_cov_formula(data, formula, V; id=nothing, components=nothing, method=:REML)` combines formula/table input with a supplied sampling covariance and aligns retained rows on both axes.

Supplied positive-definite covariance, a nested scalar case, and a synthetic two-outcome case have fixture-level checks. Other multivariate structures, three or more outcomes for the unstructured model, small-sample tests, and profile intervals are not supported. See the [dependent-effects tutorials](../tutorials/dependent-gls.md) and [compatibility table](../assets/generated/references/COMPATIBILITY.md).
