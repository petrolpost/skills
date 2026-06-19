# 可插拔体系设计指南

本文件指导 `pattern-hunter` skill 将识别出的体系设计为可复用、可插拔的模块。

---

## 核心原则

1. **自包含**：模块不依赖宿主项目的私有变量，或通过占位符明确声明依赖
2. **声明式接口**：模块顶部有清晰的"需要什么 / 提供什么"说明
3. **可测试**：模块有 1-2 个验证场景可以快速确认是否生效
4. **可组合**：多个模块可以叠加使用，互不干扰
5. **分层导出**：可以导出任意层级的模块——业务体系、Agent 规则体系或子体系

---

## ⚠️ 前置步骤：探测目标项目是否支持模块导入

在走决策树之前，先确认目标项目的**导入能力**——`@import`/`include` 不是通用标准，不同框架支持方式差异很大（甚至完全不支持）。

**探测方法：**
- 检索入口文件中是否已有 `@import`、`#include`、`{% include %}` 等导入语法的实际使用案例
- 若宿主项目本身从未出现任何导入语法 → **视为不支持**，即使框架文档声称支持
- 若不确定 → 直接询问用户："目标项目是否支持文件级导入（如 `@import`）？如果不确定，我会默认生成自包含格式，你可以手动拼接进主文件。"

**探测结果决定格式 B 是否可用：**
- ✅ 确认支持 → 决策树正常走格式 B
- ❌ 不支持/不确定 → 格式 B 自动降级为**格式 A**（自包含 Markdown 片段，用户手动复制粘贴到主规则文件即可生效，不依赖任何导入机制）

---

## 输出形式决策树

```
用户想要可插拔模块
        │
        ├─ 要导出哪个层级？
        │   │
        │   ├─ 业务体系（整个业务域的规则集）
        │   │   └─ → 完整模块目录（格式 D）
        │   │
        │   ├─ Agent 规则体系（单个 Agent 的完整规则）
        │   │   └─ → 完整模块目录（格式 D）
        │   │
        │   └─ 子体系（记忆/工具/角色等具体子模块）
        │       │
        │       ├─ 规则是纯行为描述（无数据）？
        │       │   └─ → Markdown 片段（格式 A）
        │       ├─ 已探测确认项目支持 @import / include 机制？
        │       │   └─ → 独立 .md 文件（格式 B）
        │       ├─ 规则含多个可变参数？
        │       │   └─ → YAML config + 规则模板（格式 C，若不支持导入则仍需手动拼接说明）
        │       └─ 体系有多个变体？
        │           └─ → 目录结构 + base + variants（格式 D）
        │
        └─ 要导出整个规则系统？
            └─ → 分层模块目录，按业务体系 → Agent → 子体系组织
               （若不支持导入，README 中需注明"按此层级顺序手动拼接到单一文件"）
```

---

## 输出格式规范

### 格式 A：Markdown 片段（最简单，直接粘贴）

```markdown
<!-- ======================================== -->
<!-- MODULE: [体系名称] v1.0                  -->
<!-- 用途: [一句话描述]                        -->
<!-- 依赖: [无 / 需要 {{PARAM}} 被替换]        -->
<!-- ======================================== -->

## [体系名称]

[规则内容]

<!-- END MODULE: [体系名称] -->
```

使用场景：规则简单，目标项目没有特定的 import 机制。

---

### 格式 B：独立文件 + Import 指令

**文件：`modules/memory-system.md`**
```markdown
---
module: memory-system
version: 1.0
requires: []
provides: [memory_read, memory_write, memory_forget]
---

# Memory System

[规则内容]
```

**在主规则中引入：**
```markdown
@import modules/memory-system.md
```

使用场景：项目规模较大，有多个规则文件，或计划在多个项目中复用。

---

### 格式 C：YAML Config + 规则模板

**文件：`modules/output-system/config.yaml`**
```yaml
output_system:
  max_length: 500           # 单次回复最大字数
  code_language_required: true
  list_threshold: 3         # 超过几项才用 bullet
  language: "zh-CN"
```

**文件：`modules/output-system/rules.md`**
```markdown
# Output System

- 每次回复不超过 {{max_length}} 字，除非用户明确要求详细
- 代码块{% if code_language_required %} 必须标注语言类型{% endif %}
- 超过 {{list_threshold}} 项时使用列表格式
- 默认使用 {{language}} 语言回复
```

使用场景：体系中有多个需要根据项目调整的参数。

---

### 格式 D：完整模块目录

```
modules/permission-system/
├── README.md               # 使用说明
├── base.md                 # 核心权限规则（必须）
├── config.yaml             # 可调参数
└── variants/
    ├── strict.md           # 严格模式（覆盖 base）
    ├── permissive.md       # 宽松模式
    └── custom-template.md  # 自定义模板
```

