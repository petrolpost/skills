# Experiment 8 — Real-Article Relation Extraction

## Status

**Protocol ready for execution.**

This experiment validates the candidate Relation Extraction model from `relation-schema-sanity-check.md` on a real article. It does not modify `dr3-reading/1.4` or the decision log.

## Purpose

Test whether Relation Extraction should be treated as an independent concern from Structure Discovery, using the previously tested Victorian diary article as the real-world case.

The experiment compares:

- **A — 1.4 baseline:** existing Datafication behavior, including relation generation as currently specified, followed by relation audit.
- **B — 1.5 candidate:** Structure Discovery and Element extraction remain unchanged, while Relation Extraction is performed independently using source-first representation and optional normalization.
- **C — audit/reference review:** an independent relation-level review of B against the article text.

The goal is **not** to maximize the number of relations. The goal is to determine whether B improves relation fidelity without changing the stable Structure/Element result.

## Source Article

Use the exact article from Experiment 3:

`Victorian diary-writers kicked off our age of self-optimisation`

Canonical slug:

`victorian-diary-writers-kicked-off-our-age-of-self-optimisation`

Source:
`https://aeon.co/essays/victorian-diary-writers-kicked-off-our-age-of-self-optimisation`

Use the exact article content already used in Experiment 3 where available. Do not substitute a different edition without recording the difference.

## Controlled Comparison

### A — 1.4 baseline

Run the current 1.4 Datafication workflow against the article.

Record:

- structures
- elements
- relations generated before audit
- relations after audit
- rejected candidates
- relation audit classifications

Do not alter the baseline output.

### B — 1.5 candidate

Run the same article through Structure Discovery using the current 1.4 behavior. Then perform Relation Extraction as an independent concern.

**Do not regenerate or redesign structures merely because relations are absent.**

For each explicit relation found in the article, preserve the source expression first:

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

### Extraction rules

1. Only extract a Relation when the relation itself is supported by the article text.
2. Evidence that merely supports both endpoints is insufficient.
3. Preserve exact source-level subject/object realization.
4. Preserve exact source-level predicate expression.
5. Determine direction from the sentence, including passive constructions.
6. Preserve modality and qualification.
7. `normalized_type` is optional.
8. Never replace `predicate.text` with the normalized type.
9. Never collapse `definition of B`, `development of B`, `access to B`, etc. into `B` unless the source itself identifies them as the same argument.
10. If normalization would lose a material distinction, leave `normalized_type: null`.
11. Do not infer relations across sentences merely because the two endpoints occur in nearby passages.
12. Do not add relations to make structures look complete.
13. Every extracted Relation must have exact-sentence evidence.

## C — Independent Relation Audit

Audit **only the Relations produced by B** against the original article.

Do not add, repair, or redesign Relations during the first audit pass.

For each Relation classify:

- **R0 — Faithful:** relation is explicitly supported and subject, predicate, object, direction, modality/qualification are preserved.
- **R1-A — Argument loss:** argument scope/realization materially changed.
- **R1-P — Predicate loss:** predicate changed to a stronger, weaker, or materially different expression.
- **R1-D — Direction error:** direction changed or collapsed.
- **R1-M — Modality/qualification loss:** modality or qualification changed or dropped.
- **R1-N — Normalization error:** source expression is preserved but optional normalized type is materially wrong.
- **R2 — Endpoint-only evidence:** both endpoints are supported but the relation itself is not.
- **R3 — Fabricated/model-generated relation:** relation has no adequate textual support.

Also record the diagnostic dimension for non-R0 cases where useful:

- argument scope / realization
- predicate type/granularity
- direction
- modality/qualification
- normalization
- unsupported relation

## Metrics

Do not judge success by relation count.

Record at minimum:

### Structure stability

Compare A and B:

- structure count
- element count
- structure scope
- structure origin/status
- rejected candidate count

### Relation fidelity

For B:

- total Relations extracted
- R0 count / percentage
- R1-A count / percentage
- R1-P count / percentage
- R1-D count / percentage
- R1-M count / percentage
- R1-N count / percentage
- R2 count / percentage
- R3 count / percentage

### Coverage

Where feasible, independently identify explicit relation instances in the article and estimate:

- explicit relations found by B
- explicit relations missed by B
- recall estimate

If an exhaustive gold set cannot be established reliably, report this limitation rather than inventing recall.

### Source preservation

Specifically inspect whether B preserves:

- argument scope
- predicate wording
- direction
- modality / qualification
- exact evidence

## Expected Comparison Shape

Use a table such as:

| Metric | A — 1.4 | B — 1.5 candidate |
|---|---:|---:|
| Structures | | |
| Elements | | |
| Relations generated | | |
| Relations retained after audit | | |
| R0 | | |
| R1-A | — | |
| R1-P | — | |
| R1-D | — | |
| R1-M | — | |
| R1-N | — | |
| R2 | | |
| R3 | | |

Do not force metrics that cannot be fairly computed.

## Primary Hypotheses

### H1 — Structure independence

Separating Relation Extraction from Structure Discovery does not materially reduce the quality or coverage of Structures and Elements.

### H2 — Relation fidelity

Source-first Relation Extraction produces fewer unsupported relations and preserves source semantics better than relation generation embedded in Structure Discovery.

### H3 — Normalization should remain optional

Keeping source-level predicate and argument expressions allows useful Relations to survive even when canonical normalization is uncertain.

### H4 — Relation extraction remains imperfect

Passing the schema sanity check does not imply reliable extraction on real prose. Real-article errors should be expected and diagnosed rather than hidden by normalization.

## Decision Criteria

### Strong support for 1.5 candidate

If B preserves Structure/Element results while producing a high proportion of R0 Relations and materially reduces R2/R3 errors compared with A, the candidate architecture is supported.

### Partial support

If Structure/Elements remain stable and B improves source fidelity but recall or normalization remains weak, retain the architecture as a candidate and identify the next extraction problem.

### Weak / negative result

If separating Relation Extraction materially damages Structure/Element discovery, or if source-first extraction does not improve relation fidelity, do not promote the candidate architecture yet.

## Important Boundaries

- Do **not** modify `dr3-reading/1.4`.
- Do **not** modify the decision log.
- Do **not** turn this experiment into an ontology design exercise.
- Do **not** introduce a canonical Relation ontology merely to improve scores.
- Do **not** infer missing relations from domain knowledge.
- Do **not** count more extracted relations as success.
- Keep A, B, and C outputs separately identifiable.

## Output Directory

Create:

```text
experiment-8-real-article-relation-extraction/
├── comparison-report.md
├── baseline-1.4/
│   └── datafication.json
├── candidate-1.5/
│   ├── datafication.json
│   └── datafication.md
└── audit/
    └── relation-audit.md
```

If the existing Experiment 3 article copy/output is reused, record the exact source path and commit/ref in `comparison-report.md`.

## Final Report Requirements

The report must answer:

1. Did Structure Discovery remain stable?
2. Did source-first Relation Extraction reduce unsupported relation generation?
3. Which relation dimensions still fail on real prose?
4. Did optional normalization preserve useful source information?
5. Is the candidate Relation Extraction architecture sufficiently supported for a future 1.5 implementation, or does another focused experiment remain necessary?

The final conclusion must distinguish:

- **observed result**
- **interpretation**
- **architecture implication**

Do not turn an experimental result into a permanent design decision automatically.
