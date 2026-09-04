# Experiment 7 — Relation Semantic Calibration Test

## Purpose

Experiment 6 showed that explicit relation extraction improves when type, direction, and semantic-strength preservation are stated explicitly, but `defines` and `depends_on` remained unreliable. Experiment 7 isolates those two relation families with minimal contrast pairs.

The goal is **diagnosis, not schema redesign**: determine whether the remaining errors are caused by semantic strength, relation type, modality/scope, direction, or an unsuitable representation of the relation itself.

## Scope

This is a controlled relation-extraction experiment. It does not test article-level Structure Discovery and must not be used to modify `dr3-reading/1.4` automatically.

## Test Set

Use minimal contrast pairs. Preserve the source wording exactly and extract a relation only when the sentence explicitly states one.

### A. `defines`

1. `A defines B.`
2. `A helps define B.`
3. `A is used to define B.`
4. `A is related to the definition of B.`

### B. `depends_on`

1. `A depends on B.`
2. `A may depend on B.`
3. `A can depend on B.`
4. `A is associated with dependency on B.`

## Extraction Requirements

For every sentence:

- Identify whether an explicit relation is present.
- If present, extract subject, relation type, object, direction, and semantic strength/modality.
- Preserve the weakest semantics actually expressed by the sentence.
- Do not upgrade:
  - helps → defines
  - used to → depends on
  - may/can → necessary or unconditional dependence
  - associated with → causal dependence
- Do not infer a relation merely because the sentence contains the same concepts as another test sentence.
- If the sentence does not support the canonical relation type, either use a more faithful relation type or record the relation as not represented by the current schema.

## Audit Categories

Classify each extracted relation as:

- **R0-S** — relation type, direction, and semantic strength/modality are preserved.
- **R1-T** — relation type is materially wrong, while the underlying relation is explicit.
- **R1-D** — direction is wrong.
- **R1-S** — semantic strength or modality is upgraded/downgraded incorrectly.
- **R1-M** — another material normalization error.
- **R2** — endpoint concepts are present, but the relation itself is not independently supported.
- **R3** — model-generated relation not supported by the sentence.

## Special Diagnostic Field

For every non-R0 result, add one diagnosis:

- `strength_or_modality`
- `relation_type`
- `direction`
- `scope_or_subject`
- `representation_limit`

The purpose is to distinguish a bad extraction from a limitation of the current relation model.

## Expected Analysis

Report:

1. Results for all 8 sentences.
2. Counts for R0-S / R1-T / R1-D / R1-S / R1-M / R2 / R3.
3. Diagnosis counts for the five diagnostic fields.
4. Whether `defines` and `depends_on` behave like ordinary event/process relations or require different semantic dimensions.
5. Whether `semantic_strength` alone is sufficient to represent the observed distinctions.

## Constraints

- Do not add relations that are not explicitly expressed.
- Do not use domain knowledge.
- Do not repair the source wording.
- Do not modify `dr3-reading/1.4`.
- Keep the original extraction output and audit output separate.
- Do not update the decision log from this experiment alone.

## Success Criterion

The experiment succeeds if it can explain **why** `defines` and `depends_on` fail in Experiment 6, rather than merely producing a higher accuracy number.
