---
name: SkillPaser
description: |
  Statically analyzes Claude Skills for structure, technologies, security risks, and design patterns — then uses them as templates to generate new Skills. Use this skill whenever the user says: "analyze this skill", "audit a skill", "review SKILL.md", "design a new skill based on X", "what does this skill do", "find risks in a skill", "is my skill up to date", "score my skill", "do my skills conflict", or "create a skill variant". Also trigger when the user uploads or pastes a SKILL.md file and wants feedback, describes an idea they want turned into a skill, or asks to batch-compare multiple skills. Even for casual phrasing like "look at my skill" or "is this skill good?", use this skill. 也可用中文触发：「分析这个skill」、「帮我设计一个skill」、「我的skill有问题吗」、「帮我优化skill」。
---

# SkillPaser: Static Meta-Analysis for Claude Skills

## Overview

This skill performs static analysis on Claude Skills (single or batch). It covers:

- **Structure**: Directory layout, files, YAML frontmatter
- **Technologies & Processes**: Languages, libraries, workflow patterns
- **Security**: Risks including prompt injection, over-permissions, logic vulnerabilities
- **Description Quality Score**: Quantified trigger coverage rating with rewrite suggestions
- **Cross-Skill Conflict Detection**: Trigger overlap and dependency issues across multiple Skills
- **Spec Upgrade Check**: Diff current Skill against latest Anthropic standards; list outdated patterns
- **Health Score**: Weighted composite score across all dimensions for at-a-glance quality assessment
- **Diff-Driven Generation**: Variant generation that identifies what to replace vs. reuse, not just template copy
- **Freeform Input Mode**: Design a Skill from a plain-language idea description, no existing SKILL.md needed

All analysis is **read-only** (bash cat/grep/ls only; no execution of analyzed code).

## Configuration

**Output language**: Match the user's language. If the user writes in Chinese, respond in Chinese. Default is English.

---

## Input Modes

SkillPaser accepts three types of input — detect automatically:

| Mode | Trigger signal | Entry point |
|------|---------------|-------------|
| **File / Path** | User gives a path or uploads a SKILL.md | → Step 2 |
| **Batch** | Multiple paths, a parent dir, or "all my skills" | → Step 2 (loop) |
| **Freeform** | User describes an idea without a file ("I want a skill that…") | → Step F |

If input is ambiguous, ask: "Do you have an existing SKILL.md to analyze, or do you want to design one from scratch?"

---

## Process (File / Batch Mode)

### Step 1 — Gather Input

- Accept Skill path(s), a pasted SKILL.md, or an uploaded file.
- If no path given, list candidates: `ls ~/.claude/skills/` or check `/mnt/skills/`.
- **Path note**: `~/.claude/skills/` assumes a Unix home directory. On Windows or custom installs, ask the user to confirm their Skills directory before proceeding.
- For batch: loop Steps 2–7 over each Skill; aggregate at the end.

### Step 2 — Structure Analysis

```bash
ls -R <skill-path>              # Directory layout
head -30 <skill-path>/SKILL.md  # YAML frontmatter + opening
wc -l <skill-path>/SKILL.md     # Size check (flag if >500 lines)
```

Report in a table:

| Component | Type | Findings |
|-----------|------|----------|

Validate YAML fields — only `name`, `description`, `compatibility` are standard. Flag any others.

### Step 3 — Technology & Process Analysis

```bash
# Dependency manifests
ls <path>/{requirements.txt,package.json,pyproject.toml,go.mod} 2>/dev/null

# Code structure (if scripts/ exists)
grep -rE "def |class |function |^func " <path>/scripts/ 2>/dev/null

# Tech stack keywords
grep -rEi "python|bash|node|pandas|pdfplumber|openpyxl|requests" <path>/ 2>/dev/null
```

Classify the Skill architecture:
- **Tool Wrapper** — wraps a CLI or API (e.g., pdf, git)
- **Router/Decision Tree** — guides user to sub-resources
- **Pipeline/Workflow** — executes a fixed sequence of steps
- **Knowledge Base** — pure documentation/RAG

Identify prompt engineering patterns used: Chain-of-Thought, Few-Shot Examples, Persona definitions.

### Step 4 — Security Analysis

**Shallow scan:**

```bash
grep -rEi "curl|wget|http|requests|fetch" <path>/      # Network (potential exfiltration)
grep -rEi "exec|os\.system|subprocess|bash !" <path>/  # Code injection
grep -rEi "pip install|apt-get|npm install" <path>/    # Forbidden installs
```

**Deep analysis (infer from reading instructions):**

