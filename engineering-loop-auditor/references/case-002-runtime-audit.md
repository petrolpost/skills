# Case #002 — Runtime Evidence Audit

- Date: 2026-09-07
- Evidence: `case-002-runtime-execution-result.md`
- Protocol: `case-002-runtime-execution.md`
- Auditor: Engineering Loop Auditor review

## Verdict

**Bounded evidence: supported. General architectural claim: not established.**

The T1/T2/T3 run is a valid and useful runtime experiment for the narrower claim that, in a file-based instruction-following Agent environment with one visible provider, the demonstrated capability-consumption path can complete without a Registry and can tolerate provider replacement while the consumer remains byte-identical.

It is **not** sufficient to establish the broader statement that the Registry is unnecessary for capability discovery or for the architecture in general. In particular, the run did not exercise native registered-Skill invocation, multi-provider selection, dynamic registration, version negotiation, or larger-scale discovery.

## Evidence Audit

### Claim 1

> The tested path does not require the Registry.

**Support: Strong within the tested scope.**

Evidence:

- T1 consulted the Registry and completed successfully.
- T2 removed only the Registry file while keeping the consumer and provider files byte-identical.
- T2 completed successfully without a Registry and selected the provider from its capability declaration.
- Pre/post SHA256 checks show no subject modified the environment.

The T2 ablation is the discriminating evidence. T1 demonstrates use/usability when present; it does not demonstrate necessity.

### Claim 2

> Provider identity is not part of the consumer contract.

**Support: Moderate-to-strong within the tested scope.**

T3 kept the consumer byte-identical and replaced the provider. The replacement had a different declared name (`friendly-language-helper`) and a non-indicative directory name (`banana-helper`). The provider still declared `greeting` and exposed a public entry, and the task succeeded.

The evidence is therefore substantially cleaner than T1/T2 for rejecting provider-name dependence.

### Claim 3

> Capability declaration is sufficient as a general discovery mechanism.

**Not established.**

Only one candidate provider was visible in each cell. There was no competing declaration, ambiguity, ranking, tie-breaking, or failure case. The experiment establishes sufficiency for this single-candidate path, not a general selection mechanism.

## Validation Audit

| Check | Result | Assessment |
|---|---|---|
| Input equivalence | Pass T1↔T2; Partial T2↔T3 | T1/T2 differ by Registry removal only. T3 also changes provider declaration form and naming semantics. |
| Baseline validity | Pass | T1 actually read and used the Registry as its primary resolution path. |
| Control validity | Pass with residual-reference note | T2 removes the Registry file, but `consumer/skill.yaml` still contains a comment referring to discovery through the Registry. This did not cause a Registry lookup, but the ablation is not a textual purge of all Registry references. |
| Independent reference set | Pass | Expected greetings come from provider public entries rather than subject output. |
| Proposition boundaries | Pass | The six protocol criteria, rather than greeting generation alone, were used for scoring. |
| Metric/objective alignment | Pass | The success criteria directly correspond to the stated experiment question. |
| Audit non-interference | Pass with caveat | Environments remained byte-identical and subjects were blinded to the hypotheses. However, the conductor authored the reporting scaffold. |
| Reproducibility | Pass with limitation | Construction, provenance, hashes, prompts, and raw reports are preserved; n=1 per cell and one model/runtime family limit robustness. |

## Important Validation Findings

### 1. Self-reported process traces are not logs

The T2 subject paraphrased the consumer's Registry-related comment as capability matching. The actual file content was independently preserved, so the scored outcome is not invalidated. But this demonstrates that an Agent's retrospective process narration can silently rewrite source semantics.

**Classification:** validation limitation, not implementation defect.

For a future protocol, actual tool-call traces should be captured where possible, with the subject's report treated as supplementary evidence.

### 2. T1/T2 provider-name semantics are confounded

`greeter` is semantically close to `greeting`, so self-report cannot completely exclude a name-based shortcut in T1/T2.

T3 is the cleaner test because both `banana-helper` and `friendly-language-helper` are non-indicative of `greeting`.

**Classification:** known experimental confound; does not invalidate T2's Registry-ablation result, but limits interpretation of the declaration-based selection claim.

### 3. T3 changes more than provider identity

T3 changes provider identity, directory naming, and declaration form (from `skill.yaml` + `SKILL.md` to prose-only `SKILL.md`). The successful result is useful for demonstrating consumer/provider contract looseness, but it cannot be used as a controlled comparison of declaration formats.

**Classification:** confound, explicitly bounded.

### 4. Native Skill invocation was not exercised

The subjects reported that the file-based Skills were not registered as invocable Skills and therefore read and followed their instructions directly.

