# note_generator 功能模板

module: note_generator
version: dr3-reading/1.0
stage: C
requires: [reconstruction.confirmed]
produces: note_final
on_blocked_requirement:
  mode: allow_override
  override_requires_explicit_flag: true
  watermark_on_override: true
outputs_to: [".petrelpost/articles/[slug]/outputs/", ".petrelpost/outputs/", ".petrelpost/articles/[slug]/trace.jsonl", ".petrelpost/articles/[slug]/state.json"]

---

## 输入

- `.petrelpost/articles/[slug]/reconstruction/reconstruction_confirmed.md`（确认的重构方案）
- `.petrelpost/articles/[slug]/reconstruction/reconstruction.json`（重构数据）
- `.petrelpost/articles/[slug]/synthesis/synthesis.md`（综合分析包）
- `.petrelpost/articles/[slug]/critique/critique.md`（批判分析，可选）
- `.petrelpost/articles/[slug]/original/metadata.yaml`（原文元数据）

## 默认参数（用户可覆盖）

- `template`: `deep_with_evidence`（可选 deep_with_evidence / concise / flashcard）
- `include_action_items`: `true`
- `include_tags`: `true`
- `evidence_link_style`: `quote_with_source`（可选 quote_with_source / footnote / inline）

## 执行流程

严格按以下 6 步执行。

### Step 1: 读取输入

读取 reconstructor 确认方案、synthesis、critic 与元数据。若 reconstruction 未确认（state.json 中 status 不是 confirmed），报错提示先完成 reconstructor 确认。

**过期分支**：若 reconstruction.confirmed 存在但 stale=true，本功能被阻塞（`!` 状态）。此时向用户呈现过期原因并提供"强制生成（写入数据新鲜度水印）"选项；用户明确确认后才以 override 模式继续（见 `references/protocol.md` 第 4 节）。

### Step 2: 确定参数

- `template`：默认 `deep_with_evidence`
- `evidence_link_style`：默认 `quote_with_source`
- `include_action_items`：默认 true
- `include_tags`：默认 true

### Step 3: 按模板生成笔记

#### 模板 1: deep_with_evidence（深度笔记 + 证据链）

这是默认且最完整的模板，产出具有长期复用价值的深度笔记。

**Obsidian Frontmatter**：

```yaml
---
title: "{中文标题}"
source: "{source}"
author: "{author}"
url: "{url}"
date: "{publish_date}"
date_imported: "{imported_at}"
type: "{article_type}"
framework: "{confirmed_framework}"
tags:
  - insightweaver
  - {领域标签}
  - {主题标签1}
  - {主题标签2}
  - {框架标签}
status: "deep-note"
---
```

**笔记正文结构**：

```markdown
# {中文标题}

> 📖 原文：[{title}]({url}) | 作者：{author} | 来源：{source}
> 🔖 框架：{framework} | 生成时间：{ISO时间}

---

## 一句话洞见

{用一句话概括全文最核心的洞见，这是笔记的"电梯演讲"}

---

## 核心洞见

{按重构框架展开的核心洞见内容，全部使用中文}

{每个洞见点后附证据链接，格式取决于 evidence_link_style}

---

## 证据链

{按 evidence_link_style 格式呈现全部证据映射}

### quote_with_source 风格

> **洞见**：{洞见内容}
> **证据**："{英文原文引文}" — P{段落号}, {source}
> **批判评估**：{critic 评估摘要}

### footnote 风格

{洞见内容} [^1]

[^1]: "{英文原文引文}" — P{段落号}, {source}. 批判评估：{critic 评估摘要}

### inline 风格

{洞见内容}（证据：P{段落号}, {source} | 批判：{critic 评估摘要}）

---

## 批判性注记

{从 critic 提取的关键批判发现，按重要性排列：

### 需要注意的局限

- {局限 1}（来源：C{n}, 严重程度：{severity}）
- {局限 2}

### 值得追问的问题

- {追问 1}
- {追问 2}

### 被削弱的论点

- {被削弱的论点}：原始强度 {original} → 批判后 {revised}
}

---

## 行动项

{从洞见中提炼的可执行行动建议，每条标注来源洞见}

- [ ] {行动项 1} — 来源：{洞见/Claim ID}
- [ ] {行动项 2} — 来源：{洞见/Claim ID}
- [ ] {行动项 3} — 来源：{洞见/Claim ID}

---

## 关键概念

{文中出现的核心概念，Obsidian 双链格式}

- [[{概念1}]]：{一句话定义}
- [[{概念2}]]：{一句话定义}
- [[{概念3}]]：{一句话定义}

---

## 相关笔记

{基于标签和概念推荐的可能相关笔记方向}

- [[{可能相关的笔记主题1}]]
- [[{可能相关的笔记主题2}]]

---

_本文由 dr3-reading 生成 | 框架：{framework} | 版本：dr3-reading/1.0_
```

