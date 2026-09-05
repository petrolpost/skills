# Relation Extraction 1.5 — Candidate Design

## Status

**Candidate only. Production `dr3-reading/1.4` is unchanged.**

This proposal is derived from Experiments 3–7 and the Relation Schema Sanity Check. It is intentionally minimal: it changes the extraction boundary, not the canonical vocabulary.

## 1. Evidence basis

The experimental sequence establishes four separate findings:

1. Relation generation in ordinary Structure Discovery systematically creates semantic links from co-occurring evidence.
2. Removing relation generation does not materially change Structure / Element discovery.
3. Explicit relations can be extracted as an independent target when relation-level evidence is required.
4. The remaining extraction errors concern different dimensions: relation type, argument realization/scope, direction, and modality/qualification. The sanity check showed that a source-first representation can preserve these distinctions without forcing canonical normalization.

## 2. Proposed architectural boundary

```text
Datafication
├── Structure Discovery
│   ├── Elements
│   └── Constraints
│
└── Relation Extraction (optional)
    ├── source-level arguments
    ├── source-level predicate
    ├── direction
    ├── modality / qualification
    ├── evidence
    └── optional normalization
```

Relation Extraction is a sibling concern of Structure Discovery. It is not required to make a Structure complete.

## 3. Candidate Relation representation

```yaml
relation:
  id: R-01
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
  origin: explicit | reconstructed | inferred
  evidence:
    - paragraphs: [12]
      quote: "..."
```

### Representation rules

- `subject.text` and `object.text` preserve source argument realization.
- `predicate.text` preserves the source relational expression.
- `normalized_ref` is optional and must not replace source text.
- `normalized_type` is optional and must not replace `predicate.text`.
- Direction is represented independently of predicate normalization.
- Modality / qualification is represented independently of relation type.
- Relation-level evidence is mandatory for a retained relation.

## 4. Extraction vs normalization

The pipeline should conceptually be:

```text
Source sentence
      ↓
Faithful extraction
      ↓
Source-level Relation
      ↓
Optional normalization
```

Normalization is not a prerequisite for relation existence.

If no defensible canonical type exists, retain the source expression and leave `normalized_type` null.

Do not normalize a specific expression into a broader or stronger relation merely because that canonical type already exists.

Examples:

```text
A helps define B.
```

must retain `predicate.text = "helps define"`; mapping it to `defines` is an unsupported strengthening unless an explicit normalization rule justifies it.

```text
A is related to the definition of B.
```

must preserve the object realization `the definition of B`; it must not silently collapse the argument to `B`.

## 5. Evidence rule

The existing Datafication evidence principle applies directly:

> Evidence(A) + Evidence(B) ≠ Evidence(A relation B).

A Relation is retained only when its own evidence expresses the relation with compatible direction and qualification.

No relation should be created merely because two Elements occur in the same structure, paragraph, or article.

## 6. Semantic restraint

Do not automatically upgrade or reinterpret:

- helps → defines
- may / can → unconditional dependence
- associated with → causal relation
- exposition order → causal order
- co-occurrence → relation

Preserve lexical modality and qualification where they carry meaning.

## 7. What remains deliberately unspecified

This candidate does **not** introduce:

- a universal relation ontology;
- a mandatory fixed relation-type enum;
- formal relation algebra;
- automatic inference or composition;
- transitivity / symmetry / inverse-property machinery;
- an ordinal semantic-strength scale for all relation families.

These remain future questions because the current experiments do not justify them.

## 8. Compatibility with Datafication 1.4

The proposal is designed as an additive boundary change rather than a rewrite of Structure Discovery.

The following remain unchanged:

- discover, don't impose;
- local structures are valid;
- Structure / Element discovery does not require Relation;
- claim-level provenance;
- evidence must support the claim at the same semantic strength;
- rejected candidates remain useful evidence;
- Datafication does not claim to produce a correct ontology.

## 9. Required validation before production adoption

Before modifying `dr3-reading/1.4`, validate the candidate on at least one real article rather than only synthetic contrast sentences.

The validation should compare:

1. Structure count and scope;
2. Element extraction;
3. explicit Relation recall;
4. unsupported Relation rate;
5. preservation of source predicate and argument realization;
6. direction preservation;
7. modality / qualification preservation;
8. normalization errors;
9. whether optional Relation Extraction changes Structure Discovery behavior.

The production change should be made only if the real-article test confirms that the new boundary improves relation fidelity without degrading the already-stable Structure / Element results.

## 10. Current judgment

The candidate is **schema-ready but not production-approved**.

The strongest current architectural statement is:

> Relation is an independently extractable, evidence-bearing concern. Faithful source-level extraction precedes optional normalization. Relation is not required for Structure Discovery.

The next experiment should therefore test this boundary on real article text, not expand the schema further.
