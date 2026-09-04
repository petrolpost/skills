# Experiment 6 — Relation Semantic Strength Test

## 1. Purpose

Experiment 5 established that Relation can be recovered when the source explicitly expresses it, but also exposed a new failure mode:

- R0: 8/13
- R1: 4/13
- R2: 2/13
- R3: 0/13

The important problem is therefore no longer primarily **whether a relation exists**, but whether the extracted relation preserves the source's **type, direction, and semantic strength**.

Experiment 6 isolates this problem.

> **Question:** When a source expresses a relation with a particular semantic strength, does Datafication preserve that strength rather than upgrading, weakening, reversing, or otherwise changing it?

This experiment is evidence collection only. It must not modify the canonical `dr3-reading/1.4` specification before the result is evaluated.

## 2. Relation to Previous Experiments

```text
Exp. 3
  Relation generation → strong over-inference
        ↓
Exp. 4
  Disable Relation generation → Structure/Elements remain stable
        ↓
Exp. 5
  Explicit relations → Relation is recoverable
  but R1 reveals semantic/type/strength errors
        ↓
Exp. 6
  Isolate semantic fidelity of explicit relations
```

## 3. Experimental Principle

Treat the source expression as the authority.

The model must not choose a stronger relation because it appears more explanatory, more complete, or more natural from domain knowledge.

In particular, test these transformations as potentially invalid:

```text
weak → strong
possible → necessary
associated → causal
correlated → causal
contributes → causes
precedes → causes
enables → requires
A → B → B → A
```

A relation may only be represented at the semantic strength actually supported by the source.

## 4. Input Selection

Use one article or passage containing explicit relation statements spanning several semantic strengths and relation types.

Prefer a source containing examples comparable to:

| Source expression | Expected interpretation |
|---|---|
| A is associated with B | association / relatedness |
| A is related to B | relatedness |
| A may contribute to B | possible contribution |
| A contributes to B | contribution |
| A enables B | enabling |
| A requires B | requirement/dependency |
| A depends on B | dependency |
| A precedes B | temporal/sequence relation |
| A causes B | causal relation |
| A prevents B | inhibitory/negative causal relation |
| A differs from B | contrast/difference |

Do not require the article to contain exactly these expressions. Use naturally occurring source language.

Record the exact source URL/title and preserve the source text used for evaluation.

## 5. Controlled Relation Set

For each explicit relation statement, identify:

- Source endpoint A
- Source endpoint B
- Source relation expression
- Expected normalized relation type
- Expected direction, if applicable
- Expected semantic strength
- Generated relation

The experiment should test at least these dimensions:

### 5.1 Type

Does the model distinguish different relation kinds?

Examples:

```text
associated_with
contributes_to
enables
requires
causes
precedes
differs_from
```

Do not collapse distinct source relations into `causes` unless the source supports causation.

### 5.2 Direction

Does the model preserve direction?

```text
A causes B
≠
B causes A
```

For symmetric relations such as `differs_from`, direction may be irrelevant; record that explicitly rather than forcing a direction.

### 5.3 Semantic Strength

Does the normalized relation preserve the strength expressed by the source?

Test at least:

```text
possible / may
association
contribution
enabling
requirement
causation
prevention
```

The model must not silently transform:

```text
may contribute → causes
associated with → causes
linked to → causes
precedes → causes
enables → requires
```

## 6. Generation Procedure

### Step 1 — Normal Structure Discovery

Run normal structure-driven Datafication.

Do not alter Structure Discovery rules to make relation extraction easier.

### Step 2 — Element Extraction

Extract endpoints as normal Elements with ordinary evidence requirements.

### Step 3 — Relation Extraction

Extract relations only when the relation itself is independently expressed in the source.

For each relation, preserve the source wording as evidence.

The generated Relation should contain enough information to reconstruct:

```text
A --[relation type / strength]--> B
```

without relying on unstated world knowledge.

### Step 4 — Semantic Normalization

Normalize wording only when normalization does not increase semantic strength.

For example:

```text
"is associated with"
→ associated_with
```

is acceptable.

But:

```text
"is associated with"
→ causes
```

is not.

When normalization is uncertain, prefer the weaker faithful representation or retain the source wording rather than inventing a stronger ontology.

## 7. Independent Relation Audit

Perform a relation-only audit after the initial generation pass.

Do not repair the initial output before recording the audit.

For every Relation classify:

