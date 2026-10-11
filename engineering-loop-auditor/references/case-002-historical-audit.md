# Case #002 — Historical Audit Result

## Scope

This is an audit of the existing Capability Discovery / Skill-to-Skill Collaboration prototype history. It is **not** a new runtime execution of an Agent. Historical commits and artifacts are treated as evidence of what was implemented and what the repository records as an experiment.

The distinction matters: repository state can establish that a counterfactual was implemented, but cannot by itself establish that an Agent successfully executed the scenario unless execution evidence is recorded.

## Observations

1. The initial Capability Discovery prototype contains a Registry file, `registry/capabilities.yaml`, but its README explicitly says the Registry is only for experimental observation and the Agent is not required to depend on it.
2. The consumer Skill discovers providers by inspecting available Skills, matching the declared capability, then reading the provider's public entry. It does not instruct the consumer to query the Registry.
3. The prototype's stated test includes replacing the provider while keeping the consumer unchanged.
4. A later `skill-to-skill-collaboration` prototype removes the Registry, `skill.yaml`, and dedicated consumer Skill. Ordinary `SKILL.md` files carry capability declaration, usage instructions, and collaboration boundaries.
5. The later prototype explicitly asks the Agent to discover `weather-greeting`, then discover a `greeting` provider and use its public entry.
6. The repository history contains a commit titled `进行了3轮实验` whose diff removes `capabilities.yaml`, replaces the original provider with `banana-helper`, adds `weather-helper`, and preserves capability-based rather than provider-name-based interaction.
7. The repository history also contains a commit titled `prototype: test skill-to-skill collaboration` that changes `weather-helper` from directly providing `greeting` to composing `weather-greeting` from another discovered `greeting` capability.

## Audit of hypotheses

### H1 — Registry quality is the main bottleneck

**Status: not supported by the available evidence.**

The consumer's documented discovery path does not require the Registry, and a later prototype removes the Registry entirely. However, no controlled failure/recovery experiment is recorded that isolates Registry quality while holding the other variables fixed.

### H2 — Capability declaration is the bottleneck

**Status: unresolved.**

The prototypes use capability declarations successfully, but there is no controlled comparison varying declaration quality while holding discovery and consumer requirement fixed.

### H3 — Consumer requirement representation is the bottleneck

**Status: unresolved.**

The consumer requirement is represented as `greeting`, and later a nested requirement appears inside `weather-helper`, but there is no controlled variation of requirement representation.

### H4 — Discovery mechanism is the bottleneck

**Status: unresolved.**

The prototypes demonstrate a discovery procedure, but there is no controlled comparison of alternative discovery mechanisms.

### H5 — Registry is not a required architectural dependency for the tested collaboration

**Status: supported within the tested scope, but not proven universally.**

A later prototype explicitly removes the Registry while preserving the capability contract and public-entry collaboration model. The repository therefore contains a genuine architectural removal/counterfactual at the design level. What remains missing is independently recorded runtime evidence showing the Agent's success under the Registry-free condition.

## Evidence strength

The strongest defensible conclusion is:

> The prototype design does not require a Registry for the demonstrated capability-consumption path, and the repository contains an explicit Registry-removal evolution. This is evidence against treating Registry presence as a necessary architectural premise for that bounded scenario.

It is **not** justified to conclude:

> Registry is unnecessary for capability discovery in general.

Nor is it justified to conclude that Registry, declarations, or discovery algorithms are irrelevant at larger scale.

## Validation audit

| Check | Result | Reason |
|---|---|---|
| Input equivalence | Partial | The historical evolution changes more than one artifact at once. |
| Baseline validity | Pass for design comparison | The earlier Registry-bearing prototype is identifiable. |
| Control validity | Weak | No isolated runtime control is recorded. |
| Independent reference set | Not available | No independent provider/reference benchmark is recorded. |
| Success definition | Partial | The README defines intended success, but execution traces are not preserved here. |
| Information leakage | Partial | The written test explicitly instructs discovery behavior; actual Agent prompt/trace is not preserved. |
| Failure interpretation | Not applicable | No failure dataset is preserved for this comparison. |
| Audit non-interference | Pass | This audit does not modify the historical prototype. |

## Transfer verdict

**The reasoning loop transfers successfully at the conceptual level.** It naturally exposes the Registry-removal hypothesis without importing Datafication-specific concepts.

**The case is not yet a full experimental validation of the tool.** The missing piece is runtime execution evidence under controlled conditions.

## Next experiment

Use the smallest possible controlled runtime matrix:

1. Registry present / direct provider discovery.
2. Registry absent / same provider set and same task.
3. Registry absent / provider replaced, consumer unchanged.

Record the actual Agent trace and outcome, without telling the Agent which provider or discovery path should succeed.

Only after this should the auditor be judged on runtime transfer rather than repository-level reasoning transfer.
