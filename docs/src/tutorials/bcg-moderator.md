# Does latitude explain effect variation?

Question: Is absolute latitude associated with the study log risk ratio in this example?

The model uses an intercept and absolute latitude as its design matrix. Its slope is the expected change in log risk ratio per degree. Interpret it as a study-level association.

Run the native example from the repository root:

```sh
julia --project=. examples/bcg.jl --case=moderator
```

The script reports the latitude coefficient, interval, and predictions at 0°, 30°, and 60°. The local `examples/bcg-comparison.html` page checks the design matrix and coefficient labels along with the estimates.

## Data and provenance

The raw data source is the [`dat.bcg` documentation](https://wviechtb.github.io/metadat/reference/dat.bcg.html). Fixture and R version details are recorded in [`reference/v1/PROVENANCE.md`](../assets/generated/references/bcg-PROVENANCE.md).

## Differences from R metafor

The numeric formula/table adapter is partial. Categorical contrasts and full R formula semantics are unsupported; see [`COMPATIBILITY.md`](../assets/generated/references/COMPATIBILITY.md).
