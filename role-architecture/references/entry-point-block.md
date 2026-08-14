
# Entry-point pointer block

Insert this block into `CLAUDE.md` / `AGENTS.md` / `Agent.md` (or equivalent). Fill in the bracketed parts. Keep it short — this is a pointer, not a copy of the role docs.

```markdown
<!-- petrelpost:role-architecture:start -->
## Collaboration & Roles

This project uses a role-based collaboration architecture. Roles: {角色1}, {角色2}, {角色3}, {角色4}.

Before making a decision that crosses role boundaries, or before starting/closing a task, read:

- `.petrelpost/docs/collaboration/roles/overview.md` — who does what, handoff rules, escalation
- `.petrelpost/docs/collaboration/role-tasks/TaskRegistry.md` — current task status

If you are acting as one of these roles, also read your own role file under `.petrelpost/docs/collaboration/roles/{your-role-slug}.md` before proceeding — it defines what you can decide unilaterally and what must be escalated.
<!-- petrelpost:role-architecture:end -->
```

## Why this stays this short

The entry-point file (`CLAUDE.md` / `AGENTS.md`) is loaded into every session automatically, regardless of what the session is actually about. Anything placed here has a permanent context-budget cost. The role/task detail belongs in files that get read *on demand* (`overview.md`, individual role files, `TaskRegistry.md`) — the entry-point block's only job is to make sure the agent knows those files exist and when to consult them.

## Multi-tool repos

If a repo has both `CLAUDE.md` (Claude Code) and `AGENTS.md` (Codex), insert the identical block into both, pointing at the same `overview.md`. Do not write tool-specific variants of the role description — the roles don't change depending on which agent tool is reading them.

## Re-running after `/role-add`

If a new role is added after the entry-point block was first inserted, update the role list in the block (between the markers) to include it. This keeps the one-line role summary in the entry file from going stale, even though the authoritative detail still lives in `overview.md`.
