# Nested study and effect variation

Question: How can the model represent variation among studies and among effects within each study?

The synthetic fixture repeats local effect labels across studies. The nested key includes both the parent study and local effect identity, which preserves grouping when covariance kernels are built.

Run the native Julia example from the repository root:

```sh
julia --project=. examples/dependent.jl --case=nested
```

The script fits a REML model with study and nested-effect variance components. The local three-language comparison includes these estimates and coefficient covariance.

## Interpretation

Each nonnegative variance component describes one level of the supplied grouping structure. The fixture is synthetic and makes no empirical claim.

## Differences from R metafor

Nested random intercepts are verified on the supplied fixture. Crossed or correlated structures beyond the listed scalar kernels remain unsupported; see [`COMPATIBILITY.md`](../assets/generated/references/COMPATIBILITY.md).
