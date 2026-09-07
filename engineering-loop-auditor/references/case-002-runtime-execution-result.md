# Case #002 — Runtime Execution Result

- Date: 2026-09-07
- Protocol: `case-002-runtime-execution.md`
- Predecessor: `case-002-historical-audit.md` (design-level evidence only; runtime evidence was the missing piece)

## Scope

This run resolves the blocker recorded in the protocol: an actual Agent runtime executed the T1/T2/T3 matrix.

Separation of roles:

- **Conductor** (this audit session): knew the hypotheses, the interpretation rules, and the success criteria. Built the environments, issued the prompts, scored the results.
- **Subjects** (one fresh general-purpose subagent per cell): received only the protocol's task prompt, plus neutral reporting instructions (see below). They did not see the protocol, the historical audit, the repository, the interpretation rules, or the success criteria. This is how "the Agent stays blind to the expected architectural conclusion" was operationalized.

Subject runtime: general-purpose subagents of the current Agent environment (same model family as the conductor). n = 1 per cell. All subjects executed the Skills by reading and following their written instructions (the file-based Skills were not registered as invocable Skills in the runtime — every subject noted this and chose instruction-following as the execution mode).

## Test matrix construction

Environments were built in a neutral temp location (`E:\CodexTemp\chg_g\case002-runtime\`), outside the audited repository, so that no experiment README or decision record was visible to the subjects.

File provenance — all files are verbatim copies:

- consumer (SKILL.md + skill.yaml) and greeter (SKILL.md + skill.yaml): `prototype/capability-discovery/skills/{consumer,greeter}/`
- registry: `prototype/capability-discovery/registry/capabilities.yaml`
- T3 alternate provider: `prototype/skill-native-capability/skills/banana-helper/SKILL.md` (declared name `friendly-language-helper`; prose-only capability declaration, no skill.yaml — the form it has in the repository)

Layouts:

```text
T1/  (Registry-bearing baseline)
  registry/capabilities.yaml
  skills/consumer/SKILL.md
  skills/consumer/skill.yaml
  skills/greeter/SKILL.md
  skills/greeter/skill.yaml

T2/  (Registry removal — identical files, registry deleted)
  skills/consumer/SKILL.md
  skills/consumer/skill.yaml
  skills/greeter/SKILL.md
  skills/greeter/skill.yaml

T3/  (Provider replacement — registry-free, greeter replaced)
  skills/banana-helper/SKILL.md
  skills/consumer/SKILL.md
  skills/consumer/skill.yaml
```

SHA256 before and after the runs (identical — no file was created, modified, or deleted by any subject; 12 files total, no extras):

```text
FABE89330CB0D4A3757EDD36E25296E270EE5E88DD3C845C8FDA488FC3259CD7  T1/registry/capabilities.yaml
907013AA29E033DC2782458AAD51A68A5238D0A0B8FC84963CF329E9E4628A4E  T1/skills/consumer/SKILL.md
853E74DF04807377557D0CE71269A322ABDB365BED2134E1F7B4D2D23E189E5C  T1/skills/consumer/skill.yaml
8EF6226F78B4F40C37303314AC042645EEFCCE7CA3FE28A20E4C2B7AE63C016E  T1/skills/greeter/SKILL.md
92FC57F34A8F0A4BDDC3A43C98DE7DBDA5FA3EBCDC803A589E01A0B843C6DA6D  T1/skills/greeter/skill.yaml
907013AA29E033DC2782458AAD51A68A5238D0A0B8FC84963CF329E9E4628A4E  T2/skills/consumer/SKILL.md
853E74DF04807377557D0CE71269A322ABDB365BED2134E1F7B4D2D23E189E5C  T2/skills/consumer/skill.yaml
8EF6226F78B4F40C37303314AC042645EEFCCE7CA3FE28A20E4C2B7AE63C016E  T2/skills/greeter/SKILL.md
92FC57F34A8F0A4BDDC3A43C98DE7DBDA5FA3EBCDC803A589E01A0B843C6DA6D  T2/skills/greeter/skill.yaml
232E777A3EB68A16745B79416B5339AA36424372A7A3D356A6F55261658BE147  T3/skills/banana-helper/SKILL.md
907013AA29E033DC2782458AAD51A68A5238D0A0B8FC84963CF329E9E4628A4E  T3/skills/consumer/SKILL.md
853E74DF04807377557D0CE71269A322ABDB365BED2134E1F7B4D2D23E189E5C  T3/skills/consumer/skill.yaml
```

The consumer files are byte-identical across T1/T2/T3, so "T3 completed without changing the consumer" holds at construction and was preserved through the run (post-run hashes unchanged).

### Prompts given to subjects (verbatim)

Conductor-added scaffolding (identical for all three cells, designed to obtain a process narration without mentioning the Registry or the experiment's purpose):

```text
Your working directory for this task is: <env path>

Rules:
- Everything you need is inside the working directory above. Do not explore outside it.
- Do not create, modify, or delete any files.

When finished, output a report with exactly these four sections:

1. Final result — the greeting text you produced.
2. Process trace — every file you opened (full path, in the order you opened them), what you were looking for at that step, and what you found in it.
3. Provider selection — which Skill you used as the provider, and what specifically made you choose it.
4. Uncertainties — any point where you were unsure, took a wrong turn, or had to retry.
```

Protocol task prompts (verbatim from `case-002-runtime-execution.md`):

- T1: `Complete one greeting using the available capability-consumer Skill. Do not assume a provider name; discover the capability and use its public entry.`
- T2: `Complete one greeting using the available capability-consumer Skill. Discover the required capability from the available Skills and use the provider's public entry. Do not assume a provider name.`
- T3: identical to T2.

## Raw execution evidence

The three subject reports are preserved verbatim below. Only harness metadata (agent IDs / system reminders appended by the runtime) was excluded; the report text itself is unedited. Conclusions appear only in later sections, never inside the raw evidence.

### T1 — Registry-bearing baseline (subject report, verbatim)

```text
I explored the working directory, followed the consumer Skill's discovery rule, and produced the greeting by resolving the capability through the registry to the provider's public entry. No files were created, modified, or deleted.

## 1. Final result

**Hello from the greeter capability.**

## 2. Process trace

First, I listed the full directory tree of `E:\CodexTemp\chg_g\case002-runtime\T1` to discover the layout: a `registry\` folder and a `skills\` folder containing two skills, `consumer` and `greeter`. Then I opened every file (in one parallel batch, listed here in batch order):

| # | File (full path) | What I was looking for | What I found |
|---|---|---|---|
| 1 | `E:\CodexTemp\chg_g\case002-runtime\T1\registry\capabilities.yaml` | The capability registry — how capabilities map to providers | The registry declares one capability: `greeting`, with provider `greeter` and public entry `greet` |
| 2 | `E:\CodexTemp\chg_g\case002-runtime\T1\skills\consumer\SKILL.md` | The consumer Skill's instructions — what it requires and how to fulfill it | The consumer requires the `greeting` capability. Its discovery rule: do **not** assume a provider name; inspect available Skills' declared capabilities, find one providing `greeting`, read that Skill's public entry instructions, and use the public entry. If none is found, report the capability as unavailable |
| 3 | `E:\CodexTemp\chg_g\case002-runtime\T1\skills\consumer\skill.yaml` | Machine-readable declaration of the consumer's requirements | Confirms `requires: [greeting]`; explicitly notes it intentionally does not name the provider and discovers it via the capability registry |
| 4 | `E:\CodexTemp\chg_g\case002-runtime\T1\skills\greeter\SKILL.md` | The provider candidate's public entry instructions | The greeter provides `greeting`. Its public entry says: "Say: `Hello from the greeter capability.`" and notes the consumer should depend on the capability name, not the Skill name |
| 5 | `E:\CodexTemp\chg_g\case002-runtime\T1\skills\greeter\skill.yaml` | Confirmation of the provider's declared capability and entry | Declares `provides: [greeting]` and `entries.greet: "Hello from the greeter capability"` — matching the registry's `entry: greet` |

Discovery chain executed: consumer requires `greeting` → registry maps `greeting` → provider `greeter`, entry `greet` → greeter's SKILL.md public entry → greeting text produced.

## 3. Provider selection

I used the **`greeter` Skill** (at `E:\CodexTemp\chg_g\case002-runtime\T1\skills\greeter`) as the provider. What made me choose it:

- The consumer Skill forbids assuming a provider name, so I resolved the capability through the registry: `capabilities.yaml` explicitly binds the `greeting` capability to provider `greeter` with public entry `greet`.
- Cross-verification confirmed the binding: the greeter's own `skill.yaml` declares `provides: [greeting]` with `entries.greet`, matching the registry — so it is genuinely the declared provider, not an assumption.
- I followed the consumer's discovery rule exactly: read the provider's public entry instructions in `greeter\SKILL.md` and used that entry ("Say: `Hello from the greeter capability.`") to fulfill the requirement, depending on the capability name rather than the provider name.

## 4. Uncertainties

- **Trailing-period discrepancy between the two provider files.** `greeter\SKILL.md` says to say `Hello from the greeter capability.` (period inside the backticks), while `greeter\skill.yaml` gives `entries.greet: "Hello from the greeter capability"` (no period). I chose the SKILL.md version because the consumer's discovery rule explicitly directs the reader to "read that Skill's public entry **instructions** and use the public entry," and SKILL.md is the instruction document. The difference is only a trailing period.
- **Whether to invoke the Skill tool.** The consumer/greeter Skills exist only as files in the working directory and are not registered in the environment's invocable Skill list, so I could not (and per the rules, should not) call them via the Skill tool by guessing a name. Instead I executed the consumer Skill's discovery procedure manually by reading its instructions and following them verbatim — which satisfies "use the available capability-consumer Skill" since I followed its documented discovery rule end-to-end.
- I initially read all files in a single batch rather than one at a time in strict dependency order; this did not affect the outcome since the discovery chain was fully consistent across all sources, but the "order opened" in Section 2 reflects batch order rather than a sequential discovery walk.
```

### T2 — Registry removal (subject report, verbatim)

```text
1. **Final result**

   Hello from the greeter capability.

2. **Process trace**

   - Step 0 (directory survey, not a file): ran a recursive listing of `E:\CodexTemp\chg_g\case002-runtime\T2` to see what exists. Found exactly two Skills, `consumer` and `greeter`, each with a `SKILL.md` and a `skill.yaml` — four files total, nothing else.
   - `E:\CodexTemp\chg_g\case002-runtime\T2\skills\consumer\SKILL.md` — opened to learn what the capability-consumer requires. Found: it requires the capability `greeting`, and its discovery rule forbids assuming a provider name; instead: inspect available Skills' declared capabilities → find one providing `greeting` → read that Skill's public entry instructions → use the public entry. If no provider is found, report the capability as unavailable.
   - `E:\CodexTemp\chg_g\case002-runtime\T2\skills\consumer\skill.yaml` — opened to confirm the machine-readable requirement. Found: `requires: [greeting]`, with an explicit comment that the consumer intentionally does not name a provider and discovers one via capability matching.
   - `E:\CodexTemp\chg_g\case002-runtime\T2\skills\greeter\SKILL.md` — opened while searching for which available Skill provides `greeting`. Found: this Skill declares it provides the capability `greeting`, and its Public entry section instructs: "Say: `Hello from the greeter capability.`" It also notes consumers should depend on the capability name, not the Skill name.
   - `E:\CodexTemp\chg_g\case002-runtime\T2\skills\greeter\skill.yaml` — opened to cross-check the capability declaration. Found: `provides: [greeting]` and a named entry `greet: "Hello from the greeter capability"`, confirming this is the provider.

   (Files 1–4 were read in a single parallel batch; the order above reflects the read request order.)

3. **Provider selection**

   I used the `greeter` Skill (at `E:\CodexTemp\chg_g\case002-runtime\T2\skills\greeter\`) as the provider. What made me choose it: the consumer Skill declares a requirement for the capability `greeting` without naming any provider; following its discovery rule, I inspected the only other available Skill in the working directory, and `greeter` declares `greeting` in both its `skill.yaml` (`provides: [greeting]`) and its `SKILL.md` ("This Skill provides the capability: `greeting`"). I then followed its public entry instruction ("Say: `Hello from the greeter capability.`") to produce the greeting. No provider name was assumed ahead of time — it was discovered purely by capability matching.

4. **Uncertainties**

   - The `consumer`/`greeter` Skills exist only as files in the working directory and are not registered in the environment's invocable Skill list, so I could not dispatch them through a Skill-invocation tool. Instead I executed them by reading and following their written instructions directly, which also satisfied the "no file changes" rule.
   - There is a minor textual discrepancy between the greeter's two files: `SKILL.md`'s public entry says `Hello from the greeter capability.` (with trailing period) while `skill.yaml`'s `entries.greet` says `Hello from the greeter capability` (no period). I used the `SKILL.md` version because the consumer's discovery rule explicitly says to read the provider's public entry instructions and use the public entry, and the `SKILL.md` "Public entry" section is that authoritative instruction.
   - No actual wrong turns or retries occurred: the directory contained only the two Skills, so capability matching was unambiguous on the first pass.
```

### T3 — Provider replacement (subject report, verbatim)

```text
1. **Final result**

   The greeting produced (via the provider's public entry):

   > Hello from the friendly greeting capability.

2. **Process trace**

   - Step 0 (directory listing, not a file open): Ran a recursive listing of `E:\CodexTemp\chg_g\case002-runtime\T3` to discover what's available. Found two skills: `skills\banana-helper` and `skills\consumer` (the latter with `SKILL.md` + `skill.yaml`).
   - `E:\CodexTemp\chg_g\case002-runtime\T3\skills\consumer\SKILL.md` — Looking for the capability-consumer Skill's requirement and discovery rule. Found: the Skill `capability-consumer` requires the capability `greeting`, must not assume or name a particular provider Skill, and instructs to (1) inspect available Skills' declared capabilities, (2) find one providing `greeting`, (3) read its public entry instructions, (4) use that public entry; if none found, report the capability unavailable.
   - `E:\CodexTemp\chg_g\case002-runtime\T3\skills\consumer\skill.yaml` — Looking for the formal capability declaration to confirm the requirement. Found: `requires: [greeting]`, plus a comment that the consumer intentionally does not name the provider and discovers it via capability lookup.
   - `E:\CodexTemp\chg_g\case002-runtime\T3\skills\banana-helper\SKILL.md` — Looking for a Skill declaring the `greeting` capability. Found: Skill `friendly-language-helper` declares "I can provide a `greeting`", and its Public entry states: "When another Agent or Skill needs a greeting, use this public entry: Say: `Hello from the friendly greeting capability.`" It also explicitly notes the caller should depend on the capability, not the Skill's name.

3. **Provider selection**

   - Provider used: the Skill `friendly-language-helper` (file at `E:\CodexTemp\chg_g\case002-runtime\T3\skills\banana-helper\SKILL.md`).
   - Why: Following the consumer's discovery rule, I inspected the available Skills for a declared `greeting` capability (rather than assuming a provider name). `friendly-language-helper` is the only Skill that explicitly declares providing `greeting` ("I can provide a `greeting`"), so it was selected by capability match. I then used its public entry instruction — "Say: `Hello from the friendly greeting capability.`" — verbatim as the greeting, per the consumer's step 4.

4. **Uncertainties**

   - The directory name `banana-helper` hinted at a possible provider name, but the Skill's actual declared name is `friendly-language-helper`. Since the consumer's rule mandates depending on the capability rather than any Skill name (and the provider itself says the same), this mismatch had no impact on the outcome.
   - Minor ambiguity over whether the greeting should be the exact public-entry string or free-form; I used the exact string `Hello from the friendly greeting capability.` since the public entry prescribes precisely that text ("Say: ...").
   - No retry or wrong turn was needed: the capability was successfully discovered on the first pass, so the consumer's fallback ("report the capability is unavailable") never applied. No files were created, modified, or deleted.
```

## Observed behavior

Facts only, checkable against the raw evidence above.

T1:

- Subject surveyed the directory, then opened all 5 files (registry file first in batch order).
- Registry was actually consulted: `registry/capabilities.yaml` was read, and the subject's stated resolution path was "consumer requires `greeting` → registry maps `greeting` → provider `greeter`, entry `greet`", with the provider's own declarations used as cross-verification.
- Final output: `Hello from the greeter capability.` — byte-match with the greeter SKILL.md public entry.
- Subject noticed the trailing-period discrepancy between greeter SKILL.md and skill.yaml and resolved it in favor of SKILL.md (the instruction document).

T2:

- Subject surveyed the directory (4 files, no registry present), opened consumer files, then the provider's files.
- No registry existed and the subject did not report searching for one.
- Provider selection was stated as declaration-based: greeter declares `greeting` in both its files.
- Final output: `Hello from the greeter capability.` — same public entry as T1.
- Discrepancy note: the consumer skill.yaml actually says `# It discovers a provider through the capability registry.` The subject's report paraphrased this comment as "discovers one via capability matching" — a meaning-changing paraphrase produced by the subject's own narration, not present in the file. Behaviorally this made no difference (no registry was sought), but it is direct evidence that self-reported traces can silently rewrite source content (see Validation audit).

T3:

- Subject surveyed the directory (consumer + banana-helper), opened consumer files, then banana-helper SKILL.md.
- Provider selected: `friendly-language-helper` (declared name), whose directory name (`banana-helper`) carries no greeting semantics.
- Selection was stated as declaration-based: the only Skill declaring `greeting`, via its prose declaration ("I can provide a `greeting`") — no skill.yaml present in this provider.
- Final output: `Hello from the friendly greeting capability.` — byte-match with the alternate provider's public entry.
- Consumer files hash-identical before/after: the consumer was not modified.
- No registry mention or search at any point.

Cross-cutting:

- All three subjects treated "use the Skill" as "read its instructions and follow them" (the file-based Skills were not invocable through a Skill tool in the runtime).
- All three environments remained byte-identical after the runs (checksum table above).
- No subject reported a failure, fallback ("capability unavailable"), or need to retry.

## Scoring — strong success criterion

Per `case-002-runtime-execution.md`, success is not "the Agent produced a greeting".

| # | Criterion | T1 | T2 | T3 |
|---|---|---|---|---|
| 1 | consumer need was identified | Yes | Yes | Yes |
| 2 | provider discovered without being named in the prompt | Yes | Yes | Yes |
| 3 | provider selected because its capability declaration/public contract matched the need | Yes — registry binding, cross-verified against provider's own declarations | Yes — declaration match in provider's skill.yaml + SKILL.md | Yes — prose declaration in SKILL.md ("I can provide a `greeting`"); directory name non-indicative, so name-based selection was not available |
| 4 | provider public entry was used | Yes | Yes | Yes |
| 5 | task completed | Yes | Yes | Yes |
| 6 | T3 completed without changing the consumer | n/a | n/a | Yes — hash-verified |

All three cells are strong successes under the protocol's criterion. No cell required the fallback path.

## Interpretation

Applying the protocol's interpretation rules to the observed results:

- **T2 success shows that the tested path does not require the Registry.** With the Registry deleted and everything else held byte-identical, the subject discovered the provider by capability declaration matching and completed the task through the public entry.
- **T3 success adds evidence that provider identity is not part of the consumer contract** (within the tested scope): the consumer, byte-unchanged, completed the same task against a different provider with a different name, a different declaration form (prose-only, no manifest), and a non-indicative directory name.
- **T1 success alone does not establish that the Registry is necessary.** T1 shows the Registry was *used* when present (it was the first file read and the subject's stated primary resolution path), i.e. it is usable as an index — but use under presence is not necessity. T2 is the cell that bears on necessity, and it removed only that factor.
- No T2/T3 failure occurred, so the protocol's failure-interpretation rule (inspect declaration, requirement representation, discovery procedure, test leakage before blaming the Registry) was not invoked.

## Hypothesis update

Against the hypotheses enumerated in `capability-discovery-case.md`:

- **H5 (Registry is not a required architectural dependency for the tested collaboration class): supported within the tested scope, now with runtime evidence.** Previously this was supported only at the design level (the repository's own Registry-removal evolution). This run adds controlled runtime evidence: same consumer, same provider, same task, Registry removed, strong success (T2); and provider replaced, consumer unchanged, strong success (T3).
- **H1 (Registry quality is the main bottleneck): still unresolved.** This matrix did not vary Registry quality, and no discovery failure was observed for any hypothesis to explain.
- **H2 (capability declaration is the bottleneck): still unresolved.** Declaration form varied incidentally between T1/T2 (structured, skill.yaml + SKILL.md) and T3 (prose-only SKILL.md) and both succeeded, which weakly suggests declaration form was not the bottleneck *for these two forms* — but this was a confound, not a designed comparison, so it cannot support a claim.
- **H3 (consumer requirement representation is the bottleneck): still unresolved.** Requirement representation was held constant.
- **H4 (discovery mechanism is the bottleneck): still unresolved.** Only one discovery procedure (read-and-match over visible Skills) was exercised.

Not claimed: that the Registry is unnecessary for capability discovery in general; anything about scale (many providers), multi-provider selection under competing declarations, versioning, dependency resolution, or dynamic registration. The tested scope is: one consumer need, one visible candidate provider, one task, instruction-following Agent runtime, n = 1 per cell.

## Decision

Within the audited scope, the minimal collaboration contract — capability declaration carried in the provider's own Skill documents, a public entry, and a consumer discovery rule that matches declarations rather than names — completed the task in all three cells, including the Registry-removal and provider-replacement counterfactuals.

The defensible statement is:

> For this bounded collaboration class, the Registry is not a required architectural dependency at runtime: discovery-by-declaration completed the path with the Registry absent (T2) and with the provider swapped while the consumer stayed byte-identical (T3). The Registry, when present, was used as an index (T1) — evidence of usability, not of necessity.

Rejected alternatives preserved:

- "T1 proves the Registry is necessary" — rejected: presence-use is not necessity; the T2 ablation is the discriminating cell and it succeeded.
- "T2/T3 success proves the Registry is worthless" — rejected: no scale, multi-provider, or versioning condition was tested.
- Inflating the incidental T1/T2-vs-T3 declaration-form difference into a claim about declaration forms — rejected: it is a confound in this matrix, not a designed comparison.

Closure status: evidence is stable for the bounded claim above. Per the skill's stopping rule, no further optimization of this prototype is warranted without a new question supported by new evidence. Retained open questions (not to be executed without a new protocol): multi-provider selection behavior when several Skills declare the same capability (the repository's `skill-native-capability` prototype already stages this but it was not tested here); discovery behavior at larger Skill counts.

## Validation audit

Auditing this experiment itself, per Mode C:

| Check | Result | Reason |
|---|---|---|
| Input equivalence | Pass (T1↔T2); Partial (T2↔T3) | T1 vs T2 differ only by the registry file (hashes confirm). T3 changes the provider *and* its declaration form (no skill.yaml) and directory-name semantics — a confound, documented, not designed. |
| Baseline validity | Pass | The T1 subject actually consulted the Registry (first file read; stated primary resolution path), so the baseline genuinely exercised the Registry-bearing path rather than bypassing it. |
| Control validity | Pass with a note | T2/T3 remove only the registry file at the file level. However, the consumer's own skill.yaml comment ("It discovers a provider through the capability registry") still textually references the removed mechanism in T2/T3. Neither subject was derailed by it, but it is a residual reference to the ablated factor. |
| Independent reference set | Pass | Expected outputs were fixed a priori by the providers' public entries (`Hello from the greeter capability.` / `Hello from the friendly greeting capability.`), independent of subject output. |
| Proposition boundaries | Pass | Scoring used the protocol's six-item strong criterion (need identified / discovered-not-named / declaration-based selection / public entry used / completed / consumer unchanged), not "produced a greeting". |
| Metric/objective alignment | Pass | The six items map 1:1 to the protocol's success definition; no substitute metric was introduced. |
| Audit non-interference | Pass | Environments hash-identical before/after; subjects reported and checksums confirm no modification. The conductor knew the hypothesis — mitigated by blind subjects and verbatim protocol prompts, but see limitations. |
| Reproducibility | Pass with a note | Full construction spec, provenance, checksums, verbatim prompts, and verbatim reports are recorded above. n = 1 per cell; single model family; single prompt phrasing per cell. |

Limitations and defects found in the validation itself (not in the tested system):

1. **Self-reported traces are narrations, not logs.** The T2 subject paraphrased the consumer skill.yaml comment "discovers a provider through the capability registry" into "discovers one via capability matching" — silently rewriting source content in the direction of what it actually did. File contents are independently checkable (and were checked); reading order and internal reasoning are not. A stricter protocol would capture actual tool-call logs rather than self-report.
2. **Name-semantics confound in T1/T2.** The provider's directory/skill name (`greeter`) is semantically aligned with the capability (`greeting`), so name-based shortcut selection cannot be fully excluded from self-report alone in those cells. T3 — where both the directory name (`banana-helper`) and the declared name (`friendly-language-helper`) are non-indicative — is the clean cell for declaration-based selection, and it succeeded.
3. **Conductor-designed report scaffolding.** The four-section report format (including "Provider selection — what specifically made you choose it") was authored by the knowing conductor and may elicit post-hoc rationalization. The protocol's own task prompts were used verbatim, which limits the exposure.
4. **No pre-deposited per-run predictions.** The decision rules were pre-registered in the protocol (what T2/T3 success means), but the conductor did not deposit per-run predictions in a durable artifact before execution. Recorded as a protocol gap for future runs.
5. **n = 1, single model family, single runtime.** Results are consistent with the historical design-level evidence but are one run per cell.
6. **Execution mode caveat.** "Runtime execution" here means an Agent reading and following Skill instructions over files, not a harness invoking registered Skills. The blocker in the protocol ("requires an actual Codex/Cursor-class Agent runtime") is resolved in this sense only.

Classification: no implementation defect and no validation-protocol defect was observed that would invalidate the scored outcome; the items above are recorded so that a future replication can close them.

## Record

```yaml
problem: "Does the capability-consumption path require the Registry at runtime?"
observations:
  - "T1 strong success; Registry consulted (first file read; stated primary resolution path)."
  - "T2 strong success; Registry absent; discovery by declaration matching; no registry sought."
  - "T3 strong success; provider replaced (prose-only declaration, non-indicative names); consumer byte-unchanged (hash-verified)."
  - "All environments hash-identical before/after; no fallback path invoked."
hypotheses:
  - id: H5
    claim: "Registry is not a required architectural dependency for the tested collaboration class."
    status: "supported within tested scope (runtime evidence)"
  - id: H1
    claim: "Registry quality is the main bottleneck."
    status: "unresolved (not tested)"
  - id: H2
    claim: "Capability declaration is the bottleneck."
    status: "unresolved (incidental variation only)"
  - id: H3
    claim: "Consumer requirement representation is the bottleneck."
    status: "unresolved (held constant)"
  - id: H4
    claim: "Discovery mechanism is the bottleneck."
    status: "unresolved (single procedure exercised)"
alternatives_rejected:
  - "T1 proves Registry necessity (presence-use != necessity; T2 ablation succeeded)."
  - "T2/T3 success proves Registry is worthless in general (scope untested)."
  - "Declaration-form comparison claim from T1/T2 vs T3 (confound, not designed)."
experiment:
  question: "Does the tested path complete with the Registry removed, and with the provider replaced?"
  design: "T1/T2/T3 matrix; blind general-purpose subagents; isolated envs in neutral temp location; checksums before/after."
  expected_results: "Strong success per protocol criterion; T2/T3 are the cells bearing on Registry necessity and provider-identity independence."
evidence:
  - "Three verbatim subject reports (raw section above)."
  - "SHA256 before/after, 12 files, identical."
decision:
  outcome: "Within the audited scope, the Registry is not a required runtime dependency; capability declaration + public entry + consumer discovery rule sufficed."
  rationale: "T2 ablation and T3 replacement both strong successes with consumer byte-identical; T1 shows Registry used when present (usability, not necessity)."
implementation: null
validation:
  status: "completed (all three cells scored strong success)"
  audit_status: "completed (6 limitations recorded, none invalidating)"
closure: "promote (bounded claim); enter observation; no further optimization without new evidence"
```
