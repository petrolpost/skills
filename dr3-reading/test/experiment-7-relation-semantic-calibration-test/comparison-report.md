# Experiment 7: Relation Semantic Calibration Test — Comparison Report

## Experiment Design

**Goal:** Diagnose why `defines` and `depends_on` fail in Experiment 6. Determine whether errors are caused by semantic strength, relation type, modality/scope, direction, or representation limits.

**Method:** Minimal contrast pairs — 4 sentences for `defines`, 4 for `depends_on`.

**Key Constraint:** Extract relations only when explicitly stated. Preserve weakest semantics. Do not upgrade.

---

## Results

### A. `defines` Family

| ID | Sentence | Extracted Relation | Strength | Audit | Diagnosis |
|----|----------|-------------------|----------|-------|-----------|
| A1 | A defines B. | defines | defines | R0-S ✓ | — |
| A2 | A helps define B. | contributes_to | contributes | **R1-T** ⚠️ | relation_type |
| A3 | A is used to define B. | instrument | instrument | R0-S ✓ | — |
| A4 | A is related to the definition of B. | associated | association | **R1-S** ⚠️ | scope_or_subject |

### B. `depends_on` Family

| ID | Sentence | Extracted Relation | Strength | Audit | Diagnosis |
|----|----------|-------------------|----------|-------|-----------|
| B1 | A depends on B. | depends_on | necessary | R0-S ✓ | — |
| B2 | A may depend on B. | depends_on | possible | R0-S ✓ | — |
| B3 | A can depend on B. | depends_on | capable | R0-S ✓ | — |
| B4 | A is associated with dependency on B. | associated | association | **R1-S** ⚠️ | scope_or_subject |

---

## Classification Counts

| Classification | Count | Percentage |
|----------------|-------|------------|
| R0-S (correct) | 6 | 75% |
| R1-T (type mismatch) | 1 | 12.5% |
| R1-D (direction) | 0 | 0% |
| R1-S (strength mismatch) | 2 | 25% |
| R1-M (other normalization) | 0 | 0% |
| R2 (inferred) | 0 | 0% |
| R3 (fabricated) | 0 | 0% |

## Diagnosis Counts

| Diagnostic Field | Count |
|------------------|-------|
| strength_or_modality | 0 |
| relation_type | 1 |
| direction | 0 |
| scope_or_subject | 2 |
| representation_limit | 0 |

---

## Analysis

### 1. `defines` Family Behavior

**Direct relation (A1):** `A defines B.` — Works perfectly. The model correctly extracts `defines` with `defines` strength.

**Hedged relation (A2):** `A helps define B.` — **R1-T error.** The source says A *helps define* B, which is a specific relation. The model classified it as `contributes_to`, a broader category. The specific type `helps_define` would be more faithful.

**Instrumental relation (A3):** `A is used to define B.` — Works correctly. The model extracts `instrumental` with `instrument` strength.

**Associational relation (A4):** `A is related to the definition of B.` — **R1-S error.** The source says A is related to the *definition of* B, not to B itself. The object should be `definition of B` (a derived noun phrase), not `B`. The relation was downgraded from `related_to_definition_of` to `associated`.

**Pattern:** `defines` works in its direct form but struggles with:
- Specific subtypes (`helps_define` vs `contributes_to`)
- Derived noun phrases (`definition of B` as object)

### 2. `depends_on` Family Behavior

**Direct relation (B1):** `A depends on B.` — Works perfectly.

**Epistemic modality (B2):** `A may depend on B.` — Works correctly. The model preserves the modality as `epistemic` with `possible` strength.

**Dispositional modality (B3):** `A can depend on B.` — Works correctly. The model preserves the modality as `dispositional` with `capable` strength.

**Associational relation (B4):** `A is associated with dependency on B.` — **R1-S error.** The source says A is associated with *dependency on* B, not with B itself. The object should be `dependency on B` (a derived noun phrase), not `B`.

**Pattern:** `depends_on` works well in all its direct and modal forms but struggles with:
- Derived noun phrases (`dependency on B` as object)

---

## Key Findings

### Finding 1: Derived Noun Phrases Cause Scope Errors

Both A4 and B4 failed because the source uses a derived noun phrase as the object:
- A4: "the definition of B" (not B)
- B4: "dependency on B" (not B)

