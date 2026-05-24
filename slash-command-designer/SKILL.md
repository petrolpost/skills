---
name: slash-command-designer
description: >
  Design and generate a complete slash command system for Agent projects (Claude Code–style).
  Use this skill whenever the user wants to add slash commands to an Agent project, CLI tool,
  or AI assistant. Trigger when the user mentions: slash commands, /commands, command system,
  agent commands, bot commands, or asks to "design commands for my project". Also trigger when
  a project has reached a stable design phase (system prompt + harness defined) and the user
  wants to improve its operability. The skill reads project files (system prompts, harness
  configs, README) to extract commands — do NOT ask the user to describe the project manually
  if files are available.
---

# Slash Command Designer

Design a complete, self-consistent slash command system for Agent projects by analyzing project
rules (SystemPrompt, Harness, README). Outputs a structured design document first, then
generates code/config on request.

---

## Phase 0 — Locate Project Artifacts

Before anything else, find the project's defining files. Look in the current directory and common
paths. Priority order:

1. **System Prompt**: `CLAUDE.md`, `system_prompt.md`, `.claude/system.md`, `harness.md`,
   `agent.md`, or any file the user identifies as the agent's rules
2. **Harness / Config**: `.claude/settings.json`, `harness.json`, `config.yaml`, `agent.json`
3. **Feature surface**: `README.md`, `docs/`, source entry points (`main.py`, `index.ts`, etc.)

> Read these files. Do NOT ask the user to describe the project if the files exist and are readable.
> The system prompt and harness are the ground truth for what the agent can and should do.

If no files are found, ask the user to paste or describe the system prompt and core capabilities.

---

## Phase 1 — Project Analysis

After reading the project artifacts, build an internal model across four dimensions:

### 1.1 Capability Map
List every discrete thing the agent can do. Derived from: tools declared in harness, actions
mentioned in system prompt, workflows described in README.

### 1.2 User Journey Map
Identify the typical session flow:
- How does a user start a session?
- What are the most frequent mid-session actions?
- How does a user inspect state or progress?
- How does a session end or get reset?

### 1.3 Admin / Operator Surface
Identify configuration and diagnostic needs:
- What parameters can be tuned at runtime?
- What internal state needs to be observable?
- What resets or reloads are needed during development?

### 1.4 Domain Mapping
Identify all functional domains in the project. **Namespaced commands are the default strategy.**

**Process:**
1. List every functional domain found in the capability map (e.g., task management, memory,
   infrastructure, I/O, configuration)
2. Assign a short namespace identifier to each domain (≤ 8 chars, noun, lowercase)
3. Reserve `admin:` for all operator/developer commands regardless of domain

**Naming pattern:** `/{domain}:{verb}` or `/{domain}:{noun}`

Examples:
```
/task:run        /task:list       /task:cancel
/mem:show        /mem:clear       /mem:export
/infra:deploy    /infra:status
/admin:debug     /admin:reload    /admin:config
```

**Exception — keep flat** only when the project has a single narrow purpose with fewer than
5 total commands. Document the exception and rationale explicitly.

Always list the domain-to-namespace mapping as a table before proceeding to Phase 2:

| Domain | Namespace | Example Commands |
|--------|-----------|-----------------|
| [domain] | `ns:` | `/ns:action` |

---

## Phase 2 — Command Extraction

### 2.1 Command Classification

Extract commands into two tiers and two types:

**By Permission Tier (fixed two-tier model):**

| Tier | Who | Characteristics |
|------|-----|-----------------|
| `user` | End users | Safe, idempotent preferred, no system mutation |
| `admin` | Operators/developers | Can mutate config, expose internals, trigger reloads |

> This is a **fixed two-tier model**. Do not introduce intermediate roles or RBAC.
> If a capability feels ambiguous, default to `admin`. Promotion to `user` requires explicit
> justification (safe, reversible, no internal exposure).

**By Command Type:**

| Type | Definition | Example |
|------|-----------|---------|
| **Atomic** | Single action, no dependency on other commands | `/status` — just reads and reports state |
| **Composite** | Orchestrates multiple steps or sub-commands | `/reset` — clears memory + reloads config + confirms |

