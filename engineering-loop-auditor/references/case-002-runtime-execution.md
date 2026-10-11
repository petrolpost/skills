# Case #002 — Runtime Execution Protocol

## Purpose

Close the remaining gap in Case #002: obtain actual Agent execution evidence rather than relying only on repository history.

This protocol intentionally keeps the Agent blind to the expected architectural conclusion.

## Test matrix

### T1 — Registry-bearing baseline

Use the original `prototype/capability-discovery` setup.

Available artifacts:
- consumer Skill requiring `greeting`
- one provider Skill
- Registry file present

Prompt:

> Complete one greeting using the available capability-consumer Skill. Do not assume a provider name; discover the capability and use its public entry.

Record:
- which Skill was selected
- how it was discovered
- whether the Registry was actually consulted
- final result

### T2 — Registry removal

Use the same bounded collaboration scenario with the Registry removed. Keep provider capability and consumer requirement otherwise equivalent.

Prompt:

> Complete one greeting using the available capability-consumer Skill. Discover the required capability from the available Skills and use the provider's public entry. Do not assume a provider name.

Record the same fields.

### T3 — Provider replacement

Use the Registry-free setup but replace the original provider with the alternate provider. Keep the consumer unchanged.

Prompt:

> Complete one greeting using the available capability-consumer Skill. Discover the required capability from the available Skills and use the provider's public entry. Do not assume a provider name.

Record the same fields.

## Strong success criterion

Do not score success merely as “the Agent produced a greeting.”

A strong success record requires:

1. the consumer need was identified;
2. a provider was discovered without being named in the prompt;
3. the provider was selected because its capability declaration/public contract matched the need;
4. the provider public entry was used;
5. the task completed;
6. T3 completed without changing the consumer.

## Interpretation rules

- T2 success shows that the tested path does not require the Registry.
- T3 success adds evidence that provider identity is not part of the consumer contract.
- T1 success alone does not establish that the Registry is necessary.
- T2/T3 failure must not immediately be interpreted as a Registry defect; inspect declaration, requirement representation, discovery procedure, and test leakage first.

## Evidence capture

Preserve the actual Agent trace/output for each run. Do not rewrite the trace into a conclusion before saving it.

The final audit record should separate:

```text
Raw execution evidence
Observed behavior
Interpretation
Hypothesis update
Decision
Validation audit
```

## Current blocker

This protocol requires an actual Codex/Cursor-class Agent runtime with the prototype Skills made available to it. The GitHub repository alone cannot provide that runtime trace.
