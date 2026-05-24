# Extraction Pattern Library

Extended examples for all five lenses. Use these as recognition aids when analyzing
project rules that are ambiguous or use unusual phrasing.

---

## Lens 1 — Explicit Quantities

### Time / Duration
```
"respond within 10 seconds"             → limits.response_timeout: 10        # seconds
"cache results for 24 hours"            → limits.cache_ttl: 86400            # seconds
"sessions expire after 30 minutes"     → limits.session_ttl: 1800           # seconds
"poll every 5 seconds"                  → behavior.poll_interval: 5          # seconds
"wait 2 seconds between retries"        → behavior.retry_delay: 2            # seconds
```

### Counts / Limits
```
"show up to 10 results"                 → limits.max_results: 10
"keep the last 20 turns in context"     → limits.context_window_turns: 20
"retry up to 5 times"                   → limits.max_retries: 5
"summarize every 50 messages"          → behavior.summary_interval: 50
"truncate at 500 words"                 → limits.max_response_words: 500
```

### LLM Parameters
```
"temperature 0.3"                       → llm.temperature: 0.3
"max 2000 tokens"                       → llm.max_tokens: 2000
"top_p 0.9"                             → llm.top_p: 0.9
"use a 4096 token context window"      → llm.context_length: 4096
```

### Thresholds / Scores
```
"if confidence is below 0.7, ask for clarification"  → limits.confidence_threshold: 0.7
"flag responses longer than 1000 words"              → limits.verbosity_flag_threshold: 1000
"escalate if error rate exceeds 10%"                 → limits.error_rate_threshold: 0.10
```

---

## Lens 2 — Behavior Adverbs (Implied Policy)

### Tone / Register
```
"always use a professional tone"         → behavior.tone: "professional"
"respond casually and conversationally" → behavior.tone: "casual"
"maintain a neutral, factual voice"     → behavior.tone: "neutral"
"be empathetic and supportive"          → behavior.tone: "empathetic"
```

### Verbosity / Length
```
"keep responses concise"                → behavior.verbosity: "concise"
"prefer bullet points over prose"      → behavior.format_preference: "bullets"
"always include a TL;DR"               → behavior.include_tldr: true
"never pad responses with filler text" → behavior.avoid_filler: true
```

### Fallback / Default Policies
```
"if unsure, ask for clarification"      → behavior.uncertainty_action: "ask"
"if unsure, make a reasonable guess"   → behavior.uncertainty_action: "attempt"
"default to the safest option"         → behavior.default_risk_preference: "safe"
"prefer speed over thoroughness"       → behavior.quality_tradeoff: "speed"
```

### Proactivity
```
"proactively suggest next steps"        → behavior.suggest_next_steps: true
"only answer what was asked"            → behavior.proactive_suggestions: false
"summarize at the end of each session" → behavior.auto_summarize: true
"remind users of deadlines unprompted" → behavior.proactive_reminders: true
```

### Privacy / Safety Policies
```
"never store user data between sessions" → behavior.persist_user_data: false
"always confirm before deleting"        → behavior.require_delete_confirm: true
"redact PII in all outputs"             → behavior.redact_pii: true
"log all admin actions"                 → behavior.log_admin_actions: true
```

---

## Lens 3 — Hardcoded Identifiers

### File Paths
```
"save output to results.md"             → paths.output_file: "results.md"
"write logs to /var/log/agent.log"     → paths.log_file: "/var/log/agent.log"
"cache goes in .agent_cache/"          → paths.cache_dir: ".agent_cache"
"read from input.json"                 → paths.input_file: "input.json"
"store memory in memory.db"            → paths.memory_db: "memory.db"
```

### Model / Service Names
```
"use claude-sonnet-4-20250514"          → llm.model: "claude-sonnet-4-20250514"
"fall back to claude-haiku-4-5"        → llm.fallback_model: "claude-haiku-4-5-20251001"
"call the OpenAI embeddings API"       → tools.embeddings_provider: "openai"
```

