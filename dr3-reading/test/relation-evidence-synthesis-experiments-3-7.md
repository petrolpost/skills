# Relation Evidence Synthesis — Experiments 3–7 + Schema Sanity Check

## Status

**Stage synthesis. No change to `dr3-reading/1.4`. No decision-log update.**

This document consolidates the evidence accumulated from Experiments 3–7 and the Relation Schema Sanity Check. It separates observed experimental findings from the design conclusions they currently justify.

## 1. Evidence chain

The experiments progressively decomposed one apparent problem into distinct problems:

```text
Exp. 3 — relation generation
    ↓
unsupported semantic completion
    ↓
Exp. 4 — remove relation generation
    ↓
Structure / Elements remain stable
    ↓
Relation is not required for Structure Discovery
    ↓
Exp. 5 — explicit relation extraction
    ↓
explicit relations are recoverable, but fidelity is incomplete
    ↓
Exp. 6 — semantic calibration
    ↓
type and direction become controllable; remaining errors are not one-dimensional
    ↓
Exp. 7 — defines / depends_on diagnosis
    ↓
scope and type granularity emerge as separate dimensions
    ↓
Schema Review
    ↓
Extraction and Normalization should be separated
    ↓
Schema Sanity Check
    ↓
18/18 source-level contrast cases preserved faithfully
```

## 2. What the evidence establishes

### 2.1 Relation generation should not be part of default Structure Discovery

Experiment 3 generated 11 relations; the relation-only audit rejected all 11. The repeated failure mode was construction of semantic links from co-occurring evidence rather than independently evidenced relations.

Experiment 4 removed relation generation and retained the same core Structure Discovery result: 4 Structures and 16 Elements.

**Supported conclusion:** Relation is not a required component or completion step for Structure Discovery.

This is stronger than saying that the current relation extractor is inaccurate. The experiment shows that removing the entire relation-generation expectation does not damage the observed Structure/Element result.

### 2.2 Relation remains a useful independent extraction target

Experiment 5 showed that explicit relations can be recovered: 8/13 were R0, 4/13 R1, 2/13 R2, and 0/13 R3.

**Supported conclusion:** The failure in Experiment 3 does not imply that Relation itself is useless. Explicitly stated relations can be extracted as an independent concern, provided relation-level evidence is required.

### 2.3 Relation evidence must be independent of endpoint evidence

The experiments repeatedly expose the distinction:

```text
Evidence(A) + Evidence(B)
        ≠
Evidence(A relation B)
```

Two independently supported elements do not constitute evidence for a semantic relation between them.

**Supported conclusion:** Relation provenance must be attached to the relation itself. Element provenance cannot substitute for relation provenance.

### 2.4 Relation fidelity has multiple independent dimensions

Experiment 6 showed that explicit instructions concerning type, direction and semantic strength materially improved extraction. Experiment 7 then showed that the remaining errors in `defines` / `depends_on` were concentrated in `scope_or_subject` and `relation_type`, with zero diagnostic errors attributed to `strength_or_modality` or direction.

**Supported conclusion:** Relation extraction should not treat semantic strength as a catch-all field. At minimum, the extraction problem distinguishes:

- relation type / predicate semantics;
- direction;
- modality / qualification;
- argument realization and scope;
- evidence.

## 3. What the evidence does NOT establish

The experiments do not justify:

- a universal relation ontology;
- a large fixed canonical relation vocabulary;
- automatic relation inference;
- automatic relation composition;
- transitivity, symmetry, or inverse-property machinery;
- a mandatory Relation field for every Structure;
- a universal ordinal semantic-strength scale.

The evidence is sufficient to define a safer extraction boundary, not a complete relation semantics.

## 4. Schema sanity check result

The candidate source-first Relation model passed all 18 controlled contrast cases:

| Classification | Count | Percentage |
|---|---:|---:|
| S0 Faithful | 18 | 100% |
| S1-A Argument loss | 0 | 0% |
| S1-P Predicate loss | 0 | 0% |
| S1-D Direction loss | 0 | 0% |
| S1-M Modality loss | 0 | 0% |
| S1-N Normalization error | 0 | 0% |
| S2 Unsupported | 0 | 0% |

All six review questions passed:

1. source expression survives normalization;
2. arguments are first-class;
3. predicate text is first-class;
4. modality is separate from relation type;
5. direction is independent;
6. normalization remains optional.

The sanity check therefore supports the candidate model as a representation foundation.

## 5. Important correction to the interpretation of the sanity check

The sanity check does **not** prove that Relation Extraction is now reliable on real articles.

It proves something narrower and more useful:

> The candidate representation can preserve source-level relation semantics without requiring premature canonical normalization, at least across the controlled contrast set.

Likewise, the earlier failures cannot all be attributed to normalization.

Experiment 3 primarily exposed **unsupported relation generation / semantic completion**.

Experiments 5–7 exposed **extraction and normalization fidelity** problems.

Therefore the causal explanation should remain decomposed rather than collapsing all failures into “fixed canonical types were bad.”

## 6. Candidate architectural model

The current evidence supports the following working architecture:

```text
Datafication
│
├── Structure Discovery
│   └── Elements / Constraints
│
└── Relation Extraction (optional)
    │
    ├── source-level arguments
    │   └── optional normalized references
    │
    ├── source-level predicate
    │   └── optional normalized relation type
    │
    ├── direction
    ├── modality / qualification
    └── relation-level evidence
```

The critical boundary is:

```text
source-faithful extraction
            ↓
   optional normalization
```

not:

```text
source
  ↓
mandatory canonicalization
```

A minimal conceptual object is therefore:

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

## 7. Current design position

At this stage the most defensible position is:

> **Relation should be treated as an independently extractable, evidence-bearing concern. Its source expression must be preserved before optional normalization. Relation Extraction is a sibling concern of Structure Discovery, not a mandatory sub-step required to complete a Structure.**

This position is supported by the combined experiments, while the exact production schema and canonical relation vocabulary remain open.

## 8. What should happen next

Do not expand the experiment suite merely to accumulate more contrast sentences.

The next engineering step should be a **minimal production-design proposal** for a future version (candidate `1.5`) that changes only the necessary boundaries:

1. make Relation optional rather than structurally required;
2. preserve source-level predicate and argument expressions;
3. make normalization optional;
4. preserve direction and modality/qualification separately;
5. require relation-level evidence;
6. keep Structure Discovery behavior unchanged unless an experiment has shown otherwise.

The proposal should remain explicitly marked as a candidate until tested on at least one real article containing both explicit and non-explicit relations.

## 9. Stage conclusion

The main result of Experiments 3–7 is not a new list of Relation fields.

It is a boundary discovery:

```text
Structure Discovery
        ≠
Relation Extraction
        ≠
Relation Normalization
```

Keeping these concerns separate explains the observed failures with fewer assumptions and avoids turning Datafication into a premature ontology-building exercise.
