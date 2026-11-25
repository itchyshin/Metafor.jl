# Differences from R metafor

This page links each tutorial to the function-level compatibility record. Status applies to a named function or option and fixture rather than to the whole package.

| Status | Meaning |
|---|---|
| Verified | Exercised against R metafor 5.2-1 using the recorded fixture and tolerance. |
| Partial | The listed subset is checked; other options or edge cases remain incomplete or unverified. |
| Unsupported | The function or option is not implemented. |
| Intentional difference | The port behaves differently by design; the consequence is documented. |

See [`COMPATIBILITY.md`](../assets/generated/references/COMPATIBILITY.md) for the detailed table. The reference scripts under `reference/` create versioned fixtures and outputs. Julia runs without R.

The [comparison index](../compare.md) links to the BCG, dependent-effects, and phylogeny reports comparing R and Julia results. Their static HTML outputs are linked from the comparison index.
