# Building forest-plot data

Question: Which estimates and intervals are drawn for each study and for the pooled REML result?

The example creates row-aligned study labels, estimates, standard errors, and confidence limits, then writes an original SVG from those data.

Run the example from the repository root:

```sh
julia --project=. examples/bcg.jl --case=forest
```

Inspect `examples/bcg-forest.svg` and the accompanying data file. The local BCG comparison checks forest rows, order, and the pooled summary against R and Python.

## Provenance

The figure is generated from the BCG fixture described in [`reference/v1/PROVENANCE.md`](../assets/generated/references/bcg-PROVENANCE.md). No upstream plot or tutorial image is reused.

## Differences from R metafor

The port provides forest-plot data and an original SVG layout. It does not reproduce the defaults or all layout options of R's `forest.rma()`.
