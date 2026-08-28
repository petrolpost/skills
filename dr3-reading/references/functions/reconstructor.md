# reconstructor 功能模板

module: reconstructor
version: dr3-reading/1.0
stage: C
requires: [synthesis_pkg.completed]
enhanced_by: [critique_report.completed]
produces: reconstruction
human_gate: true
on_upstream_stale: flag_confirmed_but_keep
outputs_to: [".petrelpost/articles/[slug]/reconstruction/", ".petrelpost/articles/[slug]/trace.jsonl", ".petrelpost/articles/[slug]/state.json"]

changelog: "承袭 DR3 v0.4 修订：Step 5 呈现格式为强制四项（方案对照表/决策启发式/推荐+理由/完整版指引），修复不同执行者呈现详略不一致、关键决策信息缺失的问题"

---

## 输入

- `.petrelpost/articles/[slug]/synthesis/synthesis.md`（综合分析包）
- `.petrelpost/articles/[slug]/synthesis/synthesis.json`（综合分析数据）
- `.petrelpost/articles/[slug]/critique/critique.md`（批判分析，**可选增强输入**）
- `.petrelpost/articles/[slug]/critique/critique.json`（批判数据，可选）
- `.petrelpost/articles/[slug]/original/article.md`（原文参照）

## 默认参数（用户可覆盖）

- `num_suggestions`: `3`
- `require_user_confirmation`: `true`
- `max_iteration`: `2`
- `reconstruction_frameworks`: `[SCQA, Pyramid, Narrative_Arc]`

## 执行流程

严格按以下 7 步执行。**本功能为 Human-in-the-Loop 核心环节，Step 5-6 必须等待用户参与。**

### Step 1: 读取输入

读取 synthesis 输出与原文。critique 为可选增强输入：存在则融合其发现，不存在则标注"未增强"继续（硬依赖仅为 synthesis）。synthesis 文件缺失则报错提示。

### Step 2: 确定参数

- `num_suggestions`：生成方案数（默认 3）
- `max_iteration`：最大迭代轮数（默认 2）
- `require_user_confirmation`：是否需确认（默认 true）

### Step 3: 分析文章特征，匹配最佳框架

根据文章特征为每个方案推荐最合适的重构框架：

| 文章特征 | 推荐框架 | 匹配理由 |
|---------|---------|---------|
| 问题驱动、提出明确问题并解答 | SCQA | 天然适配 Situation-Complication-Question-Answer 结构 |
| 论证严密、多层主张逐层支撑 | Pyramid | 结论先行，证据逐层展开 |
| 叙事驱动、案例/故事为核心 | Narrative_Arc | 按故事弧线重组洞见 |
| 混合型 | 优先 Pyramid + 备选 SCQA | 混合文章先试结构化框架 |

**每个方案使用不同框架**（若 num_suggestions=3，则分别使用三种框架），确保用户有结构化视角的选择。

### Step 4: 生成重构方案

对每个方案，使用对应框架重构 synthesis + critic 的结果。

#### 方案 A: SCQA 框架重构

```markdown
## 方案 A：SCQA 重构

### S — Situation（情境）

{用中文重述文章所描述的现实情境/背景，2-3 段}

### C — Complication（冲突）

{从 synthesis 和 critic 中提炼核心矛盾/冲突/问题，突出 critic 指出的逻辑漏洞和实践障碍}

### Q — Question（核心问题）

{将 Complication 转化为一个精准的核心问题，这是重构的关键——好的问题比答案更重要}

### A — Answer（洞见回答）

{基于 synthesis 中的主张体系，回答核心问题：
- 主洞见：最核心的回答
- 次洞见：补充性回答
- 批判性补充：critic 的关键发现如何修正回答}

### 证据链

| 洞见 | 证据来源 | 原文段落 | 批判评估 |
|------|---------|---------|---------|
| {洞见} | {synthesis/claim_id} | P{段落} | {critic/severity} |
```

#### 方案 B: Pyramid 金字塔原理重构

```markdown
## 方案 B：金字塔原理重构

### 顶层结论

{用一句话概括全文最核心的洞见，这是金字塔的塔尖}

### 关键论点（3-5 个支撑论点）

**论点 1**：{关键论点}
  - 证据：P{段落} — "{引文}"
  - 批判备注：{critic 对该论点的关键发现}

**论点 2**：{关键论点}
  - 证据：...
  - 批判备注：...

{继续}

### 逻辑结构图

{用文本表示金字塔层级关系}

顶层结论
├── 论点 1
│   ├── 证据 A
│   └── 证据 B
├── 论点 2
│   ├── 证据 C
│   └── 证据 D
└── 论点 3
    └── 证据 E

### 批判性修正

{基于 critic 结果，对金字塔结构提出修正建议：
- 哪些论点因批判而需降级？
- 哪些论点应增加限定条件？
- 是否需要新增论点应对 critic 的发现？}
```