| Risk Type | What to check |
|-----------|--------------|
| Prompt Injection | Is `$ARGUMENTS` passed unsanitized into sub-prompts? |
| Over-permission | Does `allowed-tools` (if present) match actual tool use in instructions? |
| Logic Vulnerabilities | Loops without termination conditions; missing error handling |
| Token Bloat | SKILL.md >500 lines risks crowding context |
| Contradiction | Instructions say read-only but steps write files |

Report each risk with severity (Low / Medium / High) and a mitigation suggestion.

### Step 5 — Description Quality Score

Rate the Skill's `description` field on a **0–100 scale** across four dimensions:

| Dimension | Weight | What to evaluate |
|-----------|--------|-----------------|
| **Trigger Breadth** | 30% | Does it cover multiple natural phrasings? (commands, questions, casual) |
| **Trigger Specificity** | 25% | Concrete enough to avoid false positives with other Skills? |
| **Action Clarity** | 25% | Does it name specific outputs, not just say "performs analysis"? |
| **Pushiness** | 20% | Does it tell Claude when to use it proactively, without explicit user request? |

**Output format:**

```
Description Quality Score: 63/100

  Trigger Breadth    ██████░░░░  18/30
  Specificity        █████████░  22/25
  Action Clarity     ████░░░░░░  10/25
  Pushiness          ██████░░░░  13/20

Key issues:
- Misses question phrasing ("what does X do?") and casual ("look at my skill")
- Action clause too vague — name specific outputs (structure table, risk report, score)

Suggested rewrite: [concrete rewritten description, max 60 words]
```

If score ≥ 80: no rewrite needed. Score 50–79: fix lowest dimensions only. Score < 50: full rewrite.

### Step 6 — Cross-Skill Conflict Detection

**Trigger only when 2+ Skills are in scope.**

```bash
grep -A5 "^description:" ~/.claude/skills/*/SKILL.md 2>/dev/null
```

For each pair, assess trigger phrase overlap, domain overlap, and implicit dependency. Output:

```
Cross-Skill Conflict Report

⚠️  OVERLAP: pdf ↔ pdf-reading
    Both trigger on "read PDF" / "extract text". Consider merging or tightening
    pdf-reading's description to inspection-only tasks.

🔗  DEPENDENCY: skillpaser → skill-creator (implied)
    Step 8 generates Skills — overlaps skill-creator's core function.
    Consider handing off to skill-creator instead of doing it inline.

✅  No conflict: docx, xlsx, pptx, frontend-design
```

Severity: ⚠️ Overlap / 🔗 Dependency / ✅ Clean

### Step 7 — Spec Upgrade Check

Compare the Skill against the current Anthropic Skill specification. Check each item:

| Spec Rule | Status | Finding |
|-----------|--------|---------|
| Only `name`, `description`, `compatibility` in YAML | ✅ / ❌ | |
| `description` includes trigger phrases, not just function summary | ✅ / ❌ | |
| SKILL.md body ≤ 500 lines | ✅ / ❌ | |
| Large reference content in `references/` not inline | ✅ / ❌ | |
| Bundled files referenced in SKILL.md actually exist | ✅ / ❌ | |
| No hardcoded absolute paths (use relative or `~/.claude/`) | ✅ / ❌ | |
| Scripts use heredoc for multi-line file creation (not `echo "\n"`) | ✅ / ❌ | |
| No `allowed-tools` field (non-standard, not enforced) | ✅ / ❌ | |

Output a prioritized upgrade list: items marked ❌ sorted by impact (High / Medium / Low).

If all ✅: "Skill is current with Anthropic spec — no upgrades needed."

### Step 8 — Health Score

After Steps 2–7, compute a single **Health Score (0–100)**:

| Dimension | Weight | Source |
|-----------|--------|--------|
| Structure validity | 20% | Step 2: YAML correctness, file integrity |
| Security posture | 25% | Step 4: highest-severity risk found |
| Description quality | 25% | Step 5: score ÷ 100 |
| Spec compliance | 20% | Step 7: ✅ count ÷ total checks |
| Conflict cleanliness | 10% | Step 6: penalty per ⚠️ found |

**Output format:**

```
┌─────────────────────────────────────┐
│  Skill Health Score: 74/100  🟡     │
├─────────────────────────────────────┤
│  Structure      ████████████  20/20 │
│  Security       ████████░░░░  15/25 │
│  Description    ███████░░░░░  16/25 │
│  Spec Compliance████████░░░░  14/20 │
│  Conflicts      ████████░░░░   9/10 │
└─────────────────────────────────────┘

🔴 < 50   Critical issues — not production-ready
🟡 50–74  Functional but needs improvement
🟢 75–89  Good — minor polish recommended
⭐ 90+    Excellent — meets all standards
```

