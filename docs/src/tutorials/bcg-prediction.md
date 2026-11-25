# Mean confidence intervals and prediction intervals

Question: What effect does the fitted BCG model predict at 0°, 30°, and 60° latitude?

The confidence interval describes uncertainty in the fitted mean. The prediction interval also includes estimated between-study variation. Both are reported on the log risk-ratio scale.

Run the native example from the repository root:

```sh
julia --project=. examples/bcg.jl --case=prediction
```

The generated results contain predictions, standard errors, confidence limits, and prediction limits. The local three-language comparison checks each prediction field against the pinned reference.

## Interpretation

Exponentiating a log risk ratio gives a risk ratio. Transform both interval endpoints consistently before interpreting them on that scale.

## Differences from R metafor

The package provides normal mean and new-study intervals for supplied design rows. Alternative small-sample interval methods are unsupported; see [`COMPATIBILITY.md`](../assets/generated/references/COMPATIBILITY.md).
