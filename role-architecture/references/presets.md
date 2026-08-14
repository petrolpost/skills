# Built-in Role Presets

Each preset defines 4 roles with the same shape as `role-template.md`. When instantiating a preset, copy each role block into its own file under `.petrelpost/docs/collaboration/roles/<role-slug>.md`, and use the "一句话使命" column to build the table in `overview.md`.

Presets are starting points, not fixed contracts — the user can rename, merge, or drop roles before files are generated. If they do, carry the new names through consistently in every generated file.

---

## Preset: `research` — 研究协作

Source pattern: literature review / long-running research project with a human decision-maker and multiple executing agents.

| Role slug             | 承担者(默认)           | 一句话使命                                                |
| --------------------- | ---------------------- | --------------------------------------------------------- |
| `pi`                | 人类(项目负责人)       | 决定研究方向、接受或否决结论、做最终判断                  |
| `research-director` | 高层 Agent(如 ChatGPT) | 制定研究策略、拆分任务、判断质量、组织 Review & Challenge |
| `research-engineer` | 工程 Agent(如 Codex)   | 项目维护、文档更新、Matrix/Metadata、结构化工作           |
| `research-worker`   | 执行 Agent(如 Trae)    | 阅读材料、提取证据、制表、初步比较、整理                  |

**Handoff loop:**

```
PI → Research Director（讨论/决策）
Research Director → Worker/Engineer（登记 Task）
Worker/Engineer → Research Director（提交 Deliverable）
Research Director → PI（结论候选）
```

**Key boundary:** Director 不能自行接受/否决最终结论（须上报 PI）；Engineer 不判断内容质量（须上报 Director）；Worker 不做跨材料综合，除非 Task 明确要求。

---

## Preset: `software` — 软件工程协作

Source pattern: a small product/engineering team shipping features iteratively.

| Role slug         | 承担者(默认)      | 一句话使命                                         |
| ----------------- | ----------------- | -------------------------------------------------- |
| `product-owner` | 人类(产品负责人)  | 决定产品方向、验收需求、排优先级                   |
| `tech-lead`     | 高层 Agent 或人类 | 拆分技术任务、把关架构与代码质量、组织 Code Review |
| `engineer`      | 执行 Agent        | 实现功能、写测试、提交 PR                          |
| `qa-reviewer`   | 执行 Agent 或人类 | 验证交付物是否满足验收标准、回归测试、缺陷记录     |

**Handoff loop:**

```
Product Owner → Tech Lead（需求/优先级）
Tech Lead → Engineer（拆分任务）
Engineer → QA Reviewer（提交待测）
QA Reviewer → Tech Lead（测试结果）
Tech Lead → Product Owner（验收候选）
```

**Key boundary:** Tech Lead 不能改变产品优先级（须上报 Product Owner）；Engineer 不能自行判断"是否满足需求"（须经 QA Reviewer 或 Product Owner 验收）；QA Reviewer 不修复缺陷，只记录并打回。

---

## Preset: `content` — 内容创作协作

Source pattern: editorial workflow for long-form or recurring content production.

| Role slug           | 承担者(默认)      | 一句话使命                                           |
| ------------------- | ----------------- | ---------------------------------------------------- |
| `editor-in-chief` | 人类(主编)        | 决定选题方向、终审、对外发布决策                     |
| `editor`          | 高层 Agent 或人类 | 拆分选题为具体写作任务、把关结构与论点、组织修改意见 |
| `writer`          | 执行 Agent        | 撰写初稿、按反馈修改                                 |
| `fact-checker`    | 执行 Agent        | 核实事实性陈述、标记未经证实的表述、检查引用来源     |

**Handoff loop:**

```
Editor-in-Chief → Editor（选题/方向）
Editor → Writer（写作任务）
Writer → Fact-Checker（提交初稿待核实）
Fact-Checker → Editor（核实结果 + 标记项）
Editor → Editor-in-Chief（终审候选）
```

**Key boundary:** Editor 不能自行决定发布（须上报 Editor-in-Chief）；Writer 不能引用未经 Fact-Checker 核实的数据作为定论；Fact-Checker 不改写内容，只标记问题并打回。

---

## Choosing / adapting a preset

- If the user's domain doesn't match any preset closely, use the closest one as a skeleton and rename roles — the *shape* (one final decision-maker, one task-splitter, one or more executors, one quality gate) is what transfers, not the specific titles.
- If the user wants fewer than 4 roles, merge adjacent ones (e.g. merge `tech-lead` and `qa-reviewer` into one "reviewer" role) rather than dropping the boundary/escalation structure.
- Always preserve the **single final decision-maker** role even in custom setups — a role architecture with no clear place for final acceptance tends to leave tasks permanently "Submitted" and never "Accepted