### 2.2 Extraction Rules

When reading project artifacts, apply these heuristics:

- **Every tool in the harness** → candidate for an atomic user command
- **Every config key** → candidate for an admin `get`/`set` pair
- **Every multi-step workflow in system prompt** → candidate for a composite command
- **Every error/recovery path** → candidate for an admin diagnostic command
- **Session lifecycle events** → always extract: init, status, reset/end

### 2.3 Command Schema

Each extracted command must be fully specified:

```
/{name} [args]

Description : One sentence. What does this command do for the user?
Type        : atomic | composite
Tier        : user | admin
Arguments   : name (type, required/optional) — description
              [none] if no arguments
Steps       : (composite only) ordered list of internal actions
Side Effects: state changes, files written, external calls made
Example     : /name arg1 value1
```

---

## Phase 3 — System Design Document

Produce a structured Markdown document. Follow this structure exactly:

```
# [Project Name] — Slash Command System

## Overview
(2–3 sentences: what this command system does, how it's organized, permission model)

## Command Reference

### User Commands
(table: command | description | type)

### Admin Commands
(table: command | description | type)

## Command Specifications

### /help
### /status
### ... (all commands, using schema from 2.3)

## Permission Model
(explain user vs admin tier, how enforcement is expected to work)

## Naming Conventions
(flat vs namespaced decision + rationale, naming rules used)

## Extension Guide
(how to add a new command: checklist of things to define)

## Implementation Notes
(non-binding hints for the developer: suggested dispatch pattern, where to hook)
```

### Built-in Commands (always include these)

These four commands are mandatory in every system produced by this skill:

| Command | Tier | Description |
|---------|------|-------------|
| `/help [command]` | user | List all available commands; with arg, show full spec for one command |
| `/status` | user | Report current agent state, active session context, last action |
| `/version` | user | Show agent version, config hash, and environment info |
| `/admin:debug` | admin | Dump internal state, active tools, and last N turns for inspection |

`/help` must be self-describing: its output should be generated from the command registry itself,
not hardcoded. Document this in the design spec.

---

## Phase 4 — Claude Code Sample Output (on request)

If the user wants a Claude Code–compatible implementation sample, generate it after the design doc.

### File structure to generate:

```
.claude/
└── commands/
    ├── help.md
    ├── status.md
    ├── [other user commands].md
    └── admin/
        ├── debug.md
        └── [other admin commands].md
```

### Template for each `.md` file:

```markdown
---
description: [one-line description for Claude Code command picker]
allowed-tools: [comma-separated tool names from harness, or "all"]
---

# /[command-name]

[Full description of what this command does]

## Arguments
$ARGUMENTS

## Behavior
[Step-by-step instructions Claude should follow when this command is invoked]

## Example
`/[command] [example args]`
```

> Read `references/claude-code-commands.md` for Claude Code–specific constraints and patterns
> before generating these files.

---

## Phase 5 — Iteration

After delivering the design document, ask:

1. **Coverage**: "Are there workflows or capabilities I missed?"
2. **Naming**: "Do these command names match the language your users will use?"
3. **Granularity**: "Are any commands too broad (should split) or too narrow (should merge)?"

Revise the document based on feedback. Track changes explicitly (note what changed and why).
When the user is satisfied, offer Phase 4 (code generation) if not already done.

---

## Output Quality Rules

- Every command in the spec must trace back to a capability in the project artifacts. No invented commands.
- No command should require knowledge of another command's internals to use correctly.
- `/help` output must always be derivable from the command registry — state this as a requirement in the design doc.
- Admin commands must be clearly marked; never blend them into user-facing docs without a separator.
- The design doc must be self-contained: a developer who hasn't read this skill should be able to implement from it alone.

---

## Reference Files

- `references/claude-code-commands.md` — Claude Code command file format, constraints, patterns
- `references/command-schema.md` — Extended schema reference with edge case examples
- `assets/templates/command-spec.md` — Blank command spec template for copy-paste
- `assets/templates/design-doc.md` — Full design document skeleton
