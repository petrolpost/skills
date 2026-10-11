# Engineering Loop Auditor

`engineering-loop-auditor` is a Skill for auditing **engineering reasoning loops**, not for directly designing or implementing engineering solutions.

> **Engineering Loop Auditor audits engineering reasoning, not engineering output.**

It helps an Agent distinguish what is actually observed from what is inferred, identify competing explanations, design a minimally discriminating test, inspect whether evidence supports the claim being made, and check whether the validation method itself is trustworthy.

## Why It Exists

The Skill grew out of real Agent engineering work in which an unexpected result repeatedly triggered an instinct to strengthen the mechanism that produced it.

The more useful question was often earlier in the loop:

> **Is the mechanism actually necessary, and does the available evidence justify changing it?**

This led to a reusable reasoning pattern:

```text
Current System
     ↓
Real Evidence
     ↓
Observe Failure / Uncertainty
     ↓
Separate Hypotheses
     ↓
Minimal Discriminating Experiment
     ↓
Evidence
     ↓
Decision
     ↓
Minimal Change
     ↓
Validation
     ↓
Validate the Validation
     ↓
Evidence Stable?
   ↙       ↘
 no         yes
 ↓           ↓
iterate   promote / use
             ↓
        observation
```

The Skill is intended to make this reasoning available during engineering work without turning every engineering task into a formal experiment.

## When to Use It

Use the Auditor when an Agent is making or evaluating an engineering judgment under meaningful uncertainty.

Current observed use cases include:

- an unexpected engineering behavior has multiple plausible explanations;
- a mechanism is being proposed because an existing implementation failed;
- it is unclear whether a mechanism is actually necessary;
- an architectural change may be compensating for a problem elsewhere in the loop;
- evidence exists, but it is unclear whether that evidence actually supports the claim;
- a validation result is being used to justify an engineering decision;
- the validation protocol itself may be defective or contaminated;
- competing implementations or explanations need to be distinguished;
- a previous engineering decision needs to be re-examined before further changes are made;
- an Agent is approaching a merge, release, or promotion decision and needs a closure check.

These are **observed use cases, not a final specification**.

## When It Is Probably Not Needed

The Auditor is probably unnecessary when:

- the task is routine implementation with little meaningful uncertainty;
- the requirement and implementation path are already well established;
- the issue is purely syntactic or mechanical;
- no consequential engineering judgment is being made;
- a straightforward test already answers the question;
- the cost of auditing is greater than the uncertainty it would resolve.

The Skill should not be invoked merely because an engineering task exists.

## What It Does Not Do

The Auditor does **not**:

- design the final solution for the Agent;
- replace the implementing Agent or engineer;
- act as a general-purpose code reviewer;
- automatically decide which architecture is correct;
- automatically determine whether a claim is true;
- require every problem to become an A/B experiment;
- require a fixed methodology when the engineering context does not justify it;
- treat every failure as evidence that the mechanism needs to be strengthened.

Its job is to improve the quality of the **reasoning path leading to an engineering decision**.

## Core Audit Questions

At minimum, the Auditor asks four questions:

1. **What do we actually observe?**
   Is the stated problem observation, interpretation, or hypothesis?

2. **What else could explain it?**
   Is there at least one meaningful alternative, especially the possibility that the questioned mechanism is unnecessary?

3. **Does the evidence support the claim?**
   Does it support the same semantic strength, direction, scope, and conditions?

4. **Can we trust the validation?**
   Is the baseline valid? Is the control meaningful? Is the reference independent? Does the metric measure the stated objective? Has the audit itself introduced information that biases the result?

## Operating Modes

The Skill currently exposes four conceptual modes:

| Mode | Purpose |
|---|---|
| **Loop Audit** | Examine an engineering problem before implementation is changed. |
| **Evidence Audit** | Examine whether evidence actually supports a claim. |
| **Validation Audit** | Examine whether an experiment or evaluation can support its conclusion. |
| **Closure Check** | Determine whether the reasoning loop has enough evidence to stop changing the system. |

These modes are deliberately small. The Skill is not intended to become a complete engineering management framework.

## Typical Interaction

A useful request is not simply:

```text
Review this code.
```

Instead, give the Auditor the engineering uncertainty that matters:

