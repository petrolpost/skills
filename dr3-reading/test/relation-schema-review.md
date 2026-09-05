# Relation Schema Review — Experiments 3–7

## Status

**Review only. No change to `dr3-reading/1.4`.**

This review consolidates the evidence from Experiments 3–7 and asks a narrower question:

> After the experiments, what Relation data model do we actually need?

The purpose is not to design a complete ontology or a universal relation model. The purpose is to avoid forcing different extraction problems into one `relation` field.

---

## 1. Evidence chain

### Experiment 3 — Relation audit

The original 1.4 run generated 11 relations. The relation-only audit rejected all 11.

The repeated failure mode was not inability to find endpoint concepts. It was construction of semantic links from co-occurring evidence:

- two supported facts were joined into a causal or functional relation;
- exposition order was converted into a semantic relation;
- relation direction was sometimes reversed;
- a source statement about one subject was assigned to another subject.

**Observation:** relation generation has a systematic tendency toward semantic completion.

### Experiment 4 — No relation generation

Removing relation generation left the core Structure Discovery result unchanged:

| Metric | Original | Experiment 4 |
|---|---:|---:|
| Structures | 4 | 4 |
| Elements | 16 | 16 |
| Relations | 11 → 0 after audit | 0 |

**Observation:** Relation is not required for discovering Structures or extracting Elements.

### Experiment 5 — Explicit relation test

Explicit relations were recoverable, but not all were faithfully represented:

- R0: 8
- R1: 4
- R2: 2
- R3: 0

**Observation:** Relation is a useful independent extraction target, but it needs its own evidence threshold and audit.

### Experiment 6 — Semantic strength test

Adding explicit instructions to preserve type, direction and semantic strength improved overall relation fidelity:

- R0-S: 57% → 75%
- type errors: 14% → 0%
- direction errors: 7% → 0%
- strength errors: 7% → 17%
- fabricated relations: 0% → 0%

**Observation:** type and direction can be controlled substantially by explicit instructions. Semantic-strength calibration remains harder.

### Experiment 7 — `defines` / `depends_on` calibration

The controlled contrast test produced:

- R0-S: 75%
- R1-T: 12.5%
- R1-S: 25%
- R2/R3: 0%

Diagnostic failures were concentrated in:

- `scope_or_subject`: 2
- `relation_type`: 1
- `strength_or_modality`: 0
- `direction`: 0
- `representation_limit`: 0

The problematic examples were derived noun phrases such as `the definition of B` and `dependency on B`, plus a granularity issue around `helps define`.

**Observation:** the remaining problem is not adequately described as semantic strength. Argument scope and relation-type granularity are separate dimensions.

---

## 2. What the current model gets wrong

The experiments suggest that a Relation object currently mixes at least four different questions:

1. **What relation is expressed?**
2. **In which direction?**
3. **How strongly / under what modality is it expressed?**
4. **What exactly are the arguments of that relation?**

A single normalized predicate is not sufficient to answer all four.

For example:

```text
A is related to the definition of B.
```

The sentence does explicitly contain a relation, but the second argument is not simply the base concept `B`. It is the expression `the definition of B`.

Collapsing that argument directly to `B` loses information that is present in the source.

Likewise:

```text
A helps define B.
```

contains an explicit relation, but `helps define` is not semantically identical to `defines`. Mapping it automatically to `defines` creates an unsupported strengthening; mapping it automatically to a broad relation such as `contributes_to` may instead lose useful specificity.

Therefore the schema should preserve source-level argument realization and should not require premature normalization.

---

## 3. Proposed minimal Relation model

The review proposes the following **candidate**, not yet a 1.5 decision:

```yaml
relations:
  - id: R-01
    subject:
      text: "A"
      ref: A
    predicate:
      text: "helps define"
      normalized: "helps_define"
    object:
      text: "B"
      ref: B
    direction: subject_to_object
    modality:
      type: none | possible | necessary | conditional | associated
      source: "..."
    origin: explicit | reconstructed | inferred
    evidence:
      - paragraphs: [12]
        quote: "A helps define B."
```

However, the important change is conceptual rather than the exact field names:

```text
Relation
├── arguments
│   ├── source-level text
│   └── optional normalized reference
├── predicate
│   ├── source-level expression
│   └── optional normalized relation type
├── direction
├── modality / semantic qualification
└── evidence
```

### Why preserve both `text` and `ref`?

