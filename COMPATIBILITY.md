# Compatibility with R metafor 5.2-1

This is an experimental, staged port. Status describes only the function and options listed in each row.

| Function or option | Status | Current scope and limits |
|---|---|---|
| `escalc(measure="RR")`, `to` correction options | partial | Log risk ratios and sampling variances for 2×2 counts. `only0`, `all`, `if0all`, and `none` are checked against the pinned release on hand cases. Other effect sizes and correction options are unsupported. |
| `rma(..., method="FE")` | partial | Matrix design, inverse-variance estimates, and normal intervals. Alternative tests and small-sample inference are unsupported. |
| `rma(..., method="REML")` | partial | Matrix design, complete-data BCG parity, zero-heterogeneity boundary, local-maximum safeguard, and single-study boundary. REML with zero sampling variances is unsupported. |
| Missing and invalid rows | partial | Native `missing` values and non-finite rows are omitted with a Julia warning and original row indices are retained. Warning text/categories do not reproduce R exactly; zero sampling variances are rejected explicitly. |
| Latitude meta-regression | verified | BCG coefficients and predictions for the supplied design rows match the pinned reference. |
| Tables and formula input | partial | StatsModels formulas over Tables.jl inputs with explicit row IDs and row-order checks. Full R formula semantics and all contrasts are unsupported. |
| Mean and new-study intervals | partial | Normal intervals for explicit design rows and scalar REML variance. New-study intervals are unavailable for FE fits. |
| Forest plot data and SVG | partial | Original study intervals and REML summary on the log-risk-ratio scale; `forest.rma` visual defaults are not reproduced. |
| Supplied phylogenetic correlation | partial | One species variance component for a supplied, labelled correlation matrix. Zero-boundary and interior synthetic fits are checked against R. When the random-effect design is contained in the fixed-effect design, REML warns and fixes the unidentifiable variance at zero. Tree estimation and unseen-species prediction are unsupported. |
| `rma.mv()` with supplied sampling covariance `V` | verified on fixtures; partial overall | Full positive-definite `V` is accepted for GLS/REML. The correlated GLS fixture matches the pinned R coefficients, standard errors, intervals, `QE`, `QEp`, and coefficient covariance. Other model families and option combinations are not covered. |
| `fit_meta_cov()` scalar covariance kernels | partial | Adds nonnegative variance components for supplied PSD kernels and evaluates zero-variance faces. The tested two-component nested fit matches the pinned R reference. At most eight independent scalar components are accepted; small-sample inference and profile intervals are unsupported. |
| Nested random intercepts | verified on fixture; partial overall | `fit_meta_nested()` builds indicator kernels from grouping vectors. Inner labels must include parent labels as tuples to avoid collisions. Other correlated or unverified crossed structures are not claimed. |
| Two-outcome `struct="UN"` study effect | verified on fixture; partial overall | `fit_meta_un()` fits a positive-semidefinite 2 × 2 within-study covariance with supplied sampling `V`; the synthetic 20-study case matches R. Three or more outcomes and other `struct` values are unsupported. |
| Dependent-effects formula/table adapter | partial | `fit_meta_cov_formula()` uses StatsModels and Tables.jl, returning original row indices/IDs while masking both axes of `V`. Numeric formula and row-order cases are checked; full R formula semantics are unsupported. |
| Other multivariate covariance structures and inference | unsupported | AR/CAR, spatial, GEN, estimated sampling correlations, profile intervals, small-sample tests, and the full diagnostic suite are not implemented. |
| Other `rma.*` families and diagnostics | unsupported | Full public-function coverage is staged after these dependent-effects examples. |
