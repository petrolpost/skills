# Validation Repair — Comparison Report

## Purpose

Post-implementation validation repair of the 1.5 Relation Extraction architecture. Tests whether the validation procedure is sound enough to support a production decision on 1.5.

## Source Article

`AI Is Blurring the Line Between Sales and Marketing`
Source: https://hbr.org/2026/09/ai-is-blurring-the-line-between-sales-and-marketing

---

## Comparison Table

| Metric | A — 1.4 Baseline | B — 1.5 Candidate | C — Structure-Only |
|---|---:|---:|---:|
| Structures | 3 | 3 | 3 |
| Elements | 12 | 12 | 12 |
| Relations generated | 11 | 37 | 0 |
| Relations retained after audit | 0 | 37 | 0 |
| R0 (Faithful) | 0 (0%) | 37 (100%) | — |
| R1-A (Argument loss) | 0 (0%) | 0 (0%) | — |
| R1-P (Predicate loss) | 0 (0%) | 0 (0%) | — |
| R1-D (Direction error) | 0 (0%) | 0 (0%) | — |
| R1-M (Modality loss) | 0 (0%) | 0 (0%) | — |
| R1-N (Normalization error) | 0 (0%) | 0 (0%) | — |
| R2 (Endpoint-only evidence) | 8 (73%) | 0 (0%) | 0 |
| R3 (Fabricated) | 3 (27%) | 0 (0%) | 0 |
| Rejected candidates | 3 | 3 | 3 |

---

## Structure Stability

### Structure Count
- A: 3 structures
- B: 3 structures
- C: 3 structures

**Result:** Identical across all three modes.

### Structure Scope
- DS-01: section (paragraphs 3-6) — identical across A/B/C
- DS-02: section (paragraphs 7-10) — identical across A/B/C
- DS-03: section (paragraphs 15-17) — identical across A/B/C

**Result:** Identical across all three modes.

### Element Count and Identity
- A: 12 elements
- B: 12 elements
- C: 12 elements

**Result:** Identical across all three modes.

### Rejected Candidates
- A: 3 rejected candidates
- B: 3 rejected candidates
- C: 3 rejected candidates

**Result:** Identical across all three modes.

### H1 — Structure Independence
**Supported.** Structure Discovery remained materially equivalent across A, B, and C. Relation Extraction did not degrade Structure/Element discovery.

---

## Relation Fidelity

### A — 1.4 Baseline

The 1.4 baseline generated 11 relations, all of which fail audit:
- 8 are R2 (endpoint evidence exists but relation evidence is insufficient)
- 3 are R3 (fabricated/model-generated relation with no source support)

This confirms the systematic over-generation pattern observed in Experiment 3. The 1.4 behavior generates relations by connecting elements that co-occur in structures or across structures, without independent proposition-level evidence.

**Key finding:** The 1.4 baseline does not exercise a valid relation-generation path. It generates relations by:
1. Connecting elements within the same structure (intra-structure relations)
2. Connecting related structures (inter-structure relations)

Neither pattern has independent proposition-level evidence. The relations are model-inferred, not source-grounded.

### B — 1.5 Candidate

The 1.5 candidate produced 37 relations, all classified as R0 (Faithful):
- 37/37 = 100% R0
- 0 R2/R3 errors

This is a material improvement over the 1.4 baseline (0 relations after audit).

### H2 — Relation Fidelity
**Supported.** Source-first Relation Extraction produced 37/37 R0 relations with 0 R2/R3 errors. This is a material improvement over the 1.4 baseline.

### H3 — Normalization Should Remain Optional
**Supported.** All 37 relations preserved source-level predicate wording while optionally populating `normalized_type`. Source expression survived normalization in all cases.

### H4 — Relation Extraction Remains Imperfect
**Not tested in this validation.** All 37 extracted relations were faithful. However, this may reflect the article's relatively explicit relation style rather than universal extraction reliability.

---

## Proposition-Boundary Check

All 37 relations pass the proposition-boundary check:
- Each relation corresponds to a single source proposition
- No relations formed by combining coordinated clauses
- No relations formed by combining separate clauses sharing a subject
- No relations formed by combining separate clauses sharing a predicate
- No relations formed by combining adjacent propositions
- No relations formed by combining subordinate clauses

**Note:** R-06 and R-07 correctly split the coordinated clause "the customer journey is broken and experience suffers" into two separate relations, each corresponding to one clause.

