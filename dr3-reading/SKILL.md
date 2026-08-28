---
name: dr3-reading
description: 深度阅读工作流：将英文专业文章（HBR、Strategy+Business、学术期刊、商业评论等）转化为可追溯的中文深度笔记。当用户提供文章 URL 或本地路径，并要求深度阅读、深度笔记、批判性分析、洞见重构或生成 Obsidian 笔记时使用。提供八个按需组合的功能（导入、结构抽取、沉浸阅读、综合、批判、人机重构、笔记生成、质量评估），支持断点续读、状态级联与数据新鲜度管理。不适用于简单翻译、快速摘要或非文章类内容处理。
---

# DR3 深度阅读（dr3-reading）

将英文专业文章转化为**属于用户的、中文、高价值、可追溯的深度笔记**。

不做简单翻译：通过 结构化理解 → 沉浸式阅读 → 批判反思 → 人机协作重构，完成从浅层阅读到深度认知的跃迁。源自 InsightWeaver DR3 v0.4 的"平台期 + 依赖矩阵"模型，无运行时依赖，高度兼容 Obsidian。

## 核心原则

| 原则 | 要求 |
|------|------|
| 深度理解而非翻译 | 聚焦洞见提取、批判反思、重构，不做表面翻译 |
| 强可追溯性 | 每条洞见标注原文证据；每次状态变更写入 trace.jsonl |
| Human-in-the-Loop | 重构方案必须等用户确认；已确认结果因上游过期时只标记、不静默覆盖 |
| 按需执行 | 用户选择执行哪些功能；系统按依赖矩阵提示可执行性，不强制全流程 |
| 风险可见 | 允许在数据过期时强制推进（仅 note_generator），产出物必须写入数据新鲜度水印 |

## 目录约定

所有读写都在当前工作目录的 `.petrelpost/` 下（相对路径，环境无关）：

```
.petrelpost/
├── articles/
│   ├── _index.md                  # 已处理文章索引（去重与总览）
│   └── [slug]/
│       ├── state.json             # 产出物状态表（执行判定的唯一依据）
│       ├── trace.jsonl            # 执行轨迹（追加式）
│       ├── original/              # importer：article.md + metadata.yaml
│       ├── analysis/              # structured_extractor
│       ├── immersion/             # immersion_reader
│       ├── synthesis/             # synthesis
│       ├── critique/              # critic
│       ├── reconstruction/        # reconstructor
│       ├── outputs/[slug].md      # note_generator 主笔记
│       └── optimization_report.md # evaluator
└── outputs/[slug].md              # 全局导出副本（Obsidian 索引）
```

## 功能与依赖矩阵

8 个功能分属 4 个平台期（Stage）。**核心链路**：importer → structured_extractor → synthesis → reconstructor → note_generator；**可选功能**：immersion_reader、critic、evaluator。

| 功能（简写） | Stage | requires（硬依赖） | enhanced_by（软依赖） | produces | 特殊规则 |
|---|---|---|---|---|---|
| importer (imp) | A 素材构建 | — | — | raw_content | 唯一强制项 |
| structured_extractor (ext) | A | raw_content | — | structured_data | |
| immersion_reader (imm) | A | raw_content | — | immersion_notes | 可选；与 ext 无依赖，可先于 ext 执行 |
| synthesis (syn) | B 分析产出 | structured_data | immersion_notes | synthesis_pkg | |
| critic (crt) | B | synthesis_pkg | — | critique_report | 可选 |
| reconstructor (rec) | C 人机重构 | synthesis_pkg | critique_report | reconstruction | human_gate；确认前 status=draft |
| note_generator (note) | C | reconstruction.confirmed | — | note_final | 允许 override（需水印） |
| evaluator (eval) | D 进化评估 | note_final | — | optimization_report | |

依赖判定基于**产出物状态**（state.json），不是"功能是否被调用过"。完整协议见 `references/protocol.md`。

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
| `!` | 已过期 | 产出存在但 stale=true（含 confirmed+stale） |
| `L` | 锁定 | 硬依赖缺失，或硬依赖过期且该功能不可 override |
| `F` | 失败 | status=failed |

## Human-in-the-Loop（reconstructor 专属）

- 呈现方案后**必须等待**用户响应，不自动推进；用户明确确认后才持久化，无"默认确认"
- 用户可选：选定方案 / 混合方案 / 修改方案（最多 2 轮迭代）/ 自定义框架
- 确认后 state.json 中 reconstruction.status 由 draft 置为 confirmed（附 confirmed_at）
- 已确认结果因上游重跑被级联标记时：保留确认记录，只追加 stale 标记，交用户裁决

## 功能菜单

文章导入或用户要求查看进度时，按状态符号展示：

```
📰 {title}

A 素材构建   x importer   · ext 结构抽取   · imm 沉浸重建 [可选]
B 分析产出   L synthesis（锁定：需 structured_data）
C 人机重构   L reconstructor   L note_generator
D 进化评估   L evaluator

回复功能名或编号执行；也可以说"继续"、"完整流程"、"只批判"等。
```

## 自然语言指令映射

| 用户说 | 动作 |
|---|---|
| 给出文章 URL / 本地路径 | 执行 importer，然后展示功能菜单 |
| "继续" / "下一步" | 按核心链路顺序执行下一个可执行功能 |
| "完整流程" / "深度阅读这篇" | imp → ext → imm → syn → crt → rec（停下等确认）→ note → eval |
| "快速流程" | 核心链路：imp → ext → syn → rec（停）→ note |
| "只批判" / "换批判模式重跑" | 执行 / 重跑 critic（可指定 red_team / socratic / collaborative） |
| "确认" / "选方案 A" | 确认 reconstructor 草稿 |
| "强制生成笔记" | note_generator override（仅 stale 时），笔记写入新鲜度水印 |
| "状态" / "看板" / "进度" | 重新计算并展示功能菜单 |
| "评估一下" | 执行 evaluator |

功能参数（抽取深度、沉浸风格、批判模式与深度、笔记模板等）默认值定义在各 reference 文件中；用户明确指定时覆盖默认值，并记入当次 trace 的 config 字段。

## 输出语言

- 默认简体中文；专业术语保留英文并附中文注释
- 引用原文证据保留英文原文
- 笔记为 Obsidian 兼容格式（YAML frontmatter + wikilinks + kebab-case 标签）

## 参考文件索引

| 文件 | 内容 |
|---|---|
| `references/protocol.md` | state.json 结构、状态判定逻辑、级联失效、override 水印、trace 格式 |
| `references/functions/importer.md` | 导入清洗：抓取、去重、9 字段元数据、slug 生成 |
| `references/functions/structured_extractor.md` | 四维度抽取：Purpose / Claims / Methods / Data + 假设 + 证据映射 |
| `references/functions/immersion_reader.md` | 3 种沉浸风格 × 3 个视角（neutral / author / skeptic） |
| `references/functions/synthesis.md` | 3 种融合策略的综合分析包 |
| `references/functions/critic.md` | 3 种批判模式 × 3 档深度的批判报告 |
| `references/functions/reconstructor.md` | SCQA / Pyramid / Narrative_Arc 重构方案 + HIL 确认协议 |
| `references/functions/note_generator.md` | 3 种模板的 Obsidian 笔记生成 |
| `references/functions/evaluator.md` | 五指标评估 + 三层进化建议 |
