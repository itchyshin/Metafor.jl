# Prediction and forest data

## `predict`

`predict(result::MetaResult, Xnew=nothing; level=0.95)` returns estimates and normal confidence intervals. For an intercept-only fit, omit `Xnew`; for moderator models, supply one row per prediction and one column per fitted coefficient. REML fits also return normal prediction intervals for a new study by adding the estimated scalar heterogeneity variance. Fixed-effect fits return `NaN` prediction limits.

These are normal intervals. Alternative small-sample methods and profile intervals are not implemented.

## `forest_plot_data`

`forest_plot_data(yi, vi, labels, pooled=nothing; level=0.95)` returns a dictionary with the scale, confidence level, row-aligned study intervals, and optional pooled summary. The project uses this data to write its own SVG; it does not implement R's `forest.rma()` layout or options.

See the [prediction tutorial](../tutorials/bcg-prediction.md) and [forest-data tutorial](../tutorials/bcg-forest.md).
