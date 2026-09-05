---
name: dr3-reading
description: 深度阅读工作流：将英文专业文章转化为可追溯的中文深度笔记，并可发现文章中的局部或整体可数据化知识结构。当用户提供文章 URL 或本地路径，并要求深度阅读、深度笔记、批判性分析、洞见重构、知识结构化或生成 Obsidian 笔记时使用。提供九个按需组合的功能（导入、结构抽取、数据化、沉浸阅读、综合、批判、人机重构、笔记生成、质量评估），支持断点续读、状态级联与数据新鲜度管理。
---

# DR3 深度阅读（dr3-reading）

将英文专业文章转化为**属于用户的、中文、高价值、可追溯的深度笔记**，并在需要时发现文章中可以脱离自然语言而独立复用的知识结构。

不做简单翻译：通过结构化理解 → 可选结构发现 → 沉浸式阅读 → 批判反思 → 人机协作重构，完成从浅层阅读到深度认知的跃迁。源自 InsightWeaver DR3 v0.4 的“平台期 + 依赖矩阵”模型，无运行时依赖，高度兼容 Obsidian。

## 核心原则

| 原则 | 要求 |
|---|---|
| 深度理解而非翻译 | 聚焦洞见提取、批判反思、重构，不做表面翻译 |
| 强可追溯性 | 每条洞见和结构对象尽可能标注原文证据；每次状态变更写入 trace.jsonl |
| 发现而非强加 | Datafication 只发现文章真实存在的结构，不为了填 schema 而制造结构 |
| 局部优先 | 文章整体没有概念系统时，仍可提取局部 process / classification / criteria 等结构 |
| 不预设本体 | Datafication 不声称建立“正确 ontology”；只记录作者表达或忠实重构的结构 |
| Human-in-the-Loop | 重构方案必须等用户确认；已确认结果因上游过期时只标记、不静默覆盖 |
| 按需执行 | 用户选择执行哪些功能；系统按依赖矩阵提示可执行性，不强制全流程 |
| 风险可见 | 允许在数据过期时强制推进（仅 note_generator），产出物必须写入数据新鲜度水印 |

## 目录约定

所有读写都在当前工作目录的 `.petrelpost/` 下：

```
.petrelpost/
├── articles/
│   ├── _index.md
│   └── [slug]/
│       ├── state.json
│       ├── trace.jsonl
│       ├── original/
│       ├── analysis/              # structured_extractor
│       ├── datafication/          # datafication
│       ├── immersion/             # immersion_reader
│       ├── synthesis/             # synthesis
│       ├── critique/              # critic
│       ├── reconstruction/        # reconstructor
│       ├── outputs/[slug].md      # note_generator
│       └── optimization_report.md # evaluator
└── outputs/[slug].md
```

## 功能与依赖矩阵

9 个功能分属 4 个平台期（Stage）。Datafication 是 A 阶段的**可选独立分支**，不进入核心链路，不阻塞 synthesis。

| 功能（简写） | Stage | requires（硬依赖） | enhanced_by（软依赖） | produces | 特殊规则 |
|---|---|---|---|---|---|
| importer (imp) | A 素材构建 | — | — | raw_content | 唯一强制项 |
| structured_extractor (ext) | A | raw_content | — | structured_data | 核心链路 |
| datafication (df) | A | raw_content | structured_data | datafication | 可选；局部/整体结构发现，不阻塞后续 |
| immersion_reader (imm) | A | raw_content | — | immersion_notes | 可选；与 ext 无依赖，可先于 ext 执行 |
| synthesis (syn) | B 分析产出 | structured_data | immersion_notes, datafication | synthesis_pkg | datafication 作为可选增强输入 |
| critic (crt) | B | synthesis_pkg | — | critique_report | 可选 |
| reconstructor (rec) | C 人机重构 | synthesis_pkg | critique_report | reconstruction | human_gate；确认前 status=draft |
| note_generator (note) | C | reconstruction.confirmed | — | note_final | 允许 override（需水印） |
| evaluator (eval) | D 进化评估 | note_final | — | optimization_report | 可选 |

依赖判定基于**产出物状态**（state.json），不是“功能是否被调用过”。完整协议见 `references/protocol.md`。

## Datafication 定位

Datafication 不是“把文章转换成数据”，而是：

> **在文章中发现具有独立结构性、边界性和复用价值的知识单元，并将这些结构显式化。**

重要边界：

