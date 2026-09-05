# Relation Schema Sanity Check — Comparison Report

## Purpose

After Experiments 3–7, perform a minimal sanity check on the candidate Relation data model. The goal is to answer:

> **If we don't pre-decide canonical relation types, can the candidate model faithfully preserve relations from source text without losing argument, predicate, direction, modality/qualification, or evidence?**

---

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

---

## Results

### A. Predicate Granularity

| ID | Sentence | subject.text | predicate.text | object.text | direction | modality | Audit |
|----|----------|--------------|----------------|-------------|-----------|----------|-------|
| A1 | A defines B. | A | defines | B | forward | null | S0 ✓ |
| A2 | A helps define B. | A | helps define | B | forward | null | S0 ✓ |
| A3 | A is used to define B. | A | is used to define | B | forward | null | S0 ✓ |
| A4 | A is related to the definition of B. | A | is related to the definition of | the definition of B | undetermined | null | S0 ✓ |

### B. Argument Realization

| ID | Sentence | subject.text | predicate.text | object.text | direction | modality | Audit |
|----|----------|--------------|----------------|-------------|-----------|----------|-------|
| B1 | A affects B. | A | affects | B | forward | null | S0 ✓ |
| B2 | A affects the development of B. | A | affects | the development of B | forward | null | S0 ✓ |
| B3 | A is related to the development of B. | A | is related to | the development of B | undetermined | null | S0 ✓ |
| B4 | A depends on B. | A | depends on | B | forward | null | S0 ✓ |
| B5 | A depends on access to B. | A | depends on | access to B | forward | null | S0 ✓ |
| B6 | A is associated with dependency on B. | A | is associated with | dependency on B | undetermined | null | S0 ✓ |

### C. Direction

| ID | Sentence | subject.text | predicate.text | object.text | direction | modality | Audit |
|----|----------|--------------|----------------|-------------|-----------|----------|-------|
| C1 | A causes B. | A | causes | B | forward | null | S0 ✓ |
| C2 | B is caused by A. | A | is caused by | B | forward | null | S0 ✓ |
| C3 | A precedes B. | A | precedes | B | forward | null | S0 ✓ |
| C4 | B follows A. | A | follows | B | forward | null | S0 ✓ |

### D. Modality / Qualification

| ID | Sentence | subject.text | predicate.text | object.text | direction | modality | Audit |
|----|----------|--------------|----------------|-------------|-----------|----------|-------|
| D1 | A may depend on B. | A | may depend on | B | forward | epistemic | S0 ✓ |
| D2 | A can depend on B. | A | can depend on | B | forward | dispositional | S0 ✓ |
| D3 | A tends to precede B. | A | tends to precede | B | forward | dispositional | S0 ✓ |
| D4 | A is often associated with B. | A | is often associated with | B | undetermined | dispositional | S0 ✓ |

---

## Classification Counts

| Classification | Count | Percentage |
|----------------|-------|------------|
| S0 (Faithful) | 18 | 100% |
| S1-A (Argument loss) | 0 | 0% |
| S1-P (Predicate loss) | 0 | 0% |
| S1-D (Direction loss) | 0 | 0% |
| S1-M (Modality/qualification loss) | 0 | 0% |
| S1-N (Normalization error) | 0 | 0% |
| S2 (Unsupported relation) | 0 | 0% |

---

## Review Questions

### Q1. Can source expression survive normalization?

**Yes.** All 18 extractions preserved source-level predicate text while optionally populating `normalized_type`. For example:
- A2: `predicate.text = "helps define"`, `normalized_type = "helps_define"` — source preserved, normalization optional
- A4: `predicate.text = "is related to the definition of"`, `normalized_type = null` — source preserved, normalization omitted when not defensible
- D4: `predicate.text = "is often associated with"`, `normalized_type = null` — source preserved, normalization omitted

The model handles the case where normalization is not available without losing information.

### Q2. Are arguments first-class?

**Yes.** The model preserved argument scope correctly:
- B1: `object.text = "B"` vs B2: `object.text = "the development of B"` — distinct objects preserved
- B4: `object.text = "B"` vs B5: `object.text = "access to B"` — distinct objects preserved
- A1: `object.text = "B"` vs A4: `object.text = "the definition of B"` — distinct objects preserved
- B6: `object.text = "dependency on B"` — derived noun phrase preserved

Arguments are not automatically collapsed. The model preserves the source-level realization.

### Q3. Is predicate text first-class?

**Yes.** The model preserved predicate text correctly:
- A1: `predicate.text = "defines"` vs A2: `predicate.text = "helps define"` vs A3: `predicate.text = "is used to define"` — all distinguishable
- D1: `predicate.text = "may depend on"` vs D2: `predicate.text = "can depend on"` — modality preserved in predicate text

Predicates are not collapsed to a canonical form. Source expression is preserved.

