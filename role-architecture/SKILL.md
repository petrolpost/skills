---
name: role-architecture
description: Bootstrap, extend, and operate a multi-role collaboration framework (PI/Director/Engineer/Worker style) for a project or agent workspace. Use whenever the user invokes /role-init, /role-add, /role-task, or /role-list, or asks in natural language to "set up roles", "add a collaborator role", "create a task for a role", "谁负责什么", "搭建角色协作体系", "加一个角色", "分配任务给某角色", or references a project's role/collaboration structure (e.g. .petrelpost/docs/collaboration/roles/, overview.md role matrix). Also trigger when the user is designing multi-agent or multi-person workflows and needs role definitions, handoff rules, or task tracking scaffolding — even if they don't use these exact commands.
---
# Role Architecture

A skill for creating and operating a lightweight, file-based multi-role collaboration system inside any project. It mirrors a proven four-role research-collaboration pattern (Principal Investigator / Director / Engineer / Worker) but is fully parameterizable to other domains.

The system it builds is **just markdown files** — no runtime, no server. Roles are documents (`.petrelpost/docs/collaboration/roles/*.md`), tasks are documents (`.petrelpost/docs/collaboration/role-tasks/Task-XXX.md`), and the "engine" is whichever Agent (Claude, Codex, a human) reads these files and follows them.

**Scope note on "task":** `role-tasks/` only tracks handoffs *between the roles this skill defines* (who assigned what to whom, in what status). It is not a general project task tracker — it doesn't own the project's business backlog or dev-phase task list. If the host project already has its own task/issue system, `role-tasks/` should reference it rather than duplicate it; don't let this skill become the de facto project task tracker just because it's the first one installed.

## Commands

This skill responds to four command-style triggers. Recognize them whether typed literally (`/role-init research`) or expressed in natural language ("帮我搭建一套研究协作的角色体系").

| Command                              | Purpose                                                              |
| ------------------------------------ | -------------------------------------------------------------------- |
| `/role-init [preset\|custom]`       | Bootstrap the full role architecture in a new or existing project    |
| `/role-add <role-name>`            | Add a new role to an existing architecture                           |
| `/role-task <role-name> "<title>"` | Create and register a new task assigned to a role                    |
| `/role-list`                       | Summarize current roles, their handoff relationships, and open tasks |

Always confirm which project/directory you're operating in before writing files. If the user hasn't specified a working directory, ask once — don't guess.

---

## `/role-init` — Bootstrap

1. **Determine the preset.** Read `references/presets.md`. It contains built-in presets: `research` (PI/Research Director/Research Engineer/Research Worker), `software` (Product Owner/Tech Lead/Engineer/QA Reviewer), `content` (Editor-in-Chief/Editor/Writer/Fact-Checker). If the user names one, use it. If they say "custom" or describe their own roles, skip presets and interview them instead (see **Custom role interview** below). If they just say `/role-init` with no argument, ask which preset fits, or offer to build custom — use `ask_user_input_v0` if available, otherwise ask directly.
2. **Confirm role count and names.** Presets ship with 4 roles but the user can add/remove/rename before generating files. Don't silently change a preset's semantics — if they rename "Director" to "Lead", carry that name through every generated file consistently.
3. **Generate files**, using `references/role-template.md` for each role and `references/overview-template.md` for the summary:

   - `.petrelpost/docs/collaboration/roles/overview.md` — role table + handoff loop diagram + handoff matrix
   - `.petrelpost/docs/collaboration/roles/<role-slug>.md` — one file per role (定位/使命/职责/权限边界/输入/输出/交接协议/Acceptance)
   - `.petrelpost/docs/collaboration/roles/template.md` — blank template, copied verbatim from `references/role-template.md`, for future roles added by hand
   - `.petrelpost/docs/collaboration/role-tasks/TaskTemplate.md` — from `references/task-template.md`
   - `.petrelpost/docs/collaboration/role-tasks/TaskRegistry.md` — empty registry table, ready for the first task
