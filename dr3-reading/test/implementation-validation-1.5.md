# Relation Extraction 1.5 — Post-Implementation Validation

## Status

Production implementation is present on branch `dr3-reading-1.5`.

This document defines the first post-implementation validation. It is deliberately separate from the synthetic Experiments 5–7 and uses a new real article.

## Test article

- Title: `Philosophy tool kit`
- Author: Alan Hájek
- URL: https://aeon.co/essays/with-the-use-of-heuristics-anybody-can-think-like-a-philosopher
- Source: Aeon Essays

The article is suitable because it contains explicit relational expressions such as `depends on`, `leads to`, `supports`, `resembles`, `requires`, and contrastive formulations, while also containing substantial non-relational exposition. This makes it possible to test whether 1.5 extracts source-grounded relations without turning ordinary co-occurrence into relations.

## Comparison

Run the same article through:

### A — Production 1.4 baseline

- existing Structure Discovery behavior;
- historical relation generation behavior;
- independent relation audit.

### B — Production 1.5

- Structure Discovery with `relation_extraction=optional`;
- source-first Relation Extraction;
- optional normalization only after source-level extraction;
- independent relation audit.

### C — Structure-only control

- `relation_extraction=disabled`;
- verifies that removing relations does not materially alter Structure / Element discovery.

## Required observations

### Structure stability

Compare A/B/C:

- structure count;
- structure scope;
- structure origin;
- element count and identity;
- rejected candidates.

Expected result: B and C should remain materially equivalent to the established Structure Discovery behavior. Relation count is not part of this criterion.

### Relation fidelity

For B, classify every retained relation:

- R0: source relation correctly extracted;
- R1-A: argument realization/scope error;
- R1-P: predicate/type error;
- R1-D: direction error;
- R1-M: modality/qualification error;
- R1-N: normalization error;
- R2: endpoint evidence exists but relation evidence is insufficient;
- R3: model-generated relation with no source support.

The default action for R2/R3 is deletion.

### Source preservation

For each B relation verify:

- `subject.text` preserves source argument realization;
- `predicate.text` preserves the source relational expression;
- `object.text` preserves source argument realization;
- `direction` is independently represented;
- modality and qualification are not silently strengthened;
- evidence directly supports the relation.

### Coverage

Construct the explicit relation reference set from the article independently of the extractor before judging recall. Do not use the extractor's own output as the gold set.

If an independently constructed gold set is not available, report only:

> explicit relation instances identified during coverage review

and do not call the number a measured recall rate.

## Pass criteria

1. B does not degrade Structure / Element discovery relative to C.
2. B does not reproduce the systematic relation over-generation observed in Experiment 3.
3. R0 is the dominant relation class.
4. R2/R3 are removed rather than retained as knowledge.
5. Source-level predicate and arguments remain recoverable even when normalization is uncertain.
6. Direction and modality remain independently inspectable.
7. A relation is never required merely to make a structure appear complete.
8. If B materially changes Structure Discovery, the change is investigated before accepting 1.5 as stable.

## What this test does not establish

This test does not establish a universal relation ontology, general recall, or general semantic normalization accuracy. It only tests whether the 1.5 architectural boundary works on a real article without degrading the already-stable Structure / Element path.
