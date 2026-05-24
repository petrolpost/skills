# Claude Code Command Reference

## What are Claude Code Slash Commands?

Claude Code slash commands are Markdown files stored in `.claude/commands/`. When a user types
`/command-name` in Claude Code, it reads the corresponding `.md` file and uses its content as
a structured prompt prefix, then appends `$ARGUMENTS` (whatever the user typed after the command).

## File Naming Rules

- Filename = command name: `help.md` → `/help`
- Subdirectories = namespaces: `admin/debug.md` → `/admin:debug`
- Only lowercase letters, hyphens: `my-command.md` not `MyCommand.md`
- No spaces in filenames

## Frontmatter Fields

```yaml
---
description: Short description shown in command picker (keep under 60 chars)
allowed-tools: Read, Write, Bash  # or "all" for unrestricted
---
```

`allowed-tools` values (as of Claude Code current):
- `Read` — read files
- `Write` — write/edit files  
- `Bash` — run shell commands
- `WebSearch` — search the web
- `WebFetch` — fetch URLs
- `mcp__[server]__[tool]` — specific MCP tool

## The `$ARGUMENTS` Variable

`$ARGUMENTS` is replaced at runtime with everything the user typed after the command name.

```
User types: /deploy production --dry-run
$ARGUMENTS becomes: production --dry-run
```

Use `$ARGUMENTS` in the Behavior section to tell Claude how to parse the input:

```markdown
## Arguments
$ARGUMENTS

Parse $ARGUMENTS as: [environment] [--flag]*
- environment: "staging" | "production" (required)
- --dry-run: simulate without executing (optional)
```

## Behavior Section Guidelines

The Behavior section is the core instruction. Write it as if writing a system prompt for this
specific action. Be explicit about:

1. What to do first (validation, state checks)
2. The main action sequence
3. What to output/report
4. Error conditions and how to handle them

## Patterns

### Read-only command (atomic)
```markdown
---
description: Show current agent status and context
allowed-tools: Read
---

# /status

Display the current state of the agent session.

## Arguments
$ARGUMENTS
(none expected — ignore if provided)

## Behavior
1. Read the current session context
2. List active tools and their states
3. Show the last 3 actions taken
4. Report any warnings or errors

Output format: structured summary, not prose.
```

### Mutating command (composite)
```markdown
---
description: Reset session state and reload configuration
allowed-tools: Read, Write, Bash
---

# /reset

Reset the agent to a clean state.

## Arguments
$ARGUMENTS
Optional: --soft (clear context only) | --hard (clear context + reload config)
Default: --soft

## Behavior
1. Confirm intent with user before proceeding
2. If --hard: reload config files from disk
3. Clear current session memory/context
4. Re-initialize tools
5. Confirm reset complete with summary of what was cleared
```

### Admin diagnostic command
```markdown
---
description: [ADMIN] Dump internal state for debugging
allowed-tools: Read, Bash
---

# /admin:debug

Dump internal agent state for operator inspection.

## Arguments
$ARGUMENTS
Optional: --turns N (show last N turns, default 5) | --tools (show tool states)

## Behavior
1. Note: this command exposes internal state. Only use in development/debug sessions.
2. Collect: active config, tool registry, session context, last N conversation turns
3. Format as structured JSON dump
4. Highlight any anomalies or error states
```

## Constraints and Known Limitations

- Commands cannot call other commands directly (no `/help` calling `/status` internally)
- `$ARGUMENTS` is always a string — Claude must parse structure from it in the Behavior section
- No built-in access control in Claude Code — admin/user distinction is by convention and placement
- Subdirectory depth beyond one level (`admin/`) is not guaranteed to work consistently
- Commands share the same Claude session context; they don't get a fresh context

## Admin Command Convention

Since Claude Code has no built-in access control, the convention for admin commands is:

1. Place in `admin/` subdirectory → invoked as `/admin:command`
2. Clearly label in description: `[ADMIN]`
3. First step in Behavior: state that this is an admin command and who should use it
4. Do NOT list admin commands in user-facing `/help` output by default

## Self-Describing /help Pattern

The `/help` command should work by reading the command directory and extracting descriptions:

```markdown
## Behavior
1. List all .md files in .claude/commands/ (excluding admin/ subdirectory)
2. For each file, extract the `description` frontmatter field and the filename
3. Format as a table: command | description
4. If $ARGUMENTS is a command name, read that file and display its full specification
5. Add a footer: "Type /help [command] for details on any command"
```

This means `/help` output is always current with the actual command set.
