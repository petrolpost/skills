# Experiment 5 — Comparison Report

> 比较时间: 2026-09-05T01:55:00+08:00
> 文章: "Suffused with causality" by Mariel Goddu (Aeon Essays, 2025-03-21)
> 实验版本: dr3-reading/1.4-experiment-5

---

## 1. Relation Audit Results

### R0 — Supported Relations (Source explicitly expresses compatible relation)

| Relation | Source Evidence | Verdict |
|----------|-----------------|---------|
| E1-1 → is_foundation_of → E1-4 | "Causal understanding is the foundation of all thoughts why, how, because, and what if" | R0 ✓ |
| E2-1 → uses → E2-2 | "causes and effects are thought of as variables with values that can change" | R0 ✓ |
| E2-1 → defines_through → E2-3 | "a causal relation is defined in terms of interventions" | R0 ✓ |
| E2-4 → is_also_known_as → E2-1 | "This interventionist way... is often referred to as 'difference-making'" | R0 ✓ |
| E3-1 → contrasts_with → E3-2 | "Interventional learning, by contrast, is active learning" | R0 ✓ |
| E4-2 → precedes → E4-3 | "By three months old, infants seem to have not only first-personal... but also third-personal" | R0 ✓ |
| E4-3 → precedes → E4-4 | "Until about age four... remains tightly tied to... goal-directed actions" (implies shift after) | R0 ✓ |
| E5-4 → uses → E1-1 | "we can use our causal understanding to intervene in our own behaviour" | R0 ✓ |

**R0 Count: 8**

### R1 — Relation Exists, Extraction Wrong

| Relation | Source Says | Generated Says | Issue |
|----------|-------------|----------------|-------|
| E1-1 → enables → E1-3 | "allows you to grasp" (enables understanding) | "enables" (causal enablement) | Semantic strength mismatch: enables understanding vs enables existence |
| E4-1 → precedes → E4-2 | "depends precisely on" (dependency) | "precedes" (sequence) | Type mismatch: dependency vs sequence |
| E5-1 → has_enabled → E5-2 | "is the foundation... It's the basis" (parallel) | "has_enabled" (causal) | Type mismatch: parallel foundation vs causal enablement |
| DS-02 → explains → DS-01 | "offers a neat way of defining" (defines) | "explains" (explanation) | Type mismatch: defines vs explains |

**R1 Count: 4**

### R2 — Endpoint-Only Evidence

| Relation | Both Endpoints | Relation Evidence | Issue |
|----------|----------------|-------------------|-------|
| DS-01 → provides_foundation_for → DS-04 | ✓ | ✗ | Source discusses both but doesn't explicitly connect them |
| DS-04 → results_in → DS-05 | ✓ | ✗ | Source discusses development and applications separately |

**R2 Count: 2**

### R3 — Model-Generated Interpretation

None identified.

**R3 Count: 0**

---

## 2. Summary Table

| Metric | Exp. 3 / 1.4 | Exp. 4 | Exp. 5 |
|--------|-------------|--------|--------|
| Structures | 4 | 4 | 5 |
| Elements | 16 | 16 | 18 |
| Relations generated | 11 (initial) → 0 (after audit) | 0 | 13 |
| Relations supported (R0) | 0 | 0 | 8 |
| Relations with extraction error (R1) | 11 | 0 | 4 |
| Endpoint-only (R2) | 0 | 0 | 2 |
| Model-generated (R3) | 0 | 0 | 0 |
| Rejected candidates | 5 | 5 | 0 |

---

## 3. Structure Stability Comparison

| Structure | Exp. 3/1.4 | Exp. 4 | Exp. 5 |
|-----------|------------|--------|--------|
| DS-01 | ✓ retained | ✓ retained | ✓ retained (expanded) |
| DS-02 | ✓ retained | ✓ retained | ✓ retained (new structure) |
| DS-03 | ✓ retained | ✓ retained | ✓ retained (new structure) |
| DS-04 | ✓ retained | ✓ retained | ✓ retained (expanded) |
| DS-05 | N/A | N/A | ✓ new structure |