4. **Do not** invent a decisions log, roadmap, or policy documents unless the user asks — this skill only owns the *role and task* layer, not the whole project documentation system. If the target project already has `docs/decisions/` or similar, reference it from `overview.md` rather than duplicating it.
5. **Wire the entry point** — see "Entry-point wiring" below. Never skip this step silently; if you decide not to do it, say why.
6. Report back a short summary: roles created, files written, entry point(s) wired, and the one command they'd use next (`/role-add` or `/role-task`).

### Custom role interview

If no preset fits, ask (briefly, one round if possible):

- How many roles, and what does each one decide vs. execute vs. review?
- Is there a single final-decision-maker (like a PI) or is it fully peer-to-peer?
- What gets handed off between roles, and in what format?

Map answers onto the same file structure as a preset — the output shape is identical regardless of where the role definitions came from.

---

## Entry-point wiring

A role architecture that isn't referenced from the agent's auto-loaded rule file is invisible to a fresh session — the agent has no reason to go read `.petrelpost/docs/collaboration/roles/` unless it's told to. This step closes that gap. Run it as part of `/role-init`, and re-run it any time (safe to repeat) if entry files are added later or the user asks explicitly ("接一下 CLAUDE.md" / "wire this into Codex").

1. **Detect existing entry-point files** at the project root (and check one level of subdirectories if the project root doesn't have one): `CLAUDE.md` (Claude Code), `AGENTS.md` (Codex and other agents that follow this convention), or a project-specific equivalent like `Agent.md` if the project already has one. Don't assume only one exists — a repo used by both Claude Code and Codex may have both `CLAUDE.md` and `AGENTS.md`.
2. **If none exist**, ask the user whether to create one, and for which tool(s). Don't create both speculatively — only create entry files for tools the user actually uses.
3. **Keep content DRY.** The substantive role/task description lives in `.petrelpost/docs/collaboration/roles/overview.md` and `.petrelpost/docs/collaboration/role-tasks/TaskRegistry.md` — never duplicate that text into the entry file. The entry file gets a short pointer block only, using `references/entry-point-block.md` as the template, filled in with the actual role/doc paths.
4. **Patch idempotently.** Wrap the inserted block in `<!-- petrelpost:role-architecture:start -->` / `<!-- petrelpost:role-architecture:end -->` markers. Before inserting:

   - If the markers already exist in the file, replace only the content between them (the role set may have changed since last run).
   - If they don't exist, append the block at the end of the file, preserving everything already there — never overwrite unrelated content in `CLAUDE.md` / `AGENTS.md` / `Agent.md`.
5. **If multiple entry files exist in the same repo** (e.g. both `CLAUDE.md` and `AGENTS.md`), insert the identical pointer block into each. They both point at the same `overview.md`, so there's nothing to keep in sync beyond the pointer itself.
6. Tell the user which file(s) were patched and show the inserted block so they can see exactly what changed — don't just silently report "done".

---

## `/role-add <role-name>`

1. Read the existing `.petrelpost/docs/collaboration/roles/overview.md` to understand the current role set and handoff matrix — don't create a role that duplicates an existing one's mission.
2. Ask (or infer from context) the new role's: 定位 (who/what fills it), 使命, 职责, 决策权限边界 (what it *can't* do, who it escalates to), inputs, outputs, handoff triggers.
3. Generate `.petrelpost/docs/collaboration/roles/<new-role-slug>.md` from `references/role-template.md`.
4. **Update `overview.md`**: add a row to the role table, and add at least one row to the handoff matrix showing how this role connects to at least one existing role (a role with no handoff edges is not integrated into the loop — flag this to the user if it happens).
5. Do not touch other roles' files unless the new role's addition changes an existing handoff (e.g. a new "QA" role inserted between Engineer and PM changes the Engineer→PM edge to Engineer→QA→PM). If so, confirm with the user before editing another role's file.
6. If an entry-point block (see "Entry-point wiring") already exists in `CLAUDE.md` / `AGENTS.md` / `Agent.md`, update the one-line role list inside the markers to include the new role — otherwise the entry file's summary silently goes stale relative to `overview.md`.

