# Supplied phylogenetic correlation

Question: How does a supplied species-correlation matrix enter a random-effects meta-analysis?

The fixture gives five observations on three species and a labelled correlation matrix. The model uses that matrix as supplied. It checks an exact zero-boundary case and an interior variance-component case.

Run the native Julia example from the repository root:

```sh
julia --project=. examples/phylogeny.jl --case=boundary
julia --project=. examples/phylogeny.jl --case=interior
```

The local [comparison page](../compare.md) shows R, Julia, and Python estimates and intervals. These fixtures test software behavior and make no empirical biological claim.

## Provenance

The generator, inputs, reference outputs, and terms are recorded under [`reference/phylogeny/`](../assets/generated/references/phylogeny-PROVENANCE.md). The upstream [Berkey analysis](https://www.metafor-project.org/doku.php/analyses:berkey1998) is a separate multivariate example; this page does not reuse its data.

## Differences from R metafor

The port accepts a supplied correlation matrix and repeated species. Tree estimation and unseen-species prediction are unsupported; see [`COMPATIBILITY.md`](../assets/generated/references/COMPATIBILITY.md).
