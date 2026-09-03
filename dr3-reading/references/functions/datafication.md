# datafication 功能模板

module: datafication
version: dr3-reading/1.2
stage: A
requires: [raw_content.completed]
enhanced_by: [structured_data]
produces: datafication
outputs_to: [".petrelpost/articles/[slug]/datafication/", ".petrelpost/articles/[slug]/trace.jsonl", ".petrelpost/articles/[slug]/state.json"]

---

## 目的

发现文章中**真实存在的、具有独立结构性、可脱离连续自然语言而复用**的知识结构，并将其显式化。

Datafication 不是把所有内容强行结构化，也不是建立作者“正确”的世界模型。它只记录文章作者实际表达或可以由紧邻原文忠实重构出的结构。

**核心原则：discover, don't impose。**

文章整体可以没有概念系统，但只要存在一个局部可数据化结构，就应提取该结构。反之，如果没有足够证据，不构造结构。

## 核心设计：先发现结构，再解释结构

Datafication 的主要产物是 **structure instance**，而不是预先规定的结构类型。

执行时可以使用已知结构模式帮助注意力，但不得把这些模式当作必须寻找的类别。模型首先回答：

> 这里是否存在一个具有独立结构性、边界清晰、可复用的知识单元？

只有确认存在后，才描述它的结构；随后可以给出 `suggested_kind` 作为解释性标签。标签不是结构本身，也不限制发现。

如果没有合适的既有标签，可以使用模型生成的描述性名称或 `unknown`。

## 输入

- `.petrelpost/articles/[slug]/original/article.md`
- `.petrelpost/articles/[slug]/original/metadata.yaml`
- `.petrelpost/articles/[slug]/analysis/structured_extraction.json`（若已存在，作为辅助输入；不得覆盖原文证据）

## 默认参数

- `discovery_depth`: `high`（可选 standard / high）
- `allow_reconstruction`: `true`（允许对紧邻原文的显式结构进行忠实重构）
- `inference_policy`: `restricted`（默认禁止仅凭推断创建结构）

## 什么算“可数据化结构”

一个候选结构至少应满足：

1. **结构性**：元素之间存在可描述的组织关系，而不仅是若干事实的集合。
2. **边界性**：可以指出结构覆盖的段落、章节或局部范围。
3. **复用价值**：结构化后明显比自然语言连续叙述更便于比较、查询、复用或后续分析。
4. **证据性**：能够回指原文；不能主要依靠模型常识补全。

典型结构模式仅作为发现提示，**非穷举、非必选**：顺序/阶段/生命周期；分类/分组/层级；条件—判断—行动/结果；判断或评价标准集合；因素分解/归因结构；多对象、多维度的系统比较；等级/尺度/成熟度；具有共同语义边界的枚举；实体/概念之间的明确关系；局部模型或其他可复用结构。

不要因为文章有标题、列表或多个名词就自动创建结构。形式上的列表只有在作者赋予它稳定语义或组织关系时才算候选结构。

## 执行流程

### Step 1: 读取原文

读取完整正文。必须以原文为第一证据来源。若 raw_content 不存在，停止并提示先运行 importer。

### Step 2: 发现候选

扫描全文，寻找作者已经表达的结构关系，同时注意局部结构。不要假设文章整体必须具有统一结构。

### Step 3: 候选验证

逐个判断：是否由作者明确表达；如果不是完全显式，是否能通过局部、忠实的结构重构表达；是否需要模型常识才能补齐缺失关系；结构化后是否具有明显复用价值；是否能给出最小且充分的证据范围。

若主要依赖模型推断，则丢弃候选，除非用户明确允许推断；即使允许，也必须标记 `origin: inferred`。

### Step 4: 描述结构，不强制分类

每个结构使用最小充分 schema：

```yaml
- id: DS-01
  name: "descriptive name"
  scope:
    type: local | section | article
    paragraphs: [...]
  origin: explicit | reconstructed | inferred
  status: author_asserted | model_reconstructed
  subject: "..."
  structure:
    elements: [...]
    relations: [...]
    constraints: [...]
  evidence:
    - paragraphs: [...]
      quote: "..."
      role: structure_definition
  interpretation:
    suggested_kind: "optional descriptive label"
```

