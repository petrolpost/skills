# config-extractor

一个用于从 Agent 项目规则中提取配置的 Claude Skill。读取 System Prompt 和 Harness 文件，识别所有显式声明和隐含的配置值，生成独立的 YAML/TOML 配置文件，并在用户确认后将规则文件中的硬编码值替换为占位符引用。

与 slash-command-designer 搭配使用：提取出的配置文件可以通过 `/admin:config` 命令在运行时读写。

---

## 适用场景

- 项目规则（System Prompt）中存在大量硬编码的数值、语言设定、行为策略
- 同一套 Agent 需要部署到不同环境（不同语言、不同限制、不同 persona）
- 想让运维人员通过修改配置文件调整行为，而不用直接编辑规则
- 已有 slash 命令系统，想通过 `/admin:config` 命令动态读写配置

**不适合**：规则还在频繁迭代时。这个 Skill 适合在项目规则相对稳定后使用。

---

## 五个识别视角

Skill 通过五个视角扫描规则文件，捕获声明的和隐含的配置：

| 视角 | 识别目标 | 示例 |
|------|---------|------|
| **Explicit Quantities** | 数字、限制、阈值 | `最多重试 3 次` → `limits.max_retries: 3` |
| **Behavior Adverbs** | 行为副词隐含的策略 | `总是用正式语气` → `behavior.tone: "formal"` |
| **Hardcoded Identifiers** | 文件路径、模型名、工具名 | `写入 output.md` → `paths.output_file: "output.md"` |
| **Env Assumptions** | 语言、时区、格式约定 | `用繁体中文回复` → `locale.language: "zh-TW"` |
| **Persona Parameters** | 沟通风格、语气、详细程度 | `保持简洁直接` → `persona.style: "direct"` |

---

## 工作流程

```
项目文件（SystemPrompt / Harness / README）
        ↓
   Phase 0  定位项目文件
   Phase 1  五视角扫描，记录每个配置项的来源文本和位置
   Phase 2  规格化：分配键名、类型、分组到 section
   Phase 3  生成 YAML / TOML 配置文件（含注释）
   Phase 4  ⚠ 确认关卡：展示摘要，等待用户确认
        ↓ YES
   Phase 5  创建配置文件 + 原地修改规则（替换为占位符）
        ↓ （可选）
   Phase 6  生成 /admin:config 命令规格（如有 slash 命令系统）
```

**Phase 4 是强制关卡**，不会因为用户说"直接做"就跳过。用户回复 YES 后才写文件。

---

## 占位符格式

```
{{config.section.key}}
```

规则文件改写示例：

```
改写前：等待最多 30 秒后超时，最多重试 3 次。
改写后：等待最多 {{config.llm.timeout}} 秒后超时，最多重试 {{config.limits.max_retries}} 次。
```

对应 YAML：
```yaml
llm:
  timeout: 30      # [EQ] Original: "等待最多 30 秒后超时"  (unit: seconds)

limits:
  max_retries: 3   # [EQ] Original: "最多重试 3 次"
```

JSON / TOML 类的 Harness 文件不支持原生插值，配置提取后会在 YAML 注释中标注"需手动同步"。

---

## 配置文件结构

生成的 YAML 文件按功能域分段，每个键附带来源注释：

```yaml
# ── Language Model ────────────────────────────
llm:
  model: "claude-sonnet-4-20250514"  # [HI] Original: "use claude-sonnet-..."
  temperature: 0.7                   # [EQ] Original: "temperature 0.7"
  timeout: 30                        # [EQ] Original: "wait up to 30 seconds"

# ── Behavior Policies ─────────────────────────
behavior:
  tone: "professional"               # [BA] Original: "always use a professional tone"
                                     # Valid values: professional | casual | neutral
```

保留注释说明：哪些值被考虑过但未提取（附原因），哪些 Harness 值需要手动同步。

---

## 与 Slash 命令系统集成（Phase 6）

如果项目已有 slash 命令系统，Phase 6 会额外生成 `/admin:config` 命令规格：

```
/admin:config              → 列出所有配置键和当前值
/admin:config llm.timeout  → 查看单个键的值
/admin:config llm.timeout 60  → 修改值（写入 agent.config.yaml）
```

该命令规格可直接并入 slash-command-designer 生成的设计文档。

---

## 文件结构

```
config-extractor/
├── README.md
├── SKILL.md                                  ← Skill 主体（6个阶段）
├── references/
│   ├── placeholder-format.md                ← 占位符语法、边界情况、跨格式处理
│   └── extraction-patterns.md               ← 五个视角的扩展模式库（含歧义判断指南）
└── assets/templates/
    ├── config-yaml.md                        ← 带注释的 YAML 配置文件模板
    └── config-toml.md                        ← 带注释的 TOML 配置文件模板
```
