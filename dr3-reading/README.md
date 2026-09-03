# DR3 深度阅读（dr3-reading）

将英文专业文章转化为**属于你的、中文、高价值、可追溯**的深度笔记，并可按需发现文章中的可数据化知识结构。

> 源自 InsightWeaver DR3 v0.4 的「平台期 + 依赖矩阵」模型。无运行时依赖、无固定本机路径，任何工作目录开箱即用，产出高度兼容 Obsidian。

---

## 它解决什么问题

用 AI 读英文文章，常见失败模式是“太浅”的摘要和“太直”的全文翻译。dr3-reading 不做简单翻译，也不把所有内容强行结构化，而是通过：

```
结构化理解 → 可选知识结构发现 → 沉浸式阅读 → 批判反思 → 人机协作重构 → 笔记沉淀 → 质量评估
```

每条洞见和知识结构尽可能保留原文证据，每次执行写入状态留痕，重构方案必须经用户确认。

---

## Datafication：把文章中的结构性知识显式化

新增的 `datafication` 是一个**可选的 A 阶段分支**。

它回答的不是“文章有什么数据”，而是：

> **文章中是否存在具有独立结构性、边界性和复用价值的知识单元？如果存在，能否忠实地把它显式化？**

可能发现的结构包括：

- Process：流程、步骤、生命周期
- Classification：分类体系
- Criteria：判断或评价标准
- Decision Rule：条件—行动规则
- Framework：框架、模型、矩阵
- Comparison：系统比较
- Scale：等级、成熟度、阶段尺度
- Enumeration：具有共同语义边界的列举
- Relationship：作者明确表达的关系

### 重要边界

- 不是所有文章都有可数据化结构。
- 文章整体没有概念系统，也可能存在局部可数据化结构。
- Datafication 是 **discover, don't impose**：不为了填 schema 而制造结构。
- 标题、普通列表、叙事顺序不会自动被当成结构。
- 每个结构必须有 scope 和 evidence。
- `author_asserted` 只表示“作者表达了该结构”，不表示 DR3 认可其正确性。
- Datafication 不自动建立 ontology；它可以成为后续 Concept System / Ontology / Alignment 工作的上游输入。

---

## 工作流总览

9 个功能分属 4 个阶段。Datafication 是 A 阶段可选分支，不改变核心链路：

| Stage | 功能 | 作用 | 定位 |
|---|---|---|---|
| A 素材构建 | `importer` | 抓取、清洗、元数据、去重 | 唯一强制项 |
| A | `structured_extractor` | Purpose / Claims / Methods / Data + 假设 + 证据 | 核心链路 |
| A | `datafication` | 发现并结构化局部或整体知识结构 | 可选增强 |
| A | `immersion_reader` | 沉浸式阅读 | 可选增强 |
| B 分析产出 | `synthesis` | 综合分析 | 核心链路 |
| B | `critic` | 批判分析 | 可选增强 |
| C 人机重构 | `reconstructor` | 重构方案，等用户确认 | 核心链路（HIL） |
| C | `note_generator` | Obsidian 笔记 | 核心链路 |
| D 进化评估 | `evaluator` | 质量评估 + 进化建议 | 可选 |

**核心链路**：`importer → structured_extractor → synthesis → reconstructor → note_generator`

**Datafication 分支**：`importer → datafication →（可选增强 synthesis）`

---

## 快速开始

导入文章后，功能菜单会显示：

```
📰 {title}

A 素材构建   x importer   · ext 结构抽取   · df 数据化 [可选]   · imm 沉浸阅读 [可选]
B 分析产出   L synthesis（锁定：需 structured_data）
C 人机重构   L reconstructor   L note_generator
D 进化评估   L evaluator
```

可以直接说：

- `数据化`：执行 datafication
- `找出可以数据化的内容`：执行 datafication
- `继续`：只沿核心链路推进，不自动加入 datafication
- `完整流程 + 数据化`：在完整流程中加入 datafication

---

## 输出结构

```
.petrelpost/articles/[slug]/
├── state.json
├── trace.jsonl
├── original/
├── analysis/
├── datafication/
│   ├── datafication.md
│   └── datafication.json
├── immersion/
├── synthesis/
├── critique/
├── reconstruction/
└── outputs/[slug].md
```

`datafication.json` 是机器可解析结果；`datafication.md` 用于人工检查。两者都必须保留结构对象的 provenance、scope 和 evidence。

---

## 状态系统

每篇文章有独立的 `state.json`。Datafication 使用 `raw_content` 作为硬依赖，`structured_data` 作为软增强：

- 只有 raw_content：`~`，可以执行但未使用 structured_extractor 增强
- raw_content + 有效 structured_data：`·`
- datafication 已完成：`x`
- importer 重跑：datafication → `!`
- structured_extractor 重跑：datafication → `stale_soft=true`，不阻塞
- datafication 重跑：synthesis 只产生软过期，不改变核心链路的硬状态

这保证 Datafication 是**可选知识产出，而不是阅读流程的强制步骤**。

---

## 设计理念

1. **深度理解而非翻译**——目标是认知增量，不是语言转换
2. **发现而非强加**——Datafication 只发现文章已有结构，不为了结构数量而制造结构
3. **局部优先**——没有整体概念系统也可以提取局部结构
4. **强可追溯性**——结构对象和洞见都尽可能回指原文
5. **不预设本体**——作者表达的结构可以被保存、比较和质疑，不自动被当成正确 ontology
6. **Human-in-the-Loop**——重构方案必须人工确认
7. **按需执行**——依赖矩阵提示可执行性，不强制全流程

---

## Skill 内部结构

```
dr3-reading/
├── SKILL.md
├── README.md
└── references/
    ├── protocol.md
    └── functions/
        ├── importer.md
        ├── structured_extractor.md
        ├── datafication.md
        ├── immersion_reader.md
        ├── synthesis.md
        ├── critic.md
        ├── reconstructor.md
        ├── note_generator.md
        └── evaluator.md
```

版本：dr3-reading/1.1 · 源自 InsightWeaver DR3 v0.4
