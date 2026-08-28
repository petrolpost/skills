# importer 功能模板

module: importer
version: dr3-reading/1.0
stage: A
requires: []
produces: raw_content
outputs_to: [".petrelpost/articles/[slug]/original/", ".petrelpost/articles/[slug]/trace.jsonl", ".petrelpost/articles/[slug]/state.json", ".petrelpost/articles/_index.md"]

---

## 输入

用户提供的**单个** URL 或本地文件路径。

## 执行流程

你将严格按照以下 8 步执行。每一步必须完成后再进入下一步。

### Step 1: 识别输入类型

判断用户提供的是 URL（以 http:// 或 https:// 开头）还是本地文件路径。

- URL → 进入 Step 2a
- 本地路径 → 进入 Step 2b
- 无法识别 → 报错并请求用户重新提供

### Step 2: 去重检查

在获取内容之前，先检查该文章是否已被处理过。去重检查按以下优先级执行：

1. **URL 去重**：若输入为 URL，遍历 `.petrelpost/articles/` 下所有 `[slug]/original/metadata.yaml`，比对 `url` 字段。若找到相同 URL，判定为重复。
2. **标题去重**：生成临时 slug，检查 `.petrelpost/articles/[slug]/` 目录是否已存在。若存在，判定为可能重复。
3. **_index.md 查询**：读取 `.petrelpost/articles/_index.md` 索引表，比对标题和来源。

**去重命中时的处理**：

```
⚠️ 去重检查：该文章可能已处理过

- 匹配方式：{URL匹配/Slug匹配/索引匹配}
- 已有记录：
  - 标题：{existing_title}
  - Slug：{existing_slug}
  - 导入时间：{imported_at}
  - 处理状态：{检查该 slug 下 state.json 各产出物状态}

请选择：
1. 重新处理：忽略已有记录，从头执行完整流程（覆盖已有输出）
2. 继续处理：从已有进度继续（读取 state.json，展示功能菜单）
3. 取消：跳过本次导入
```

等待用户选择后继续。若用户选择"重新处理"，标注 `force_overwrite: true`；若选择"继续处理"，读取已有 state.json 并直接展示功能菜单；若选择"取消"，退出 importer。

**去重未命中**：进入 Step 3。

### Step 3a: 抓取网页内容（混合模式）

**优先策略**：使用你自身的内容获取能力直接抓取 URL 对应的网页正文。
**回退策略**：若优先策略失败（超时、内容为空、无法解析），使用 webfetch 工具重新获取。

抓取后，进入 Step 4。

### Step 3b: 读取本地文件

使用文件读取工具读取用户指定的本地文件内容。

- 支持 .md、.txt、.html、.mhtml 格式
- 若文件不存在或无法读取，报错并退出

读取后，进入 Step 4。

### Step 4: 清洗正文

对获取的原始内容进行清洗，规则如下：

1. **去除噪音**：删除广告、导航栏、侧边栏、页脚、Cookie 提示、订阅弹窗等非正文内容
2. **保留结构**：保留标题层级（# / ## / ###）、段落、有序/无序列表、引用块（>）、粗体/斜体、代码块
3. **保留关键链接**：正文中的超链接保留原文链接（不展开、不删除）
4. **去除冗余**：删除"阅读更多""相关文章""分享到"等功能性文字
5. **统一格式**：确保输出为干净的 Markdown 格式

### Step 5: 提取元数据

从原文中提取以下 9 个字段，写入 metadata.yaml：

| 字段                | 类型    | 必填 | 说明                                                         |
| ------------------- | ------- | ---- | ------------------------------------------------------------ |
| title               | string  | Y    | 文章标题                                                     |
| author              | string  | Y    | 作者（多人用逗号分隔）                                       |
| publish_date        | string  | N    | 发布日期（ISO 8601，无法确定则留空）                         |
| source              | string  | Y    | 来源/期刊名（如 Harvard Business Review、Strategy+Business） |
| url                 | string  | Y    | 原文 URL 或本地文件路径                                      |
| word_count          | integer | Y    | 英文单词数（清洗后正文）                                     |
| language            | string  | Y    | 正文主要语言（默认 en）                                      |
| article_type        | string  | Y    | 类型：journal / article / blog / paper / book_chapter        |
| estimated_read_time | integer | Y    | 预估阅读时间（分钟），按 word_count / 250 向上取整           |

### Step 6: 生成 Article Slug

将文章标题转换为 kebab-case 格式的 slug：

1. 取标题的英文部分（若有中文则用拼音或保留）
2. 转小写
3. 空格和特殊字符替换为连字符
4. 去除连续连字符
5. 截断至 80 字符