---

## `/role-task <role-name> "<title>"`

1. Confirm the target role exists (check `overview.md`); if not, offer to `/role-add` it first.
2. Determine the next Task ID by reading `.petrelpost/docs/collaboration/role-tasks/TaskRegistry.md` (increment from the highest existing `Task-XXX`).
3. Generate `.petrelpost/docs/collaboration/role-tasks/Task-XXX.md` from `references/task-template.md`, filling in Title, Assigned to, Created by (the role initiating the task — usually the "director"-equivalent role), Objective. Leave Requirements/Deliverable/Acceptance Criteria for the user to fill in if not provided, but prompt for at least Objective and Deliverable before finalizing — a task with no deliverable can't be tracked to completion.
4. Add a row to `.petrelpost/docs/collaboration/role-tasks/TaskRegistry.md` with Status `Proposed`.
5. Status values are fixed and must not be renamed: `Proposed, Assigned, In Progress, Blocked, Submitted, Under Review, Accepted, Revision Required, Closed, Cancelled`. Keep every Task-XXX.md and the registry in sync on every status change — this is the most common drift point, so re-read the registry before editing a task's status.

---

## `/role-list`

Read `overview.md` and `TaskRegistry.md`, then produce a short conversational summary (not a new file) covering:

- Current roles and one-line missions
- The handoff loop (as a compact text diagram, matching the style already in `overview.md`)
- Open tasks by status, grouped (e.g. "2 Proposed, 1 In Progress")

Don't dump the full file contents — synthesize.

---

## Design principles carried into every generated file

These come from the source system this skill was extracted from, and they matter more than the specific role names:

- **One role, one file.** Relationships between roles belong in `overview.md`'s handoff matrix, not repeated in each role file.
- **A role's file states what it *cannot* do and who it escalates to** — this is as important as what it can do. Never generate a role file without a 决策权限边界 / boundaries section.
- **Tasks are not conclusions.** The task-tracking layer (`.petrelpost/docs/collaboration/role-tasks/`) records what was assigned, executed, and accepted — it never holds research/product conclusions itself. Keep task files procedural.
- **Submitted ≠ Accepted.** A worker-type role marking a task "Submitted" never auto-closes it. Closure requires the decision-making role's explicit acceptance, generally logged by whichever role owns structural maintenance.
- **Don't invent structure the user didn't ask for.** If a preset's 4 roles are overkill for what the user described, say so and suggest fewer.

## Rest 接入判断

按 `.petrelpost/docs/meta/SkillConventions.md` 硬规则第 3 条的判断标准（这个 Skill 维护的状态，会不会随时间变得不健康）：**可以接入 Rest**——`TaskRegistry.md` 里的任务状态会随时间堆积或卡住（长期停在 `In Progress` / `Blocked` 未推进），属于典型的会腐化的状态。V1 暂不强制实现登记逻辑，待 Rest 体系落地后，按其"最小学习闭环"（硬规则第 4 条）向 `.petrelpost/docs/maintenance/` 登记即可，不在本 Skill 内预先设计。

## Reference files

- `references/presets.md` — the 3 built-in role presets (research / software / content), each with full role definitions ready to instantiate
- `references/role-template.md` — blank single-role template
- `references/overview-template.md` — overview.md structure (role table, handoff loop, handoff matrix, escalation rules)
- `references/task-template.md` — blank Task-XXX.md template
- `references/entry-point-block.md` — the pointer block template for wiring into `CLAUDE.md` / `AGENTS.md` / `Agent.md`, with the idempotency markers