---

#### 模板 2: concise（精简笔记）

精简版，适合快速回顾或已熟悉领域的文章。

```yaml
---
title: "{中文标题}"
source: "{source}"
author: "{author}"
tags: [insightweaver, {领域标签}]
status: "concise-note"
---
```

```markdown
# {中文标题}

> 📖 [{title}]({url}) — {author}, {source}

## 核心洞见

{3-5 条核心洞见，每条 1-2 句中文}

## 关键数据

- {数据点1}（P{段落}）
- {数据点2}（P{段落}）

## 行动项

- [ ] {行动项1}
- [ ] {行动项2}

## 批判提醒

- ⚠️ {最关键的批判发现}
```

---

#### 模板 3: flashcard（闪卡笔记）

闪卡版，适合间隔重复记忆。

```yaml
---
title: "{中文标题}"
source: "{source}"
tags: [insightweaver, flashcard, {领域标签}]
status: "flashcard"
---
```

```markdown
# {中文标题} — 闪卡

> 📖 [{title}]({url})

---

## 卡片组

### 卡片 1：{问题/概念}

**正面**：{问题}
**背面**：{答案，1-2 句中文}

---

### 卡片 2：{问题/概念}

**正面**：{问题}
**背面**：{答案}

---

{继续，每条核心洞见一张卡片}

---

## 来源

{url}
```

### Step 4: 生成 Obsidian 兼容元素

**标签生成规则**：

| 来源 | 示例 |
|------|------|
| 固定标签 | `insightweaver` |
| 领域标签 | 文章所属领域（如 `strategy`, `leadership`, `innovation`） |
| 主题标签 | 文章核心主题（2-3 个，如 `simple-rules`, `decision-making`） |
| 框架标签 | 使用的重构框架（如 `scqa`, `pyramid`, `narrative-arc`） |
| 类型标签 | 文章类型（如 `journal`, `paper`, `blog`） |

**Wikilink 生成规则**：

- 关键概念使用 `[[概念名]]` 双链
- 概念名统一为中文（英文概念用中文译名）
- 避免过度链接：仅对真正核心的 3-8 个概念生成双链

**行动项生成规则**：

- 从洞见中提炼可执行建议
- 每条行动项必须是具体、可操作的（非"深入思考"类模糊建议）
- 标注来源洞见/Claim ID，确保可追溯
- 数量控制在 3-6 条

### Step 5: 持久化输出

写入以下位置：

**`.petrelpost/articles/[slug]/outputs/[slug].md`**：主笔记文件

**`.petrelpost/outputs/[slug].md`**：全局快捷导出的副本（与主文件内容一致，方便 Obsidian 直接索引）

同时更新 `.petrelpost/articles/_index.md`（若不存在则创建），追加条目：

```markdown
## [{中文标题}]({slug})
- 来源：{source} | 作者：{author} | 日期：{publish_date}
- 框架：{framework} | 模板：{template}
- 洞见数：{n} | 行动项：{n}
```

**更新 state.json**（按 `references/protocol.md` 结构）：

```json
"note_final": {
  "status": "completed",
  "run_at": "[ISO时间]",
  "stale": false,
  "produced_by": { "module": "note_generator", "version": "dr3-reading/1.0" },
  "preview": "{template}, [N] core insights, [N] evidence links, [N] action items, written to outputs/",
  "override": { "decided_by": "user", "decided_at": "[ISO时间]", "action": "proceed_with_stale" }
}
```