This means the experiment demonstrates **Agent instruction-following over Skill artifacts**, not the stronger claim that a native Skill registration/invocation mechanism does not require a Registry.

**Classification:** protocol-scope limitation, not an invalidation of the narrower file-based result.

### 5. Blindness was materially improved

The conductor knew the hypotheses and scoring rules, but each subject received only the task prompt and neutral reporting scaffold. The subjects did not see the protocol, historical audit, repository, or interpretation rules.

This is a meaningful mitigation against conclusion leakage. It does not eliminate post-hoc rationalization in the report, which is why the source files and hashes remain primary evidence.

### 6. No pre-deposited per-run predictions

The protocol contained interpretation rules in advance, but the conductor did not persist a separate pre-run prediction artifact for each cell.

**Classification:** protocol improvement opportunity; not outcome-invalidating.

## Hypothesis Update

- **H5 — Registry is not a required architectural dependency for the tested collaboration class:** **supported only after narrowing the class** to the demonstrated file-based, single-provider, instruction-following path. The broader architectural formulation remains unproven.
- **H1 — Registry quality is the main bottleneck:** unresolved.
- **H2 — Capability declaration is the bottleneck:** unresolved; T3's declaration-form variation is incidental.
- **H3 — Consumer requirement representation is the bottleneck:** unresolved.
- **H4 — Discovery mechanism is the bottleneck:** unresolved; only one discovery procedure was exercised.

## Decision

Promote the following bounded observation:

> In the tested file-based collaboration path, one consumer can discover a single provider by capability declaration and use its public entry without consulting a Registry; the same consumer can also complete the task after the provider is replaced while the consumer remains byte-identical.

Do **not** promote the stronger statement:

> "The Registry is unnecessary for capability discovery in general."

That statement requires new evidence.

## Rejected Interpretations

- **"T1 used the Registry, therefore the Registry is necessary."** Rejected: presence-use is not necessity; T2 is the ablation and succeeded.
- **"T2/T3 prove the Registry is worthless."** Rejected: scale, competing providers, dynamic registration, and versioning were not tested.
- **"T3 proves declaration formats are interchangeable."** Rejected: declaration form changed as a confound rather than as a controlled factor.
- **"The Agent's process trace is equivalent to an execution log."** Rejected: T2 demonstrates silent paraphrasing of source content.
- **"This experiment validates native Skill registration/invocation."** Rejected: the subjects did not invoke registered Skills; they followed the file instructions directly.

## Closure

**Evidence is stable for the bounded observation.** No modification to `engineering-loop-auditor/SKILL.md` is justified by a repeatable defect in the auditor itself.

The next experiment should only be created if we choose a new question, such as:

1. multi-provider selection when several Skills declare the same capability;
2. native OpenCode Skill registration/invocation rather than file-based instruction-following;
3. discovery behavior as the number of visible Skills grows.

These are separate questions and should not be smuggled into Case #002.

## Minimal Record

```yaml
problem: "Does the demonstrated capability-consumption path require a Registry?"
observations:
  - "T1 strong success; Registry consulted."
  - "T2 strong success; Registry absent; provider discovered by declaration."
  - "T3 strong success; provider replaced; consumer byte-identical."
  - "All environments remained byte-identical before/after."
hypotheses:
  - id: H5
    claim: "Registry is not required for the tested file-based single-provider collaboration path."
    status: "supported within tested scope"
  - id: H1
    claim: "Registry quality is the main bottleneck."
    status: "unresolved"
  - id: H2
    claim: "Capability declaration is the bottleneck."
    status: "unresolved"
  - id: H3
    claim: "Consumer requirement representation is the bottleneck."
    status: "unresolved"
  - id: H4
    claim: "Discovery mechanism is the bottleneck."
    status: "unresolved"
alternatives_rejected:
  - "Presence-use proves Registry necessity."
  - "T2/T3 prove Registry is generally unnecessary."
  - "T3 is a controlled declaration-format comparison."
  - "Self-reported trace equals execution log."
experiment:
  question: "Does the tested path complete with Registry removal and provider replacement?"
  design: "T1/T2/T3 with blinded subjects, isolated environments, checksums, and preserved raw reports."
evidence:
  - "Verbatim subject reports."
  - "Pre/post SHA256 verification."
  - "T1/T2/T3 scoring against pre-existing strong-success criteria."
decision:
  outcome: "Promote bounded file-based observation; do not generalize to native Skill runtime or general architecture."
  rationale: "T2 is a successful ablation; T3 provides provider-identity evidence; validation limitations are documented and none invalidate the bounded result."
implementation: null
validation:
  status: "completed"
  audit_status: "completed; limitations recorded"
closure: "observation"
```