# Relation Extraction 1.5 — Validation Repair

## Status

The first post-implementation validation exposed two methodological defects before 1.5 can be accepted as a production baseline:

1. The A condition did not actually execute the historical 1.4 relation-generation path; it used `relation_extraction=disabled`, so it was not a valid A/B test of the former over-generation behavior.
2. The independent audit contained at least one apparent clause-composition error (`the customer journey is broken and experience suffers` was represented as one binary relation), showing that relation audit fidelity itself needs a stricter proposition-boundary check.

This repair validates the validation procedure. It does **not** modify the production 1.5 implementation.

## Source Article

Use a new real English professional article. Do not use the Victorian diary article.

The previous validation article may be reused only if necessary to reproduce the audit defect; otherwise prefer another article with explicit relational language and coordinated clauses.

## A — Historical 1.4 Baseline

Run the actual 1.4 Relation Generation behavior, including the generation behavior tested in Experiment 3.

Do **not** substitute `relation_extraction=disabled` for the historical baseline.

Then independently audit the generated relations using the established R0/R1/R2/R3 classification.

Purpose:
- establish a genuine baseline for relation over-generation;
- verify that the observed 1.4 behavior is comparable to the earlier experiments.

## B — 1.5 Candidate

Run current `dr3-reading-1.5` with source-first Relation Extraction.

Do not change production files during this validation.

Audit every extracted relation independently against the original article.

## C — Structure-Only Control

Run the same article with Relation Extraction disabled.

C is a control for Structure / Element stability, not a relation-quality baseline.

## Revised Relation Audit Rules

For every B relation, check the following in order:

### 1. Proposition boundary

Verify that the subject, predicate, and object belong to the **same source proposition**.

Reject relations that are formed by combining:
- coordinated clauses;
- separate clauses sharing a subject;
- separate clauses sharing a predicate;
- adjacent propositions;
- subordinate clauses whose arguments do not form the claimed relation.

In particular:

> Evidence for proposition A + evidence for proposition B does not establish relation A → B.

### 2. Argument realization

Verify that `subject.text` and `object.text` preserve the actual source-level argument realization.

Do not silently collapse:
- pronouns or demonstratives;
- derived noun phrases;
- prepositional complements;
- modifiers or qualifiers.

### 3. Predicate fidelity

`predicate.text` must correspond to the relational expression actually connecting the extracted arguments.

Do not construct a predicate by combining predicates from separate clauses.

### 4. Direction

Check direction independently from argument identification.

### 5. Modality / qualification

Preserve modal and qualifying language. Do not strengthen `can`, `may`, `often`, `sometimes`, etc. into unconditional claims.

### 6. Evidence

The cited evidence must directly support the complete relation, not merely its endpoints or separate propositions.

## Classification

- R0: faithful source-grounded relation
- R1-A: argument realization/scope error
- R1-P: predicate error
- R1-D: direction error
- R1-M: modality/qualification error
- R1-N: normalization error
- R2: endpoint evidence exists but relation evidence is insufficient
- R3: fabricated/model-generated relation with no source support

A relation assembled from multiple independent clauses without a source proposition connecting its arguments should be classified as **R2 or R3**, depending on whether any relation claim is actually supported.

## Coverage

If recall is assessed, construct the explicit relation reference set independently **before** examining B's extracted relations.

If no independent gold set is available, report only:

> explicit relation instances identified during coverage review

Do not report extractor-output agreement as measured recall.

## Required Comparison

Report:
- A/B/C structure count;
- structure scope and origin;
- element count and identity;
- rejected candidates;
- A relation-generation count and post-audit count;
- B relation count and post-audit count;
- B R0/R1/R2/R3 distribution;
- proposition-boundary failures;
- source-preservation failures;
- coverage observations.

## Acceptance

1. A genuinely exercises the historical 1.4 relation-generation path.
2. B does not degrade Structure / Element discovery relative to C.
3. B does not reproduce the systematic 1.4 relation over-generation pattern.
4. B relations have independently supported proposition boundaries.
5. Source-level arguments and predicates remain recoverable.
6. Direction and modality remain independently inspectable.
7. R2/R3 are not retained as knowledge.
8. No relation is required to make a structure appear complete.

## Non-goals

This repair does not establish:
- a universal relation ontology;
- general recall;
- universal semantic normalization accuracy;
- performance across all article genres.

It only establishes whether the validation procedure is sound enough to support a production decision on 1.5.

## Execution Rule

If a defect is found:

1. record the defect and evidence;
2. do not modify production 1.5 to explain it away;
3. distinguish implementation defects from audit/protocol defects;
4. only after the validation is methodologically sound decide whether 1.5 should be promoted to `main`.
