---
name: config-extractor
description: >
  Extract declared and implied configuration from Agent project rules (SystemPrompt, Harness),
  generate a standalone YAML/TOML config file, and rewrite the rules to reference config keys
  via placeholders. Use when a project's rules contain hardcoded values, behavior assumptions,
  or policy defaults that should be externalized and managed independently. Trigger when the
  user mentions: "extract config", "externalize settings", "config file", "hardcoded values",
  "make this configurable", or asks to separate configuration from agent rules. Also trigger
  when slash-command-designer has produced a command system and the user wants the config
  to be readable/writable via admin commands. Read project files directly — do NOT ask the
  user to describe values manually if files are available.
---

# Config Extractor

Analyze Agent project rules to surface all configuration — both explicitly stated and implied —
then produce a standalone config file and rewrite the rules to reference it via placeholders.

Designed to work alongside slash-command-designer: the config file produced here is the
backing store that `/admin:config` commands read and write.

---

## Phase 0 — Locate Project Artifacts

Find all project rule files before doing any analysis. Check in order:

1. **System Prompt**: `CLAUDE.md`, `system_prompt.md`, `.claude/system.md`, `harness.md`,
   `agent.md`, or any file the user identifies as the agent's instructions
2. **Harness / Tool Config**: `.claude/settings.json`, `harness.json`, `config.yaml`,
   `agent.json` — these may already contain some explicit config
3. **Existing config files**: any `*.yaml`, `*.toml`, `*.env`, `.env*` — note what already
   exists so you don't duplicate it
4. **README / docs**: may contain intended behavior that isn't yet in rules

> Read every file found. Do NOT ask the user to list values manually.
> If a config file already exists, treat its keys as already-extracted and focus on what's missing.

If no project files are found, ask the user to paste the system prompt.

---

## Phase 1 — Config Identification

Read all project rule files and apply the five extraction lenses below. For each item found,
record: the original text, the line/section it appears in, and the lens that triggered it.

### Lens 1 — Explicit Quantities
Numeric values with clear meaning. Look for: numbers + units, counts, limits, thresholds.

Patterns to match:
- `N seconds / minutes / hours / days`
- `up to N`, `at most N`, `maximum N`, `retry N times`
- `top N results`, `last N turns`, `N items per page`
- Percentages, temperatures (LLM), token counts

Examples:
```
"wait up to 30 seconds"          → timeout: 30  (unit: seconds)
"retry at most 3 times"          → max_retries: 3
"show the top 5 results"         → results_limit: 5
"temperature 0.7"                → llm.temperature: 0.7
```

### Lens 2 — Behavior Adverbs (Implied Policy)
Absolute or habitual behavior described in natural language. These encode policy that should
be tunable.

Trigger words: `always`, `never`, `by default`, `prefer`, `prioritize`, `fall back to`,
`unless told otherwise`, `if not specified`, `assume`

Examples:
```
"always respond in formal tone"           → behavior.tone: "formal"
"prefer shorter responses"               → behavior.response_length: "concise"
"if not specified, use UTC"              → defaults.timezone: "UTC"
"fall back to English if unsure"         → defaults.language: "en"
"never include raw stack traces"         → behavior.expose_stack_traces: false
```

### Lens 3 — Hardcoded Identifiers
String literals that name specific resources, paths, tools, or models. These should be
configurable if they might change across deployments.

Look for: file paths, output filenames, model names, tool names used as strings, API
endpoint patterns, environment names.

Examples:
```
"write the result to output.md"          → paths.output_file: "output.md"
"use the web_search tool"                → tools.search: "web_search"
"call the production API"                → environment: "production"
"save to /tmp/agent_cache"              → paths.cache_dir: "/tmp/agent_cache"
```

> Only extract tool names as config if they appear to be deployment-specific choices.
> Don't extract tool names that are structural (e.g. the harness declares exactly one search tool).

### Lens 4 — Environment and Format Assumptions
Locale, language, date/time format, output format conventions that are stated as fixed but
could reasonably vary.

