# Datafication v2

## Purpose

Discover reusable, dataifiable knowledge structures in an article without assuming that the article as a whole is a conceptual system.

The primary output is a **structure instance**, not a predefined structure type. A structure may be local to a paragraph/section, span several passages, or apply to the article as a whole.

## Core principle

> Discover, don't impose.

Do not manufacture a process, taxonomy, framework, rule, comparison, or other structure merely because the prose can be made to fit one. Preserve ordinary narrative, examples, rhetoric, and loose lists as prose unless there is evidence of an independently reusable structure.

## What counts as dataifiable

A candidate is worth extracting when its organization can be represented explicitly and doing so provides reuse value beyond the original prose. Typical signals include:

- ordered stages or transitions;
- grouping or categorization;
- repeated attributes or dimensions applied to alternatives;
- conditions mapped to actions or outcomes;
- decomposition of an outcome into factors;
- levels, scales, or maturity stages;
- explicit sets of criteria or conditions;
- stable relationships between entities/concepts;
- comparisons whose dimensions and values are recoverable;
- a locally coherent model that can be reused independently.

These are prompts for discovery, not an exhaustive type list.

## Required workflow

### 1. Discover candidates

Read for structures that the author actually expresses, explicitly or through a defensible local reconstruction.

### 2. Validate each candidate

Ask:

1. Does the candidate have identifiable elements?
2. Is there a meaningful relation, ordering, grouping, mapping, constraint, or repeated dimension among them?
3. Would an explicit representation make it independently reusable?
4. Is the structure supported by contiguous or clearly related evidence?
5. Am I extracting an authorial structure rather than imposing a familiar schema?

Reject candidates that fail these tests.

### 3. Describe the structure without forcing a type

The canonical representation is:

```yaml
id: DS-01
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

`interpretation.suggested_kind` is optional and descriptive. It must not constrain discovery. If no useful existing label fits, use a model-generated label or `unknown`.

### 4. Preserve provenance

Every structure must be traceable to source evidence. Distinguish:

- `explicit`: the author clearly states or presents the structure;
- `reconstructed`: the structure is assembled from multiple passages but is strongly supported by the author;
- `inferred`: the structure requires a substantive interpretive leap.

Prefer explicit and reconstructed structures. Do not promote an inferred structure to an author assertion.

### 5. Determine scope

Scope describes the extent of the structure itself, not merely where one supporting sentence occurs:

- `local`: limited to a passage or small group of passages;
- `section`: organizes a recognizable section;
- `article`: genuinely organizes the article as a whole.

Do not use `article` merely because a structure is central to the thesis.

## Output rules

- Zero structures is a valid and often correct result.
- Multiple independent local structures are valid.
- Structures do not need to form a unified conceptual system.
- Do not infer an ontology from the existence of structured objects.
- Do not merge structures merely because they concern the same topic.
- Do not convert every numbered/bulleted list into a structure.
- Do not convert examples into categories unless the author establishes the category relationship.
- Do not convert narrative chronology into a process unless the sequence is presented as a reusable process.
- Do not convert two opposing examples into a comparison unless dimensions or contrast are structurally recoverable.

## Optional pattern vocabulary

For discovery assistance only, the model may consider patterns such as:

`sequence`, `classification`, `criterion_set`, `decision_mapping`, `factor_decomposition`, `comparison_matrix`, `scale`, `relationship_graph`, `enumerated_set`, `model`.

These labels are not required and must never be used as a reason to create a structure that the text does not support.

## Rejected candidates

Record important near-misses when useful:

```yaml
rejected_candidates:
  - description: ...
    reason: ...
```

This is especially useful for evaluating over-structuring.

## Quality target

Optimize for **structural precision and reuse value**, not structural count. A smaller set of strongly evidenced structures is preferable to a larger set produced by schema-driven pattern matching.