#### 方案 C: Narrative_Arc 叙事弧线重构

```markdown
## 方案 C：叙事弧线重构

### 铺垫（Setup）

{建立背景与情境，引入核心概念/问题，2-3 段}

### 冲突（Conflict）

{呈现核心矛盾/挑战/争议，融入 critic 指出的关键质疑}

### 转折（Turning Point）

{文章论证的关键转折，作者提出的核心洞见/解决方案}

### 高潮（Climax）

{最有力量的论点与证据，支撑转折成立的论证高潮}

### 结论（Resolution）

{综合洞见，回应冲突，指向实践启示}

### 叙事弧线图

{用文本表示弧线结构}

  Climax ●
         / \
        /   \
Turning ●     \
Point   /       \
       /         ● Resolution
Setup ●         /
      \         /
       ● Conflict

### 批判性注脚

{critic 的关键发现如何影响叙事弧线的可信度}
```

### Step 5: 呈现方案，等待用户参与 ⚠️ Human-in-the-Loop

**这是核心的 Human-in-the-Loop 环节，必须等待用户响应。**

呈现内容必须包含以下四个部分，**缺一不可**——这不是格式偏好，是用户做出真实判断所需的最低信息量。历史教训：仅用"一句话概括该方案核心思路"这种宽松要求，不同执行者（不同模型/不同轮次）呈现的详略程度会有很大落差，轻则让用户在信息不足的情况下盲选，重则把"三个方案对同一个 critic 问题处理方式其实相同"这种关键事实（会让选择退化成纯风格偏好）藏了起来。

#### 5.1 方案对照表（强制，不能用散文代替）

以表格形式，逐条列出 critic 报告中的关键发现（至少覆盖全部 severity=high 的条目），说明每个方案分别**具体**如何回应。**不允许写"三个方案均已整合 critic 修正"这类笼统表述**：
- 如果三个方案对同一条 critic 发现的处理方式确实相同，也要明确写出"处理方式相同：{具体做法}"，不能略过不提
- 如果不同，必须写出具体差异（不是"处理得更好"这种模糊评价，而是"A 方案把这个问题放进过渡段一笔带过，B 方案单独开一节质询、C 方案通过角色/案例侧面回应"这种可比较的具体描述）

| Critic 发现（severity） | 方案 A 如何处理 | 方案 B 如何处理 | 方案 C 如何处理 |
|---|---|---|---|
| {发现1}（high） | {具体做法，非"已回应"} | {具体做法} | {具体做法} |
| {发现2}（high） | ... | ... | ... |

#### 5.2 决策启发式（强制，至少 2 条）

不要求用户读完整版才能做基本判断。给出至少 2 条"如果你更看重 X，倾向选 Y"的启发式规则，覆盖读者最可能关心的取舍维度——常见维度包括：结构清晰度 / 论证严密度 / 叙事感染力 / 与原文语域（正式论文 vs 播客闲聊等）的贴近程度 / 阅读耗时。启发式必须针对**这篇具体文章**给出，不能是三个框架的通用优缺点罗列（"SCQA 适合问题驱动的文章"这种放在任何文章下都成立的话不算启发式）。

#### 5.3 推荐 + 理由（强制）

必须给出一个推荐方案。理由必须具体到"为什么在这篇文章的语境下更合适"，禁止空泛的框架优点描述：

> ❌ "叙事弧线感染力强，因此推荐方案 C"（这句话换到任何一篇文章都成立，没有传达关于*这篇*文章的任何信息）
>
> ✅ "推荐方案 C，因为原文围绕 eBay 案例展开、案例本身自带转折点，叙事弧线能自然承载这个转折，而 A/B 两种结构化框架会把案例拆散成证据点，削弱案例本身的说服力"

#### 5.4 完整版指引（在呈现开头就说明，不是末尾小字）

明确告知完整方案在 `.petrelpost/articles/[slug]/reconstruction/reconstruction_drafts.md`，并说明"如果 5.1 的对照表还不够你判断，建议先打开这份文件"。这句话要放在呈现的**开头**，让用户在看对照表之前就知道有更详细的版本可查，而不是埋在末尾容易被忽略的位置。

呈现模板：