（override 字段仅 override 模式下写入；override 模式下笔记正文开头必须包含数据新鲜度水印）

若为重新执行：先写入本条目，再按级联规则标记下游（evaluator）。

### Step 6: 追加 trace + 输出摘要

追加 `trace.jsonl`：

```json
{"module": "note_generator", "timestamp": "[ISO时间]", "status": "success", "input": ["reconstruction/", "synthesis/", "critique/"], "config": {"template": "deep_with_evidence", "evidence_link_style": "quote_with_source", "include_action_items": true, "include_tags": true}, "stats": {"insights_count": 0, "evidence_links": 0, "action_items": 0, "tags_count": 0, "wikilinks_count": 0}}
```

输出摘要：

```
✅ note_generator 完成

- 笔记模板：{template}
- 证据链接：{evidence_link_style}
- 核心洞见：[N] 条
- 证据链：[N] 条 | 行动项：[N] 条 | 标签：[N] 个
- 双链概念：[N] 个
- 存储路径：.petrelpost/articles/[slug]/outputs/[slug].md
- 全局导出：.petrelpost/outputs/[slug].md
```

完成后重新展示功能菜单（evaluator 应已变为可执行状态），等待用户选择。

---

## 输出语言规则

笔记是最终面向用户的产出，**全中文为主**：
- 标题、洞见、行动项：全部中文
- 引用原文证据：保留英文原文
- 专业术语：英文 + 中文注释（首次出现时），后续仅用中文
- Frontmatter 字段名：英文（Obsidian 标准）
- 标签：英文 kebab-case（Obsidian 标签惯例）

---

## 错误处理

| 场景 | 处理方式 |
|------|---------|
| Reconstruction 未确认 | 报错，提示先完成 reconstructor 确认 |
| Reconstruction 过期（stale） | 呈现原因，提供 override 选项，确认后写入水印继续 |
| 笔记模板无效 | 回退至 deep_with_evidence 并警告 |
| 证据链接风格无效 | 回退至 quote_with_source |
| 洞见数为 0 | 警告，生成仅含元数据的占位笔记 |
| _index.md 更新失败 | 不阻断主流程，仅警告 |

---

## Prompt 指令体

```
你是 dr3-reading 的 note_generator 功能。

任务：根据用户确认的重构结果，生成 Obsidian 兼容的中文深度笔记。

输入文件：
- .petrelpost/articles/[slug]/reconstruction/reconstruction_confirmed.md + .json
- .petrelpost/articles/[slug]/synthesis/synthesis.md
- .petrelpost/articles/[slug]/critique/critique.md（可选）
- .petrelpost/articles/[slug]/original/metadata.yaml

配置：
- 笔记模板：{template}（deep_with_evidence / concise / flashcard）
- 证据链接风格：{evidence_link_style}（quote_with_source / footnote / inline）
- 包含行动项：{include_action_items}
- 包含标签：{include_tags}

请严格按以下步骤执行：
1. 读取 reconstructor 确认方案、synthesis、critic 与元数据
2. 确定笔记配置
3. 按模板生成笔记：
   - deep_with_evidence：完整深度笔记 + 证据链 + 批判注记 + 行动项 + 双链概念
   - concise：精简版，3-5 条核心洞见 + 关键数据 + 行动项
   - flashcard：闪卡版，每条洞见一张卡片
4. 生成 Obsidian 兼容元素（frontmatter + tags + wikilinks）
5. 持久化到 .petrelpost/articles/[slug]/outputs/ + .petrelpost/outputs/ + 更新 _index.md
   + 更新 state.json + 级联
6. 追加 trace.jsonl + 输出摘要

关键规则：
- 笔记是最终产出，必须具有长期复用价值
- 每条洞见必须有证据链支撑（可追溯性）
- 行动项必须具体可操作，标注来源洞见
- Obsidian frontmatter 格式严格遵循 YAML 规范
- 标签使用英文 kebab-case，概念双链使用中文
- 不引入新的批判或重构——忠实转化 reconstructor 确认的方案
- override 模式下笔记开头必须写入数据新鲜度水印

输出语言：全中文为主，引用保留英文，术语首次出现英文+中文注释
```
