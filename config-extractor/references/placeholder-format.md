# Placeholder Format Reference

## Standard Format

```
{{config.section.key}}
```

- Double curly braces, no spaces inside
- Always prefixed with `config.` to distinguish from other template variables
- Dot-notation path mirrors the YAML structure exactly
- Case: lowercase with underscores (`llm.max_tokens`, not `LLM.MaxTokens`)

## Examples by Context

### In Markdown / Plain Text (System Prompt)

Original:
```
Wait up to 30 seconds before timing out.
Retry at most 3 times before reporting failure.
Always respond in Traditional Chinese.
```

Rewritten:
```
Wait up to {{config.llm.timeout}} seconds before timing out.
Retry at most {{config.limits.max_retries}} times before reporting failure.
Always respond in {{config.locale.language}}.
```

### In JSON (Harness)

Original:
```json
{
  "model": "claude-sonnet-4-20250514",
  "max_tokens": 1000,
  "temperature": 0.7
}
```

JSON does not natively support `{{}}` interpolation. Two options:

**Option A — Document as comment in config file (recommended for static harness)**
```yaml
llm:
  model: "claude-sonnet-4-20250514"    # [Explicit] Harness: "model": "..."
                                        # NOTE: Update harness.json manually when changing this.
  max_tokens: 1000                      # [Explicit] Harness: "max_tokens": 1000
  temperature: 0.7                      # [Explicit] Harness: "temperature": 0.7
```

Note in the config file header:
```yaml
# WARNING: llm.* keys are mirrored from harness.json.
# Changing these here does NOT automatically update harness.json.
# See: harness.json lines 4-6.
```

**Option B — Use a loader pattern (if project has a config loader)**
```json
{
  "model": "{{config.llm.model}}",
  "max_tokens": "{{config.llm.max_tokens}}",
  "temperature": "{{config.llm.temperature}}"
}
```
Only use Option B if the project already has a template/interpolation loader. Document which
loader is responsible for resolving placeholders.

### In YAML (Existing Config or Harness)

Original:
```yaml
agent:
  response_language: zh-TW
  max_output_tokens: 2000
```

Rewritten (if this file itself becomes config-managed):
```yaml
agent:
  response_language: "{{config.locale.language}}"
  max_output_tokens: "{{config.limits.max_output_tokens}}"
```

Note: Only use placeholder syntax in YAML if the YAML file is processed by a loader that
resolves `{{}}`. Otherwise use Option A (document the mapping, update manually).

### In TOML

Same rules as JSON — TOML has no native interpolation. Use Option A unless a loader exists.

## Placeholder Naming Rules

### Key naming
```
config.section.key_name          ✓
config.section.keyName           ✗  (no camelCase)
config.section.key-name          ✗  (no hyphens in key names)
config.Section.key               ✗  (no uppercase in section names)
```

### Depth
- Maximum 3 levels: `config.section.key`
- Do not use 4+ levels: `config.llm.sampling.temperature` → flatten to `config.llm.temperature`
- Exception: if two sections would have a key collision, use 3 levels with a disambiguating middle

### Reserved section names
These section names are reserved for specific purposes:
```
config.agent.*     — agent identity (name, version, description)
config.llm.*       — language model parameters
config.limits.*    — all numeric limits and thresholds
config.paths.*     — all file/directory paths
config.locale.*    — language, region, timezone, date format
config.persona.*   — communication style and tone
config.tools.*     — tool name mappings
config.defaults.*  — fallback values for unspecified inputs
config.behavior.*  — policy decisions (always/never/prefer)
```

## Edge Cases

### Value that is a sentence fragment
When replacing a value that is mid-sentence, the placeholder must preserve grammaticality:

Original: `"respond in formal, professional English"`
Bad:  `"respond in {{config.persona.style}}"`  — loses "formal, professional"
Good: `"respond in {{config.persona.tone}} {{config.locale.language}}"`
      where `persona.tone: "formal, professional"` and `locale.language: "English"`

Or: extract as a single key if the whole phrase is the unit:
      `"respond in {{config.persona.response_style}}"`
      where `persona.response_style: "formal, professional English"`

### Boolean values
Original: `"never include raw stack traces"`
Config: `behavior.expose_stack_traces: false`
Rewrite: `"{% if config.behavior.expose_stack_traces %}include{% else %}never include{% endif %} raw stack traces"`

This level of complexity is usually not worth it. Instead:
- Keep the boolean in config for documentation/slash-command purposes
- Leave the prose in the rules as-is
- Note in config file: `# NOTE: Changing this requires manual update to system_prompt.md line N`

### Same literal, different meanings
Original text has `"5"` appearing as both a result limit and a retry count.
→ Create two separate keys: `limits.results_per_page: 5` and `limits.max_retries: 5`
→ Replace each occurrence independently with its specific key

### Values that shouldn't be extracted
Do NOT extract:
- Structural logic values (if/else branch conditions that define the algorithm, not parameters)
- Example values used in documentation ("for example, type /help")  
- Values inside code blocks that are illustrative
- Version numbers that are part of API contracts (breaking to change)
- Values already managed by an existing config system in the project
