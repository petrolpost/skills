# DR3 深度阅读（dr3-reading）

将英文专业文章转化为**属于你的、中文、高价值、可追溯**的深度笔记。

> 源自 InsightWeaver DR3 v0.4 的「平台期 + 依赖矩阵」模型。无运行时依赖、无固定本机路径，任何工作目录开箱即用，产出高度兼容 Obsidian。

---

## 它解决什么问题

用 AI 读英文文章，通常有两种失败模式：

| 常见做法 | 问题 |
|---|---|
| AI 三句话摘要 | 太浅——观点有了，证据链没有，一周后只剩模糊印象 |
| AI 全文翻译 | 太直——语言转换了，认知没有转换，读完仍是"看过"而非"读懂" |

dr3-reading 不做翻译，也不做摘要。它走一条完整链路：

```
结构化理解 → 沉浸式阅读 → 批判反思 → 人机协作重构 → 笔记沉淀 → 质量评估
```

每条洞见标注原文证据，每次执行写入状态留痕，重构方案必须经你确认——笔记是"和 AI 一起想出来的"，不是"AI 替你总结的"。

---

## 适用 / 不适用

**适用**：
- HBR、Strategy+Business、麦肯锡季刊、学术期刊、高质量商业博客等**英文专业文章**
- 需要长期沉淀进个人知识库（尤其 Obsidian）的深度笔记
- 希望对文章观点做批判性检验，而非单向接收
- 跨多次会话的断点续读：处理到一半，下次接着来

**不适用**：
- 简单翻译（直接让 AI 翻即可）
- 快速摘要（杀鸡用牛刀）
- 非文章类内容（视频、播客转写稿、书籍整本）

---

## 工作流总览

8 个功能分属 4 个阶段（Stage），按依赖矩阵组合执行，**不强制全流程**：

| Stage | 功能 | 作用 | 定位 |
|---|---|---|---|
| A 素材构建 | `importer` | 抓取、清洗、9 字段元数据、去重 | 唯一强制项 |
| A | `structured_extractor` | 四维度抽取：目的 / 主张 / 方法 / 数据 + 隐含假设 + 证据映射 | 核心链路 |
| A | `immersion_reader` | 3 种沉浸风格 × 3 个视角（中立 / 作者 / 怀疑者） | 可选增强 |
| B 分析产出 | `synthesis` | 融合抽取结果与沉浸笔记，生成综合分析包 | 核心链路 |
| B | `critic` | 3 种批判模式（red_team / socratic / collaborative）× 3 档深度 | 可选增强 |
| C 人机重构 | `reconstructor` | 3 种框架（SCQA / Pyramid / Narrative_Arc）生成方案，**等你确认** | 核心链路（HIL） |
| C | `note_generator` | 3 种模板生成 Obsidian 笔记 | 核心链路 |
| D 进化评估 | `evaluator` | 5 项指标质量评估 + 三层进化建议 | 可选 |

**核心链路**：`importer → structured_extractor → synthesis → reconstructor → note_generator`

---

## 快速开始

### 1. 安装

- **TRAE**：下载 [dr3-reading.skill](releases/dr3-reading.skill)（ZIP 格式），在技能市场导入
- **手动**：解压到你的 skills 目录，确保 `SKILL.md` 位于 `dr3-reading/` 根下

### 2. 第一篇文章

直接把文章 URL 丢给 AI：

```
帮我深度阅读这篇文章：https://hbr.org/2025/01/xxxx
```

importer 自动执行，然后展示功能菜单：

```
📰 Why Strategy Unsticks

A 素材构建   x importer   · ext 结构抽取   · imm 沉浸重建 [可选]
B 分析产出   L synthesis（锁定：需 structured_data）
C 人机重构   L reconstructor   L note_generator
D 进化评估   L evaluator

回复功能名或编号执行；也可以说"继续"、"完整流程"、"只批判"等。
```

### 3. 三种推进方式

| 你说 | AI 做 |
|---|---|
| `完整流程` | 8 个功能依次执行，到 reconstructor 停下等你确认方案 |
| `继续` | 按核心链路执行下一个可执行功能 |
| `快速流程` | 跳过可选项，只走核心链路 |

重构方案确认是唯一强制的人工卡点——AI 呈现 2-3 个候选方案、各自如何回应批判发现、推荐理由，你拍板后才生成笔记。

