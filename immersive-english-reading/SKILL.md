---
name: "immersive-english-reading"
description: "Immersive English reading and learning assistant. Guides paragraph-by-paragraph reading with translation, sentence analysis, vocabulary, reading comprehension, and progress tracking. Invoke when user wants to read English articles/books for language learning, or mentions immersive reading, paragraph-by-paragraph study, or improving English reading skills."
---

# Immersive English Reading（沉浸式英文阅读）

## Overview

This skill turns reading any English article into an immersive, paragraph-by-paragraph language learning experience. It is designed for non-native English speakers who want to:

1. **Read the article** — understand the full content
2. **Improve English reading skills** — learn vocabulary, sentence structures, rhetoric
3. **Experience AI-assisted language learning** — let AI guide the reading process

The skill divides the article into **thematic paragraphs** (not necessarily natural paragraphs), then guides the learner through each paragraph using a **9-step learning template**, tracking progress in a structured Markdown file.

---

## Workflow

### Step 1: Acquire the Article

- If the user provides a URL, fetch the full article text using `WebFetch`.
- If the user provides text directly, use it as-is.
- If the user mentions an article by name/author, search for it using `WebSearch`, then fetch the full text.

### Step 2: Divide into Thematic Paragraphs

- Read through the entire article.
- Divide it into **thematic paragraphs** based on topic shifts, NOT natural paragraphs. A thematic paragraph may span multiple natural paragraphs if they share the same topic.
- Typically 5–8 thematic paragraphs for a short article (3–10 min read). Adjust based on article length.
- Give each thematic paragraph a **short English title** and a **Chinese subtitle** (e.g., "The Meeting | 偶遇 Michael").

### Step 3: Create the Learning Record File

Create a Markdown file in the user's working directory (or a location the user specifies) with the following structure:

```markdown
# {Article Title} — 沉浸式阅读学习

> **作者**：{Author}
> **出处**：{URL}
> **日期**：{Date}
> **阅读时长**：{X min read}
> **学习目标**：阅读文章 · 提升英文阅读水平 · 体验 AI 辅助语言学习

---

## 学习进度

| # | 主题段落 | 主题 | 状态 |
|---|---------|------|------|
| 1 | {English Title} | {Chinese subtitle} | ⬜ 待学习 |
| 2 | ... | ... | ⬜ 待学习 |

> 当前进度：**0 / {N}**

> **学习模板说明**
> 1. 英文原文 → 2. 段落翻译 → 3. 逐句精析 → 4. 词组与生词汇总 → 5. 阅读理解自测 → 6. 段落大意（后置）→ 7. 段落在文章中的作用与呼应关系 → 8. 段落结束考察题 → 9. 学习者感触（可选）。文章结束时另设"全文综合考察题"与"感触汇总/读后感"。
```

### Step 4: Guide Paragraph-by-Paragraph Learning

For each thematic paragraph, apply the **9-Step Learning Template** (see below). Update the progress table after each paragraph. Add a "next paragraph" prompt at the end of each section.

### Step 5: Final Section (After Last Paragraph)

After the last paragraph, add:
- **全文综合考察题** (Full-text comprehensive quiz) — see template below
- **感触汇总** (Reflections summary) — collect all paragraph reflections
- **读后感** (Reading reflection) — placeholder for final essay

---

## The 9-Step Learning Template

For each thematic paragraph, generate the following 9 sections. **The language of instruction (Chinese/English) should match the user's language.**

### 一、英文原文 (English Original)

Paste the original English text for this thematic paragraph in a blockquote.

### 二、段落翻译 (Paragraph Translation)

Provide a **complete, flowing Chinese translation** of the entire paragraph. This serves as a holistic reference for the learner to compare against the sentence-by-sentence translations in Step 3.

### 三、逐句精析 (Sentence-by-Sentence Analysis)

For **each sentence** in the paragraph, provide:

- **翻译** (Translation): Chinese translation of the sentence.
- **结构** (Structure): Grammatical structure analysis — clause types, tense, voice, key constructions.
- **词组/词** (Phrases/Words): Key phrases, collocations, and vocabulary with meanings.
- **拓展例句** (Example Sentences) — **for typical structures and phrases only**: Provide 2 extra example sentences showing the structure/phrase in different contexts. Add a brief usage note (易错点/对比). Not every sentence needs this — only when the structure or phrase is worth mastering.
- **句子作用** (Sentence Function): What role this sentence plays in the paragraph — opening, transition, evidence, climax, closing, etc.
- **修辞** (Rhetoric): Rhetorical devices used — metaphor, simile, parallelism, contrast, hyperbole, etc. Explain how the rhetoric serves the meaning.

**Format**: Use `**S1. {sentence}**` as a header, then bullet points for each aspect.

### 四、词组与短语汇总 (Phrase Summary)

A table of all key phrases from this paragraph:

| 英文 | 释义 | 原文例句 |
|------|------|---------|
| {phrase} | {meaning} | {original usage} |

### 五、生词 (Vocabulary)

A table of new/difficult words:

| 词 | 音标 | 释义 |
|----|------|------|
| {word} | {phonetic} | {meaning} |

### 六、阅读理解自测 (Reading Comprehension Quiz)

3–6 comprehension questions about this paragraph's content, language points, or rhetoric. Use `<details><summary>参考答案</summary>` to hide answers.

### 七、段落大意（后置）(Paragraph Summary — Delayed)

Place this **after** the comprehension quiz, so the learner tries to summarize on their own first. Use `<details>` to hide the reference summary.

> 先尝试用自己的话归纳本段，再与下方参考对照。

### 八、段落在文章中的作用与呼应关系 (Paragraph Function & Echoes)

This is a key differentiator of the skill. Analyze:

