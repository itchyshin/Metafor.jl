# Aligning a phylogenetic matrix by species

**Question.** Why should correlation-matrix labels be checked before fitting?

## Data and model

A correlation matrix is meaningful only when each row and column refers to the intended species. The fixture includes labels on both axes; the example verifies that their order agrees before passing the matrix to the model.

## Run the example

From the repository root, run:

```sh
julia --project=. examples/phylogeny.jl --case=interior
```

The equivalent Python command is `python examples/phylogeny.py --case=interior` in [metafor-py](https://github.com/itchyshin/metafor-py). See the [comparison index](../compare.md) for the relevant fixture reports.

## Interpretation

The model maps observation species to the labelled matrix. Reordering either axis without applying the same permutation changes the model. Unseen species and tree estimation are outside the current supported scope.

## Scope

These checks establish behavior only for the named synthetic or BCG fixture and options. They do not establish full compatibility with R metafor. See [Differences from R metafor](differences.md) and the function-by-option [compatibility table](../assets/generated/references/COMPATIBILITY.md).