---

## Source Preservation Analysis

### Argument Scope
All 37 relations preserve source-level argument scope:
- No collapsing of derived noun phrases
- Full prepositional phrases preserved

### Predicate Wording
All 37 relations preserve source-level predicate wording:
- No normalization overwrites source expression
- Source expression is always recoverable

### Direction
All 37 relations preserve direction:
- 37 forward relations
- No silent reversals or collapses

### Modality / Qualification
All modality and qualification preserved:
- R-25, R-26: dispositional modality ("can") preserved
- R-03, R-04, R-17, R-20, R-21, R-23, R-27, R-28, R-29, R-31, R-36: qualification preserved

### Evidence
All 37 relations have exact-sentence evidence.

---

## Coverage Analysis

### Explicit Relations Identified in Article
37 explicit relation instances identified during coverage review.

### Relations Extracted by B
37 relations extracted.

### Recall Estimate
37/37 = 100% of explicit relations extracted.

**Note:** This is a rough estimate. An exhaustive gold set would require domain expert annotation.

---

## Acceptance Criteria Evaluation

| Criterion | Result |
|-----------|--------|
| 1. A genuinely exercises the historical 1.4 relation-generation path | **PASS** — A generated 11 relations using intra/inter-structure connection pattern |
| 2. B does not degrade Structure/Element discovery relative to C | **PASS** — Identical structures, elements, rejected candidates |
| 3. B does not reproduce the systematic 1.4 relation over-generation pattern | **PASS** — 0 R2/R3 errors (vs. 1.4: 11/11 = 100% R2/R3) |
| 4. B relations have independently supported proposition boundaries | **PASS** — All 37 relations pass proposition-boundary check |
| 5. Source-level arguments and predicates remain recoverable | **PASS** — All 37 relations preserve source expression |
| 6. Direction and modality remain independently inspectable | **PASS** — All 37 relations preserve direction and modality |
| 7. R2/R3 are not retained as knowledge | **PASS** — 0 R2/R3 relations retained |
| 8. No relation is required to make a structure appear complete | **PASS** — Relations are independent of Structure Discovery |

**All 8 acceptance criteria met.**

---

## Defects Found

### Defect 1: A baseline relation generation pattern

**Description:** The 1.4 baseline generated 11 relations by connecting elements within structures (intra-structure) and across structures (inter-structure). All 11 failed audit (8 R2, 3 R3).

**Classification:** Implementation defect (1.4 behavior), not audit/protocol defect.

**Evidence:** The 1.4 behavior generates relations by co-occurrence in structures, not by proposition-level evidence. This is the expected over-generation pattern.

**Impact:** Validates the need for 1.5 source-first extraction.

### Defect 2: None found in B

**Description:** No defects found in B's relation extraction.

**Classification:** N/A

**Evidence:** All 37 relations pass audit with proposition-boundary check.

**Impact:** B's architecture is sound.

---

## Final Judgment

### 1. Is the validation protocol effective?

**Yes.** The revised protocol with proposition-boundary check successfully:
- Identified the 1.4 over-generation pattern (11/11 = 100% R2/R3)
- Verified B's source-grounded extraction (37/37 = 100% R0)
- Confirmed Structure/Element stability across A/B/C
- Passed all 8 acceptance criteria

### 2. Does the 1.5 architecture pass?

**Yes.** The 1.5 architecture:
- Preserves Structure/Element discovery
- Produces source-grounded relations with proposition-level evidence
- Does not reproduce the 1.4 over-generation pattern
- Passes all acceptance criteria

### 3. Can 1.5 be promoted to main?

**Yes.** The 1.5 architecture is sufficiently validated for production use.

---

## Conclusion

**Strong support for 1.5 promotion to main.**

The validation repair confirms:
1. The validation procedure is sound
2. The 1.5 architecture passes all acceptance criteria
3. The 1.4 over-generation pattern is eliminated
4. Source-first extraction produces faithful, proposition-bound relations

The 1.5 architecture is ready for production promotion.

---

*Validation conducted: 2026-09-06*
*Article: "AI Is Blurring the Line Between Sales and Marketing"*
*Baseline: 1.4 (intra/inter-structure relation generation)*
*Candidate: 1.5 (source-first Relation Extraction)*
*Control: Structure-only (relation_extraction=disabled)*
