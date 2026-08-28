# immersion_reader 功能模板

module: immersion_reader
version: dr3-reading/1.0
stage: A
requires: [raw_content.completed]
produces: immersion_notes
optional: true
outputs_to: [".petrelpost/articles/[slug]/immersion/", ".petrelpost/articles/[slug]/trace.jsonl", ".petrelpost/articles/[slug]/state.json"]

> 依赖说明：本功能仅硬依赖 raw_content，与 structured_extractor 无依赖关系、可先于或后于其执行。若 structured_extraction.json 已存在则作为增强输入使用；不存在时基于正文直接沉浸，产出在 state.json 中标注"未增强"。

---

## 输入

- `.petrelpost/articles/[slug]/original/article.md`（清洗后正文）
- `.petrelpost/articles/[slug]/analysis/structured_extraction.json`（结构化抽取结果，**可选增强输入**）
- `.petrelpost/articles/[slug]/original/metadata.yaml`（元数据）

## 默认参数（用户可覆盖）

- `style`: `narrative_immersion`（可选 narrative_immersion / contextual_map / role_play）
- `perspectives`: `[neutral, author, skeptic]`

## 执行流程

严格按以下 6 步执行。

### Step 1: 读取输入

读取正文与元数据；若结构化抽取结果存在，一并读取作为增强输入。若正文不存在，报错提示先运行 importer。

### Step 2: 确定沉浸风格

默认 `narrative_immersion`；用户明确指定时采用用户值。

### Step 3: 确定视角列表

默认 `["neutral", "author", "skeptic"]`；用户明确指定时采用用户值。

### Step 4: 按风格执行多视角沉浸

对配置中的每个视角，使用选定的沉浸风格生成独立的沉浸输出。

---

## 三种沉浸风格详细定义

### 风格 1: narrative_immersion（叙事式沉浸）

**核心方法**：将文章还原为一段叙事旅程，重建写作动机、时代背景、论战脉络。

**执行要点**：

1. **时代与场景还原**：文章发表时的社会/行业/学术背景，当时的核心争论
2. **作者写作动机重建**：为什么写、写给谁、试图改变什么
3. **论战脉络**：文章在何种对话中发声——回应谁、反驳谁、延续谁
4. **情感弧线**：文章的论辩节奏与情感走向（铺垫→高潮→结论）
5. **关键转折点**：论证中的关键转折，为何在此处转折

**输出形态**：叙事式长文，具有时间线与故事感。

---

### 风格 2: contextual_map（语境地图式沉浸）

**核心方法**：构建结构化语境图谱，定位文章在知识网络中的位置。

**执行要点**：

1. **领域定位**：文章属于哪个学科/行业领域，交叉领域标注
2. **学术谱系**：文章依赖的理论源流，引用的关键先驱工作
3. **同期思潮**：与文章同时期的相关思潮与对立观点
4. **现实对应**：文章论点对应的现实场景、行业案例、政策背景
5. **知识图谱**：核心概念间的关系网络（层级、因果、对立、互补）

**输出形态**：结构化图谱 + 概念关系说明。

---

### 风格 3: role_play（角色代入式沉浸）

**核心方法**：代入不同角色体验文章，重建各方的认知与情感体验。

**执行要点**：

1. **作者角色**：我（作者）为什么写这篇文章？我最想让读者接受什么？我刻意回避了什么？
2. **目标读者角色**：作为目标读者，我读到了什么？我可能在哪里点头、在哪里皱眉？这篇文章如何改变我的认知？
3. **对手角色**：作为观点对立者，我最想反驳什么？我看到的漏洞是什么？我会如何回应？

**输出形态**：角色视角报告，每个角色独立成节。

---

## 三种视角详细定义

每个视角在沉浸输出中体现不同的关注倾向：

| 视角 | 沉浸立场 | 关注重点 | 输出基调 |
|------|---------|---------|---------|
| neutral | 旁观者 | 客观语境、事实背景、领域知识 | 中性陈述，避免价值判断 |
| author | 作者本人 | 写作意图、立场倾向、修辞策略、情感脉络 | 代入作者视角，理解而非评判 |
| skeptic | 质疑者 | 论证弱点、未言明之处、选择性证据、替代解释 | 审视式，指出盲区与替代可能 |

**视角与风格的交叉**：
- 同一风格下，不同视角产生不同的沉浸侧重点
- 例：narrative_immersion + skeptic → 叙事中对每个转折点的质疑性审视
- 例：contextual_map + author → 语境地图中突出作者的理论谱系归属

---

## Step 5: 持久化输出

写入 `.petrelpost/articles/[slug]/immersion/` 目录。

### 输出文件结构

```
immersion/
├── immersion_neutral.md      # neutral 视角沉浸
├── immersion_author.md       # author 视角沉浸
├── immersion_skeptic.md      # skeptic 视角沉浸
├── immersion_meta.md         # 沉浸元信息（风格、视角、摘要）
└── immersion_index.json      # 机器可解析索引
```

### 各视角文件格式

**immersion_neutral.md**：

