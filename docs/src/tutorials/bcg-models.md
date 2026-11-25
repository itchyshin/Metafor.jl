# Fixed-effect and random-effects estimates

Question: What pooled estimate follows when all studies share one effect, and what changes when study effects vary?

The fixed-effect fit uses inverse sampling-variance weights. The REML fit estimates between-study variance and uses it in the weights. Both fits use the same BCG log risk ratios and are checked against the pinned R fixture.

Run the native example from the repository root:

```sh
julia --project=. examples/bcg.jl --case=models
```

The output labels the `fixed` and `random` fits and reports coefficients, standard errors, heterogeneity, and intervals. The [comparison index](../compare.md) shows each result from R, Julia, and Python with quantity-specific tolerances.

## Interpretation

The REML fit accounts for estimated variation among study effects. Its prediction interval describes a future study effect and is wider than a confidence interval for the mean.

## Differences from R metafor

Supported FE and REML options and unimplemented inference choices are listed by function in [`COMPATIBILITY.md`](../assets/generated/references/COMPATIBILITY.md).
