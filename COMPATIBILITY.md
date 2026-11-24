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
| Correlated sampling covariance and nested effects | unsupported | Planned after BCG parity. |
| Other model families, diagnostics, and inference options | unsupported | Not implemented in this milestone. |
