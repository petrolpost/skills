---
name: book-immersive-reader
description: 'Companion for immersive reading of a whole book (EPUB/PDF/Markdown): preview chapter maps, immersive per-paragraph explanations grounded in whole-book context, and Obsidian-savable notes/concept cards. Use when the user says "陪我读这本书", "/preview", "/read 第N章", "/concept 某概念", asks for 导读卡/沉浸式讲解/章节复盘 on a full book, or invokes $book-immersive-reader. For single articles/URLs use immersive-reading instead.'
metadata:
  argument-hint: '[book-path] [preview|read|note|concept|recap|progress] [target]'
---

# book-immersive-reader（图书沉浸式阅读伴侣）

当用户要求对一本书（EPUB/PDF/Markdown 全文）做**预读、沉浸式讲解、读书笔记**时使用本 skill。
触发语示例：「陪我读这本书」「/preview」「/read 第二章」「/concept 孤寂感」「生成导读卡」「把这次讲解记录下来」。
整本书沉浸式阅读场景触发本 skill；单篇文章（URL/剪藏）的语言学习式阅读走 `immersive-english-reading` 或 `immersive-reading`，不要用本 skill。

## 运行时输入（$ARGUMENTS）

格式（均可省略，缺省全读）：
`<书文件路径> [mode] [target]`
- 书文件路径：EPUB/PDF/已解压目录/Markdown。例：`E:\reposite\obsidian\图书\爱的艺术\Ai De Yi Zhu - [Mei ] Fu Luo Mu.epub`
- mode：`preview` | `read` | `note` | `concept` | `recap` | `progress` | `all`（缺省 `all` = 先 preview 再 read）
- target：`all`、章节号（如 `第二章`）、语义段（如 `第二章§1`）、关键词（concept 模式用）

## 三条铁律（对齐用户阅读心态，不可违背）

1. **不替代读者判断**：讲解提供理解支架，不做摘要替代阅读；自测题给"参考点"（折叠），不下结论。
2. **先定位后讲解**：任何段落讲解前，必须先说明"这段在整书论辩结构中的位置"（承上/启下/反驳/例证/总纲），再讲内容。全书地图未生成时，先花一步通读目录与章首段建立地图。
3. **一切可沉淀**：预读卡、讲解记录、概念卡、复盘必须落盘为 Markdown 到约定目录，可被 Obsidian 双链；聊天里可另给摘要。

## 目录约定（在书的所在目录内生成）

```
<书名>/
  <原文件.epub>                     # 原件，勿改
  _preview/全书地图.md
  _preview/<第N章>-导读卡.md
  _immersive/<第N章>-§<k>-讲解.md   # 每个语义段一个文件
  _notes/批注.md                    # 追加式，按时间倒序
  _notes/概念卡/<概念名>.md
  _notes/章节复盘/<第N章>-复盘.md
  _progress.md                      # 进度追踪（单文件，每次更新）
```
若书的目录已存在上述结构（用户可能跨 session 续读），先读 `_progress.md` 与 `_notes/` 恢复上下文再动手。

## 上下文装载策略（防超长）

1. EPUB 先解压到工作区 `<workspace>/.agnes/work/epub-preview/<书名>/`（用 zip/PowerShell Expand-Archive 或 `python -c "import zipfile,..."`；若已解压过，复用）。
2. 去 HTML 标签得纯文本：`[System.IO.File]::ReadAllText` + `-replace '<[^>]+>',''`（PowerShell 注意 UTF-8 编码）。
3. **首轮**生成 `_preview/全书地图.md`：章结构 + 每章「核心问题 / 关键词 / 论证路径 / 与前章钩子」各一句话。此后每次 `read` 前置注入 = 全书地图 + 目标章全文 + 前后 2 段。
4. 全书地图 > 4000 字时，read 模式只注入「目标章 + 相邻章导语」，避免全文塞入对话。

## 各模式输出格式

### preview
- 写 `_preview/全书地图.md`（结构见上）+ 每个章节一张导读卡 `<第N章>-导读卡.md`。
- 导读卡四要素：① 本章要回应的核心问题 ② 关键概念清单 ③ 论证路径节奏（提出→反驳→例证→收束）④ 衔接钩子（前章/后章）。
- **不是摘要**：写"读之前先知道这章要回答什么问题"。

### read（沉浸式讲解）
输入：`target` 章节或语义段。输出（写 `_immersive/<第N章>-§<k>-讲解.md`，聊天中同步展示）：

```
## §<k> <段落标题>
### 📖 原文
> 完整原文（不改写、不节选、不用翻译替代）
### 🧭 段落定位
本段在全书论辩结构中的位置（先于内容讲"位置"）
### 📖 讲解
概念/术语拆解 + 论证逻辑 + 作者立场 + 常见误读点
### 🔗 联想钩子
前文互证 / 跨书跨学科 / 用户已有概念（查 _notes/概念卡/ 已有条目优先链接）
### ❓ 自测（3–5 问）
1. …（开放题）
<details><summary>参考点</summary> … </details>
```

讲解完成后：更新 `_progress.md`；问用户"要记录批注/概念卡吗？"。

### note
- 追加到 `_notes/批注.md`：`## <ISO日期> §<k> 批注` + 用户原话（逐字保留），Agent 可附一行「语境：本段在…」帮助未来回看。
- 用户说"记一下我的想法 X"时，直接 X 入批注，**不改写用户原话**。

### concept
- 建 `_notes/概念卡/<概念名>.md`：定义（含原文引句）/ 在本书中的角色 / 误读点 / 跨书关联。
- 若用户有 Obsidian `MyAgentMemories/concepts/` 目录且要求打通，双链 `[[MyAgentMemories/concepts/<概念名>]]`，不要重复建卡。

### recap
- 写 `_notes/章节复盘/<第N章>-复盘.md`：上半「读者自述」（引导用户写 3–5 句），下半「共读复盘」（Agent 对照读者自述 + 本章讲解记录，指出理解深化/偏差/遗留问题）。

### progress
- 读并展示 `_progress.md`；格式：`已读章节 / 已讲解段落 / 待处理 / 最近一次 session 摘要`。

## 失败处理

- 解压 EPUB 失败 → 请用户给已解压目录或改用 PDF 逐页文本。
- 全书地图无法建立（无章结构，如散文集）→ 退化为"语义段落"切分（每 500–800 字一段，人工定标题），并告知用户。
- 用户拒绝落盘（明确说"只在聊天里讲"）→ 只跳过写文件，讲解格式不变。
- 原文与讲解冲突（如译本段落顺序异常）→ 以原文文件为准，标记异常到 `_progress.md`。

## 参考样例

- 单文章沉浸式阅读输出范式（含原文/段落大意/语言点/自测/参考点折叠）：`E:\reposite\obsidian\阅读\Justin Welsh《Having fun is the new moat》.md` 及观察笔记 `E:\reposite\obsidian\阅读\阅读观察笔记\*`。
- 首本落地书：`E:\reposite\obsidian\图书\爱的艺术\`（弗洛姆《爱的艺术》EPUB，四章 + 附录，正文 part0015–0018）。
