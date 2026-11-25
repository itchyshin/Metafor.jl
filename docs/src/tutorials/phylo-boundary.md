# Phylogenetic model at the zero boundary

Can the supplied species correlation improve this example?

## Data and model

The synthetic fixture has repeated observations for three labelled species and a supplied correlation matrix. In this boundary case, the estimated phylogenetic variance is zero.

## Run the example

From the repository root, run:

```sh
julia --project=. examples/phylogeny.jl --case=boundary
```

The equivalent Python command is `python examples/phylogeny.py --case=boundary` in [metafor-py](https://github.com/itchyshin/metafor-py). See the [comparison index](../compare.md) for the relevant fixture reports.

## Interpretation

At the boundary, the fitted phylogenetic component contributes zero variance. The synthetic observations exercise the software’s handling of that boundary.

## Scope

These checks establish behavior only for the named synthetic or BCG fixture and options. They do not establish full compatibility with R metafor. See [Differences from R metafor](differences.md) and the function-by-option [compatibility table](../assets/generated/references/COMPATIBILITY.md).