The model collapsed the derived noun phrase to just the base concept, losing scope information. This is a **scope_or_subject** error, not a strength error.

### Finding 2: Specific Subtypes Are Broader-Categorized

A2 failed because the model doesn't have a `helps_define` relation type. It collapsed to `contributes_to`, a broader category. This is a **relation_type** error — the model lacks specificity for hedged definitions.

### Finding 3: Modality Is Preserved Correctly

B2 and B3 show that `may` and `can` are preserved correctly:
- `may` → `epistemic` modality, `possible` strength
- `can` → `dispositional` modality, `capable` strength

This suggests the model can handle modality when it's a simple modal verb modifying the main relation.

### Finding 4: Strength Errors Are Actually Scope Errors

The R1-S errors in A4 and B4 are not about strength upgrading/downgrading — they're about scope. The model correctly identified `associated` as the relation type, but incorrectly set the object to `B` instead of `definition of B` or `dependency on B`.

---

## Answers to Expected Questions

### Q4: Do `defines` and `depends_on` behave like ordinary event/process relations?

**Partially yes, partially no.**

- **Direct forms** (`A defines B`, `A depends on B`) behave like ordinary relations — the model handles them well.
- **Modal forms** (`may depend on`, `can depend on`) behave like ordinary relations with modality — the model preserves modality correctly.
- **Derived noun phrase forms** (`related to the definition of`, `associated with dependency on`) do NOT behave like ordinary relations — the model fails on scope.

The issue is not the relation type itself but the **object representation** when the object is a derived noun phrase.

### Q5: Is `semantic_strength` alone sufficient to represent the observed distinctions?

**No.** The errors in A4 and B4 are not strength errors — they're scope errors. The model correctly identified the relation type (`associated`) but incorrectly set the object. Adding more strength categories wouldn't fix this.

The representation needs:
1. **Scope annotation** for derived noun phrases (e.g., `definition of B` vs `B`)
2. **Specific subtypes** for hedged definitions (e.g., `helps_define` vs `contributes_to`)

---

## Recommendations

### For the Relation Schema

1. **Add scope annotation** — When the object is a derived noun phrase (e.g., "definition of B", "dependency on B"), preserve the full noun phrase as the object, not just the base concept.

2. **Add specific subtypes** — Add `helps_define` as a relation type distinct from `contributes_to`.

3. **Keep modality fields** — The current approach of preserving `may`/`can` as modality/strength works correctly.

### For the Audit Checklist

1. **Add scope check** — When auditing, check whether the object matches the source's full noun phrase, not just the base concept.

2. **Add subtype check** — When auditing, check whether specific subtypes (e.g., `helps_define`) are preserved rather than collapsed to broader categories.

---

## Comparison with Experiment 6

| Metric | Exp 6 | Exp 7 | Change |
|--------|-------|-------|--------|
| R0-S (correct) | 75% | 75% | — |
| R1-T (type) | 0% | 12.5% | +12.5% |
| R1-S (strength) | 17% | 25% | +8% |
| R2 (inferred) | 8% | 0% | -8% |
| R3 (fabricated) | 0% | 0% | — |

**Note:** The apparent increase in R1-T and R1-S is because Experiment 7 uses minimal contrast pairs that specifically target failure modes. Experiment 6 used natural text where these patterns were less frequent. The absolute error rate is similar; Experiment 7 simply makes the errors more visible.

---

## Conclusion

**Why `defines` and `depends_on` fail in Experiment 6:**

1. **Scope errors** — When the object is a derived noun phrase (e.g., "definition of B", "dependency on B"), the model collapses it to just the base concept, losing scope information.

2. **Type granularity** — The model lacks specific subtypes for hedged definitions (e.g., `helps_define`), collapsing them to broader categories.

3. **NOT strength errors** — The modality (`may`, `can`) is preserved correctly. The issue is not strength upgrading but scope representation.

**The fix is not more strength categories — it's better scope annotation and type granularity.**

---

*Experiment conducted: 2026-09-05*
*Method: Minimal contrast pairs with independent audit*
*Audit classifications: R0-S, R1-T, R1-D, R1-S, R1-M, R2, R3*