**README.md 模板：**
```markdown
# [体系名称] Module

## 所属层级
- 父级 Agent 规则体系：[名称]
- 所属业务体系：[名称]
- 体系类型：[治理输出 / 治理输入 / 子体系]

## 提供能力
- [能力 1]
- [能力 2]

## 依赖
- [无 / 依赖其他模块名称]

## 快速使用
1. 复制整个目录到你的项目 `modules/` 下
2. 在主规则文件中添加：`@import modules/[name]/base.md`
3. 如需调整参数，编辑 `config.yaml`
4. 如需变体，添加：`@import modules/[name]/variants/strict.md`

## 验证
发送以下测试消息，验证模块生效：
- "[测试场景 1]" → 预期行为：[...]
- "[测试场景 2]" → 预期行为：[...]
```

---

## 分层模块目录组织

当用户要求导出**整个规则系统**或**业务体系**时，按层级组织模块：

```
rule-modules/
├── README.md                           # 整体说明 + 层级图
├── business-system/                    # 业务体系（可选）
│   ├── README.md
│   ├── domain-definition.md            # 业务域定义
│   └── design-paradigm.md              # 设计范式声明
├── agent-rules/                        # Agent 规则体系
│   ├── README.md                       # 概述该 Agent 的职责边界
│   ├── governance-output/              # 治理输出（对外提供的规则）
│   │   ├── schema.md                   # Schema 定义
│   │   ├── adapter-guide.md            # Adapter 开发指南
│   │   └── variants/
│   │       ├── customer-service.md     # 客服变体
│   │       └── technical-support.md    # 技术支持变体
│   └── governance-input/               # 治理输入（项目自身遵守的规则）
│       ├── workflow.md                 # 开发工作流
│       ├── architecture-red-lines.md   # 架构红线
│       └── terminology.md              # 术语约束
└── sub-systems/                        # 子体系（可被多个 Agent 引用）
    ├── memory-system/
    │   ├── README.md
    │   ├── base.md
    │   └── config.yaml
    ├── tool-system/
    ├── persona-system/
    ├── output-system/
    ├── trigger-system/
    ├── process-system/
    ├── permission-system/
    ├── safety-system/
    ├── terminology-system/             # 术语治理体系
    └── architecture-boundary-system/   # 架构边界体系
```

**组织原则：**
- 业务体系在最顶层，描述业务域和设计范式
- Agent 规则体系在第二层，区分治理输出和治理输入
- 子体系在第三层，作为可复用的基础积木
- 子体系之间尽量解耦，可以被不同 Agent 自由组合
- 自引用体系在 README 中特别说明

---

## 占位符约定

统一使用 `{{UPPER_SNAKE_CASE}}` 格式：

| 占位符 | 含义 |
|--------|------|
| `{{AGENT_NAME}}` | 智能体名称 |
| `{{PROJECT_NAME}}` | 项目名称 |
| `{{MAX_CONTEXT_LINES}}` | 上下文行数限制 |
| `{{MEMORY_BACKEND}}` | 记忆存储后端类型 |
| `{{DEFAULT_LANGUAGE}}` | 默认输出语言 |
| `{{TOOL_LIST}}` | 工具列表（多行） |
| `{{BUSINESS_DOMAIN}}` | 业务领域名称 |
| `{{DESIGN_PARADIGM}}` | 设计范式声明 |
| `<!-- INSERT: section-name -->` | 标记需要用户填充的插入点 |

---

## 模块组合示例

多个模块可以在主规则中按顺序引入：

```markdown
# Agent Rules

# 功能子体系
@import modules/sub-systems/persona-system/base.md
@import modules/sub-systems/memory-system/base.md
@import modules/sub-systems/tool-system/base.md

# 结构子体系
@import modules/sub-systems/trigger-system/base.md
@import modules/sub-systems/process-system/base.md

# 治理子体系（放最后，避免被覆盖）
@import modules/sub-systems/permission-system/variants/strict.md
@import modules/sub-systems/safety-system/base.md
@import modules/sub-systems/output-system/base.md

# Agent 规则体系特有规则
## 售后客服变体专属规则
[项目特有规则写在这里，覆盖模块默认值]
```

**组合原则：**
- 治理体系（权限、安全）放最后，避免被覆盖
- 项目特有规则永远在模块 import 之后，确保优先级最高
- 有冲突的模块在 README 中声明互斥关系
- 术语治理体系应放在最前面，确保后续规则使用统一术语

---

## 质量检查清单

在输出模块前，验证：

- [ ] 模块可以在空项目中独立使用（删除宿主规则后仍然有意义）
- [ ] **已确认目标项目是否支持 @import/include，未确认时默认用格式 A（自包含）**
- [ ] 所有 `{{占位符}}` 都有说明文档
- [ ] 有至少 1 个验证测试场景
- [ ] README 中说明了与其他常见模块的兼容性
- [ ] 版本号已标注（v1.0）
- [ ] 如果是子体系模块，说明清楚它在哪个 Agent 规则体系中使用
- [ ] 如果导出的是分层结构，README 中有层级说明
- [ ] 如果涉及术语治理，说明批准的术语和禁用的术语
- [ ] 如果有自引用关系，在 README 中注明