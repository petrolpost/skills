# role-architecture

一个用于在任意项目里**搭建、扩展、运行"多角色协作体系"**的 Claude Skill。

角色是文件,任务是文件,整套机制没有运行时依赖——任何能读 Markdown 的 Agent(Claude、Codex、人类)都能照着这套文件协作。它把一套已经在真实研究项目中跑通的四角色模式(PI / Director / Engineer / Worker)抽象成可复用、可参数化的模板。

---

## 这个 Skill 解决什么问题

多 Agent 或多人协作项目经常遇到:

- 角色职责写在某次对话里,没人记得住,新会话里全部重来
- 任务分配和验收标准全靠口头约定,谁做了什么、谁验收了说不清
- 新建一个类似项目,又要把角色体系手动搭一遍

这个 Skill 把"搭角色体系"这件事变成 4 个命令,并且保证生成的文件能被 Claude Code / Codex 这类工具在**每次会话启动时自动感知到**,而不是变成一堆孤立的文档。

---

## 安装

将 `role-architecture.skill` 解压后放入项目 / Agent 的 skills 目录,或通过 skill 目录直接添加。解压后结构应为:

```
role-architecture/
├── SKILL.md
└── references/
    ├── presets.md
    ├── role-template.md
    ├── overview-template.md
    ├── task-template.md
    └── entry-point-block.md
```

安装后,在对话中输入命令,或用自然语言描述意图(如"帮我搭一套研究协作的角色体系"),Skill 会自动触发。

---

## 命令

| 命令 | 作用 |
|---|---|
| `/role-init [preset\|custom]` | 在项目中从零搭建整套角色架构,并接入 Agent 的规则入口文件 |
| `/role-add <role-name>` | 新增一个角色,自动同步交接矩阵与入口文件摘要 |
| `/role-task <role-name> "<title>"` | 为某个角色创建并登记一个新任务 |
| `/role-list` | 汇总当前角色、协作闭环与任务状态 |

### 示例

```
/role-init research
```
> 用内置的"研究协作"预设(PI / Research Director / Research Engineer / Research Worker)一键搭建。

```
/role-init custom
```
> 不使用预设,Skill 会通过几个问题(角色数量、决策权归属、交接物形式)反推出角色结构。

```
/role-add qa-reviewer
```
> 在已有架构基础上新增一个"质量把关"角色,并提示它至少要和一个现有角色建立交接关系。

```
/role-task research-worker "P02 Protocol Extraction"
```
> 给 Research Worker 角色登记一个新任务,自动分配下一个 Task ID 并写入 Registry。

---

## 内置预设

| Preset | 角色组成 | 适用场景 |
|---|---|---|
| `research` | PI / Research Director / Research Engineer / Research Worker | 文献综述、长期研究项目,人类做最终判断,多个 Agent 分工执行 |
| `software` | Product Owner / Tech Lead / Engineer / QA Reviewer | 小型迭代开发,需求→拆分→实现→验收 |
| `content` | Editor-in-Chief / Editor / Writer / Fact-Checker | 内容生产流水线,选题→写作→核实→终审 |

预设只是起手式——角色名字、数量、职责均可在生成前调整。三套预设共享同一个骨架:**一个最终决策者 + 一个任务拆分者 + 一个或多个执行者 + 一个质量把关**,这个结构比具体名字更重要。

---

## 生成的文件结构

```
docs/
├── collaboration/roles/
│   ├── overview.md          # 角色一览 + 协作闭环 + 交接矩阵
│   ├── template.md          # 空白角色模板,供后续手动添加
│   └── <role-slug>.md       # 每个角色一份文件
└── tasks/
    ├── TaskRegistry.md      # 任务总登记表(导航 + 状态)
    ├── TaskTemplate.md      # 空白任务模板
    └── Task-XXX.md          # 每个任务一份完整记录
```

每个角色文件固定包含**决策权限边界**(不能做什么 / 需上报给谁)——这是整套设计里最关键的一条,任何生成的角色文件都不允许缺失这部分。

任务状态机固定为:

```
Proposed → Assigned → In Progress → Submitted → Under Review → Accepted → Closed
                ↓ Blocked          ↓ Revision Required
```

`Submitted` 不等于 `Accepted`——必须经过角色体系中最终决策者的明确验收。

---

## 与 Agent 规则入口文件的接线

Skill 生成的角色文档默认不会被新会话自动读取,除非接入 Agent 的规则入口文件:

- **Claude Code** → `CLAUDE.md`
- **Codex** → `AGENTS.md`
- 也兼容项目自定义的入口文件(如 `Agent.md`)

`/role-init` 会自动检测这些文件,并插入一段**指针**(而非正文副本):

```markdown
<!-- role-architecture:start -->
## Collaboration & Roles

This project uses a role-based collaboration architecture. Roles: PI, Research Director, ...

Before making a decision that crosses role boundaries, or before starting/closing a task, read:
- `docs/collaboration/roles/overview.md`
- `docs/tasks/TaskRegistry.md`
<!-- role-architecture:end -->
```

设计原则:

- **只放指针,不放正文**——入口文件每次会话都会自动加载、占用上下文预算,详细规则留在按需读取的 `overview.md` 里。
- **幂等**——用注释标记包裹,重复执行不会重复插入,`/role-add` 新增角色后会自动更新标记内的角色列表。
- **多工具共存**——若同一仓库同时有 `CLAUDE.md` 和 `AGENTS.md`,两边插入完全相同的内容,避免措辞分叉导致的规则漂移。

---

## 设计原则(生成文件时始终遵守)

- **一个角色一份文件**,角色间关系只写在 `overview.md` 的交接矩阵里,不在各角色文件里重复。
- **角色文件必须写清"不能做什么"**,和"能做什么"同等重要。
- **任务文件不承载结论**——只记录分配、执行、交付、验收过程。
- **不擅自创建用户没要求的结构**——如果预设的角色数量对当前场景是过度设计,应提示用户精简,而不是照搬生成。

---

## 局限性

- 这是一套**文件约定**,不是运行时系统——协作是否真的被遵守,取决于读这些文件的 Agent 是否严格执行。
- 目前只覆盖角色与任务两层,不生成项目决策日志、路线图等其他文档层——如果项目已有类似机制,建议在 `overview.md` 里引用而非重复。
