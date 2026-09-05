# DR3-Reading 1.5 — Implementation Review

## Review Scope

Review `dr3-reading/1.4` before modifying production behavior. The purpose is to identify the minimum locations where Relation generation is coupled to Structure Discovery.

## Current Findings

The 1.4 datafication function template currently describes the primary output as a structure instance and its schema includes `structure.elements`, `structure.relations`, and `structure.constraints`. It also explicitly requires claim-level provenance for relations and constraints. This means the existing document contains two distinct ideas that must be separated carefully:

1. Relations as one possible component used to describe a discovered structure.
2. Relations as independently extractable source-grounded knowledge.

The experiments establish that the second capability should not be required by the first.

## Required Review Questions

### Structure Discovery coupling

Check whether any instruction says, explicitly or implicitly:

- every structure must contain relations;
- relations should be generated to explain connections among elements;
- a structure is incomplete when relations are absent;
- relations should be inferred from co-mentioned elements.

If found, replace only the coupling, not the general evidence/provenance discipline.

### Relation representation

Check whether current examples represent a relation as only:

```yaml
from: A
relation: affects
to: B
```

If so, 1.5 should add source-first representation without requiring immediate normalization.

### Provenance

Keep the existing rule that every relation/constraint has its own evidence. The new architecture should strengthen this by making relation evidence independent from endpoint evidence.

### State and trace

Inspect the protocol and any other DR3 documents for assumptions that a completed Datafication artifact requires relation output. Absence of relations must remain a valid completed result.

Do not create a new state machine unless a real implementation dependency requires it.

### Downstream consumers

Search for consumers of `datafication` and determine whether they:

- read `structure.relations` as mandatory;
- depend on a canonical relation type;
- assume relation generation occurred during Datafication.

If no such dependency exists, do not modify the consumer.

## Minimal Migration Rule

Prefer instruction-level separation over schema proliferation.

The desired semantic change is:

```text
1.4
Structure Discovery
  └── structure may contain relations
       ↑ relation generation tends to be coupled here

1.5
Structure Discovery
  └── structure does not require relations

Relation Extraction (optional)
  └── independently extracts explicit source-grounded relations
```

The fact that a relation can later be linked to structure elements does not make relation extraction part of structure discovery.

## Do Not Change Yet

- Datafication state lifecycle unless necessary.
- Structured extraction.
- Synthesis.
- Other DR3 modules.
- The relation audit experiments.
- Historical experiment records.

## Review Outcome

The implementation can proceed with a minimal 1.5 change focused on `datafication.md` and, only if inspection demonstrates a dependency, the corresponding state/trace or downstream documentation.

The experiment branch remains the evidence record. Production `main` remains unchanged until the 1.5 implementation is explicitly validated.