# Built-in Role Presets

Each preset defines 4 roles with the same shape as `role-template.md`. When instantiating a preset, copy each role block into its own file under `docs/collaboration/roles/<role-slug>.md`, and use the "一句话使命" column to build the table in `overview.md`.

Presets are starting points, not fixed contracts — the user can rename, merge, or drop roles before files are generated. If they do, carry the new names through consistently in every generated file.

---

## Preset: `research` — 研究协作

Source pattern: literature review / long-running research project with a human decision-maker and multiple executing agents.

| Role slug             | 承担者(默认)           | 一句话使命                                                |
| --------------------- | ---------------------- | --------------------------------------------------------- |
| `pi`                | 人类(项目负责人)       | 决定研究方向、接受或否决结论、做最终判断                  |
| `research-director` | 高层 Agent(如 ChatGPT) | 制定研究策略、拆分任务、判断质量、组织 Review & Challenge |
| `research-engineer` | 工程 Agent(如 Codex)   | 项目维护、文档更新、Matrix/Metadata、结构化工作           |
| `research-worker`   | 执行 Agent(如 Trae)    | 阅读材料、提取证据、制表、初步比较、整理                  |

**Handoff loop:**

```
PI → Research Director（讨论/决策）
Research Director → Worker/Engineer（登记 Task）
Worker/Engineer → Research Director（提交 Deliverable）
Research Director → PI（结论候选）
```

**Key boundary:** Director 不能自行接受/否决最终结论（须上报 PI）；Engineer 不判断内容质量（须上报 Director）；Worker 不做跨材料综合，除非 Task 明确要求。

---

## Preset: `software` — 软件工程协作

Source pattern: a small product/engineering team shipping features iteratively.

| Role slug         | 承担者(默认)      | 一句话使命                                         |
| ----------------- | ----------------- | -------------------------------------------------- |
| `product-owner` | 人类(产品负责人)  | 决定产品方向、验收需求、排优先级                   |
| `tech-lead`     | 高层 Agent 或人类 | 拆分技术任务、把关架构与代码质量、组织 Code Review |
| `engineer`      | 执行 Agent        | 实现功能、写测试、提交 PR                          |
| `qa-reviewer`   | 执行 Agent 或人类 | 验证交付物是否满足验收标准、回归测试、缺陷记录     |

**Handoff loop:**

```
Product Owner → Tech Lead（需求/优先级）
Tech Lead → Engineer（拆分任务）
Engineer → QA Reviewer（提交待测）
QA Reviewer → Tech Lead（测试结果）
Tech Lead → Product Owner（验收候选）
```

**Key boundary:** Tech Lead 不能改变产品优先级（须上报 Product Owner）；Engineer 不能自行判断"是否满足需求"（须经 QA Reviewer 或 Product Owner 验收）；QA Reviewer 不修复缺陷，只记录并打回。

---

## Preset: `content` — 内容创作协作

Source pattern: editorial workflow for long-form or recurring content production.

| Role slug           | 承担者(默认)      | 一句话使命                                           |
| ------------------- | ----------------- | ---------------------------------------------------- |
| `editor-in-chief` | 人类(主编)        | 决定选题方向、终审、对外发布决策                     |
| `editor`          | 高层 Agent 或人类 | 拆分选题为具体写作任务、把关结构与论点、组织修改意见 |
| `writer`          | 执行 Agent        | 撰写初稿、按反馈修改                                 |
| `fact-checker`    | 执行 Agent        | 核实事实性陈述、标记未经证实的表述、检查引用来源     |

**Handoff loop:**

```
Editor-in-Chief → Editor（选题/方向）
Editor → Writer（写作任务）
Writer → Fact-Checker（提交初稿待核实）
Fact-Checker → Editor（核实结果 + 标记项）
Editor → Editor-in-Chief（终审候选）
```

**Key boundary:** Editor 不能自行决定发布（须上报 Editor-in-Chief）；Writer 不能引用未经 Fact-Checker 核实的数据作为定论；Fact-Checker 不改写内容，只标记问题并打回。

---

## Choosing / adapting a preset

- If the user's domain doesn't match any preset closely, use the closest one as a skeleton and rename roles — the *shape* (one final decision-maker, one task-splitter, one or more executors, one quality gate) is what transfers, not the specific titles.
- If the user wants fewer than 4 roles, merge adjacent ones (e.g. merge `tech-lead` and `qa-reviewer` into one "reviewer" role) rather than dropping the boundary/escalation structure.
- Always preserve the **single final decision-maker** role even in custom setups — a role architecture with no clear place for final acceptance tends to leave tasks permanently "Submitted" and never "Accepted".
