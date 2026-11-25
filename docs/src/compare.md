# R vs Julia comparisons

All five static reports directly compare selected R and Julia outputs for named fixtures. The table-adapter report also checks formula-to-matrix alignment within Julia. Each result is limited to the stated inputs, model options, and tolerances; it does not establish complete compatibility between packages.

- [BCG effects and models](assets/generated/comparisons/bcg-comparison.html)
- [Dependent effects](assets/generated/comparisons/dependent-comparison.html)
- [Supplied phylogenetic correlation](assets/generated/comparisons/phylogeny-comparison.html)
- [Effect sizes](assets/generated/comparisons/effect-size-comparison.html)
- [Table adapter and row alignment](assets/generated/comparisons/table-adapter-comparison.html)

The reports are copied from the checked-in `examples/pairwise/` inputs during the Documenter build. A missing report input fails the normal build; `METAFOR_PREVIEW=1` is an explicit local preview opt-out. For data origins and reference versions, see each linked [fixture provenance record](assets/generated/references/bcg-PROVENANCE.md) or the [compatibility table](assets/generated/references/COMPATIBILITY.md).
