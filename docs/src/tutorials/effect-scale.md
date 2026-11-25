# Choosing an effect scale

**Question.** Why can one dataset produce estimates with very different magnitudes?

## Data and model

The same BCG counts can be summarized as a log risk ratio, log odds ratio, or risk difference. Each scale answers a related question but weights the data differently and uses different units.

## Run the example

From the repository root, run:

```sh
julia --project=. examples/effect-sizes.jl --case=scale
```

The equivalent Python command is `python examples/effect-sizes.py --case=scale` in [metafor-py](https://github.com/itchyshin/metafor-py). The shared three-language comparison is [effect-size parity](../assets/generated/comparisons/effect-size-comparison.html); phylogenetic results are in the [phylogeny comparison](../assets/generated/comparisons/phylogeny-comparison.html).

## Interpretation

Read each pooled result with its scale label. The pooled log odds ratio can be exponentiated to an odds ratio; the risk difference is already an absolute probability contrast. The three numeric values are not interchangeable.

## Scope

These checks establish behavior only for the named synthetic or BCG fixture and options. They do not establish full compatibility with R metafor. See [Differences from R metafor](differences.md) and the function-by-option [compatibility table](../assets/generated/references/COMPATIBILITY.md).
