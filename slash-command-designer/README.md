# slash-command-designer

一个用于为 Agent 项目设计 Slash 命令系统的 Claude Skill。在项目设计趋于稳定（System Prompt 和 Harness 已定义）后，通过读取项目文件自动提取并设计一套完整的 `/command` 体系。

---

## 适用场景

- 你正在开发一个类 Claude Code 的 Agent 项目，想为它添加 slash 命令
- 项目的 System Prompt 和工具 Harness 已经基本稳定
- 你需要一份可直接交给开发者实现的命令设计文档
- 你想生成 Claude Code 兼容的 `.claude/commands/` 文件

**不适合**：项目还在早期探索阶段，功能尚未确定时。Skill 依赖稳定的项目规则来提取有意义的命令。

---

## 工作流程

```
项目文件（SystemPrompt / Harness / README）
        ↓
   Phase 0  定位项目文件
   Phase 1  分析项目（能力图谱 / 用户旅程 / 领域划分）
   Phase 2  提取命令（原子 / 复合 × 用户 / 管理员）
   Phase 3  输出设计文档
        ↓
  [按需] Phase 4  生成 Claude Code 示例文件
  [按需] Phase 5  迭代修订
```

Skill 会**主动读取项目文件**，不需要你手动描述项目功能。

---

## 设计原则

### 权限模型：固定两层

| 层级 | 使用者 | 特征 |
|------|--------|------|
| `user` | 终端用户 | 安全、幂等优先，不改变系统状态 |
| `admin` | 开发者 / 运维 | 可修改配置、暴露内部状态、触发重载 |

权限归属有歧义时，默认划为 `admin`。没有中间角色，没有 RBAC。

### 命名空间：默认启用

采用 `/{domain}:{command}` 格式，按功能域组织：

```
/task:run      /task:list     /task:cancel
/mem:show      /mem:clear
/infra:deploy  /infra:status
/admin:debug   /admin:reload
```

`admin:` 命名空间专用于管理员命令，无论其功能属于哪个域。只有在单一用途、命令总数少于 5 条时，才允许使用扁平结构。

### 四个内置命令（每个项目必须包含）

| 命令 | 层级 | 说明 |
|------|------|------|
| `/help [command]` | user | 列出所有命令；加参数时显示单条完整规格 |
| `/status` | user | 显示当前 Agent 状态和会话上下文 |
| `/version` | user | 显示版本、配置哈希和环境信息 |
| `/admin:debug` | admin | 导出内部状态供调试 |

`/help` 必须是**自描述的**：从命令注册表动态读取，不能硬编码列表。

---

## 输出内容

### Phase 3：设计文档（必出）

一份完整的 Markdown 文档，包含：

- 命令快速参考表（用户命令 / 管理员命令）
- 每条命令的完整规格（类型、权限、参数、步骤、副作用、示例、错误处理）
- 权限模型说明
- 命名约定与领域映射
- 扩展指南（如何新增命令的检查清单）
- 实现建议（分发模式、参数解析等）

文档设计目标：**开发者无需阅读本 Skill，仅凭设计文档即可完成实现。**

### Phase 4：Claude Code 文件（按需）

生成 `.claude/commands/` 目录结构：

```
.claude/
└── commands/
    ├── help.md
    ├── status.md
    ├── version.md
    ├── task/
    │   ├── run.md
    │   └── list.md
    └── admin/
        ├── debug.md
        └── reload.md
```

每个文件包含 frontmatter（`description`、`allowed-tools`）和结构化的行为指令。

---

## 文件结构

```
slash-command-designer/
├── README.md                             ← 本文件
├── SKILL.md                              ← Skill 主体（5个阶段的完整指令）
├── references/
│   ├── claude-code-commands.md          ← Claude Code 命令格式规范与样例
│   └── command-schema.md                ← 命令 Schema 完整参考、命名规则、反模式
└── assets/templates/
    ├── design-doc.md                    ← 设计文档骨架（含内置命令规格）
    └── command-spec.md                  ← 单条命令规格 copy-paste 模板
```

---

## 使用方式

在 Claude Code 或支持 Skill 的 Claude 环境中安装后，对话时提及即可触发：

> "帮我为这个项目设计 slash 命令系统"  
> "分析项目文件，提取合适的 slash 命令"  
> "项目设计稳定了，想加一套 /command 体系"

Skill 会自动定位项目文件（`CLAUDE.md`、`harness.json`、`README.md` 等），无需额外说明。

---

## 迭代与修订

设计文档输出后，Skill 会主动询问三个维度的反馈：

- **覆盖度**：有没有遗漏的工作流或能力？
- **命名**：命令名称是否符合用户的语言习惯？
- **粒度**：有没有过宽（需拆分）或过窄（需合并）的命令？

每次修订都会记录变更原因，保持文档的可追溯性。
