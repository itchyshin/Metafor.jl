# From counts to log risk ratios

Question: How do the reported tuberculosis case counts translate into study effects?

Each row has cases and non-cases for vaccinated and control groups. `escalc_rr` computes a log risk ratio and its sampling variance. Negative values correspond to lower observed risk in the vaccinated group.

The fixture derives from [`dat.bcg`](https://wviechtb.github.io/metadat/reference/dat.bcg.html). Its source, terms, and pinned R reference are recorded in [`reference/v1/PROVENANCE.md`](../assets/generated/references/bcg-PROVENANCE.md). This page uses original wording and an original plot.

Run the native Julia example from the repository root:

```sh
julia --project=. examples/bcg.jl --case=effects
```

The script reads raw counts from the versioned fixture, computes each study effect, and writes results for comparison with R and Python. The [comparison index](../compare.md) reports differences by output and tolerance.

## Interpretation

The pooled estimates summarize the study effects. They do not adjust for latitude; see [meta-regression](bcg-moderator.md).

## Differences from R metafor

The Julia implementation supports log risk ratios and the checked zero-cell correction options listed in [`COMPATIBILITY.md`](../assets/generated/references/COMPATIBILITY.md). Other `escalc()` measures are unsupported.
