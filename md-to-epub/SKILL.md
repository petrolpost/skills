---
name: md-to-epub
description: |
  Convert a Markdown file (including Obsidian Clippings with YAML frontmatter) to EPUB using pandoc, then register the EPUB in the Calibre library.
  
  Use when the user asks to:
  - Convert Markdown to EPUB / 导出 epub / 转成 epub
  - Add a reading file to Calibre library
  - Export article as ebook
  
  Supports Obsidian Clippings format with YAML frontmatter including title, author (single or list with [[wikilinks]]), source, tags, description, and published date.
  
  支持 `-C` 参数：强制将原文（含标题）翻译成中文后再进行 EPUB 转换。
  支持把 frontmatter 的 source 存储为 Calibre 的「丛书」（series）字段。
  
  也可用中文触发：「把这份 Markdown 转成 epub」、「导出为 epub」、「加入 Calibre 书库」。
---

# Markdown to EPUB via Calibre

## Trigger

When the user asks to convert a Markdown file to EPUB, or mentions "markdown to epub", "导出 epub", "转成 epub", "加入 Calibre", or similar.

## 调用参数：`-C`

支持在调用 skill 时添加参数 `-C`，强制将原文**翻译成中文**（含标题）后再进行 EPUB 格式转换，例如：

- `md-to-epub -C <Markdown 文件路径>`
- `把这份 Markdown 转成 epub，用中文 -C`

`-C` 的规则：

1. 在 pandoc 转换前，将 Markdown 正文（prose）与**标题（title）**翻译成简体中文。
2. 保留不翻译的内容：代码块、URL 链接、图片路径、frontmatter 中的 **author（作者名）**、tags 标签值（均保留原文以便 Calibre 匹配与搜索）。
3. YAML frontmatter 中 `title` / `description` / `summary` 字段翻译为中文。
4. EPUB 与 Calibre 的 `title` 在 `-C` 时使用中文译文（默认时用原文）；`author` 始终保留原文。
5. EPUB 的 `language` 元数据设为 `zh-CN`（默认 `en`）。
6. 不改变其他转换流程；`-C` 只影响标题/正文语言与 language 标签。
7. 未提供 `-C` 时，保持原文不做翻译，沿用默认 `language=en`。该参数仅作用于当前调用，不写入跨调用偏好。

## 调用参数：source → 丛书（series）

frontmatter 的 `source`（或 `url`）除了提取 domain 作为 tag 外，可一并映射为 Calibre 的**「丛书」（series）**字段，便于在 Calibre 中按来源组织同一站点/出版物下的文章：

- 若 frontmatter 含显式 `series` 字段，优先使用它。
- 否则从 `source` / `url` 提取 domain（如 `hbr.org`）作为默认 series。
- 无 `source` / `series` 时，series 留空。
- 该映射与 `-C` 无关（无论是否翻译，series 都用原文 domain/显式值，保证丛书名一致、可检索）。

## Process

1. **Locate the source Markdown file.**
   - The file path is passed as `$ARGUMENTS` (with flags like `-C` stripped). If no path is given, ask the user for the Markdown file path.
   - **Parse flags**: Check if `-C` is present in `$ARGUMENTS`. If found, set `translate_to_chinese = true`. The remaining token is the file path.
   - **Validation**: Verify the file exists and has a `.md` extension before proceeding.
   - Read the file to inspect its structure and metadata.

2. **Extract metadata from the Markdown frontmatter.**
   - Many Obsidian Clippings-style Markdown files include a YAML frontmatter block at the top with fields like:
     - `title` - EPUB title (may have quotes, strip them)
     - `author` - EPUB author(s) (may be a single value or a list with wikilinks [[Name]])
     - `date` / `published` - publication date
     - `tags` - subject/category (list format)
     - `source` / `url` - source URL (extract domain; used as a tag AND as the Calibre series / 丛书)
     - `series` - optional explicit 丛书 name (takes precedence over source domain)
     - `description` / `summary` - description (maps to Calibre comments)
   - If frontmatter exists, parse these fields. If not, use the filename as the title and leave author blank.
   - If the `title` field is missing, derive it from the first `# ` heading.
   - Resolve `series` (丛书): use `frontmatter.series` if present; else extract the domain from `source` / `url`; else leave empty.

