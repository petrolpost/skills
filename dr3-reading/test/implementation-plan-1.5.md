# DR3-Reading 1.5 — Minimal Implementation Plan

## Status

**Implemented on branch `dr3-reading-1.5`; post-implementation validation is pending.**

Candidate architecture is supported by Experiments 3–8. The implementation deliberately uses the smallest boundary change that can preserve the existing Datafication lifecycle.

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

## Implemented Changes

### 1. Structure Discovery

The production template keeps 1.4 discovery behavior and explicitly removes `relations` from the required `structure` shape.

A Structure is complete without Relations. Relations must not be generated merely to connect existing elements or make a structure look complete.

### 2. Relation Extraction

Relation Extraction is now an explicit optional operation inside Datafication, controlled by `relation_extraction`:

- `disabled`: Structure Discovery only;
- `optional`: Structure Discovery + independent Relation Extraction;
- `relations_only`: Relation Extraction without constructing Structures merely to host Relations.

This keeps the global `datafication` artifact and lifecycle unchanged while allowing Relation Extraction to be invoked independently from Structure Discovery.

When enabled, only relations independently supported by source text are retained.

### 3. Source-first representation

```yaml
relation:
  id: R-01
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
  origin: explicit | reconstructed | inferred
  evidence: []
```

### 4. Normalization

Normalization is optional and must never replace source expression.

If normalization loses a material distinction, preserve the source expression and leave the normalized field null.

No canonical relation ontology is introduced in 1.5.

### 5. Provenance

Every extracted relation must have relation-level evidence. The evidence must support the relation itself, not merely its endpoints.

The existing 1.4 claim-level provenance discipline remains in force for Structures, Elements, Relations, and Constraints.

### 6. State / Trace

The global state model is unchanged. Relation Extraction remains a non-blocking Datafication operation and does not create a new hard dependency.

`produced_by.version` and trace configuration now record `dr3-reading/1.5` and the relation-extraction mode.

## Explicit Non-Goals

- No ontology for relations.
- No new relation taxonomy solely to improve benchmark scores.
- No redesign of Structure Discovery.
- No automatic relation inference from co-occurrence.
- No cross-sentence relation completion unless independently supported by source text.
- No changes to synthesis or unrelated DR3 functions unless an actual dependency is found.

## Implementation Review Checklist

- [x] Locate every instruction that makes `structure.relations` mandatory: production schema updated; no downstream dependency found in inspected production files.
- [x] Locate every instruction that generates relations as part of Structure Discovery: generation boundary removed from the production template.
- [x] Locate every consumer that assumes relations exist: no such consumer found in inspected production templates; synthesis does not directly consume Datafication relations.
- [x] Check state/trace assumptions about datafication completion: global artifact remains `datafication`; no new dependency introduced.
- [x] Check output schema examples and prompt text for 1.4 relation-generation assumptions: production template updated to source-first 1.5 representation.
- [x] Preserve all unrelated 1.4 behavior.

## Acceptance Criteria

1. Structure discovery remains behaviorally equivalent to 1.4.
2. Relation extraction can be invoked independently through `relation_extraction=relations_only`.
3. No relation is required merely for structural completeness.
4. Source-level subject/object/predicate survive extraction.
5. Direction and modality/qualification are independent fields.
6. Evidence is attached to the relation itself.
7. Normalization is optional.
8. Existing downstream behavior is not broken by absence of Relations.

## Validation After Implementation

A new real article is now selected for post-implementation validation:

`Philosophy tool kit` — Alan Hájek, Aeon Essays.

See `dr3-reading/test/implementation-validation-1.5.md` for the controlled A/B/C comparison and pass criteria.

Do not convert the validation result into a permanent design decision automatically.
