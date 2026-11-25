# Zero-cell correction policies

**Question.** How does a zero event count affect an effect size?

## Data and model

A hand-checkable two-study table includes one study with a zero cell and one complete table. The `to` option decides which cells receive the continuity correction before calculating the effect and its variance.

## Run the example

From the repository root, run:

```sh
julia --project=. examples/effect-sizes.jl --case=zero-correction
```

The equivalent Python command is `python examples/effect-sizes.py --case=zero-correction` in [metafor-py](https://github.com/itchyshin/metafor-py). The shared three-language comparison is [effect-size parity](../assets/generated/comparisons/effect-size-comparison.html); phylogenetic results are in the [phylogeny comparison](../assets/generated/comparisons/phylogeny-comparison.html).

## Interpretation

The page reports `only0`, `all`, `if0all`, and `none` for both odds ratios and risk differences. With no correction, the zero-cell odds ratio is undefined and represented as missing. A warning category is not yet identical to R.

## Scope

These checks establish behavior only for the named synthetic or BCG fixture and options. They do not establish full compatibility with R metafor. See [Differences from R metafor](differences.md) and the function-by-option [compatibility table](../assets/generated/references/COMPATIBILITY.md).
