# Pooling risk differences

**Question.** What does heterogeneity look like on an absolute scale?

## Data and model

Use the BCG study risk differences and their binomial sampling variances as the model inputs. Fit the same fixed-effect and REML specifications used for the log odds ratios.

## Run the example

From the repository root, run:

```sh
julia --project=. examples/effect-sizes.jl --case=risk-difference
```

The equivalent Python command is `python examples/effect-sizes.py --case=risk-difference` in [metafor-py](https://github.com/itchyshin/metafor-py). See the [comparison index](../compare.md) for the relevant fixture reports.

## Interpretation

The pooled risk difference is an absolute probability contrast. Heterogeneity summaries depend on the scale and sampling variances, so they need not match the log odds ratio analysis.

## Scope

These checks establish behavior only for the named synthetic or BCG fixture and options. They do not establish full compatibility with R metafor. See [Differences from R metafor](differences.md) and the function-by-option [compatibility table](../assets/generated/references/COMPATIBILITY.md).
