# Experiment 5 — Explicit Relation Test

## 1. Purpose

Experiment 4 established that removing Relation Generation does not materially affect Structure Discovery or Element Extraction. Experiment 5 now tests the complementary question:

> When the source text explicitly expresses relations, can Datafication recover those relations without generating unsupported semantic links?

This is a controlled experiment for determining the boundary and role of `Relation` in Datafication. It does **not** modify the canonical `dr3-reading` specification.

## 2. Relation to Previous Experiments

```text
Experiment 3
  4 Structures / 16 Elements / 11 Relations
                         ↓
Relation Audit
  11 / 11 Relations rejected
                         ↓
Experiment 4
  Relation Generation disabled
  4 Structures / 16 Elements / 0 Relations
                         ↓
Experiment 5
  Source deliberately contains explicit relations
  → test whether supported relations are recovered
```

Experiment 5 must therefore avoid the opposite error of Experiment 4: **do not optimize for zero relations**. The target is evidence fidelity.

## 3. Input Selection

Select one article or passage with multiple relations that are explicitly expressed in the source text. The source should preferably contain several relation forms, for example:

- causal: `A causes B`
- conditional/dependency: `A requires B` / `A depends on B`
- sequence: `A precedes B` / `A is followed by B`
- composition/inclusion: `A consists of B and C`
- contrast/difference: `A differs from B`
- enabling: `A enables B`

The selected source should contain enough explicit relation statements to test both relation **existence** and relation **semantic strength/direction**.

Record the exact source URL/title and preserve the source text used for evaluation.

## 4. Experimental Variable

Keep the following unchanged from Datafication 1.4:

- Structure Discovery
- Element Extraction
- Evidence / provenance requirements
- claim-level evidence validation
- structure-driven discovery
- anti-overstructuring principles

Change only the relation instruction:

> Relation is optional. Generate a Relation only when the source independently provides evidence for the relation itself. The existence of evidence for Element A and Element B is insufficient evidence for `A → B`.

Do not infer a relation merely because:

- two elements co-occur;
- two elements are adjacent in the source;
- one element appears to explain another from general knowledge;
- the relation would make the structure look more complete;
- the model believes the relation is semantically plausible.

## 5. Required Procedure

### Step 1 — Discover Structures

Run normal structure-driven Datafication.

Do not begin by looking for a predetermined relation inventory. Discover the structures actually present in the source.

### Step 2 — Extract Elements

Extract the elements belonging to each discovered structure with normal 1.4 evidence requirements.

### Step 3 — Extract Relations

For every candidate Relation, require **relation-level evidence**.

A valid Relation must have evidence that supports:

1. the two endpoints;
2. the existence of a relation between those endpoints;
3. the direction of the relation, where direction is meaningful;
4. the semantic strength/type of the relation (`causes`, `enables`, `requires`, etc.).

If the source supports only a weaker relation, record the weaker relation rather than upgrading it.

If the relation itself is not supported, do not create it.

### Step 4 — Preserve Negative Cases

Include at least some cases where both endpoints are explicitly present but the source does **not** explicitly relate them, if such cases naturally occur in the selected source.

These are important controls:

```text
Evidence(A) ✓
Evidence(B) ✓
Evidence(A ↔ B) ✗

→ no Relation
```

### Step 5 — Independent Relation Audit

After the initial Datafication output, perform a separate relation-only audit against the original source.

For every generated Relation classify it as:

- `R0 Supported relation` — source explicitly expresses a compatible relation with compatible direction and semantic strength.
- `R1 Relation exists, extraction wrong` — source expresses a relation, but the generated type, direction, or semantic strength is wrong.
- `R2 Endpoint-only evidence` — both endpoints are supported, but the relation itself is not.
- `R3 Model-generated interpretation` — relation is not supported by the source and arises from interpretation/world knowledge.

For `R1`, record the minimally supported correction for analysis, but do not silently alter the original experimental output.

For `R2` and `R3`, the relation should be rejected.

## 6. Do Not Repair During Generation

The generation pass and audit pass must remain separate.

Do not use the audit to rewrite the original result before measuring it.

The experiment must preserve:

```text
initial output
      ↓
independent audit
      ↓
classified findings
```

This is necessary to measure both extraction capability and over-inference.

## 7. Output Requirements

Create:

```text
experiment-5-explicit-relation-test/
├── comparison-report.md
└── datafication/
    ├── datafication.json
    └── datafication.md
```

### `datafication.json`

Contain the complete initial Datafication result, including all generated Structures, Elements, Relations, evidence/provenance, and rejected candidates.

Do not remove rejected or unsupported Relations from the initial output merely because they fail the later audit.

### `datafication.md`

Human-readable rendering of the same initial result.

### `comparison-report.md`

Compare Experiment 5 with Experiments 3 and 4. At minimum report:

| Metric | Exp. 3 / 1.4 | Exp. 4 | Exp. 5 |
|---|---:|---:|---:|
| Structures | | | |
| Elements | | | |
| Relations generated | | | |
| Relations supported (R0) | | | |
| Relations with extraction error (R1) | | | |
| Endpoint-only (R2) | | | |
| Model-generated (R3) | | | |
| Rejected candidates | | | |

Also compare whether Structure Discovery and Element Extraction materially change when Relation extraction is active.

## 8. Evaluation Questions

The experiment must answer these questions explicitly:

### Q1 — Can explicitly expressed relations be recovered?

If the source contains clear relation statements, are they represented in the output?

### Q2 — Does relation extraction introduce unsupported relations?

Measure R2 + R3, not merely total relation count.

### Q3 — Does the model preserve semantic strength?

For example:

```text
Source: A is associated with B

Invalid:
A causes B
A enables B
A requires B
```

Likewise, if the source says `A causes B`, reversing it to `B causes A` is invalid.

### Q4 — Does enabling Relation extraction alter Structure Discovery?

Compare Structures and Elements against the relevant baseline. The desired result is that relation extraction remains an independent layer rather than changing what structures/elements are discovered.

## 9. Success Criteria

Experiment 5 is considered supportive if it demonstrates the following pattern:

```text
Explicit Relation in source
        ↓
Relation recovered
        ↓
Relation evidence supports
        ↓
Direction/type/strength preserved
```

while simultaneously showing:

```text
Element A + Element B
        ↓
no relation evidence
        ↓
no Relation generated
```

A low relation count by itself is **not** a success criterion.

A high relation count by itself is **not** a failure criterion.

The central metric is the relationship between **source-supported relations and generated relations**.

## 10. Interpretation Boundaries

Do not conclude from this experiment that Relation must become mandatory in Datafication.

Possible outcomes include:

1. **Strong result** — explicit relations are recovered accurately and unsupported relations remain rare. This supports retaining Relation as an optional, independently evidenced output.
2. **Mixed result** — explicit relations can be recovered, but semantic-strength errors remain common. This supports a stricter relation extraction/audit procedure.
3. **Weak result** — even explicit relations are frequently missed or distorted. This suggests Relation may require a separate specialized extraction process rather than being part of normal Datafication generation.
4. **Unexpected result** — relation extraction materially changes Structure/Element discovery. Investigate this before changing the canonical design.

Do not update `main`, `dr3-reading/1.4`, or the decision log as part of this experiment. Experiment 5 is evidence collection only.

## 11. Core Principle Under Test

> **Evidence(A) + Evidence(B) does not imply Evidence(A → B).**
>
> Conversely, when the source explicitly provides `Evidence(A → B)`, Datafication should be able to preserve that relation without strengthening, reversing, or inventing its semantics.