Examples:
```
"respond in Traditional Chinese"         → locale.language: "zh-TW"
"format dates as YYYY-MM-DD"            → format.date: "YYYY-MM-DD"
"output as markdown"                     → format.output: "markdown"
"assume the user is in Taiwan"          → locale.region: "TW"
```

### Lens 5 — Persona and Tone Parameters
Personality, communication style, formality level, verbosity — things that characterize
the agent's voice and could be adjusted per deployment.

Examples:
```
"be concise and direct"                  → persona.style: "concise"
"use a warm, friendly tone"              → persona.tone: "friendly"
"avoid jargon unless the user uses it"  → persona.jargon_mirroring: true
"sign off each response with a summary" → persona.response_suffix: "summary"
```

---

## Phase 2 — Config Item Specification

For every item identified in Phase 1, produce a full specification record:

```
key         : config.section.name          # dot-notation path in the config file
value       : <current hardcoded value>    # exactly as it appears / implied
type        : string | integer | float | boolean | enum | duration | path
unit        : (for numeric types) seconds | tokens | items | etc.
enum_values : (for enum type) list of valid values
source      : "<verbatim original text from rules>"
location    : <filename, section or approximate line>
lens        : explicit_quantity | behavior_adverb | hardcoded_id | env_assumption | persona
rationale   : why this should be externalized (one sentence)
slash_cmd   : (optional) which admin command would read/write this, if slash system exists
```

### Grouping into Sections

Organize keys into logical YAML sections. Suggested section names (adapt to project):

| Section | Contains |
|---------|----------|
| `agent` | identity, version, name |
| `llm` | model, temperature, max_tokens, timeout |
| `behavior` | tone, style, verbosity, fallback policies |
| `defaults` | language, timezone, output format |
| `limits` | retries, result counts, turn depth, rate limits |
| `paths` | file paths, cache directories, output locations |
| `tools` | tool name mappings (if deployment-specific) |
| `locale` | language, region, date/time format |
| `persona` | communication style parameters |

Do not create sections with a single key. Merge orphan keys into the closest parent section
or into a `misc` section.

---

## Phase 3 — Generate Config File

Produce a YAML file. Default filename: `agent.config.yaml`.
If a TOML file is more appropriate (user indicated, or project uses TOML elsewhere), produce
`agent.config.toml` instead.

### YAML Format Rules

```yaml
# agent.config.yaml
# Auto-generated by config-extractor skill
# Project: [project name]
# Source files: [list of files analyzed]
# Generated: [date]
#
# Each key references a value that was hardcoded or implied in the project rules.
# Edit here to change behavior without modifying the rules directly.

# ── Section Name ──────────────────────────────────────────────
section:

  key_name: value          # [Lens] Original: "verbatim source text"
                           # Rationale: one-sentence justification

  another_key: value       # [Lens] Original: "..."
```

Rules:
- Every key gets an inline comment with: lens tag, verbatim source text (truncated to 80 chars)
- Rationale comment on the next line if the key is non-obvious
- Section dividers use `# ── Name ──` format for visual scanning
- Boolean values: `true` / `false` (not `yes`/`no`)
- Duration values: integer + comment with unit (`30  # seconds`)
- Enum values: string, with a comment listing valid options
- String values containing `{{` are reserved for template references — do not use in values

### TOML Format Rules (if applicable)

```toml
# agent.config.toml
# [same header as YAML]

# ── Section Name ──
[section]
# [Lens] Original: "verbatim source text"
# Rationale: ...
key_name = "value"
```

---

## Phase 4 — Confirmation Gate

**Do not modify any project file until the user explicitly confirms.**

Present the following before proceeding:

```
## Config Extraction Summary

Analyzed files: [list]
Config items found: N
  — Explicit quantities : N
  — Behavior policies   : N
  — Hardcoded identifiers: N
  — Environment assumptions: N
  — Persona parameters  : N

Config file to create: agent.config.yaml

Files to be modified (in-place):
  — system_prompt.md  : N replacements
  — harness.json      : N replacements  (if applicable)

Placeholder format: {{config.section.key}}

[show the full generated config file here]

Proceed with (a) creating the config file and (b) rewriting the rules?
Reply YES to proceed, or describe changes before I apply anything.
```

