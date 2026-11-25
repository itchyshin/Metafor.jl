# Effect sizes

The package computes selected study-level effect sizes from two-by-two count data. The functions return vectors of estimates and sampling variances; omitted or invalid rows are represented according to each function's current behavior.

## `escalc_rr`

`escalc_rr(ai, bi, ci, di; add=0.5, to=:only0)` returns log risk ratios and large-sample sampling variances. `to` accepts `:only0`, `:all`, `:if0all`, or `:none` for the checked zero-cell policies.

## `escalc_or` and `escalc_rd`

`escalc_or` returns log odds ratios with large-sample variances. `escalc_rd` returns risk differences with binomial variances. Both accept the same correction keywords. Other measures from R `escalc()` are not implemented.

Counts must be nonnegative integers. The correction default is 0.5; `:none` leaves tables with unusable zero cells without an estimate. See the [effect-size tutorials](../tutorials/effect-scale.md) and the [compatibility table](../assets/generated/references/COMPATIBILITY.md) for fixture-specific checks and limitations.
