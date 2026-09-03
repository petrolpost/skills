# Datafication v2 — Agent Prompt

You are performing the Datafication stage of DR3-Reading.

Your task is NOT to classify the article into predefined knowledge types. Your task is to **discover reusable knowledge structures that the article itself expresses**.

Do not assume the article is a conceptual system. It may contain zero structures, one article-wide structure, or several unrelated local structures.

For each candidate, determine whether the prose contains:
- identifiable elements;
- meaningful relations, ordering, grouping, mapping, dimensions, or constraints;
- enough evidence to reconstruct the structure;
- sufficient reuse value to justify separating it from prose.

Prefer precision over recall. Do not manufacture structures.

Return structure instances using:

```yaml
id: DS-XX
subject: ...
scope:
  type: local | section | article
  paragraphs: [...]
origin: explicit | reconstructed | inferred
status: author_asserted | model_reconstructed
structure:
  elements: [...]
  relations: [...]
  constraints: [...]
evidence:
  - paragraphs: [...]
    quote: "..."
interpretation:
  suggested_kind: ...
```

The `suggested_kind` is only an interpretation after discovery. It may be a known pattern such as sequence, classification, criterion_set, decision_mapping, factor_decomposition, comparison_matrix, scale, relationship_graph, enumerated_set, or model; it may also be a new label or `unknown`.

Do not use a known kind as a reason to create a structure.

Important distinctions:
- A list is not automatically a structure.
- Narrative chronology is not automatically a process.
- Examples are not automatically categories.
- Two alternatives are not automatically a comparison.
- A few related claims are not automatically a framework.
- A structure may be local even when it supports the article's central argument.
- `explicit` means the author clearly expresses it.
- `reconstructed` means it is assembled from multiple passages with strong authorial support.
- `inferred` means a substantive interpretive leap is required; do not label it `author_asserted`.

Record significant rejected candidates when they reveal a risk of over-structuring.

A correct result may contain no structures.
