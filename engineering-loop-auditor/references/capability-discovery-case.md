# Case #002 — Capability Discovery

## Why this case exists

Case #001 came from Datafication. Case #002 deliberately uses a different engineering problem: Agent/Skill capability discovery.

The purpose is **not** to prove the capability-discovery architecture correct. It is to test whether the engineering-loop reasoning can be applied without importing the conclusions of Case #001.

## Starting problem

A capability consumer needs a capability supplied by another Skill. The engineering question is how capability discovery should work, including the role of registration/Registry and the public provider entry point.

A previously run prototype established one concrete behavior:

```text
consumer needs capability
        ↓
discover provider Skill
        ↓
use provider's public entry
        ↓
complete collaboration
```

A related prototype also demonstrated multiple Skills declaring/providing the same `greeting` capability, including a consumer that discovers a provider and composes the capability into a larger task.

These are observations about the prototype, not yet proof of a general architecture.

## Initial interpretations to resist

Several explanations can easily be mistaken for the problem itself:

- "The Registry needs to be more intelligent."
- "Capability declarations need a richer ontology."
- "Discovery should be centralized."
- "The consumer should know providers directly."

None of these is an observation.

## Competing hypotheses

### H1 — Registry quality is the main bottleneck

Discovery failures primarily come from insufficient registration/indexing. Improving Registry data should materially improve discovery.

### H2 — Capability declaration is the bottleneck

The discovery mechanism is adequate, but provider Skills do not expose sufficiently precise capability descriptions.

### H3 — Consumer requirement representation is the bottleneck

Providers may be discoverable, but consumers describe their needed capability in a way that does not match available declarations.

### H4 — Discovery mechanism is the bottleneck

The Registry/declarations may be adequate, but the matching/search procedure fails to select the right provider.

### H5 — Registry is not a required architectural dependency

A consumer can discover or compose against a published capability contract without a central Registry, at least for the target class of collaboration.

H5 is deliberately included because a natural engineering response tends to optimize the existing mechanism before testing whether that mechanism is necessary.

## Discriminating experiments

Do not immediately implement a richer Registry.

### Experiment A — Declaration adequacy

Hold discovery mechanism fixed. Create provider Skills whose capability declarations vary in specificity while keeping the underlying capability identical.

Question:

> Does discovery quality change primarily with declaration quality?

Evidence should distinguish:

- provider exists
- capability exists
- declaration is discoverable
- declaration is semantically matchable

### Experiment B — Consumer representation

Hold provider declarations fixed. Vary only the consumer's capability requirement representation.

Question:

> Does discovery success change primarily with the way the consumer expresses its need?

### Experiment C — Discovery mechanism

Hold declarations and consumer requirement fixed. Compare discovery procedures.

Question:

> Is the failure attributable to matching/search rather than the Registry data itself?

### Experiment D — Removal / counterfactual

Remove the Registry from a deliberately bounded collaboration scenario while preserving the public provider capability contract.

Question:

> Is the Registry actually necessary for the capability-consumption path being evaluated?

A successful result would not prove "Registry is unnecessary" in general. It would establish only that the tested collaboration does not require it.

## Evidence discipline

Do not count these as equivalent:

```text
Provider A declares capability X.
Consumer asks for capability X.
```

and:

```text
The discovery mechanism successfully selected A because
A's declaration semantically satisfies the consumer's need.
```

The first is endpoint evidence. The second is discovery evidence.

Likewise:

```text
A and B both provide greeting.
```

does not by itself establish:

```text
A is interchangeable with B under every consumer context.
```

## Validation audit questions

Before concluding that a discovery architecture is better, verify:

1. Are provider Skills equivalent across the comparison except for the intended variable?
2. Is the consumer requirement held constant when testing provider-side hypotheses?
3. Is the provider set constructed independently of the discovery result?
4. Is success defined as "found a provider" or "found a semantically suitable provider and successfully invoked its public entry"?
5. Does the test accidentally give the consumer information that the discovery mechanism is supposed to discover?
6. Does a failure demonstrate a discovery defect, or merely an unavailable capability?
7. Does the audit introduce assumptions about capability equivalence that the prototype never established?

## Current status

This case is a **transfer test specification**, not a claim that H1–H5 have been experimentally resolved.

The important observation is already useful: the same loop can be instantiated without carrying over Datafication's specific concepts such as relations, source-level predicates, or proposition boundaries.

The next evidence needed is execution of the discriminating experiments against the actual capability-discovery prototype.