```
🔍 reconstructor — 洞见重构方案

已基于 synthesis + critic 生成 {num_suggestions} 个重构方案，完整版见
.petrelpost/articles/[slug]/reconstruction/reconstruction_drafts.md。以下是
决策所需的关键信息；如果还不够判断，建议先打开完整版再决定。

━━━━━━━━━━━━━━━━━━━━━━━

## 方案对照：critic 发现如何被处理

| Critic 发现 | 方案 A（SCQA） | 方案 B（Pyramid） | 方案 C（Narrative_Arc） |
|---|---|---|---|
| {发现1}（{severity}） | {具体做法} | {具体做法} | {具体做法} |
| {发现2}（{severity}） | {具体做法} | {具体做法} | {具体做法} |
| ... | ... | ... | ... |

## 怎么选

- 更看重{维度1}（针对本文具体说明）：倾向 {方案}
- 更看重{维度2}（针对本文具体说明）：倾向 {方案}
- {视情况增加}

## 推荐

推荐 **方案 {X}**，因为：{具体到本文语境的理由，不是框架的通用优点}

━━━━━━━━━━━━━━━━━━━━━━━

请选择：
1. 选择某个方案作为最终重构（输入 A / B / C）
2. 混合方案：选择某方案为主，融入另一方案的局部（如 "A 为主 + C 的叙事弧线"）
3. 修改方案：对某方案提出修改意见，我将调整后重新呈现
4. 自定义框架：如果你有自己的重构思路，请描述
```

**呈现前自查**：如果发现自己准备写"三个方案都已处理"这类笼统表述、或者推荐理由是一句放到任何文章都成立的话，说明还没有真正比较三个方案，需要重新审视方案本身的差异，而不是把审视工作留给用户。

**等待用户响应**，不自动推进。

### Step 6: 用户确认与迭代

根据用户响应执行：

| 用户操作 | 处理 |
|---------|------|
| 选择某方案 | 标记为 confirmed，进入持久化 |
| 混合方案 | 按用户指示融合指定方案的部分，生成混合方案，再次呈现确认 |
| 修改方案 | 根据修改意见调整方案，重新呈现（迭代轮数 +1） |
| 自定义框架 | 按用户描述生成新方案，呈现确认 |

**迭代控制**：
- 每次修改后 iteration_count + 1
- 当 iteration_count 达到 max_iteration 时，提示"已达最大迭代轮数，请确认当前版本或接受最终修改"
- 用户确认后才进入持久化

### Step 7: 持久化输出

写入 `.petrelpost/articles/[slug]/reconstruction/` 目录。

**reconstruction/reconstruction_drafts.md**：所有候选方案完整内容（Step 4-6 迭代过程中生成）

**reconstruction/reconstruction_confirmed.md**：用户最终确认的方案

```markdown
# 洞见重构：{title}

> 确认框架：{framework} | 迭代轮数：{iteration_count} | 确认时间：{ISO时间}

---

{用户确认的方案完整内容}

## 确认信息

- 选择方案：{A/B/C/混合/自定义}
- 迭代轮数：{iteration_count}
- 用户修改记录：
  1. {第1轮修改摘要}
  2. {第2轮修改摘要}
```

**reconstruction/reconstruction.json**：

```json
{
  "module": "reconstructor",
  "slug": "[slug]",
  "confirmed_framework": "SCQA",
  "num_suggestions": 3,
  "iteration_count": 0,
  "confirmed_at": "[ISO时间]",
  "suggestions": [
    {
      "id": "A",
      "framework": "SCQA",
      "core_idea": "方案核心思路概述"
    },
    {
      "id": "B",
      "framework": "Pyramid",
      "core_idea": "方案核心思路概述"
    },
    {
      "id": "C",
      "framework": "Narrative_Arc",
      "core_idea": "方案核心思路概述"
    }
  ],
  "confirmed_suggestion": "A",
  "user_modifications": [],
  "evidence_preserved": true
}
```

**更新 state.json**（两阶段）：

生成草稿时（Step 4-5 完成后）：

```json
"reconstruction": {
  "status": "draft",
  "run_at": "[ISO时间]",
  "stale": false,
  "produced_by": { "module": "reconstructor", "version": "dr3-reading/1.0" },
  "preview": "{N} schemes generated, awaiting user confirmation"
}
```

用户确认后（Step 6 完成后）：

```json
"reconstruction": {
  "status": "confirmed",
  "run_at": "[生成时间]",
  "confirmed_at": "[确认时间]",
  "stale": false,
  "produced_by": { "module": "reconstructor", "version": "dr3-reading/1.0" },
  "preview": "{framework} confirmed (iteration {N}), {critic enhanced: true/false}"
}
```

