# Datafication 1.4 — Relation Horizontal Comparison

## Purpose

Compare the relation behavior of the three 1.4 Datafication experiments before changing the canonical specification.

The question is not yet “how do we improve relation extraction?”, but:

> Is relation a reliably datafied part of source structure, or is the model systematically adding relations because a structure feels incomplete without them?

## Experiments

| Experiment | Article-level conceptualization | Structure pattern | Main relation issue |
|---|---|---|---|
| Are Great Leaders Truly Great, or Just Lucky? | Not detected | Mostly explicit structures | 1.4 successfully removed unsupported independence/additivity claims; remaining relations are comparatively well grounded, but one relation connected two elements because they belonged to the same five-factor discussion. |
| AI Is Blurring the Line Between Sales and Marketing | Detected/reconstructed | Explicit + reconstructed | Strongest evidence of relation over-inference: independently supported elements were connected with causal/functional relations whose evidence only co-located the elements; reconstructed progression also sometimes exceeded source strength. |
| Victorian diary-writers kicked off our age of self-optimisation | Not detected | Local/section-level explicit structures | Structure discovery worked without forcing an article-level framework, but several relations were created from co-occurrence or nearby discussion and were then labeled `explicit`; direction and semantic strength were sometimes wrong. |

## Cross-experiment finding

The recurring failure is more specific than “relations are sometimes wrong”.

### Evidence granularity mismatch

The current 1.4 validation can establish:

1. **Structure evidence** — the source contains the described structure.
2. **Element evidence** — the source supports an element.
3. **Relation evidence** — the source explicitly or adequately supports a relation between two elements.

The experiments show that (1) and (2) can be strong while (3) is weak.

A recurring invalid pattern is:

> Evidence(A) + Evidence(B) ≠ Evidence(A → B)

This appears in all three experiments, with different severity.

### Relation semantic-strength mismatch

Even when a source does express some connection, the extracted relation may be stronger or differently directed than the source:

- association → causation
- co-occurrence → dependency
- sequence in exposition → progression in the subject matter
- “travels with” → “maintains”
- consequence stated elsewhere → relation in the reverse direction

Therefore relation validation cannot be reduced to checking whether the evidence quote contains both endpoints.

## Preliminary hypothesis

There are currently two competing explanations.

### H1 — Workflow gap

The model can perform relation verification, but 1.4 does not require a sufficiently independent relation-level verification step.

Prediction: a relation-only second pass over the existing output will delete or weaken a meaningful subset of relations while preserving most explicitly stated relations.

### H2 — Structural-completion bias

The model tends to construct relations whenever several elements are placed inside the same structure, because an internally connected structure appears more complete or explanatory.

Prediction: an independent second pass will still endorse many relations whose only evidence is separate support for the two endpoints.

### H3 — Conservative relation model is needed

Relations may be intrinsically less stable than elements in Datafication. Therefore the canonical output may need to treat relations as optional, with a higher evidentiary threshold than elements.

Prediction: the second pass will systematically remove unsupported relations, especially reconstructed ones, while leaving the element set substantially intact.

These hypotheses are not mutually exclusive. The experiment is intended to determine which mechanism dominates.

## Relation audit taxonomy

For the next pass, classify every existing relation as exactly one of:

- **R0 — Supported relation**: the source explicitly expresses the relation with compatible direction and semantic strength.
- **R1 — Relation exists, extraction is wrong**: the source expresses a relation, but the current relation type, direction, or strength is wrong.
- **R2 — Endpoint-only evidence**: both endpoints are supported, but the source does not independently support the relation between them.
- **R3 — Model-generated interpretation**: the relation is primarily an interpretation introduced by the model rather than recoverable from the source.

For R1, record the minimally supported relation if one can be stated without adding interpretation. For R2/R3, the default action should be deletion rather than replacement by a more interesting relation.

## Important audit constraint

The second pass must **not**:

- add new elements;
- add new relations;
- repair the structure for completeness;
- reinterpret the article globally;
- use general world knowledge to justify a relation;
- infer causality, dependency, exhaustiveness, exclusivity, necessity, or sequence merely from co-occurrence or ordering.

It should only audit the relations already produced by 1.4 against the original article evidence.

## Expected outcome

The useful result is not a higher relation count. It is a more reliable boundary between:

> what the source structurally says
>
> and
>
> what the model can reasonably infer from it.

Only after this audit should we decide whether 1.4 needs a 1.5 relation-validation change.