Present Health Score immediately after all steps complete, as a summary header before detailed findings.

### Step 9 — Diff-Driven Generation

When the user wants a variant ("make a version that handles images instead of PDFs"):

**9a — Analyze the delta**: Before generating anything, explicitly map what changes:

```
Delta Analysis:
  REPLACE: pdfplumber → Pillow / PIL
  REPLACE: trigger phrases mentioning "PDF" → "image", "photo", "PNG/JPG"
  REPLACE: Step 3 bash grep for pdfplumber → grep for PIL/Pillow
  KEEP:    Overall Pipeline/Workflow architecture
  KEEP:    Security analysis steps (unchanged)
  KEEP:    Description scoring logic (unchanged)
  KEEP:    Error handling table structure
  ADAPT:   File size checks (PDFs use pages; images use dimensions/MB)
```

**9b — Generate only the delta-affected sections** first, show them to the user for confirmation.

**9c — Assemble full SKILL.md** after confirmation, with bash creation sequence:

```bash
mkdir -p ~/.claude/skills/new-skill-name/
cat > ~/.claude/skills/new-skill-name/SKILL.md << 'EOF'
[assembled content]
EOF
# Copy unchanged scripts from original
cp -r <original>/scripts/unchanged_module.py ~/.claude/skills/new-skill-name/scripts/
```

This avoids blindly regenerating content that doesn't need to change, and makes the diff reviewable before committing.

---

## Freeform Input Mode (Step F)

**Trigger**: User describes an idea without an existing SKILL.md.

Examples: "I want a skill that summarizes Slack threads", "Help me design a skill for code review"

### Step F1 — Extract Intent

Ask (or infer from context):
1. What should this Skill enable Claude to do? (the core action)
2. When should it trigger? (user phrases, contexts)
3. What's the expected output format?
4. Does it need external tools, scripts, or just instructions?

If the user's description already answers these, skip asking and proceed.

### Step F2 — Classify & Architect

Based on intent, recommend an architecture type and justify it:

```
Recommended architecture: Pipeline/Workflow
Reason: "summarize Slack threads" implies a fixed sequence —
fetch → parse → summarize → format. No branching needed.
Alternative: Router (if the skill needs to handle multiple thread types differently)
```

### Step F3 — Draft SKILL.md

Generate a complete, ready-to-use SKILL.md:
- Write a strong `description` (target Score ≥ 80 from Step 5 criteria)
- Include placeholder steps that match the inferred workflow
- Flag any assumptions made (e.g., "Assumed output is Markdown — let me know if you want plain text")

### Step F4 — Self-Score

Run Step 5 (Description Quality Score) and Step 7 (Spec Upgrade Check) on the generated Skill immediately. If score < 80, revise before presenting.

Present final SKILL.md with Health Score and bash creation commands.

---

## Batch Mode

For multiple Skills, run Steps 2–8 on each, then:
- Produce a comparative Health Score table (sortable by score)
- Run Step 6 (Cross-Skill Conflict Detection) across all Skills in scope
- Offer diff-driven generation for any Skill the user wants to improve

Limit to 10 Skills per batch to avoid context overflow.

---

## Error Handling

| Situation | Response |
|-----------|----------|
| Path not found | "Skill not found at `<path>`. Want me to list available skills?" |
| File >10k lines | "File is very large — running partial analysis on first 300 lines." |
| No scripts directory | Skip Step 3 code analysis; note absence |
| Binary files in path | Skip; flag as non-analyzable |
| Freeform input too vague | Ask the three Step F1 questions before proceeding |

---

## Common Findings Reference

| Issue | Severity | Fix |
|-------|----------|-----|
| Non-standard YAML fields | Medium | Remove; use only `name`, `description`, `compatibility` |
| Weak description (undertriggers) | High | Rewrite with explicit trigger phrases |
| SKILL.md >500 lines | Medium | Split into SKILL.md + `references/` files |
| `allowed-tools` listed but not enforced | Low | Remove misleading field |
| Write operations in "read-only" skill | High | Reconcile instructions with actual behavior |
| Missing bundled files referenced in text | High | Create the files or remove the references |
| `echo "\n"` for multi-line file creation | Medium | Replace with heredoc (`cat << 'EOF'`) |
| Hardcoded absolute paths | Medium | Use `~/.claude/skills/` or relative paths |
