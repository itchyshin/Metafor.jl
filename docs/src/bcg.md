# Does BCG vaccination reduce tuberculosis risk?

This example asks whether vaccination lowers tuberculosis incidence across 13 studies, and whether the estimated effect changes with absolute latitude. The upstream question and dataset are described in the [metadat BCG example](https://wviechtb.github.io/metadat/reference/dat.bcg.html). The repository includes the raw-count fixture and provenance under `reference/v1/`.

## Data and effects

Each study reports cases and non-cases among vaccinated and control participants. The analysis converts those counts to log risk ratios and sampling variances. A negative log risk ratio indicates lower risk in the vaccinated group.

Run `julia --project=. examples/bcg.jl` from the repository root. It reads the fixture, prints machine-readable results, and writes forest-plot data and an original SVG to `examples/`.

## Models and predictions

The example fits an inverse-variance fixed-effect model, a REML random-effects model, and a REML model with absolute latitude as a moderator. It predicts the mean log risk ratio at 0°, 30°, and 60°. The confidence interval describes uncertainty in the fitted mean. The prediction interval also includes the estimated variation among study effects.

The latitude coefficient is the estimated change in log risk ratio per degree. It is negative for these studies, indicating more negative estimated effects at higher absolute latitudes. This association does not establish why effects vary geographically.

## Supplied phylogenetic correlation

The phylogenetic example uses five synthetic observations on three species and a supplied, labelled species-correlation matrix. It includes a zero-boundary case and an interior variance-component case, both checked against pinned R references. These fixtures demonstrate software behavior and make no empirical biological claim.

Run `julia --project=. examples/phylogeny.jl`. From the Python repository, run `OPENBLAS_NUM_THREADS=1 .venv/bin/python tools/compare-phylogeny.py` to fit all three programs and write the local `examples/phylogeny-comparison.html`. The implementation accepts supplied matrices and repeated species; it does not estimate trees or predict effects for unseen species.

## Differences from R metafor

This experimental Julia port supports log risk ratios, fixed-effect and REML matrix models, a StatsModels formula/table adapter, normal mean and new-study intervals, forest data, and the supplied-correlation phylogenetic model shown here. Missing and non-finite rows are omitted with a Julia warning and row indices are retained, but warning categories differ from R. REML with zero sampling variances is unsupported and raises an explicit error. The package does not implement every effect-size measure, all multivariate structures, small-sample inference options, or the full diagnostic suite. See `COMPATIBILITY.md` for verified and unsupported options.
