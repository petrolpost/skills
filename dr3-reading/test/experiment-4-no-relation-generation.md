# Experiment 4 — Relation Optionality / No-Forced-Relation

## Purpose

Test whether relations are necessary for successful Datafication structure discovery, or whether the 1.4 relation output is partly produced by a structural-completion tendency.

This is a controlled rerun of the **Victorian diary-writers** article. The article, importer output, and original 1.4 Datafication result remain unchanged. Only the Datafication generation instruction changes.

## Research question

> If relation generation is no longer treated as a normal/default part of completing a structure, does Structure discovery and Element extraction remain substantially intact?

The experiment must **not** modify the canonical `main` specification.

## Control

Use the existing article and existing 1.4 result:

`dr3-reading/test/victorian-diary-writers/`

Do not change:

- `original/article.md`
- the existing 1.4 `datafication/datafication.json`
- the existing 1.4 `datafication/datafication.md`

Create the new result in a separate directory:

`dr3-reading/test/victorian-diary-writers/experiment-4-no-relation-generation/`

## Experimental instruction

Run Datafication against the same original article with the following additional constraint:

> **Relations are optional, not required for structural completeness.**
>
> First identify the dataficable structure and its elements. Do not create relations merely because two or more elements belong to the same structure, are discussed together, occur nearby, or appear in a meaningful order.
>
> Create a relation only when the original text independently expresses a relation between the two elements with compatible direction and semantic strength.
>
> Evidence for element A plus evidence for element B is not evidence for A → B.
>
> Do not infer causality, dependency, enablement, transformation, sequence, maintenance, production, or other semantic relations from co-occurrence.
>
> If no independently supported relation exists, leave the relation set empty. An internally sparse structure is valid and should not be repaired for completeness.
>
> Do not add, delete, or reinterpret elements merely to compensate for the absence of relations.

Keep the existing 1.4 requirements for:

- structure discovery
- local/section/article scope
- importance
- explicit/reconstructed/inferred origin
- claim-level provenance
- evidence consistency
- rejected candidates
- conceptualization detection
- conservative semantic strength

## Required output

Produce the same core Datafication schema as 1.4, but allow:

```yaml
relations: []
```

when no relation has sufficient evidence.

For every retained relation, provide its own provenance and evidence as required by 1.4.

## Comparison protocol

After generation, compare Experiment 4 with the original 1.4 result **before looking at whether the relation count is lower**.

Record:

### 1. Structure stability

For each original DS object:

- retained / substantially retained / missing
- scope changed?
- importance changed?
- origin changed?

Also record any newly discovered structure, but do not add one merely because the experimental prompt encourages caution.

### 2. Element stability

For each original element:

- retained
- weakened
- removed
- materially changed

Record whether the change is actually supported by the source or appears to be an artifact of the experimental instruction.

### 3. Relation result

Report:

- number of relations in original 1.4
- number retained in Experiment 4
- number rejected
- for each retained relation, why independent relation evidence exists

### 4. Evidence quality

Check whether the experiment still preserves claim-level provenance for retained relations and substantive element attributes.

### 5. Main observation

Answer only this question:

> Does removing the expectation of relational completeness materially damage the discovery of structures and elements?

Do not infer the final Datafication design from this experiment alone.

## Expected interpretations

### Result A — Structures/elements stable, relations sharply reduced

Supports the hypothesis that relations are not necessary for structure discovery and that 1.4 may over-generate relations during structure construction.

### Result B — Structures/elements substantially degrade

Suggests that relations may be functioning as a useful intermediate representation for discovering or reconstructing structures. Further investigation is needed before making relations optional.

### Result C — Mixed result

Inspect which kinds of structures degrade. Relation optionality may depend on structure origin or structure type.

## Important constraint

This is an experiment, not a specification change.

Do not update `dr3-reading/SKILL.md` or `dr3-reading/references/functions/datafication.md` as part of this experiment.
