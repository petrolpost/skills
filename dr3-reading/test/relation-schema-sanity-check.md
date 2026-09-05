# Relation Schema Sanity Check

## Purpose

在 Experiments 3–7 之后，对候选 Relation data model 做一次最小 sanity check。

本检查不是为了继续提高 extraction accuracy，也不是立即设计 `1.5` schema，而是回答一个更基础的问题：

> **如果不提前决定 canonical relation type，候选模型能否忠实保存原文中的 Relation，而不丢失 argument、predicate、direction、modality / qualification 与 evidence？**

如果答案是否定的，应明确指出是哪一维造成损失。

## Candidate Model

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

`normalized_type` 是可选的解释/归一化结果，不得覆盖 `predicate.text`。

## Minimal Contrast Set

### A. Predicate granularity

1. `A defines B.`
2. `A helps define B.`
3. `A is used to define B.`
4. `A is related to the definition of B.`

### B. Argument realization

5. `A affects B.`
6. `A affects the development of B.`
7. `A is related to the development of B.`
8. `A depends on B.`
9. `A depends on access to B.`
10. `A is associated with dependency on B.`

### C. Direction

11. `A causes B.`
12. `B is caused by A.`
13. `A precedes B.`
14. `B follows A.`

### D. Modality / qualification

15. `A may depend on B.`
16. `A can depend on B.`
17. `A tends to precede B.`
18. `A is often associated with B.`

## Extraction Requirements

For each sentence:

1. Preserve the source-level subject/object wording.
2. Preserve the source-level predicate wording.
3. Determine direction from the sentence itself.
4. Preserve modality and qualification instead of silently upgrading them.
5. Only populate `normalized_type` when normalization is defensible.
6. If normalization would lose a material distinction, leave it null and retain the source expression.
7. Evidence must point to the exact sentence.
8. Do not infer relations across sentences.

## Audit Categories

- **S0 — Faithful**: source arguments, predicate, direction and modality/qualification are preserved; normalization does not alter meaning.
- **S1-A — Argument loss**: source argument scope or realization is materially changed.
- **S1-P — Predicate loss**: source predicate is replaced by a stronger/weaker/different predicate.
- **S1-D — Direction loss**: direction is changed or collapsed.
- **S1-M — Modality/qualification loss**: modality or qualification is changed or dropped in a meaning-changing way.
- **S1-N — Normalization error**: canonical type is materially wrong even though source expression is preserved.
- **S2 — Unsupported relation**: relation itself is not explicitly supported by the sentence.

## Review Questions

### Q1. Can source expression survive normalization?

A Relation must remain faithful even when no canonical type is available.

### Q2. Are arguments first-class?

`B`, `definition of B`, `development of B`, and `access to B` must not automatically collapse into the same object.

### Q3. Is predicate text first-class?

`defines`, `helps define`, `is used to define`, and `is related to the definition of` must remain distinguishable before normalization.

### Q4. Is modality separate from relation type?

`depends on`, `may depend on`, and `can depend on` must not require inventing unrelated relation types merely to preserve modality.

### Q5. Is direction independent?

Active/passive or lexical alternations must not silently reverse or erase relation direction.

### Q6. Does normalization remain optional?

A relation should still be valid if `normalized_type = null`.

## Decision Rule

Do **not** modify `dr3-reading/1.4` from this check alone.

If the model passes, record that the current conceptual model is sufficient as a candidate foundation for a future Relation Extraction schema.

If it fails, identify the minimum missing dimension. Do not add fields merely because a test sentence is difficult.