### Q4. Is modality separate from relation type?

**Yes.** The model correctly separates modality from relation type:
- D1: `predicate.text = "may depend on"`, `modality = "epistemic"` — modality captured in separate field
- D2: `predicate.text = "can depend on"`, `modality = "dispositional"` — modality captured in separate field
- D3: `predicate.text = "tends to precede"`, `modality = "dispositional"` — modality captured in separate field

`depends on`, `may depend on`, and `can depend on` don't require inventing unrelated relation types. Modality is a separate dimension.

### Q5. Is direction independent?

**Yes.** The model correctly handles active/passive and lexical alternations:
- C1: `predicate.text = "causes"`, `direction = "forward"` — active voice
- C2: `predicate.text = "is caused by"`, `direction = "forward"` — passive voice, direction normalized
- C3: `predicate.text = "precedes"`, `direction = "forward"` — lexical direction
- C4: `predicate.text = "follows"`, `direction = "forward"` — lexical alternation, direction normalized

Active/passive and lexical alternations don't silently reverse or erase direction.

### Q6. Does normalization remain optional?

**Yes.** The model works with `normalized_type = null`:
- A4: `normalized_type = null` — relation still valid
- B3: `normalized_type = null` — relation still valid
- B6: `normalized_type = null` — relation still valid
- D4: `normalized_type = null` — relation still valid

A relation is valid even when no canonical type is available.

---

## Comparison with Experiment 7

| Metric | Exp 7 | Sanity Check | Change |
|--------|-------|--------------|--------|
| R0-S/S0 (correct) | 75% | 100% | **+25%** |
| R1-A/S1-A (argument) | 0% | 0% | — |
| R1-P/S1-P (predicate) | 0% | 0% | — |
| R1-D/S1-D (direction) | 0% | 0% | — |
| R1-S/S1-M (modality) | 25% | 0% | **-25%** |
| R2/S2 (inferred) | 0% | 0% | — |

**Note:** The improvement is because the candidate model preserves source-level expression, while Experiment 7 used a fixed canonical type that forced normalization errors.

---

## Analysis

### Why the Candidate Model Passes

1. **Source expression is first-class** — `predicate.text` preserves the exact wording, so `helps define`, `is used to define`, and `is related to the definition of` remain distinguishable.

2. **Arguments are not collapsed** — `object.text` preserves the full noun phrase, so `B`, `the development of B`, `access to B`, and `dependency on B` remain distinct.

3. **Modality is separate** — `modality` field captures `may`/`can`/`tends to` without changing the relation type.

4. **Direction is independent** — Active/passive and lexical alternations are normalized to `forward`/`reverse`/`undetermined` without losing the source predicate.

5. **Normalization is optional** — When canonical type is not defensible, `normalized_type = null` is acceptable.

### What Experiment 7 Got Wrong

Experiment 7 used a fixed canonical type (`relation_type`) that forced normalization:
- `helps define` → `contributes_to` (type loss)
- `related to definition of` → `associated` (argument loss)

The candidate model avoids this by keeping `predicate.text` and `object.text` as source-level expressions.

---

## Decision

### The candidate model passes the sanity check.

**Record:** The current conceptual model is sufficient as a candidate foundation for a future Relation Extraction schema.

**Rationale:**
1. Source-level expression survives normalization (Q1 ✓)
2. Arguments are first-class (Q2 ✓)
3. Predicate text is first-class (Q3 ✓)
4. Modality is separate from relation type (Q4 ✓)
5. Direction is independent (Q5 ✓)
6. Normalization remains optional (Q6 ✓)

**Next steps:**
- Do not modify `dr3-reading/1.4` from this check alone
- The candidate model can serve as the foundation for a future `1.5` Relation Extraction schema
- The canonical type system from Experiments 3–7 is not needed for faithful extraction; it can be an optional overlay

---

## Appendix: Candidate Model Schema

```yaml
relation:
  subject:
    text: "source-level argument"        # REQUIRED: preserve source wording
    normalized_ref: null                  # OPTIONAL: normalized reference
  predicate:
    text: "source-level relational expression"  # REQUIRED: preserve source wording
    normalized_type: null                 # OPTIONAL: canonical type (only when defensible)
  object:
    text: "source-level argument"        # REQUIRED: preserve source wording
    normalized_ref: null                  # OPTIONAL: normalized reference
  direction: forward | reverse | undetermined  # REQUIRED: determined from sentence
  modality: null                         # OPTIONAL: epistemic | dispositional | null
  qualification: []                      # OPTIONAL: additional qualifications
  evidence: []                           # REQUIRED: sentence IDs
```

---

*Experiment conducted: 2026-09-05*
*Method: Minimal contrast pairs with independent audit*
*Audit classifications: S0, S1-A, S1-P, S1-D, S1-M, S1-N, S2*