```text
The current implementation produces an unexpected result.
We are considering changing mechanism X.
Audit whether the evidence justifies that change and identify
an alternative explanation we should test first.
```

Or:

```text
We believe change X fixed the problem because test Y passed.
Audit whether Y actually supports that claim.
```

The Auditor should normally return reasoning artifacts such as:

```text
Observed
Interpretations
Competing hypotheses
Missing alternative
Discriminating experiment
Expected evidence
Decision rule
```

It should not silently turn these into an implementation plan unless the surrounding engineering workflow explicitly asks for that next step.

## Evidence and Boundaries

A central principle is:

> **Evidence exists ≠ evidence supports the claim.**

The Auditor therefore preserves the distinction between:

```text
Observation
   ↓
Interpretation
   ↓
Hypothesis
   ↓
Experiment
   ↓
Evidence
   ↓
Decision
```

It also treats validation as an engineering object. A failed validation may indicate:

```text
implementation defect
        or
validation / protocol defect
```

These must not be conflated.

## Current Evidence Base

The Skill currently has two materially different engineering cases behind it:

- **Datafication / relation extraction** — the originating case, where source-first extraction, claim/evidence fit, necessity testing, and validation-of-validation became explicit engineering concerns.
- **Capability Discovery** — a separate engineering case used to test whether the reasoning pattern transfers outside Datafication.

The Capability Discovery case provided evidence that the reasoning loop transfers to a different engineering domain. It did **not** establish that every rule of the Auditor is universally applicable.

The detailed evidence and limitations are kept under `references/` rather than being treated as normative rules here.

## Scope Is an Open Question

The scope of `engineering-loop-auditor` is intentionally **not fully specified yet**.

The Skill originated by observing recurring engineering reasoning patterns in real work. Its current scope is therefore an empirical hypothesis rather than a finished methodology.

The next phase is **Integration Application**:

```text
Skill prototype
      ↓
Integration into real Agent engineering work
      ↓
Observe actual use
      ↓
When does it help?
When is it unnecessary?
When does it mislead?
When is it too expensive?
      ↓
Revise scope
      ↓
Repeat
```

The README records the **current boundary**. Integration cases provide the evidence for changing that boundary.

## Integration Application

The next stage is not primarily a runtime feature exercise. It is an application experiment:

> **Put Engineering Loop Auditor into a real Agent engineering workflow and observe what changes.**

The first integrations should therefore favor real engineering tasks with genuine judgment space over artificial benchmarks.

Questions to observe include:

- Does the Agent invoke the Auditor at useful moments without being forced to?
- Does the Auditor change what the Agent investigates before implementation?
- Does it expose alternatives that would otherwise be missed?
- Does it reduce unnecessary implementation changes?
- Does it improve validation quality?
- Does it sometimes slow down work without adding useful information?
- Does the Auditor itself make incorrect or overly formal judgments?
- What kinds of engineering problems fall outside its useful scope?

These observations should feed back into the Skill rather than being hidden as exceptions.

## Relationship to Other Skills

`engineering-loop-auditor` and `decision-archivist` operate at different points in the engineering reasoning process.

- **Engineering Loop Auditor:** Why does this engineering decision have enough evidence to stand?
- **Decision Archivist:** What was decided, and how does it relate to previous decisions?

The Auditor can produce evidence lineage that is useful to the Decision Archivist, but it does not own the Decision state.

## Current Limitations

This prototype:

- does not automatically execute experiments;
- does not automatically determine truth;
- does not guarantee that a useful alternative can always be constructed;
- does not establish universal engineering laws;
- has not yet been validated across many domains, runtimes, models, or team workflows;
- may be unnecessary for simple engineering tasks;
- still needs real-world integration evidence to determine its practical invocation boundary.

## Development Principle

Do not optimize the Auditor merely to make the Skill more complete.

Prefer:

```text
real engineering use
    ↓
observed limitation
    ↓
minimal change
    ↓
validation
    ↓
updated scope
```

A stable boundary is more valuable than a theoretically complete one.

## Status

**Prototype — moving from transfer validation to Integration Application.**

The current README should be treated as a living description of the Skill's observed scope. Changes to its scope should preferably be backed by an integration case or other concrete evidence.
