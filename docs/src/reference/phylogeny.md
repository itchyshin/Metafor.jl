# Phylogeny

`fit_phylo(yi, vi, species, correlation, correlation_labels; X=nothing, method=:REML)` fits the checked model with a supplied, labelled species-correlation matrix `A` and random-effect design `Z`. Inputs must agree in row and species order; use labels to verify that alignment before fitting.

The package does not estimate a tree, infer a correlation matrix, or predict for unseen species. The boundary and interior demonstrations use named fixtures and do not establish general coverage of phylogenetic meta-analysis. If the random-effect design is contained in the fixed-effect design, the variance component is not identifiable and the implementation warns and fixes it at zero.

See the [phylogeny tutorials](../tutorials/phylogeny.md) and [compatibility table](../assets/generated/references/COMPATIBILITY.md).
