# Command Schema Reference

## Full Schema

```
/{namespace:}name [<required-arg>] [optional-arg]

Description  : One sentence. Lead with verb. Focus on user value, not implementation.
Type         : atomic | composite
Tier         : user | admin
Namespace    : (omit if flat) logical domain this command belongs to
Arguments    :
  <arg-name>   type        required   description
  [arg-name]   type        optional   description  (default: value)
  (none)                              — write this if no arguments
Steps        : (composite only)
  1. First internal action
  2. Second internal action
  ...
Side Effects :
  - state changes
  - files written or deleted
  - external calls made
  - (none) if purely read-only
Example      : /name arg1 value
Error Cases  :
  - condition → expected behavior
```

## Naming Rules

### Verb-first for actions
```
/run        ✓     /execution    ✗
/reset      ✓     /resetter     ✗
/show-log   ✓     /log-shower   ✗
```

### Noun for inspectors
```
/status     ✓     /get-status   ✗  (too verbose)
/config     ✓     /configuration ✗  (too long)
```

### Namespace separator: colon (default strategy)
```
/task:run       ✓
/mem:show       ✓
/infra:deploy   ✓
/admin:debug    ✓   (always namespaced, regardless of project structure)
```

Flat commands (no namespace) are only acceptable for single-purpose projects with < 5 total
commands. In all other cases, use namespaced form.

```
/run            ✗  (ambiguous — which domain?)
/task-run       ✗  (looks like a hyphenated name, not a namespace)
/task_run       ✗  (underscore reserved by convention)
```

## Argument Type Reference

| Type | Description | Example |
|------|-------------|---------|
| `string` | Free text | `"my task description"` |
| `identifier` | Slug-like, no spaces | `task-123`, `prod` |
| `enum` | Fixed set of values | `staging\|production\|local` |
| `integer` | Whole number | `5`, `100` |
| `flag` | Boolean switch, `--flag` style | `--dry-run`, `--verbose` |
| `key=value` | Structured pair | `timeout=30` |
| `path` | File or directory path | `./output/`, `config.yaml` |

## Edge Cases

### Commands with optional namespacing
If a project starts flat but may grow, use this pattern in the spec:

```
/status
Future-compatible form: /agent:status
Note: if project expands beyond 3 domains, migrate to namespaced form.
```

### Commands that are both atomic and composite depending on arguments
Document both modes:

```
/config [key] [value]

Without arguments  → composite: interactive config editor
With key only      → atomic: show current value of key
With key + value   → atomic: set key to value
```

### Composite commands with conditional branches
Use indented sub-steps:

```
Steps:
  1. Validate arguments
  2. Check current state
     a. If state is X → execute path A
     b. If state is Y → execute path B
  3. Confirm result
```

### Admin commands with elevated risk
Add a DANGER marker:

```
⚠ DANGER: This command mutates persistent state and cannot be undone.
Tier: admin
Steps:
  1. CONFIRM: require user to type "yes" before proceeding
  ...
```

## /help Contract

The `/help` command has a special contract with the rest of the system:

1. **Source of truth**: `/help` derives its output from the command registry (file listing +
   frontmatter), not from hardcoded text. This means `/help` is always accurate.

2. **Tiered output**:
   - `/help` → show only user-tier commands
   - `/help --admin` → show admin commands (operator signals intent explicitly)
   - `/help <command>` → show full spec for named command (any tier)

3. **Format**:
   ```
   Available commands:
   
   /command-name    Description from frontmatter
   /other-command   Another description
   
   Type /help <command> for full details.
   ```

4. **Failure mode**: If the command registry can't be read, `/help` must still respond with a
   minimal hardcoded list of the four built-in commands.

## Composite Command Design Checklist

Before finalizing a composite command, verify:

- [ ] Each step is a discrete, nameable action
- [ ] Steps are ordered: validate → act → confirm
- [ ] Side effects are listed explicitly
- [ ] There is a defined failure mode for each step that can fail
- [ ] The command is not duplicating a sequence the user could do manually with atomics in < 3 steps
  (if so, reconsider whether it's worth a composite command)
- [ ] The composite doesn't require another composite command as a sub-step

## Common Anti-Patterns

| Anti-pattern | Problem | Fix |
|---|---|---|
| `/do-everything` | Too broad, unpredictable | Split into focused atomic commands |
| `/get-x` and `/set-x` as separate commands | Harder to discover | Use `/x [value]` — no value = get, with value = set |
| Admin commands with generic names | Risk of accidental use | Prefix with `/admin:` namespace |
| Commands that silently succeed | User doesn't know what happened | Every command must output a confirmation or result |
| Arguments that change command behavior entirely | Confusing UX | If behavior branches radically, consider two commands |