3. **Parse authors (handle list format).**
   - Authors may be specified as:
     - Single value: `author: John Doe`
     - List with wikilinks: `author: [[John Doe]]`
     - Multi-line list:
       ```yaml
       author:
         - [[John Doe]]
         - [[Jane Smith]]
       ```
   - For single author, use as-is.
   - For multiple authors, join with " and " (e.g., "John Doe and Jane Smith").
   - Remove wikilink syntax `[[Name]]` -> `Name`.
   - **Author names are never translated** (proper nouns), even when `-C` is active.

4. **Clean the frontmatter for pandoc compatibility.**
   - Remove wikilinks from author list: `- [[Name]]` -> `- Name`
   - Remove quotes from single-value fields: `title: "..."` -> `title: ...`
   - Use regex replacements to clean the content before saving to the temp directory.

5. **(Conditional, `-C` only) Translate title and body to Chinese.**
   - If `translate_to_chinese` is `true`, translate the Markdown body (everything after the frontmatter) AND the title to simplified Chinese before pandoc conversion.
   - **Translation rules**:
     - All prose paragraphs, headings, list items, and blockquotes are translated to 简体中文.
     - The document `title` is translated to 简体中文 (store as `title_zh`). The `# ` H1 heading in the body is likewise translated.
     - Code blocks (```...```) are preserved as-is, NOT translated.
     - URLs, file paths, and inline code spans (`...`) are preserved as-is.
     - Proper nouns, technical terms, author names, and product names are preserved in original language; first occurrence may add a Chinese gloss in parentheses.
     - Wikilinks `[[Name]]` syntax is preserved; display text is translated.
     - YAML frontmatter: `title`, `description` / `summary` ARE translated to Chinese; `author` and `tags` values are NOT (kept in original for Calibre matching/search).
     - `series` (丛书) is NOT translated — use the original domain / explicit value for consistent grouping.
   - Set `effective_title = title_zh` (used for both EPUB metadata and Calibre title when `-C` is active).
   - Set the pandoc `language` metadata value to `zh-CN`.
   - If `translate_to_chinese` is `false`, skip this step; `effective_title = title` (original).

6. **Create a temporary working directory for pandoc.**
   - Use `mktemp` (Unix) or a local temp directory (Windows PowerShell) to create a temp directory.
   - Copy the cleaned (and if `-C`, translated) source Markdown to the temp directory.

7. **Locate pandoc dynamically.**
   - Run `where pandoc` (Windows) or `which pandoc` (Unix) to find the binary.
   - If not found in PATH, check common install locations or report failure and stop.
   - **Do NOT hardcode paths** like `d:\home\CMD\pandoc.exe`.

8. **Run pandoc to generate the EPUB (CRITICAL: Use Python subprocess with explicit UTF-8 encoding).**
   - **Do NOT call pandoc directly from PowerShell/cmd** - Windows codepage 936 (GBK) corrupts smart quotes and other UTF-8 characters when passed as command-line arguments.
   - Instead, use Python's `subprocess.run()` with `encoding='utf-8'` to call pandoc:
     ```python
     import subprocess
     
     lang = 'zh-CN' if translate_to_chinese else 'en'
     epub_title = title_zh if translate_to_chinese else title   # 标题：-C 时用中文译文
     result = subprocess.run(
         [pandoc_path, input_path, '-o', output_path,
          '--metadata', f'title={epub_title}',
          '--metadata', f'author={author}',
          '--metadata', f'description={description}',
          '--metadata', f'language={lang}',
          '--toc', '--wrap=none'],
         capture_output=True, text=True, encoding='utf-8'
     )
     ```
   - **Important**: `title` passed to pandoc is the Chinese translation when `-C` is active, otherwise the original.
   - **Important**: Pass `description` from frontmatter as `--metadata description` so it appears in the EPUB comments. When `-C` is active, the description value is the Chinese-translated version.
   - **Important**: Use `--wrap=none` to prevent pandoc from re-wrapping text and corrupting encoding.
   - After generation, verify the EPUB contains correct UTF-8 characters (especially CJK characters when `-C` is active).

