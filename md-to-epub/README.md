# md-to-epub

将 Markdown 文件（支持 Obsidian Clippings 格式的 YAML 元数据）转换为 EPUB 电子书，并自动添加到 Calibre 书库。

## 功能特性

- 自动解析 Obsidian Clippings 格式的 frontmatter 元数据
- 支持多作者列表（自动处理 `[[wikilinks]]` 语法）
- 自动提取 source URL 域名作为标签
- 解决 Windows GBK 编码导致的 smart quote 乱码问题
- 自动添加到 Calibre 书库，支持 Calibre Portable

## 使用方法

### 基本用法

```
$md-to-epub /path/to/file.md
```

### 自然语言

```
把这份 Markdown 转成 epub 加入 Calibre
```

```
导出这份文章为 epub
```

## 元数据映射

| Markdown frontmatter | Calibre 字段 | 说明 |
|---------------------|-------------|------|
| `title` | 标题 | 自动去除引号 |
| `author` | 作者 | 支持单作者和多作者列表 |
| `source` | 标签 | 提取域名（如 hbr.org） |
| `tags` | 标签 | 多个标签用逗号分隔 |
| `description` | 描述 | 完整保留 |
| `published` | 出版日期 | |

## 支持的 Markdown 格式

### 单作者

```yaml
---
title: "文章标题"
author: John Doe
source: https://example.com/article
description: "文章描述"
tags:
  - clippings
  - AI
published: 2026-10-11
---
```

### 多作者（Obsidian Clippings 格式）

```yaml
---
title: "文章标题"
source: "https://hbr.org/2026/10/..."
author:
  - [[Christopher Stanton]]
  - [[Justin Shriber]]
  - [[Simon Rudat]]
published: 2026-10-08
description: "文章描述"
tags:
  - clippings
---
```

## 依赖要求

- **pandoc**: 通过 pip 安装（`where pandoc` 可找到）
- **Calibre**: 安装 Calibre Portable 或完整版
- **环境变量**:
  - `CALIBRE_LIB`: Calibre 书库路径（如 `F:\Calibre\Calibre Portable\Calibre Library`）
  - `CALIBRE_HOME`: Calibre 安装路径（如 `F:\Calibre\Calibre Portable\Calibre`）

## 已知限制

- Windows 代码页 936 (GBK) 环境下，直接调用 pandoc 会导致 smart quote 乱码，本 skill 使用 Python subprocess 绕过此问题
- 如果 Calibre 正在运行，`calibredb` 可能无法连接数据库，会自动 fallback 到手动放置文件

## 故障排除

### 书籍不在 Calibre 中显示

1. 关闭并重新打开 Calibre
2. 或者在 Calibre 中点击"刷新"按钮
3. 检查 `CALIBRE_LIB` 环境变量是否正确设置

### EPUB 内容乱码

确认使用本 skill 的 Python subprocess 方式调用 pandoc，不要直接调用 pandoc 命令行。
