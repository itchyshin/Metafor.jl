# Correlated sampling errors

Question: How should estimates be combined when their sampling errors have a supplied covariance matrix?

The GLS fixture supplies the full sampling covariance matrix `V` and a two-column design matrix. The model uses `V` directly and does not estimate its correlations.

Run the native Julia example from the repository root:

```sh
julia --project=. examples/dependent.jl --case=gls
```

Its output includes coefficients, standard errors, intervals, heterogeneity statistics, and coefficient covariance. The local dependent-effects comparison checks these values against pinned R results and Python output.

## Data and provenance

The generated rows and supplied covariance matrix are documented with their row order, creation details, versions, and terms in [`reference/dependent/v1/PROVENANCE.md`](../assets/generated/references/dependent-PROVENANCE.md).

## Differences from R metafor

The supplied positive-definite `V` case is verified on this fixture. Other multivariate covariance structures are unsupported; see [`COMPATIBILITY.md`](../assets/generated/references/COMPATIBILITY.md).