Because extraction and normalization are different operations.

- `text` answers: **what did the source actually say?**
- `ref` answers: **what existing Datafication object does this expression refer to, if that mapping is justified?**

A missing `ref` is acceptable. A guessed `ref` is not.

This directly addresses the Experiment 7 scope failures without requiring a large ontology layer.

---

## 4. `semantic_strength` should not become a catch-all

The experiments support retaining semantic qualification, but not using it to encode unrelated dimensions.

Keep separate:

```text
relation type       = what relation
 direction           = which way
modality/qualification = may / can / must / associated / etc.
argument realization = what exactly is being related
```

In particular:

```text
A may depend on B
```

should not be represented as simply:

```text
A depends_on B
semantic_strength: weak
```

if doing so obscures the fact that `may` is a modality expressed by the source.

The model should preserve the lexical qualification when practical, rather than forcing every distinction into an ordinal strength scale.

This is especially important because Experiment 7 found **zero diagnostic errors in strength_or_modality** while scope and type remained problematic.

---

## 5. Relation type should allow faithful surface normalization

The experiment does not justify adding a large canonical relation vocabulary yet.

Instead, distinguish:

```yaml
predicate:
  text: "helps define"
  normalized: "helps_define"
```

from:

```yaml
predicate:
  text: "helps define"
  normalized: "contributes_to"
```

The second is a semantic normalization decision and therefore needs evidence or an explicit normalization rule. It should not happen merely because a broader canonical type already exists.

A useful interim rule is:

> **Do not normalize a specific relation expression to a broader or stronger canonical relation unless the normalization preserves the source semantics.**

If no safe canonical type exists, retain the source-level predicate and leave canonical normalization unresolved.

This avoids prematurely expanding the canonical relation vocabulary while preventing silent semantic loss.

---

## 6. Relation evidence should be relation-level, not endpoint-level

The experiments strongly support keeping relation provenance independent from element provenance.

This distinction must remain explicit:

```text
Evidence(A) + Evidence(B)
        ≠
Evidence(A relation B)
```

A Relation should therefore be retained only when its own evidence expresses the relation with compatible direction and semantic qualification.

Endpoint references can be useful for linking the relation to Structures/Elements, but they cannot substitute for relation evidence.

---

## 7. What should NOT be added yet

The evidence does **not** justify introducing all of the following now:

- a universal relation ontology;
- a large fixed relation-type enum;
- a formal relation algebra;
- transitivity / symmetry / inverse-property machinery;
- automatic relation inference;
- automatic relation composition;
- a mandatory Relation field for every Structure;
- an ordinal semantic-strength scale covering all relation families.

These would solve problems that the experiments have not demonstrated.

The current evidence only justifies a more careful extraction boundary.

---

## 8. Revised conceptual architecture

The experiments support this separation:

```text
Datafication
│
├── Structure Discovery
│   └── Elements / Constraints
│
└── Relation Extraction (optional)
    ├── source-level predicate
    ├── arguments / argument realization
    ├── direction
    ├── modality / qualification
    └── evidence
```

The key architectural point is that **Relation Extraction is a sibling concern of Structure Discovery, not a mandatory sub-step required to make a Structure complete.**

Within Relation Extraction, normalization should be conservative and separable from source-faithful extraction.

---

## 9. Proposed next step

Do **not** modify `dr3-reading/1.4` yet.

Before changing the production template, run a small schema sanity check using a deliberately mixed set of relation sentences containing:

1. direct binary relations;
2. qualified/modal relations;
3. derived noun-phrase arguments;
4. relation expressions with different specificity;
5. relations whose canonical normalization is intentionally unavailable.

The test should ask only one question:

> Can the proposed model preserve source semantics without forcing premature normalization?

If it passes, then a minimal 1.5 change can be considered. If it fails, the failure should be used to refine the model before changing production behavior.

---

## 10. Current review conclusion

The evidence now supports a stronger statement than the original Experiment 5 hypothesis:

> **Relation should be treated as an independently extractable, evidence-bearing structure whose extraction and normalization are separate concerns.**

The experiments do **not** yet support a final canonical relation ontology.

The most important schema addition is therefore not another relation-type category. It is preservation of the distinction between:

- source expression,
- normalized relation type,
- argument realization,
- direction,
- modality/qualification,
- and relation-level evidence.

This is the smallest change that directly explains the observed failure modes without overfitting the schema to Experiments 6–7.