示例：`"Why Strategy Should Be Simple"` → `why-strategy-should-be-simple`

### Step 7: 持久化输出

检查 `.petrelpost/articles/[slug]/` 目录是否已存在：

- **已存在且 force_overwrite != true** → 停止，提示用户该文章已导入过，询问是否覆盖。若用户未确认覆盖则跳过。
- **已存在且 force_overwrite == true** → 覆盖已有文件。
- **不存在** → 创建目录并写入以下文件。

**`.petrelpost/articles/[slug]/original/article.md`**：

```markdown
# [title]

> 来源：[source] | 作者：[author] | 日期：[publish_date]
> 原文：[url]

---

[清洗后的正文内容]
```

**`.petrelpost/articles/[slug]/original/metadata.yaml`**：

```yaml
title: "[title]"
author: "[author]"
publish_date: "[publish_date]"
source: "[source]"
url: "[url]"
word_count: [word_count]
language: "[language]"
article_type: "[article_type]"
estimated_read_time: [estimated_read_time]
imported_at: "[当前ISO时间]"
```

**`.petrelpost/articles/[slug]/state.json`**（若不存在则创建）：

```json
{
  "raw_content": {
    "status": "completed",
    "run_at": "[ISO时间]",
    "stale": false,
    "produced_by": { "module": "importer", "version": "dr3-reading/1.0" },
    "preview": "[source] article, [word_count] words, [article_type]"
  }
}
```

**`.petrelpost/articles/[slug]/trace.jsonl`**（追加一行）：

```json
{"module": "importer", "timestamp": "[ISO时间]", "status": "success", "input": "[url或路径]", "output_slug": "[slug]", "word_count": [word_count]}
```

**`.petrelpost/articles/_index.md`**（追加条目，文件不存在则创建）：

```markdown
## [{title}]
- 来源：{source} | 作者：{author} | 日期：{publish_date}
- 类型：{article_type} | 字数：{word_count} | 预估阅读：{estimated_read_time} 分钟
```

### Step 8: 输出摘要并返回功能菜单

向用户报告导入结果：

```
✅ importer 完成

- 标题：[title]
- 作者：[author]（[source]）
- 字数：[word_count] | 预估阅读：[estimated_read_time] 分钟
- 文章类型：[article_type]
- 存储路径：.petrelpost/articles/[slug]/original/
```

随后按 SKILL.md 的功能菜单格式展示 8 个功能的当前状态，等待用户选择。不自动执行后续功能。

---

## 错误处理

| 场景                       | 处理方式                                        |
| -------------------------- | ----------------------------------------------- |
| URL 无法抓取               | 先回退至 webfetch，仍失败则提示用户手动粘贴正文 |
| 本地文件不存在             | 报错，提供正确路径示例                          |
| 正文为空或过短（< 100 词） | 报警，提示可能抓取失败，询问是否继续            |
| Slug 目录已存在            | 提示已导入，等待用户确认是否覆盖                |
| 元数据字段缺失             | 必填字段缺失时报错，选填字段留空                |
| 去重命中                   | 提示已有记录，提供重新处理/继续处理/取消三个选项 |
| 去重检查无 _index.md       | 跳过索引查询，仅做 URL 和 slug 去重             |

---

## Prompt 指令体

以下是你作为 importer 功能实际接收的执行指令：

```
你是 dr3-reading 的 importer 功能。

任务：导入并清洗用户提供的文章，为后续深度阅读流程准备干净的结构化输入。

输入：{user_input}

请严格按以下步骤执行：
1. 识别输入类型（URL / 本地路径）
2. 去重检查（URL 匹配 → slug 匹配 → _index.md 索引匹配），命中时提示用户选择重新处理/继续处理/取消
3. 获取内容（URL: 优先自身抓取 → 失败回退 webfetch；本地: 直接读取）
4. 清洗正文（去噪音、保结构、输出干净 Markdown）
5. 提取元数据（title, author, publish_date, source, url, word_count, language, article_type, estimated_read_time）
6. 生成 article slug（标题 → kebab-case）
7. 持久化（original/article.md + metadata.yaml + state.json 初始条目 + trace.jsonl + _index.md）
8. 输出导入摘要，返回功能菜单

注意：
- 不做翻译，不做分析，只做导入与清洗
- 去重检查在获取内容之前执行，避免重复抓取
- 去重命中时必须等待用户选择，不自动覆盖
- 若目录已存在且未设置 force_overwrite，提示用户而非直接覆盖
- 清洗后的正文必须保留原文的结构与证据链
- 每条 trace 记录必须包含 module、timestamp、status、input、output_slug
```
