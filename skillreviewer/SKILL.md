---
name: SkillReviewer
description: |
  Reviews a Claude Skill for publication readiness — checks structure, security, description quality, spec compliance, and cross-skill conflicts. Use this skill when the user says: "review this skill", "is this skill ready to publish", "audit my skill", "check my SKILL.md", "score my skill", "is my skill up to date with the spec", "do my skills conflict", or "help me improve this skill". Also trigger when the user uploads or pastes a SKILL.md and asks for feedback or quality check. 也可用中文触发：「帮我检查这个skill」、「这个skill能发布吗」、「审查我的skill」、「我的skill有问题吗」。
---

# SkillReviewer

**CRITICAL RULE: Produce every section below in full. Do not summarize, collapse, or skip any section. Do not jump to the Health Score without completing all prior steps. Every table must be filled in with real findings — never leave cells empty or use placeholder text.**

Output language: match the user's language automatically.

---

## 0 — Detect Input Mode

- **Single file**: user gave a path, pasted content, or uploaded a SKILL.md → run Sections 1–6
- **Batch**: multiple Skills or "all my skills" → run Sections 1–5 per Skill, then Section 6 across all
- **Ambiguous**: ask "Which SKILL.md would you like me to review?"

---

## 1 — Structure Report

Read the SKILL.md. Then **MUST OUTPUT** this table with real values:

| Field | Value |
|-------|-------|
| Skill name | |
| Line count | |
| YAML fields present | |
| Non-standard YAML fields | |
| Files in directory | |
| Bundled references / scripts | |
| Architecture type | Tool Wrapper / Router / Pipeline / Knowledge Base |

**YAML validation**: list every frontmatter field. Flag anything not in (`name`, `description`, `compatibility`) as ❌ non-standard.

**Architecture classification**: pick exactly one type and justify in one sentence.

---

## 2 — Technology & Process Report

**MUST OUTPUT**:

**Tech stack detected** (list every language, library, or external tool mentioned; write "none" if absent):

**Prompt engineering patterns** (mark each ✅ present / ❌ absent, add one line of evidence):

| Pattern | Status | Evidence |
|---------|--------|----------|
| Chain-of-Thought (step-by-step reasoning) | | |
| Few-Shot Examples | | |
| Persona / role definition | | |
| Explicit output format specification | | |
| Negative examples ("do not…") | | |

**Workflow summary**: 2–3 sentences describing execution flow.

---

## 3 — Security Report

**MUST OUTPUT** — every row requires a real Severity and Finding:

| Risk | Severity | Finding |
|------|----------|---------|
| Network calls (curl / wget / fetch / requests) | Low/Med/High | |
| Code execution (exec / subprocess / os.system) | Low/Med/High | |
| Package installs (pip / apt / npm) | Low/Med/High | |
| Prompt injection ($ARGUMENTS unsanitized) | Low/Med/High | |
| Over-permission (allowed-tools mismatch) | Low/Med/High | |
| Read/write contradiction | Low/Med/High | |
| Token bloat (>500 lines) | Low/Med/High | |

For any Med or High: add a **Mitigation:** line directly below that row.

---

## 4 — Description Quality Score

Read only the `description` field. **MUST OUTPUT**:

```
Description Quality Score: XX/100

  Trigger Breadth (30)   XX/30  — [one-line justification]
  Specificity     (25)   XX/25  — [one-line justification]
  Action Clarity  (25)   XX/25  — [one-line justification]
  Pushiness       (20)   XX/20  — [one-line justification]
```

- Score < 80: **MUST OUTPUT** a rewritten description (max 60 words) under "Suggested rewrite:"
- Score ≥ 80: write "Description is strong — no rewrite needed."

Scoring guide in `references/scoring.md`.

---

## 5 — Spec Compliance Check

**MUST OUTPUT** — fill every Status and Finding cell:

| Rule | Status | Finding |
|------|--------|---------|
| Only `name`, `description`, `compatibility` in YAML | ✅/❌ | |
| `description` contains trigger phrases, not just function summary | ✅/❌ | |
| SKILL.md body ≤ 500 lines | ✅/❌ | |
| Large reference content in `references/`, not inline | ✅/❌ | |
| All files referenced in body actually exist | ✅/❌ | |
| No hardcoded absolute paths | ✅/❌ | |
| Multi-line file creation uses heredoc, not `echo "\n"` | ✅/❌ | |
| No `allowed-tools` field | ✅/❌ | |

After the table: list every ❌ as a numbered action item with priority (High / Med / Low).

---

## 6 — Cross-Skill Conflict Detection

**Run only when 2+ Skills are in scope, or user asks about conflicts.**

For each Skill pair, check: trigger phrase overlap, domain overlap, implicit dependency.

**MUST OUTPUT** one entry per finding:

```
[⚠️ OVERLAP / 🔗 DEPENDENCY / ✅ CLEAN]: SkillA ↔ SkillB
  Reason: [what overlaps or depends]
  Fix: [concrete recommendation]
```

**Note**: In Claude.ai, only Skills present in the current conversation can be compared. Full global scan requires Claude Code.

---

## 7 — Health Score

Compute after Sections 1–5 are complete. **MUST OUTPUT**:

```
Health Score: XX/100  [🔴/🟡/🟢/⭐]

  Structure validity    XX/20   (Section 1: YAML + file integrity)
  Security posture      XX/25   (Section 3: worst severity found)
  Description quality   XX/25   (Section 4 score × 0.25)
  Spec compliance       XX/20   (Section 5: ✅ count / 8 × 20)
  Conflict cleanliness  XX/10   (Section 6 if run, else full marks)

🔴 <50   Not production-ready
🟡 50–74 Needs improvement
🟢 75–89 Good, minor polish
⭐ 90+   Excellent
```

**Top 3 action items**: highest-impact fixes, each referencing its source section.

---

## Reference Files

- `references/scoring.md` — detailed scoring rubric for Section 4
- `references/spec.md` — full Anthropic Skill spec for Section 5
