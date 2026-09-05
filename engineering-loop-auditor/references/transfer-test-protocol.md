# Transfer Test Protocol

The Engineering Loop Auditor must be tested on a materially different engineering problem before its rules are expanded.

## Test principle

Do not ask whether the target architecture is good. Ask whether the auditor changes the engineering process in a useful, evidence-preserving way.

## Required sequence

1. Record observations without importing a solution.
2. Separate observations from interpretations.
3. Enumerate at least two competing hypotheses.
4. Include a necessity/removal hypothesis when an existing mechanism is implicated.
5. Design the smallest experiment that produces different predictions for competing hypotheses.
6. Define evidence before observing the result where practical.
7. Separate endpoint evidence from claim-level support.
8. Audit the validation method before accepting its conclusion.
9. Preserve rejected hypotheses and their rejection evidence.
10. Stop when the stated decision has stable supporting evidence.

## Transfer success criteria

A case passes the transfer test if the auditor can perform the sequence without requiring concepts, metrics, or conclusions that were specific to the original Datafication case.

A case does **not** pass merely because the final recommendation resembles Case #001.

## Failure categories

- **Concept leakage** — auditor imports a Datafication-specific concept into the new problem.
- **Premature solutioning** — auditor jumps from problem to implementation.
- **Missing alternative** — auditor fails to test whether the implicated mechanism is necessary.
- **Evidence inflation** — endpoint or co-occurrence evidence is treated as stronger claim support.
- **Validation blindness** — auditor accepts a flawed baseline, reference set, or metric.
- **Over-formalization** — auditor creates a schema/framework that exceeds the evidence needed for the case.
- **Closure failure** — auditor continues optimization after evidence is stable without a new question.

## Decision rule

The auditor itself should be modified only when the transfer case reveals a repeatable failure in the auditing process, not merely because the target engineering problem is difficult.
