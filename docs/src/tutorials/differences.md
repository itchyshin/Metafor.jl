# Differences from R metafor

This page links each tutorial to the function-level compatibility record. Status applies to a named function or option and fixture rather than to the whole package.

| Status | Meaning |
|---|---|
| Verified | Exercised against R metafor 5.2-1 using the recorded fixture and tolerance. |
| Partial | The listed subset is checked; other options or edge cases remain incomplete or unverified. |
| Unsupported | The function or option is not implemented. |
| Intentional difference | The port behaves differently by design; the consequence is documented. |

See [`COMPATIBILITY.md`](../assets/generated/references/COMPATIBILITY.md) for the detailed table. The reference scripts under `reference/` create versioned fixtures and outputs. Julia runs without R.

The local [BCG](../assets/generated/comparisons/bcg-comparison.html), [dependent-effects](../assets/generated/comparisons/dependent-comparison.html), and [phylogeny](../assets/generated/comparisons/phylogeny-comparison.html) artifacts compare R, Julia, and Python results. They are HTML files in this checkout and have not been hosted.
