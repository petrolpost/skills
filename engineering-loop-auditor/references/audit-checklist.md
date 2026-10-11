# Engineering Loop Audit Checklist

## Problem framing

- [ ] Is the problem stated as an observation before interpretation?
- [ ] Is the target capability explicit?
- [ ] Is the failure criterion explicit?

## Hypotheses

- [ ] Is the current explanation named?
- [ ] Is there at least one competing explanation?
- [ ] Has “the mechanism may not be necessary” been considered where applicable?
- [ ] Do alternatives make different predictions?

## Experiment

- [ ] Does the experiment distinguish hypotheses rather than merely produce more examples?
- [ ] Is there a removal/ablation/control condition when appropriate?
- [ ] Are expected outcomes specified before looking at results?
- [ ] Is the reference set independent?

## Evidence

- [ ] Does evidence support the claim itself?
- [ ] Does semantic strength match?
- [ ] Does direction match?
- [ ] Does scope match?
- [ ] Are multiple propositions being incorrectly combined?
- [ ] Is source-level evidence preserved?

## Decision

- [ ] Is the decision tied to observed evidence?
- [ ] Are rejected alternatives recorded?
- [ ] Is the minimal boundary change clear?

## Validation

- [ ] Does the baseline actually exercise the old mechanism?
- [ ] Does the control remove only the intended factor?
- [ ] Is the metric aligned with the stated objective?
- [ ] Can the audit itself introduce a claim?
- [ ] Can another reviewer reproduce the judgment?

## Closure

- [ ] Is the result stable enough to promote?
- [ ] Are unresolved hypotheses explicitly retained?
- [ ] Is there a reason to continue optimizing, supported by new evidence?
- [ ] Otherwise, enter observation/usage rather than inventing more work.