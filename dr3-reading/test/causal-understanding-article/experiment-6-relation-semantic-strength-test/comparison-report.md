# Experiment 6: Relation Semantic Strength Test — Comparison Report

## Experiment Design

**Goal:** Test whether explicitly stated relations can be extracted with preserved semantic strength (not just type, not just direction, but the precise strength of the relation).

**Article:** "Suffused with causality: How our idea of cause and effect is coloured by our senses" by Mariel Goddu (2023)

**Key Constraint:** Preserve source relation type, direction, and semantic strength. Do not upgrade weaker relations to stronger ones.

**Audit Classifications:**
- R0-S: Correct — correct source, correct type, correct direction, correct strength
- R1-T: Type mismatch — correct source, wrong relation type
- R1-D: Direction mismatch — correct source, reversed direction
- R1-S: Strength mismatch — correct source, correct type, but strength too strong or too weak
- R1-M: Missing — relation exists in source but was not extracted
- R2: Model-inferred — relation not in source, model-generated
- R3: Fabricated — relation contradicts source

---

## Relations Extracted

### Intra-Structure Relations (within DS-01–DS-05)

| # | From | Relation | Strength | To | Source Evidence | Audit |
|---|------|----------|----------|-----|----------------|-------|
| 1 | E1-1 (因果理解能力) | enables | enabling | E1-3 (因果关系实例) | "concept...allows you to grasp how Moon causes tides" | R0-S ✓ |
| 2 | E1-1 (因果理解能力) | is_foundation_of | foundation | E1-4 (因果理解的基础作用) | "Causal understanding is the foundation of all thoughts" | R0-S ✓ |
| 3 | E2-1 (干预主义) | uses_as_framework | uses_as_framework | E2-2 (变量与值) | "causes and effects are thought of as variables" | R0-S ✓ |
| 4 | E2-1 (干预主义) | defines_through | defines | E2-3 (干预) | "causal relation is defined in terms of interventions" | R0-S ✓ |
| 5 | E2-4 (差异制造) | is_referred_to_as | is_referred_to_as | E2-1 (干预主义) | "interventionist way...often referred to as 'difference-making'" | R0-S ✓ |
| 6 | E3-1 (统计学习) | differs_from | contrast | E3-2 (干预学习) | "Interventional learning, by contrast, is active learning" | R0-S ✓ |
| 7 | E4-1 (点做) | depends_on | depends_on | E4-2 (我因) | "development of causal understanding depends on 'insider perspective'" | **R1-S** ⚠️ |
| 8 | E4-2 (我因) | precedes | temporal_precedence | E4-3 (他们因) | "infants seem to have not only me-causal... but also they-causal" | R0-S ✓ |
| 9 | E4-3 (他们因) | precedes | temporal_precedence | E4-4 (它因) | "Until about age four... remains tied to actions" | R0-S ✓ |

### Inter-Structure Relations (between DS-01–DS-05)

| # | From | Relation | Strength | To | Source Evidence | Audit |
|---|------|----------|----------|-----|----------------|-------|
| 10 | DS-01 (因果理解定义) | provides_basis_for | provides_basis | DS-04 (发展轨迹) | "causal understanding depends on 'insider perspective'" | R0-S ✓ |
| 11 | DS-02 (干预主义) | defines | defines | DS-01 (因果理解定义) | "interventionism offers a neat way of defining 'cause'" | **R1-S** ⚠️ |
| 12 | DS-04 (发展轨迹) | results_in | results_in | DS-05 (应用与后果) | "shift...to objective one...foundation of science" | **R2** ⚠️ |

---

## Strength-Error Matrix