若为重新执行：先写入条目，再按级联规则标记下游（note_generator → evaluator；note_generator 被阻塞但可 override）。

**追加 trace.jsonl**：

```json
{"module": "reconstructor", "timestamp": "[ISO时间]", "status": "success", "input": ["synthesis/", "critique/"], "config": {"num_suggestions": 3, "max_iteration": 2, "require_user_confirmation": true}, "result": {"framework": "SCQA", "iteration_count": 0, "user_confirmed": true}}
```

输出摘要：

```
✅ reconstructor 完成

- 确认框架：{framework}
- 生成方案：{num_suggestions} 个
- 迭代轮数：{iteration_count}
- 用户确认：是
- 存储路径：.petrelpost/articles/[slug]/reconstruction/
```

完成后重新展示功能菜单（note_generator 应已变为可执行状态），等待用户选择。

---

## 输出语言规则

重构方案是面向用户的理解性输出，使用**中文为主**：
- 重构内容全部中文
- 引用原文关键段落保留英文
- 专业术语英文 + 中文注释
- 框架名称保留英文（SCQA, Pyramid, Narrative_Arc）

---

## Human-in-the-Loop 规范

本功能是整个流程中**最关键的人机交互环节**，严格遵循：

1. **必须等待**：Step 5 后必须等待用户响应，不得自动推进
2. **必须确认**：用户明确确认后才持久化 confirmed 状态，无"默认确认"
3. **迭代有界**：max_iteration 限制迭代轮数，避免无限循环
4. **用户主权**：用户可选择、修改、混合、自定义，Agent 不主导决策
5. **修改可追溯**：每轮修改都记录在 reconstruction_confirmed.md 中

---

## 错误处理

| 场景 | 处理方式 |
|------|---------|
| Synthesis 文件缺失 | 报错，提示先运行 synthesis（硬依赖） |
| Critique 文件缺失 | 标注"未增强"继续（critic 为软依赖） |
| 用户长时间无响应 | 提示"等待确认中"，不自动推进 |
| 迭代达到上限 | 提示已达上限，请确认当前版本 |
| 用户选择无效 | 提示有效选项，重新等待 |
| 框架参数无效 | 回退至 SCQA 并警告 |
| 呈现内容缺少 Step 5 强制的四项之一 | 不得呈现给用户，先自查补全（尤其避免"均已处理"这类笼统表述） |

---

## Prompt 指令体

```
你是 dr3-reading 的 reconstructor 功能。

任务：基于 synthesis + critic 结果，提出 2-3 个洞见重构方案，供用户选择与确认。

输入文件：
- .petrelpost/articles/[slug]/synthesis/synthesis.md + .json
- .petrelpost/articles/[slug]/critique/critique.md + .json（可选增强）
- .petrelpost/articles/[slug]/original/article.md

配置：
- 建议方案数：{num_suggestions}（默认 3）
- 需要用户确认：{require_user_confirmation}（默认 true）
- 最大迭代轮数：{max_iteration}（默认 2）
- 可用框架：SCQA, Pyramid, Narrative_Arc

请严格按以下步骤执行：
1. 读取 synthesis、critic（若有）输出与原文
2. 确定配置
3. 分析文章特征，为每个方案匹配最佳框架
4. 生成重构方案：
   - 方案 A: SCQA（Situation-Complication-Question-Answer）
   - 方案 B: Pyramid（结论先行 → 关键论点 → 证据）
   - 方案 C: Narrative_Arc（铺垫 → 冲突 → 转折 → 高潮 → 结论）
5. ⚠️ 呈现所有方案，等待用户选择/修改/混合/自定义——呈现必须包含四项
   （方案对照表/决策启发式/推荐+理由/完整版指引），不能只给一句话概括，
   见 Step 5 的强制要求与自查清单
6. 根据用户响应迭代修改，直至确认
7. 持久化确认方案 + 更新 state.json（draft → confirmed）+ 级联 + 追加 trace.jsonl

⚠️ Human-in-the-Loop 核心：
- 必须等待用户确认，不得自动推进
- 用户可选择/修改/混合/自定义
- 每轮修改记录可追溯
- 迭代不超过 {max_iteration} 轮

关键规则：
- 重构必须融合 critic 的批判发现（若有），不是忽略而是回应
- 每条洞见保留证据链，确保可追溯
- 框架选择基于文章特征，但用户有最终决定权

输出语言：中文为主，引用保留英文，术语英文+中文注释
```
