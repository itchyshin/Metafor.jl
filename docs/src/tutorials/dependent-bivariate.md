# Two correlated outcomes per study

Question: How can two outcomes share a study-level covariance while their sampling errors are correlated?

The synthetic two-outcome case supplies the sampling covariance matrix and fits an unstructured 2 × 2 study-level outcome covariance. Benefit and harm labels define the design columns.

Run the native Julia example from the repository root:

```sh
julia --project=. examples/dependent.jl --case=bivariate
```

The generated comparison reports both outcome means, variance components, covariance and correlation, and coefficient covariance.

## Data and provenance

The fixture contains generated data that demonstrate a Berkey-style two-outcome structure. Its provenance, generator, and checksums are in [`reference/dependent/v1/PROVENANCE.md`](../assets/generated/references/dependent-PROVENANCE.md).

## Differences from R metafor

The unstructured covariance is implemented for two outcomes on the checked fixture. Three or more outcomes and other structures are unsupported; see [`COMPATIBILITY.md`](../assets/generated/references/COMPATIBILITY.md).