- `R0-S` — supported, type and semantic strength preserved.
- `R1-T` — relation exists, but relation type is wrong.
- `R1-D` — relation exists, but direction is wrong.
- `R1-S` — relation exists, but semantic strength is wrong.
- `R1-M` — relation exists, but normalization changes meaning in another material way.
- `R2` — endpoints are evidenced, relation itself is not independently evidenced.
- `R3` — model-generated relation without source support.

If one relation has multiple problems, record all applicable error dimensions while assigning a primary classification for counting.

## 8. Strength-Error Matrix

The audit should explicitly look for the following patterns:

| Error pattern | Example | Classification |
|---|---|---|
| Upgrade | associated → causes | R1-S |
| Upgrade | may contribute → causes | R1-S |
| Upgrade | enables → requires | R1-S |
| Type substitution | differs → causes | R1-T |
| Direction reversal | A causes B → B causes A | R1-D |
| Temporal→causal | A precedes B → A causes B | R1-S / R1-T |
| Endpoint-only | A and B both evidenced, no A→B statement | R2 |
| World-knowledge link | source omits relation, model supplies one | R3 |

The exact labels can be refined during analysis if the source reveals a better taxonomy. Do not force a taxonomy onto relations that do not fit it.

## 9. Output Requirements

Create:

```text
experiment-6-relation-semantic-strength-test/
├── comparison-report.md
└── datafication/
    ├── datafication.json
    └── datafication.md
```

### `datafication.json`

Preserve the complete initial Datafication output, including all generated Relations and their evidence. Do not silently correct R1 relations before the audit.

### `datafication.md`

Human-readable rendering of the same initial output.

### `comparison-report.md`

Compare Experiment 6 with Experiments 4 and 5 at minimum:

| Metric | Exp. 4 | Exp. 5 | Exp. 6 |
|---|---:|---:|---:|
| Structures | | | |
| Elements | | | |
| Relations generated | | 13 | |
| Supported relations | | 8 | |
| Type errors | | — | |
| Direction errors | | — | |
| Semantic-strength errors | | 4 R1 | |
| Endpoint-only | | 2 | |
| Model-generated | | 0 | |

Also report the individual source relation statements tested and the corresponding generated relation.

## 10. Evaluation Questions

### Q1 — Is relation type preserved?

Can the model distinguish association, contribution, enabling, requirement, causation, sequence, contrast, etc.?

### Q2 — Is direction preserved?

Does the model maintain the source's direction where direction is semantically meaningful?

### Q3 — Is semantic strength preserved?

Does the model avoid turning weaker relations into stronger ones?

### Q4 — Does normalization remain semantics-preserving?

Can source wording be normalized without changing what the author actually asserted?

### Q5 — Is the R1 problem concentrated in one dimension?

Determine whether the Experiment 5 R1 errors are primarily:

- type errors;
- direction errors;
- strength errors;
- or another normalization problem.

### Q6 — Does Relation extraction remain independent of Structure Discovery?

Check whether Structure and Element results remain materially stable relative to the baseline.

## 11. Success Criteria

Experiment 6 is supportive if:

1. explicit relations are recovered;
2. relation type is preserved;
3. direction is preserved where meaningful;
4. semantic strength is not upgraded without evidence;
5. endpoint-only cases do not become relations;
6. Structure Discovery and Element Extraction remain substantially independent of Relation extraction.

Do **not** use raw relation count as the success metric.

The central measure is **semantic fidelity**.

## 12. Interpretation Boundaries

Do not conclude from a poor result that Relation should be removed.

Distinguish:

```text
Relation is useful
        ≠
Current Relation extractor is sufficiently reliable
```

Possible outcomes:

### Strong

Explicit relations are usually recovered with type, direction, and semantic strength preserved.

This supports retaining Relation as an optional independently evidenced output.

### Mixed

Relations are recoverable, but semantic-strength or type errors remain systematic.

This supports a stricter relation normalization/validation stage.

### Weak

Even explicit relations are frequently missed or materially distorted.

This suggests Relation should be handled by a dedicated extraction process rather than ordinary Datafication generation.

### Unexpected

Relation extraction materially changes Structure Discovery or Element Extraction.

Investigate that interaction before changing the canonical specification.

## 13. Decision Gate

Do not update `dr3-reading/1.4` automatically after Experiment 6.

Only after reviewing Experiments 3–6 together should we decide whether the evidence warrants a specification change.

Potential future design direction, **not yet a decision**:

```text
Datafication
├── Structure Discovery
│   ├── Elements
│   └── Constraints (when evidenced)
│
└── Relation Extraction (optional)
    ├── independently evidenced
    ├── direction-aware
    └── semantic-strength constrained
```

The purpose of Experiment 6 is to determine whether this separation is merely conceptually attractive or empirically justified.