9. **Register the EPUB with Calibre.**
   - Locate the Calibre library using the `CALIBRE_LIB` environment variable.
   - Build the tags list from:
     - `tags` field from frontmatter (if present, skip empty/dash-only entries; **preserve original language even when `-C` is active**)
     - `source` field from frontmatter (extract domain and add as tag)
     - Combine into a comma-separated string for Calibre
   - Resolve the **series (丛书)**:
     - `series = frontmatter.series` if an explicit `series` field exists;
     - else `series = domain extracted from source/url` (e.g., `hbr.org`);
     - else `series = ""` (omit the flag).
     - Series is always in the original language (not affected by `-C`), so books from the same source group consistently.
   - Use `calibredb` CLI to add the book (pass `--series` only when non-empty; pass the same `epub_title` used in step 8):
     ```
     calibredb add --with-library "$CALIBRE_LIB" /path/to/output.epub \
       --title "$epub_title" --authors "..." --series "hbr.org" --tags "clippings,hbr.org"
     ```
   - If `calibredb` fails (e.g., Calibre is running and blocks the connection), place the EPUB manually into the library:
     - Create the author directory: `$CALIBRE_LIB/$AuthorName/`
     - Create the book directory: `$CALIBRE_LIB/$AuthorName/$Title/`
     - Copy the EPUB there as `output.epub`
     - (Manual placement cannot set series; if series matters, ask the user to set it in Calibre or retry calibredb.)
   - Calibre will index the book on next launch or when it syncs.
   - If `CALIBRE_LIB` is not set - output the EPUB path and inform the user they need to manually add it.

10. **Report the result.**
    - Print the absolute path of the generated EPUB.
    - Confirm whether it was successfully added to the Calibre library (via calibredb or manual placement).
    - Report the **series (丛书)** value that was set (or note it was empty).
    - If `-C` was used, confirm: "标题与正文已翻译为中文（language=zh-CN），author、tags 与丛书（series）保留原文。"
    - If any step failed, report the error and stop.

## Notes

- The skill works with both global and project-level Markdown files.
- If the Markdown uses Obsidian-specific syntax (e.g., `[[wikilinks]]`), pandoc handles these as links by default. No additional processing is needed beyond frontmatter cleaning.
- `CALIBRE_HOME` may point to the Calibre installation directory where `calibredb.exe` resides, but Calibre Portable setups place it in a different path.
- Calibre Portable on Windows stores the library at `CALIBRE_LIB` and the executable at `CALIBRE_HOME\calibredb.exe`.
- If the book doesn't appear in Calibre UI immediately, ask the user to close and reopen Calibre, or click the sync/library refresh button.
- **CRITICAL**: On Windows with codepage 936 (GBK), calling pandoc directly from PowerShell/cmd will corrupt smart quotes and other non-ASCII characters. Always use Python's `subprocess.run()` with `encoding='utf-8'` as the call wrapper.
- **CRITICAL**: `description` from frontmatter is not automatically included in the EPUB - always pass it explicitly via `--metadata description`.
- **CRITICAL**: Always use `--wrap=none` to prevent pandoc from re-wrapping text and corrupting encoding.
- **`-C` 翻译规则**：`-C` 时标题与正文翻译为简体中文；author、tags、代码块、URL、专有名词、图片路径保留原文；frontmatter 中 title/description 翻译，author/tags/series 保留原文。
- **丛书（series）**：source 的 domain（或显式 `series` 字段）映射为 Calibre 的 series，用于按来源分组；series 始终用原文、不受 `-C` 影响。
- **Calibre metadata mapping**:
  - `title` -> Calibre title（`-C` 时为中文译文）
  - `author` -> Calibre author (join multiple with " and "；保留原文)
  - `source` -> Calibre tags (extract domain, e.g., "hbr.org") **AND** Calibre series（丛书）
  - `series`（显式，若有）-> Calibre series（优先于 source domain）
  - `tags` -> Calibre tags
  - `description` -> Calibre comments/description
  - `date` / `published` -> Calibre published date