| Semantic Strength | Total | R0-S | R1-T | R1-D | R1-S | R2 | R3 | Error Rate |
|-------------------|-------|------|------|------|------|-----|-----|------------|
| enabling | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 0% |
| foundation | 2 | 2 | 0 | 0 | 0 | 0 | 0 | 0% |
| uses_as_framework | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 0% |
| defines | 1 | 0 | 0 | 0 | 1 | 0 | 0 | 100% |
| is_referred_to_as | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 0% |
| contrast | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 0% |
| depends_on | 1 | 0 | 0 | 0 | 1 | 0 | 0 | 100% |
| temporal_precedence | 2 | 2 | 0 | 0 | 0 | 0 | 0 | 0% |
| provides_basis | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 0% |
| results_in | 1 | 0 | 0 | 0 | 0 | 1 | 0 | 100% |
| **TOTAL** | **12** | **9** | **0** | **0** | **2** | **1** | **0** | **25%** |

---

## Analysis

### Overall Performance
- **R0-S (correct): 9/12 = 75%** — improved from Exp 5 (57%)
- **R1 (any mismatch): 2/12 = 17%** — down from Exp 5 (29%)
- **R2 (inferred): 1/12 = 8%** — down from Exp 5 (14%)
- **R3 (fabricated): 0/12 = 0%** — same as Exp 5

### Semantic Strength Accuracy
- **Foundation relations:** 2/2 = 100% correct
- **Enabling relations:** 1/1 = 100% correct
- **Temporal precedence:** 2/2 = 100% correct
- **Defines/depends_on:** 0/2 = 0% correct (R1-S errors)

### What Went Right
1. **Foundation/enabling/contrast preserved:** The model did not upgrade weaker relations to stronger ones for foundation, enabling, contrast, and temporal_precedence
2. **Type distinction maintained:** No R1-T errors (compare Exp 5: 2)
3. **Direction preserved:** No R1-D errors (compare Exp 5: 1)
4. **No fabrication:** R3 = 0 maintained from Exp 5

### What Went Wrong
1. **"defines" strength mismatch (R1-S):** Source says interventionism defines "cause" (narrower), model says it defines "causal understanding" (broader). The strength was upgraded from defining a concept to defining a capacity.

2. **"depends_on" strength mismatch (R1-S):** Source says development depends on point of do, model says point of do depends on I-causation. The relation was semantically shifted.

3. **Inter-structure "results_in" (R2):** Model inferred causal chain between development trajectory and applications, but source only presents them sequentially.

---

## Comparison with Experiment 5

| Metric | Exp 5 | Exp 6 | Change |
|--------|-------|-------|--------|
| R0-S (correct) | 57% | 75% | **+18%** |
| R1-T (type) | 14% | 0% | **-14%** |
| R1-D (direction) | 7% | 0% | **-7%** |
| R1-S (strength) | 7% | 17% | +10% |
| R2 (inferred) | 14% | 8% | -6% |
| R3 (fabricated) | 0% | 0% | — |
| Total R1 errors | 29% | 17% | **-12%** |

### Key Findings
1. **Strength preservation instruction reduced type/direction errors** — explicit constraint on strength appears to have improved overall precision
2. **New error pattern emerged** — R1-S increased, suggesting the model struggles with precise strength calibration even when explicitly instructed
3. **"defines" and "depends_on" are high-risk relations** — these tend to be upgraded or shifted semantically
4. **Foundation/enabling/contrast are reliably preserved** — these strengths appear more stable in extraction

---

## Conclusions

### Primary Finding
**Semantic strength preservation is partially achievable.** When explicitly instructed, the model can preserve weaker relation strengths (enabling, foundation, contrast, temporal_precedence) but struggles with definitional and dependency relations.

### Implications for Datafication Design
1. **Strength classification should be preserved** — the model can handle it when instructed
2. **"Defines" and "depends_on" need special attention** — these relations are prone to strength upgrading
3. **Inter-structure relations need stronger constraints** — model-inferred inter-structure relations remain problematic
4. **The strength-error hierarchy is clear:** enabling/foundation/contrast/temporal_precedence > defines/depends_on/results_in

### Recommendation
The relation schema should preserve `semantic_strength` as a field and include it in the audit checklist. The instruction "do not upgrade weaker relations to stronger ones" is effective but should be supplemented with specific guidance for "defines" and "depends_on" relations.

---

*Experiment conducted: 2026-09-05*
*Article: "Suffused with causality" by Mariel Goddu*
*Audit method: Manual source-text verification against extracted relations*