- **结构功能** (Structural function): What role this paragraph plays in the whole article (hook, development, climax, conclusion, etc.)
- **内部结构** (Internal structure): If the paragraph has sub-layers, map them in a table.
- **伏笔与铺垫** (Foreshadowing): What elements in this paragraph set up later paragraphs. Use a table: `本段元素 → 为后文什么铺垫`.
- **呼应关系** (Echoes): Callbacks to previous paragraphs and setups for future paragraphs. Include **first-last echoes** (首尾呼应) if applicable.
- **逻辑链条** (Logic chain): Where this paragraph sits in the overall argument chain.

### 九、段落结束考察题 (Paragraph Quiz)

A comprehensive quiz with 5 sections:

- **A. 词汇运用** (Vocabulary): 6 fill-in-the-blank sentences using phrases from this paragraph.
- **B. 句式仿写** (Sentence imitation): 2 prompts to imitate key sentence patterns.
- **C. 英译中** (EN→CN): 3 key sentences to translate.
- **D. 中译英** (CN→EN): 3 sentences to translate back using learned phrases.
- **E. 思考题** (Discussion): 3 open-ended questions about content, rhetoric, or logic.

Use `<details>` to hide all answers.

### 十、学习者感触 (Learner Reflection — Optional)

Only when the learner has a personal reflection to share. Record:
- **触动点** (What touched them)
- **感触** (Their reflection)

If the learner provides a reflection, lightly polish it while preserving their voice. Add cross-references to the article's themes if helpful.

---

## Full-Text Comprehensive Quiz (After Last Paragraph)

Structure the final quiz in 4 sections:

- **I. 全文结构梳理** (Structure): Core thesis, paragraph functions, argument structure.
- **II. 论证逻辑分析** (Logic): Case selection rationale, concession function, rhetoric of short paragraphs, first-last echoes.
- **III. 语言综合运用** (Language): Motif evolution across paragraphs, phrase usage, English summary writing.
- **IV. 主题与个人反思** (Reflection): Personal response to the article's core question, reflection connecting to earlier paragraph reflections.

Use `<details>` to hide answers/hints.

---

## Reflections Summary & Reading Reflection

At the end of the file, create:

### 感触汇总 (Reflections Summary)
- Collect all paragraph-level reflections under headers.
- Add a "综合感触" section after all paragraph reflections for cross-article comparisons.

### 读后感 (Reading Reflection)
- Leave a placeholder for the learner to write (or ask AI to help write) a final reading reflection, drawing on the reflections summary.

---

## Key Design Principles

1. **Thematic paragraphs, not natural paragraphs**: Group by topic. A thematic paragraph may span multiple natural paragraphs.
2. **Paragraph translation BEFORE sentence analysis**: Let the learner see the whole picture first, then zoom into details. The paragraph translation and sentence translations should be comparable.
3. **Paragraph summary DELAYED**: Place it after the comprehension quiz so the learner tries to summarize independently first.
4. **Typical structures get example sentences**: Not every phrase needs 2 extra examples — only the ones worth mastering (high-frequency, easily confused, grammatically interesting).
5. **Paragraph function & echoes are mandatory**: This is what makes the reading "immersive" — understanding how each piece fits the whole, not just translating words.
6. **Quizzes are mandatory**: Every paragraph ends with a quiz. The article ends with a comprehensive quiz.
7. **Reflections are optional**: Only record when the learner has something to say. Never force reflections.
8. **Progress tracking**: Update the progress table after each paragraph. Show current progress (e.g., "3 / 7").
9. **Next-paragraph prompt**: End each paragraph section with a prompt to continue, so the learner controls the pace.
10. **Language matching**: All instruction language (Chinese/English) should match the user's language. Article text stays in original English.

---

## Interaction Pattern

- After creating the learning record file and completing the first paragraph, present a summary in chat and prompt: "回复 '下一段' 或 '继续' 进入段落 2。"
- Wait for the learner to say "下一段" / "继续" / "next" before proceeding.
- If the learner asks to modify the template (e.g., "add paragraph translation", "put summary at the end"), update the template in the file's "学习模板说明" section and apply to all subsequent paragraphs.
- If the learner has a reflection mid-reading, record it in both the paragraph's "学习者感触" section and the end-of-file "感触汇总" section.

---

## File Output

- **Learning record file**: A single Markdown file (e.g., `{Author}《{Title}》.md`) in the user's working directory.
- **All content goes into this one file**: paragraph analyses, quizzes, reflections, summary — everything. The learner gets one complete document at the end.
- Use `<details><summary>` tags to hide answers and reference summaries, keeping the file scannable.

---

## Adaptability

This skill works for:
- Newsletter articles (like Justin Welsh, Dan Koe, etc.)
- Blog posts and essays
- Book chapters (divide by section/theme)
- Any English prose with enough substance for language learning

For shorter articles (< 500 words), reduce to 3–5 thematic paragraphs. For longer pieces (book chapters), increase to 8–12 paragraphs.

---

## Example Output Structure

```
{Author}《{Title}》.md
├── Header (metadata)
├── 学习进度 (progress table)
├── 学习模板说明 (template description)
├── 段落 1
│   ├── 一、英文原文
│   ├── 二、段落翻译
│   ├── 三、逐句精析 (S1, S2, S3...)
│   ├── 四、词组与短语汇总
│   ├── 五、生词
│   ├── 六、阅读理解自测
│   ├── 七、段落大意（后置）
│   ├── 八、段落在文章中的作用与呼应关系
│   ├── 九、段落结束考察题
│   └── 十、学习者感触（可选）
├── 段落 2 ... 段落 N (same structure)
├── 全文综合考察题
├── 感触汇总
│   ├── 段落 X 感触
│   ├── ...
│   └── 综合感触
└── 读后感
```