- 不是所有文章都有可数据化结构。
- 一篇文章没有概念系统，也可能存在一个或多个局部结构。
- 只有在文章本身形成相互组织的结构时，才描述 article-level conceptualization。
- 不将 author_asserted 等同于“正确”；它只表示该结构由作者表达。
- 不把 Datafication 的结果自动升级为 ontology。

## 执行协议（每个功能执行必走）

1. **读状态**：读取 `.petrelpost/articles/[slug]/state.json`（不存在则视为全空状态）
2. **判状态**：按状态符号表计算目标功能的当前状态；锁定（L）或过期（!）时向用户说明原因与选项，不擅自执行
3. **执行**：读取 `references/functions/<function>.md`，严格按模板执行并落盘
4. **更新状态**：写入 state.json（status + run_at + produced_by + preview）并追加 trace.jsonl
5. **级联**：按 `references/protocol.md` 的级联规则同步标记下游，然后重新展示功能菜单

### 状态符号

| 符号 | 含义 | 判定 |
|---|---|---|
| `·` | 可执行 | 产出缺失且依赖全部满足 |
| `~` | 可执行（未增强） | 产出缺失，硬依赖满足但软依赖缺失或过期 |
| `x` | 已完成 | 产出存在且非 stale |
| `!` | 已过期 | 产出存在但 stale=true |
| `L` | 锁定 | 硬依赖缺失，或硬依赖过期且该功能不可 override |
| `F` | 失败 | status=failed |

## 功能菜单

文章导入或用户要求查看进度时，按状态符号展示：

```
📰 {title}

A 素材构建   x importer   · ext 结构抽取   · df 数据化 [可选]   · imm 沉浸重建 [可选]
B 分析产出   L synthesis（锁定：需 structured_data）
C 人机重构   L reconstructor   L note_generator
D 进化评估   L evaluator

回复功能名或编号执行；也可以说“继续”、“完整流程”、“数据化”等。
```

## 自然语言指令映射

| 用户说 | 动作 |
|---|---|
| 给出文章 URL / 本地路径 | 执行 importer，然后展示功能菜单 |
| “继续” / “下一步” | 按核心链路顺序执行下一个可执行功能；Datafication 不自动加入核心链路 |
| “完整流程” / “深度阅读这篇” | imp → ext → imm → syn → crt → rec（停下等确认）→ note → eval；Datafication 需明确要求或选择 |
| “数据化” / “找出可以数据化的内容” | 执行 datafication |
| “完整流程 + 数据化” | 核心流程并在 A 阶段执行 datafication |
| “只批判” / “换批判模式重跑” | 执行 / 重跑 critic |
| “确认” / “选方案 A” | 确认 reconstructor 草稿 |
| “强制生成笔记” | note_generator override（仅 stale 时），笔记写入新鲜度水印 |
| “状态” / “看板” / “进度” | 重新计算并展示功能菜单 |
| “评估一下” | 执行 evaluator |

功能参数默认值定义在各 reference 文件中；用户明确指定时覆盖默认值，并记入当次 trace 的 config 字段。

## Human-in-the-Loop（reconstructor 专属）

- 呈现方案后必须等待用户响应，不自动推进。
- 用户可选：选定方案 / 混合方案 / 修改方案 / 自定义框架。
- 确认后 reconstruction.status → confirmed（附 confirmed_at）。
- 已确认结果因上游重跑被级联标记时：保留确认记录，只追加 stale 标记，交用户裁决。

## 输出语言

- 默认简体中文；专业术语保留英文并附中文解释
- 引用原文证据保留英文原文
- 笔记为 Obsidian 兼容格式（YAML frontmatter + wikilinks + kebab-case 标签）

## 参考文件索引

| 文件 | 内容 |
|---|---|
| `references/protocol.md` | state.json、状态判定、级联失效、override、trace |
| `references/functions/importer.md` | 导入清洗与元数据 |
| `references/functions/structured_extractor.md` | Purpose / Claims / Methods / Data + 假设 + 证据 |
| `references/functions/datafication.md` | 可数据化结构发现、验证、局部结构化、provenance 与反过度结构化 |
| `references/functions/immersion_reader.md` | 沉浸式阅读 |
| `references/functions/synthesis.md` | 综合分析包 |
| `references/functions/critic.md` | 批判报告 |
| `references/functions/reconstructor.md` | 重构方案 + HIL |
| `references/functions/note_generator.md` | Obsidian 笔记生成 |
| `references/functions/evaluator.md` | 质量评估与进化建议 |

版本：dr3-reading/1.5 · 源自 InsightWeaver DR3 v0.4