### Tool Names (deployment-specific only)
```
"use the company_search MCP tool"      → tools.search: "company_search"
"route through the proxy_fetch tool"   → tools.fetch: "proxy_fetch"
```

Do NOT extract:
```
"use the Read tool to open files"      ✗  (structural, not deployment-specific)
"call Bash to run commands"            ✗  (structural)
```

### Environment / Stage Names
```
"connect to the production database"   → environment.stage: "production"
"use the staging API endpoint"         → environment.api_stage: "staging"
"run in debug mode"                    → environment.debug: true
```

---

## Lens 4 — Environment and Format Assumptions

### Language / Locale
```
"respond in Traditional Chinese"        → locale.language: "zh-TW"
"all outputs in English"                → locale.language: "en"
"support both English and French"      → locale.supported_languages: ["en", "fr"]
"translate to the user's language"     → locale.auto_translate: true
```

### Timezone / Date
```
"use UTC for all timestamps"            → locale.timezone: "UTC"
"display dates as MM/DD/YYYY"          → locale.date_format: "MM/DD/YYYY"
"assume Asia/Taipei timezone"          → locale.timezone: "Asia/Taipei"
"use ISO 8601 for dates"               → locale.date_format: "ISO8601"
```

### Output Format
```
"format all output as Markdown"         → format.output: "markdown"
"return structured JSON"                → format.output: "json"
"use plain text, no markdown"           → format.output: "plaintext"
"render tables where appropriate"       → format.use_tables: true
"use code blocks for all code"          → format.code_blocks: true
```

### Region / Context
```
"assume users are in Taiwan"            → locale.region: "TW"
"prices in USD"                         → locale.currency: "USD"
"use metric units"                      → locale.units: "metric"
```

---

## Lens 5 — Persona and Tone Parameters

### Communication Style
```
"be direct and get to the point"        → persona.style: "direct"
"explain your reasoning step by step"  → persona.show_reasoning: true
"ask one question at a time"            → persona.questions_per_turn: 1
"use examples to illustrate"           → persona.use_examples: true
```

### Formality
```
"use casual, friendly language"         → persona.formality: "casual"
"maintain professional register"        → persona.formality: "professional"
"match the user's level of formality"  → persona.formality_mirroring: true
```

### Expertise Level
```
"assume technical expertise"            → persona.assumed_user_level: "expert"
"explain concepts for beginners"        → persona.assumed_user_level: "beginner"
"adapt to the user's apparent level"   → persona.adaptive_level: true
"avoid jargon"                          → persona.use_jargon: false
```

### Structural Habits
```
"always start with a summary"           → persona.response_prefix: "summary"
"end with suggested next steps"         → persona.response_suffix: "next_steps"
"use numbered lists for instructions"  → persona.instruction_format: "numbered"
"sign responses with [Agent Name]"     → persona.signature: "[Agent Name]"
```

---

## Ambiguous Cases — Extraction Decision Guide

| Pattern | Extract? | Reason |
|---------|----------|--------|
| `"if the user says X, do Y"` | ✗ | Structural logic, not a parameter |
| `"for example, type /help"` | ✗ | Illustrative example, not a value |
| `"respond in 3 bullet points"` | ✓ | Count is a tunable parameter |
| `"use the search tool"` (only tool) | ✗ | Not a choice, it's the only option |
| `"use the search tool"` (among several) | ✓ | Deployment choice |
| `"do not discuss competitors"` | ✓ | Policy → `behavior.competitor_mentions: false` |
| `"this agent is named Aria"` | ✓ | Identity → `agent.name: "Aria"` |
| `"version 2.1"` in a contract context | ✗ | Breaking to change, not runtime config |
| `"version 2.1"` as a display label | ✓ | `agent.version: "2.1"` |

---

## Considered but Excluded — How to Report

When a value was identified but deliberately not extracted, report it in Phase 4 summary:

```
Considered but excluded:
  — "if the user asks about pricing, redirect to sales" 
    Reason: structural routing logic, not a tunable parameter
  — "use the Read tool"
    Reason: only available tool, no deployment choice
```

This transparency helps the user understand the extraction was thorough, not incomplete.