If the user requests changes to the config (rename a key, adjust a value, skip an item),
update the config spec first, then re-present the summary. Never apply writes during
this negotiation phase.

---

## Phase 5 — Rewrite Project Rules

Only after explicit user confirmation. Apply changes in this order:

### 5.1 Create the Config File

Write `agent.config.yaml` (or `.toml`) to the project root (or the directory the user specifies).

### 5.2 Rewrite Rule Files In-Place

For each rule file that contains extracted values:

1. **Read** the current file content
2. **Build a replacement map**: `{original_text_fragment: "{{config.section.key}}"}`
3. **Apply replacements** precisely — replace only the value portion, preserve surrounding prose
4. **Add a config reference header** at the top of the file (if not already present):
   ```
   <!-- config: agent.config.yaml -->
   ```
   or for non-HTML files:
   ```
   # config: agent.config.yaml
   ```
5. **Write** the modified content back to the file

### 5.3 Replacement Precision Rules

These rules prevent broken or ambiguous rewrites:

- Replace the **value only**, not the surrounding sentence structure
  - ✓ `wait up to {{config.llm.timeout}} seconds`
  - ✗ `{{config.rule_about_waiting}}`
- If the same literal value appears in multiple contexts with different meanings, create
  separate keys and replace each occurrence independently
- If a value appears in a JSON/TOML harness file, use the appropriate reference syntax for
  that format — document it in the config file header if non-standard
- Do not replace values inside code blocks, examples, or comments unless they are
  themselves the source of truth for the config item
- After all replacements, verify no `{{config.` references point to non-existent keys

### 5.4 Post-Write Verification

After writing all files:

1. List every file modified with a count of replacements made
2. Show a diff-style summary (before → after) for the first 3 replacements per file
3. Check that every `{{config.X.Y}}` in the rule files has a corresponding key in the
   config file — report any mismatches as errors
4. Report any values that were identified in Phase 1 but NOT replaced (with reason)

---

## Phase 6 — Slash Command Integration (if slash system exists)

If the project already has a slash command system (from slash-command-designer or otherwise),
generate the `/admin:config` command spec after Phase 5.

### Config Command Spec to Add

```
/admin:config [key] [value]

Description  : Read or write a configuration value at runtime.
Type         : atomic
Tier         : admin
Arguments    :
  [key]    identifier   optional   Dot-notation config key (e.g. llm.timeout)
  [value]  string       optional   New value to set. Omit to read current value.
Steps        :
  Without arguments  → list all config keys and current values (grouped by section)
  With key only      → read and display current value of that key + its source comment
  With key + value   → validate type, set value, confirm change
Side Effects :
  Writes to agent.config.yaml when setting a value
Example      : /admin:config llm.timeout 60
               /admin:config behavior.tone
               /admin:config
Error Cases  :
  - Unknown key     → "Unknown config key. Run /admin:config to see all keys."
  - Type mismatch   → "Expected [type] for [key]. Got: [value]"
  - Read-only key   → (mark keys as read-only in config file with # readonly comment)
```

Also note in the design: the `/help` command should list `/admin:config` in its admin section,
and the config file path should appear in `/version` output.

---

## Output Quality Rules

- Every extracted key must cite its source text verbatim. No invented config items.
- Placeholder replacements must be surgically precise — surrounding prose must remain
  grammatically correct after replacement.
- The config file must be the single source of truth: no value should exist in both the
  config file and the rule file after rewriting.
- Phase 4 confirmation gate is mandatory. Never skip it, even if the user says "just do it."
  Present the summary; the user can reply YES immediately if they want.
- If a value appears ambiguous (could be config or could be structural logic), err toward
  NOT extracting it and note it in the summary as "considered but excluded."

---

## Reference Files

- `references/placeholder-format.md` — Placeholder syntax, edge cases, format-specific variants
- `references/extraction-patterns.md` — Extended pattern library for all five lenses
- `assets/templates/config-yaml.md` — Annotated YAML config file template
- `assets/templates/config-toml.md` — Annotated TOML config file template
