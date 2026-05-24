# Command Spec Template

Copy this block for each command you add to the design document.

---

### `/[command-name] [<required>] [optional]`

```
Description  : [One sentence. Start with a verb. Focus on user value.]
Type         : atomic | composite
Tier         : user | admin
Namespace    : [domain] | (none — flat)
Arguments    :
  <arg-name>   [type]   required   [description]
  [arg-name]   [type]   optional   [description]  (default: [value])
  (none)
Steps        : (composite only — delete this block for atomic)
  1. [First action]
  2. [Second action]
  ...
Side Effects :
  - [State changed, file written, external call made]
  - (none)
Example      : /[command] [example args]
Error Cases  :
  - [Condition] → [Expected response]
```

---

## Argument Types Cheat Sheet

| Type | Format | Example |
|------|--------|---------|
| `string` | free text (quote if spaces) | `"my note"` |
| `identifier` | slug, no spaces | `task-42` |
| `enum` | one of fixed set | `staging\|prod` |
| `integer` | whole number | `10` |
| `flag` | `--flag-name` | `--dry-run` |
| `key=value` | paired | `timeout=30` |
| `path` | file/dir path | `./output/` |

## Type Descriptors Cheat Sheet

- `atomic` — single action, executes in one step
- `composite` — orchestrates multiple steps, often involves confirmation

## Side Effect Keywords

Use consistent language:
- `Writes [file]` — creates or modifies a file
- `Deletes [file/entry]` — removes something
- `Mutates [config key]` — changes runtime config
- `Calls [service/API]` — external network call
- `Clears [memory/context/cache]` — wipes in-memory state
- `(none)` — purely read-only