---

## 自然语言指令速查

| 你说 | 动作 |
|---|---|
| 给出文章 URL / 本地路径 | 执行 importer，展示功能菜单 |
| `继续` / `下一步` | 执行下一个可执行功能 |
| `完整流程` / `深度阅读这篇` | 全流程（重构处停下等确认） |
| `快速流程` | 核心链路直达笔记 |
| `只批判` / `换 red_team 模式重跑` | 执行 / 重跑 critic |
| `确认` / `选方案 A` | 确认重构方案 |
| `强制生成笔记` | 过期数据下放行 note_generator（笔记写入新鲜度水印） |
| `状态` / `看板` / `进度` | 重新展示功能菜单 |
| `评估一下` | 执行 evaluator |

---

## 状态系统与断点续读

每篇文章有独立的 `state.json`，功能菜单的每个符号实时反映可执行性：

| 符号 | 含义 |
|---|---|
| `·` | 可执行 |
| `~` | 可执行（软依赖缺失，产出会标注"未增强"） |
| `x` | 已完成 |
| `!` | 已过期（上游重跑过） |
| `L` | 锁定（依赖缺失或过期） |
| `F` | 失败（可重试） |

**级联失效**：重跑任一功能，下游自动标记过期。已确认的重构方案不会被静默覆盖——保留确认记录、追加过期标记、交你裁决。会话中断后，AI 读取状态即可无缝续读。

**数据新鲜度**：唯一允许的强制放行是"基于过期重构生成笔记"，此时笔记开头必须写入水印，声明数据已过期。过期就是过期，不装新鲜。

---

## 输出结构

所有产出写入当前工作目录的 `.petrelpost/`（相对路径，环境无关）：

```
.petrelpost/
├── articles/
│   ├── _index.md                  # 已处理文章索引（去重 + 总览）
│   └── [slug]/
│       ├── state.json             # 状态表（执行判定唯一依据）
│       ├── trace.jsonl            # 执行轨迹（追加式审计日志）
│       ├── original/              # 清洗后原文 + 元数据
│       ├── analysis/              # 结构化抽取结果
│       ├── immersion/             # 沉浸阅读笔记
│       ├── synthesis/             # 综合分析包
│       ├── critique/              # 批判报告
│       ├── reconstruction/        # 重构方案（draft → confirmed）
│       ├── outputs/[slug].md      # 最终笔记
│       └── optimization_report.md # 质量评估报告
└── outputs/[slug].md              # 全局导出副本（Obsidian 直接索引）
```

笔记为标准 Obsidian 格式：YAML frontmatter、kebab-case 标签、中文概念双链、行动项复选框。把 `.petrelpost/outputs/` 指向 Obsidian 库即可直接使用。

---

## 可调参数（各功能默认值见对应模板）

| 功能 | 参数 | 选项 |
|---|---|---|
| structured_extractor | extraction_depth | standard / high |
| immersion_reader | style × persona | 3 风格 × 3 视角 |
| critic | critique_mode × depth | red_team / socratic / collaborative × 3 档 |
| reconstructor | framework | SCQA / Pyramid / Narrative_Arc / 自定义 |
| note_generator | template | deep_with_evidence / concise / flashcard |
| note_generator | evidence_link_style | quote_with_source / footnote / inline |

参数默认值内置于模板；你明确指定时覆盖默认，并记入 trace 留痕。

---

## 设计理念

1. **深度理解而非翻译**——目标是认知增量，不是语言转换
2. **强可追溯性**——每条洞见有证据链，每次执行有 trace；笔记经得起半年后回看追问
3. **Human-in-the-Loop**——重构方案必须人工确认；已确认结果不静默覆盖；无"默认同意"
4. **按需执行**——依赖矩阵提示可执行性，不强制全流程；熟悉领域可以走快速链路
5. **风险可见**——允许在过期数据上强制推进，但产出物必须声明，决策权在你

---

## Skill 内部结构

```
dr3-reading/
├── SKILL.md              # 总纲：依赖矩阵、状态机、指令映射
├── README.md             # 本文件
└── references/
    ├── protocol.md       # state / trace 协议 + 级联失效规则
    └── functions/        # 8 个功能模板（执行时按需加载）
```

版本：dr3-reading/1.0 · 源自 InsightWeaver DR3 v0.4