```markdown
# 沉浸式阅读 — Neutral 视角

> 风格：{style} | 文章：{title} | 视角：neutral

---

{按选定风格生成的 neutral 视角沉浸内容}

## 关键发现

- {发现1}
- {发现2}
- {发现3}

## 对后续功能的提示

- synthesis 应关注：{该视角下需要融合的关键信息}
```

**immersion_author.md** / **immersion_skeptic.md** 格式同上，仅视角标签与内容不同。

**immersion_meta.md**：

```markdown
# 沉浸阅读元信息

- **文章**：{title}
- **沉浸风格**：{style}
- **视角**：neutral, author, skeptic
- **生成时间**：{ISO时间}

## 各视角摘要

### Neutral
{2-3句话摘要}

### Author
{2-3句话摘要}

### Skeptic
{2-3句话摘要}
```

**immersion_index.json**：

```json
{
  "module": "immersion_reader",
  "slug": "[slug]",
  "style": "narrative_immersion",
  "perspectives": ["neutral", "author", "skeptic"],
  "generated_at": "[ISO时间]",
  "perspectives_summary": {
    "neutral": "摘要...",
    "author": "摘要...",
    "skeptic": "摘要..."
  },
  "key_findings": {
    "neutral": ["发现1", "发现2"],
    "author": ["发现1", "发现2"],
    "skeptic": ["发现1", "发现2"]
  }
}
```

**更新 state.json**（按 `references/protocol.md` 结构）：

```json
"immersion_notes": {
  "status": "completed",
  "run_at": "[ISO时间]",
  "stale": false,
  "produced_by": { "module": "immersion_reader", "version": "dr3-reading/1.0" },
  "preview": "{style}, {N} perspectives, enhanced: {true/false}"
}
```

若为重新执行：先写入本条目，再按级联规则标记下游（synthesis 获 stale_soft，不阻塞）。

### Step 6: 追加 trace + 输出摘要

追加 `trace.jsonl`：

```json
{"module": "immersion_reader", "timestamp": "[ISO时间]", "status": "success", "input": ".petrelpost/articles/[slug]/original/article.md", "config": {"style": "narrative_immersion", "perspectives": ["neutral", "author", "skeptic"]}}
```

输出摘要：

```
✅ immersion_reader 完成

- 沉浸风格：{style}
- 视角：neutral ✅ | author ✅ | skeptic ✅
- 增强输入：{structured_extraction 已使用 / 未使用（未增强）}
- 存储路径：.petrelpost/articles/[slug]/immersion/

各视角关键发现：
- Neutral: {一句话}
- Author: {一句话}
- Skeptic: {一句话}
```

完成后重新展示功能菜单，等待用户选择下一步。不自动执行后续功能。

---

## 输出语言规则

immersion_reader 是第一个"理解性"功能，输出采用**中英混合**：
- 分析与理解内容：**中文**
- 引用原文关键段落：**保留英文原文**
- 专业术语：**英文 + 中文注释**（如 "Porter's Five Forces（波特五力模型）"）
- 概念名称：**英文 + 中文释义**

---

## 错误处理

| 场景 | 处理方式 |
|------|---------|
| 正文文件不存在 | 报错，提示先运行 importer |
| 文章过短无法沉浸 | 降级为 contextual_map 风格，生成简版语境地图 |
| 某视角输出为空 | 标注 `insufficient_context`，保留其他视角结果 |
| 风格参数无效 | 回退至 narrative_immersion 并警告 |

---

## Prompt 指令体

```
你是 dr3-reading 的 immersion_reader 功能。

任务：对文章进行沉浸式阅读，重建文章的语境、场景、情感、作者立场与历史背景，从多个视角生成深层理解。

输入文件：
- .petrelpost/articles/[slug]/original/article.md
- .petrelpost/articles/[slug]/analysis/structured_extraction.json（可选增强）
- .petrelpost/articles/[slug]/original/metadata.yaml

配置：
- 沉浸风格：{style}（narrative_immersion / contextual_map / role_play）
- 视角：{perspectives}

请严格按以下步骤执行：
1. 读取正文、元数据与（若存在的）结构化抽取结果
2. 确定沉浸风格（{style}）
3. 确定视角列表（{perspectives}）
4. 对每个视角，使用选定风格生成沉浸输出：
   - neutral：客观语境重建，中性陈述
   - author：代入作者视角，理解写作意图与立场
   - skeptic：质疑者视角，审视论证弱点与替代解释
5. 持久化到 immersion/ 目录（每视角独立 .md + meta + index.json）+ 更新 state.json + 级联
6. 追加 trace.jsonl + 输出摘要

输出语言规则：
- 分析内容使用中文
- 引用原文保留英文
- 专业术语：英文 + 中文注释

关键规则：
- 不做批判——skeptic 视角指出盲区但不做定论，定论留给 critic 功能
- 不做重构——只加深理解，不改变结构
- 每个视角的输出必须标注"对后续功能的提示"，帮助 synthesis 融合
- 不同视角应呈现真实差异，而非换词重写
```
