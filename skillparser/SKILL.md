---
name: SkillParser
description: |
  Reverse-engineers a Claude Skill to extract its embedded business logic, design decisions, user model, and reusable patterns — helping you learn from how others build Skills. Use this skill when the user says: "help me understand this skill", "what is this skill really doing", "reverse engineer this skill", "what can I learn from this skill", "why is it designed this way", "what patterns does this skill use", "break down this skill for me", or "analyze the logic behind this skill". Also trigger when the user pastes or uploads a SKILL.md and seems to want to understand or learn from it rather than fix it. 也可用中文触发：「帮我读懂这个skill」、「这个skill的设计逻辑是什么」、「我想学习这个skill的思路」、「拆解这个skill」。
---

# SkillParser

**CRITICAL RULE: Produce every section below in full. Do not summarize or skip. Your job is not to evaluate quality — it is to make implicit design decisions explicit. Every insight must be grounded in specific evidence from the Skill text.**

Output language: match the user's language automatically.

---

## 0 — Detect Input

Accept a SKILL.md via path, upload, or paste. If the user also provides project context files (AGENTS.md, rules/, other Skills), read them — they are essential for Section 5.

If no file is provided: ask "Which Skill would you like me to parse?"

State at the start: which files you have access to, and which you don't (this affects depth of Section 5).

---

## 1 — What This Skill Actually Does

Do not restate the description field. Instead, **MUST OUTPUT**:

**Core job** (one sentence): what problem does this Skill solve that Claude alone could not solve well without it?

**User model**: who is the assumed user, and what state are they in when they trigger this Skill? (e.g., "a job seeker who has already prepared a meta-resume and now faces a specific opportunity")

**What the Skill replaces**: what would the user have to do manually, or what would Claude do differently, without this Skill?

**Scope boundary**: what does this Skill explicitly NOT do, and why? (infer from omissions and "do not" rules)

---

## 2 — Step-by-Step Logic Decomposition

For each step or phase in the Skill, **MUST OUTPUT** a row in this table:

| Step | Name | Real purpose | Key constraint | Output |
|------|------|-------------|----------------|--------|
| | | | | |

**Real purpose**: go beyond the step title. Why does this step exist at this position in the flow? What would break if it were skipped or reordered?

**Key constraint**: the most important rule embedded in this step (explicit or implicit).

After the table, identify:
- **Decision gates**: steps where the flow can branch or terminate — what triggers each branch?
- **Ordering logic**: why are steps in this sequence? Which dependencies force the order?

---

## 3 — Embedded Business Logic

This is the core of SkillParser. Extract rules that encode business knowledge — things that would not be obvious to someone unfamiliar with the domain.

**MUST OUTPUT** each rule in this format:

```
Rule: [state the rule clearly]
Type: Hard constraint / Soft preference / Default assumption
Evidence: [quote or paraphrase the exact line in the Skill]
Why it exists: [infer the business or user-experience reason]
What breaks without it: [what failure mode this rule prevents]
```

Produce at least one entry per major step. Do not summarize multiple rules into one.

---

## 4 — Design Decisions Worth Learning

Identify 3–5 design choices the author made that are non-obvious and transferable to other Skills.

**MUST OUTPUT** each as:

```
Pattern: [name the pattern in a reusable way]
How it's used here: [specific evidence from this Skill]
When to use it: [what conditions make this pattern appropriate]
When NOT to use it: [what conditions make it a poor fit]
```

Examples of patterns to look for (not exhaustive):
- Gate-before-generate (judge first, produce output only if warranted)
- Anchor document (single source of truth for facts)
- Persona enforcement (explicit voice/tone rules with examples)
- Mandatory intermediate artifact (required output before next phase)
- Negative constraint cascade (rules that propagate across all steps)

---

## 5 — Project Fit Analysis

**Run this section only if project context files are available** (AGENTS.md, rules/, other Skills, data files).

If no context: write "Project context not available — Section 5 skipped. To enable this section, provide project files alongside the Skill."

If context available, **MUST OUTPUT**:

**Resources used well**: which project files, rules, or other Skills does this Skill correctly integrate with?

**Resources not used but should be**: what exists in the project that this Skill ignores but could benefit from?

| Missing integration | What it is | What would improve |
|--------------------|------------|-------------------|
| | | |

**Data flow gaps**: does this Skill's output connect back into the project's data structures? If not, what's missing?

**Conflict with other Skills**: does this Skill's scope overlap with any other Skill in the project?

---

## 6 — Reusable Takeaways

Synthesize what someone reading this Skill should walk away knowing.

**MUST OUTPUT**:

**Top insight** (one sentence): the single most important thing this Skill teaches about Skill design.

**Transferable patterns** (list): the 2–3 patterns from Section 4 most worth borrowing for other contexts.

**Limitations to be aware of**: what assumptions or constraints are baked in that would break if the context changed?

**If you were to adapt this Skill**: what would you keep, what would you change, and why?