**Observation:** Structure discovery is stable across experiments. Exp. 5 discovers 5 structures vs 4 in Exp. 3/4, but this is due to different article content, not experimental effect.

---

## 4. Element Stability Comparison

| Metric | Exp. 3/1.4 | Exp. 4 | Exp. 5 |
|--------|------------|--------|--------|
| Total elements | 16 | 16 | 18 |
| Elements per structure | 4 | 4 | 3.6 |
| Evidence quality | high | high | high |

**Observation:** Element extraction is stable. All elements have claim-level provenance.

---

## 5. Evaluation Questions

### Q1 — Can explicitly expressed relations be recovered?

**Yes.** 8 out of 13 generated relations are classified as R0 (supported). Examples:
- "Causal understanding is the foundation of all thoughts" → E1-1 → is_foundation_of → E1-4
- "Interventional learning, by contrast, is active learning" → E3-1 → contrasts_with → E3-2
- "By three months old, infants seem to have not only... but also..." → E4-2 → precedes → E4-3

### Q2 — Does relation extraction introduce unsupported relations?

**Some.** 4 relations are classified as R1 (extraction error) and 2 as R2 (endpoint-only). No R3 (model-generated) relations were produced.

R1 errors involve:
- Semantic strength mismatches (enables understanding vs enables)
- Type mismatches (dependency vs sequence, parallel vs causal, defines vs explains)

R2 errors involve:
- Endpoint-only evidence where both elements are discussed but not explicitly connected

### Q3 — Does the model preserve semantic strength?

**Partially.** 4 out of 13 relations have semantic strength issues:
- E1-1 → enables → E1-3: "allows you to grasp" ≠ "enables"
- E4-1 → precedes → E4-2: "depends on" ≠ "precedes"
- E5-1 → has_enabled → E5-2: "is foundation" ≠ "has_enabled"
- DS-02 → explains → DS-01: "defines" ≠ "explains"

The model tends to upgrade relation strength or misclassify relation type.

### Q4 — Does enabling Relation extraction alter Structure Discovery?

**No.** Structure discovery remains independent. The5 structures discovered in Exp. 5 are appropriate for the article content, and element extraction quality is consistent.

---

## 6. Main Observation

> **Does removing the expectation of relational completeness materially damage the discovery of structures and elements?**

**Answer: No** (confirmed by Exp. 4).

> **When the source text explicitly expresses relations, can Datafication recover those relations without generating unsupported semantic links?**

**Answer: Partially.**

- 8/13 relations are correctly recovered (R0)
- 4/13 have extraction errors (R1) - mostly semantic strength/type mismatches
- 2/13 are endpoint-only (R2) - both elements present but relation not explicitly stated
- 0/13 are model-generated (R3)

**Key finding:** Datafication can recover explicitly expressed relations, but with a ~30% error rate in semantic strength/type. The model tends to:
1. Upgrade semantic strength (e.g., "allows understanding" → "enables")
2. Misclassify relation type (e.g., dependency → sequence)
3. Create relations from endpoint co-occurrence (R2)

This suggests that relation extraction would benefit from stricter semantic strength validation, but the basic capability to recover explicit relations exists.

---

## 7. Interpretation

**Result: Mixed ( leaning toward Strong)**

- Explicit relations CAN be recovered (8/13 R0)
- Semantic strength preservation needs improvement (4/13 R1)
- No model-generated relations (0 R3) - good
- Structure/Element discovery unaffected

**Recommendation:** Relation extraction could be retained as an optional, independently evidenced output with stricter semantic strength validation. The R1 errors suggest the need for a post-generation audit focused on semantic strength matching.

---

## 8. Files Created

```
experiment-5-explicit-relation-test/
├── comparison-report.md          # This file
└── datafication/
    ├── datafication.json         # Initial Datafication output
    └── datafication.md           # Human-readable rendering
```