`suggested_kind` 可以是 `decision_rule`、`classification`、`factor_decomposition` 等，也可以是模型自己提出的更准确名称；不得要求模型把结构塞进固定枚举。

### Step 5: 判断范围

每个结构必须标记 `scope`。scope 描述**结构自身的覆盖范围**，而不只是某个证据句的位置。只有当结构确实组织文章整体时，才使用 `scope.type: article`。

### Step 6: 保存来源性质

- `explicit`：作者直接陈述、列出或展示结构。
- `reconstructed`：结构跨多个紧邻或明确相关段落，但可以忠实重构。
- `inferred`：需要实质性的解释性推断。

`status: author_asserted` 只表示“作者表达了该结构”，**不表示 DR3 认可其正确性**。

### Step 7: 结构之间的关系

只有原文存在足够证据时才建立关系。不要为了形成漂亮的图而添加关系。

### Step 8: 判断是否存在概念化

仅作描述，不作本体化判断：

```yaml
conceptualization:
  detected: true
  scope: article
  coherence: high
```

这里的 `conceptualization` 表示文章中是否存在相互组织的概念结构，不代表“正确 ontology”。

### Step 9: 记录重要的拒绝候选

重点记录那些**看起来像结构但经过判断不值得结构化**的候选，用于评估过度结构化。

### Step 10: 持久化

写入 `.petrelpost/articles/[slug]/datafication/datafication.md` 和 `datafication.json`，包含发现摘要、结构对象、scope / origin / status、原文证据、显式关系和重要拒绝候选。

### Step 11: 更新 state + trace

Datafication 是非阻塞功能。完成后重新展示功能菜单，不自动执行 synthesis 或其他后续功能。

## 反过度结构化规则

1. 不把文章的自然段强行变成结构。
2. 不把普通列表自动当作分类体系。
3. 不把叙事顺序自动当作过程。
4. 不把作者提出的几个观点自动拼成框架。
5. 不因为存在两个以上结构，就推断存在 concept system。
6. 不将模型推断的关系写成作者明确表达的关系。
7. 结构化结果必须能够回到原文的明确证据范围。
8. 如果结构化后没有明显的查询、比较、复用价值，则宁可不抽取。
9. 不为了填满预定义类型而寻找结构。
10. **结构数量不是质量目标；结构精确性和复用价值优先。**

**宁缺毋滥。**

## Prompt 指令体

```
你是 dr3-reading 的 datafication 功能。

任务：从文章中发现真实存在的、具有独立结构性并具有复用价值的知识结构，将其显式化。

核心原则：discover, don't impose。

你不是在把整篇文章转换成数据库，也不是在建立“正确”的 ontology。
你要识别文章中哪些局部或整体知识结构值得脱离连续自然语言而独立存在。

首先发现结构，不要首先给内容分类。
不要为了匹配某个预定义类别而创造结构。

执行：
1. 阅读完整原文
2. 发现候选结构，允许结构只存在于局部
3. 用原文验证候选
4. 判断每个结构的最小 scope
5. 用最小充分的 elements / relations / constraints 描述结构
6. 保留原文证据
7. 标记 origin：explicit / reconstructed / inferred
8. 可选地给出 suggested_kind，但它只是解释性标签，不限制结构发现
9. 仅在原文有证据时建立结构间关系
10. 可选地描述是否存在 article-level conceptualization，但不要把它宣称为 ontology
11. 记录重要的拒绝候选
12. 持久化 JSON + Markdown + state + trace

可以参考以下结构模式帮助注意力，但它们不是穷举，也不是必须寻找：
- sequence / stages
- classification / grouping
- criteria
- condition → action / outcome
- factor decomposition
- systematic comparison
- scale / maturity
- meaningful enumeration
- explicit relationship
- model / other reusable structure

重要限制：
- 不是所有文章都有可数据化结构
- 一篇文章没有概念系统，也可能存在一个或多个局部结构
- 不要把标题、普通列表、叙事顺序自动解释为结构
- 不要用领域常识补齐作者没有表达的关系
- inference_policy=restricted 时，不得创建主要依赖推断的结构
- 每个结构必须有 scope 和 evidence
- status=author_asserted 只表示“作者表达了该结构”，不表示 DR3 认可其正确性
- 不要为了填充类型而结构化
- 宁缺毋滥
```
