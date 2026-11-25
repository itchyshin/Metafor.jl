# Univariate models

## `fit_meta`

`fit_meta(yi, vi; X=nothing, method=:REML, threshold=1e-5)` fits a fixed-effect (`:FE`) or random-effects (`:REML`) model by inverse-variance weighting. Supply a design matrix `X` with one row per input effect to fit moderators. Without `X`, an intercept-only model is used.

`MetaResult` contains coefficient estimates in `beta`, the coefficient covariance matrix, heterogeneity summaries, convergence status, fitting method, and original retained row indices. Non-finite effects and variances and missing values are omitted with row alignment retained; negative variances are rejected. The inferential options are narrower than R `rma()`.

## `fit_meta_formula`

`fit_meta_formula(data, formula; vi=:vi, id=nothing, method=:REML)` accepts a Tables.jl table and StatsModels formula. Incomplete rows are omitted consistently across the response, moderator, and variance columns. If `id` is supplied, row IDs are retained and required to be unique. Formula semantics and categorical contrasts are not claimed to match R comprehensively.

See [fixed and random effects](../tutorials/bcg-models.md), [meta-regression](../tutorials/bcg-moderator.md), and [table/formula input](../tutorials/table-adapter.md).
