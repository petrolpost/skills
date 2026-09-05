# DR3-Reading 1.5 — Minimal Implementation Plan

## Status

Candidate architecture supported by Experiments 3–8. This document defines the smallest implementation change before post-implementation validation.

## Evidence Basis

Experiments 3–8 establish:

- Relation generation embedded in Structure Discovery systematically produces unsupported links.
- Removing relation generation does not materially change Structure/Element discovery.
- Explicit relations can be extracted independently.
- Relation errors decompose into argument scope, predicate/type, direction, modality/qualification, and normalization issues.
- Source-first representation preserves these distinctions in the schema sanity check.
- On the Victorian diary article, the candidate approach preserved 4 Structures / 16 Elements and extracted 20 explicit Relations with 20/20 R0 in the experiment audit.

The 20/20 result is treated as an experimental result, not a general recall guarantee, because the coverage set was not independently constructed.

## Target Architecture

```text
Datafication
├── Structure Discovery
│   ├── Elements
│   └── Constraints
│
└── Relation Extraction (optional)
    ├── source-level arguments
    ├── source-level predicate
    ├── direction
    ├── modality / qualification
    ├── evidence
    └── optional normalization
```

## Minimal Changes

### 1. Structure Discovery

Keep the current 1.4 discovery behavior unchanged.

Do not require Relations for a Structure to be considered complete.

Do not add relations merely to connect existing elements or make a structure look complete.

### 2. Relation Extraction

Make Relation Extraction an explicit optional operation rather than an implicit completion step of Structure Discovery.

When enabled, extract only relations independently supported by source text.

Use source-first representation:

```yaml
relation:
  subject:
    text: "source-level argument"
    normalized_ref: null
  predicate:
    text: "source-level relational expression"
    normalized_type: null
  object:
    text: "source-level argument"
    normalized_ref: null
  direction: forward | reverse | undetermined
  modality: null
  qualification: []
  evidence: []
```

### 3. Normalization

Normalization is optional and must never replace source expression.

If normalization loses a material distinction, preserve the source expression and leave the normalized field null.

Do not introduce a canonical relation ontology in 1.5.

### 4. Provenance

Every extracted relation must have relation-level evidence. The evidence must support the relation itself, not merely its endpoints.

Preserve the existing 1.4 claim-level provenance discipline for Structures, Elements, Relations, and Constraints.

### 5. State / Trace

Do not change the global state model unless implementation inspection shows that the current datafication lifecycle assumes relation generation is mandatory.

If Relation Extraction becomes a separately invokable operation, its lifecycle should remain non-blocking and should not invalidate Structure Discovery merely because no relations were extracted.

Any state/trace change must be the minimum required to represent this optional operation.

## Explicit Non-Goals

- No ontology for relations.
- No new relation taxonomy solely to improve benchmark scores.
- No redesign of Structure Discovery.
- No automatic relation inference from co-occurrence.
- No cross-sentence relation completion unless independently supported by source text.
- No changes to synthesis or unrelated DR3 functions unless an actual dependency is found.

## Implementation Review Checklist

Before changing production files:

- [ ] Locate every instruction that makes `structure.relations` mandatory.
- [ ] Locate every instruction that generates relations as part of Structure Discovery.
- [ ] Locate every consumer that assumes relations exist.
- [ ] Check state/trace assumptions about datafication completion.
- [ ] Check output schema examples and prompt text for 1.4 relation-generation assumptions.
- [ ] Preserve all unrelated 1.4 behavior.

## Acceptance Criteria

1. Structure discovery remains behaviorally equivalent to 1.4.
2. Relation extraction can be invoked independently.
3. No relation is required merely for structural completeness.
4. Source-level subject/object/predicate survive extraction.
5. Direction and modality/qualification are independent fields.
6. Evidence is attached to the relation itself.
7. Normalization is optional.
8. Existing downstream behavior is not broken by absence of Relations.

## Validation After Implementation

After implementation, run a new article as post-implementation validation.

The validation article should not be the Victorian diary article used in Experiment 8. The goal is to test whether the architecture generalizes beyond the case that motivated it.

Record:

- Structure/Element stability
- number of Relations extracted
- source-fidelity audit
- unsupported relations
- missed explicit relations where an independently reviewable reference set can be established
- any regression in existing Datafication behavior

Do not convert the validation result into a permanent design decision automatically.