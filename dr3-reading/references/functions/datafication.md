# datafication 功能模板

module: datafication
version: dr3-reading/1.5
stage: A
requires: [raw_content.completed]
enhanced_by: [structured_data]
produces: datafication
outputs_to: [".petrelpost/articles/[slug]/datafication/", ".petrelpost/articles/[slug]/trace.jsonl", ".petrelpost/articles/[slug]/state.json"]

---

## 目的

发现文章中真实存在、具有独立结构性、可脱离连续自然语言而复用的知识结构，并可选地抽取文章中**明确表达且有独立证据的关系**。

Datafication 不是把所有内容强行结构化，也不是建立作者“正确”的世界模型。它只记录文章作者实际表达，或可以由明确相关原文忠实重构出的结构与关系。

**核心原则：discover, don't impose。**

重要边界：

- Structure Discovery 不要求 Relation 才算完整。
- Relation Extraction 是可选操作，不用于“补全”结构。
- 关系必须有自己的证据；共同出现不是关系证据。
- 关系先忠实抽取 source-level 表达，再可选 normalization；规范化不能替换原文表达。

## 输入

- `.petrelpost/articles/[slug]/original/article.md`
- `.petrelpost/articles/[slug]/original/metadata.yaml`
- `.petrelpost/articles/[slug]/analysis/structured_extraction.json`（若已存在，仅作为辅助输入；不得覆盖原文证据）

## 默认参数

- `discovery_depth`: `high`
- `allow_reconstruction`: `true`
- `inference_policy`: `restricted`
- `relation_extraction`: `optional`

`relation_extraction` 可取：

- `disabled`：只做 Structure Discovery；
- `optional`：发现结构后，对原文中明确关系进行独立抽取；
- `relations_only`：只执行 Relation Extraction，不因关系存在而构造结构。

默认 `optional`。这不是要求每个结构都必须产生 relation。

## 什么算“可数据化结构”

候选结构至少应满足：

1. **结构性**：元素之间存在可描述的组织关系，而不仅是若干事实的集合。
2. **边界性**：可以指出结构覆盖的段落、章节或局部范围。
3. **复用价值**：结构化后明显比自然语言连续叙述更便于查询、比较、复用或后续分析。
4. **证据性**：能够回指原文；不能主要依靠模型常识补全。

典型模式仅作为发现提示，非穷举、非必选：顺序/阶段/生命周期；分类/分组/层级；条件—判断—行动/结果；判断或评价标准集合；因素分解/归因结构；多对象、多维度的系统比较；等级/尺度/成熟度；具有共同语义边界的枚举；实体/概念之间的明确关系；局部模型或其他可复用结构。

不要因为文章有标题、列表或多个名词就自动创建结构。

## 执行流程

### Step 1: 读取原文

读取完整正文。必须以原文为第一证据来源。若 raw_content 不存在，停止并提示先运行 importer。

### Step 2: 发现候选结构

扫描全文，寻找作者已经表达的结构关系，同时注意局部结构。不要假设文章整体必须具有统一结构。

### Step 3: 候选验证

逐个判断：

- 是否由作者直接表达？
- 如果不是完全显式，是否能通过局部、忠实的结构重构表达？
- 是否需要模型常识才能补齐缺失关系？
- 结构化后是否具有明显复用价值？
- 能否给出最小且充分的证据范围？

若主要依赖模型推断，则丢弃候选，除非用户明确允许推断；即使允许，也必须标记 `origin: inferred`。

### Step 4: 描述结构，不强制关系

每个结构使用最小充分 schema：

```yaml
- id: DS-01
  name: "descriptive name"
  scope:
    type: local | section | article
    paragraphs: [...]
  importance:
    role: peripheral | supporting | central
  origin: explicit | reconstructed | inferred
  status: author_asserted | model_reconstructed
  subject: "..."
  structure:
    elements: [...]
    constraints: [...]
  evidence:
    - paragraphs: [...]
      quote: "..."
      role: structure_definition
  interpretation:
    suggested_kind: "optional descriptive label"
```

**1.5 边界：`structure` 不再要求 `relations`。** Structure Discovery 不得为了让结构“完整”而生成关系。

### Step 5: 判断范围与重要性

`scope` 只描述结构自身覆盖的文本范围：`local / section / article`。

`importance.role` 单独描述结构在文章中的重要程度：`peripheral / supporting / central`。

不要因为结构是文章核心论点、反复出现或对全文解释力很强，就把 scope 自动扩大为 `article`。

### Step 6: 保存来源性质

- `explicit`：作者直接陈述、列出或展示结构。
- `reconstructed`：结构跨多个紧邻或明确相关段落，但可以忠实重构。
- `inferred`：需要实质性的解释性推断。

`status: author_asserted` 只表示“作者表达了该结构”，不表示 DR3 认可其正确性。

### Step 7: 结构性断言的证据一致性

**每一个被写入 Datafication 的结构性断言，都必须被相应证据支持到相同的语义强度。**

区分：

1. **Evidence exists**：原文中确实有相关文字。
2. **Evidence supports claim**：该文字足以支持当前写下的 claim。

只有第二种才允许保留该 claim。

特别禁止：

```text
multiple factors affect X → independent_factors
multiple factors affect X → additive_effects
co-mentioned → requires
co-mentioned → causes
two endpoints → no_intermediate_state
listed categories → exhaustive_categories
exposition order → causal_sequence
```

每个 relation / constraint，以及带有实质语义的 element 属性，都必须拥有自己的 `origin` 与 `evidence`。

验证问题：

> 如果只给另一个读者看这里引用的 evidence，他能否从这段文字本身合理地得到我写下的这个 claim，而无需加入领域常识或额外假设？

若不能，则降低语义强度、标记为 `reconstructed`（仅在确实可忠实重构时），或在 `inference_policy=restricted` 下删除。

## Relation Extraction（1.5）

Relation Extraction 是与 Structure Discovery 并列的可选输出。它不是 Structure Discovery 的组成要求，也不是用于把共现元素连接起来。

### 关系表示

```yaml
relations:
  - id: R-01
    subject:
      text: "source-level argument"
      normalized_ref: null
    predicate:
      text: "source-level relational expression"
      normalized_type: null
    object:
      text: "source-level argument"
      normalized_ref: null
    direction: forward | reverse | undetermined
    modality: null
    qualification: []
    origin: explicit | reconstructed | inferred
    evidence:
      - paragraphs: [12]
        quote: "..."
```

### Source-first 原则

关系处理顺序必须是：

```text
Source sentence
      ↓
Faithful extraction
      ↓
Source-level Relation
      ↓
Optional normalization
```

必须保留：

- `subject.text`：原文中的主语/源参数表达；
- `predicate.text`：原文关系表达；
- `object.text`：原文中的宾语/目标参数表达；
- `direction`：独立记录方向；
- `modality`：如 `may / can / could` 等具有语义作用的模态；
- `qualification`：范围、条件或其他限定；
- `evidence`：直接支持该关系的原文证据。

`normalized_ref` 与 `normalized_type` 都是可选字段，不能替换 source-level 表达。

例如：

```text
A helps define B.
```

必须保留 `predicate.text = "helps define"`。不得仅因为存在 `defines` 这一规范类型，就把它无条件强化为 `defines`。

```text
A is related to the definition of B.
```

必须保留 object 的原始论元范围 `the definition of B`，不得静默压缩成 `B`。

### Relation evidence 规则

关系必须由自己的证据直接支持到相应语义强度。尤其禁止：

- `Evidence(A) + Evidence(B) ≠ Evidence(A relation B)`；
- 同一段落共现 ≠ relation；
- 同一 structure 内共现 ≠ relation；
- 两个 endpoint 都存在 ≠ endpoint 之间存在某种特定关系；
- narrative / exposition order ≠ causal order。

若关系存在但 canonical relation type 无法可靠确定，保留 source expression，令 `normalized_type: null`。不要为了获得规范类型而改变原文语义。

### Relation 来源性质

- `explicit`：原文直接表达该关系；
- `reconstructed`：关系可由明确相关原文忠实重构，但不是单句直接表达；
- `inferred`：需要实质性解释性推断。

在 `inference_policy=restricted` 下，不保留 `inferred` relation。

## Step 8: 概念化判断

仅作描述，不作本体化判断：

```yaml
conceptualization:
  detected: true | false
  scope: local | section | article | null
  coherence: low | medium | high | null
```

不要因为发现多个 Datafication objects 就推断存在 article-level conceptual system。

## Step 9: 记录重要的拒绝候选

```yaml
rejected_candidates:
  - description: ...
    reason: ...
    evidence: ...
```

特别记录看起来像结构或关系、但实际上只是普通列表、例子、叙事顺序、共现或模型推断的候选，用于评估 over-structuring / over-relation-extraction。

## Step 10: 持久化

写入：

- `.petrelpost/articles/[slug]/datafication/datafication.md`
- `.petrelpost/articles/[slug]/datafication/datafication.json`

JSON 至少包含：

```yaml
module: datafication
version: dr3-reading/1.5
structures: []
relations: []
conceptualization: {}
rejected_candidates: []
```

`relations` 可以为空；**relation 数量不是 Datafication 完整性的质量目标。**

## Step 11: 更新 state + trace

Datafication 仍是非阻塞功能。完成后重新展示功能菜单，不自动执行 synthesis 或其他后续功能。

`state.json` 继续使用 `datafication` artifact，不新增独立的 hard dependency。`produced_by.version` 必须记录 `dr3-reading/1.5`。

trace 中建议记录：

```json
{
  "module": "datafication",
  "timestamp": "[ISO时间]",
  "status": "success",
  "config": {
    "discovery_depth": "high",
    "allow_reconstruction": true,
    "inference_policy": "restricted",
    "relation_extraction": "optional"
  },
  "stats": {
    "structures": 0,
    "relations_extracted": 0,
    "relations_retained": 0
  }
}
```

## 反过度结构化与关系提取规则

1. 不把文章的自然段强行变成结构。
2. 不把普通列表自动当作分类体系。
3. 不把叙事顺序自动当作过程。
4. 不把作者提出的几个观点自动拼成框架。
5. 不因为存在两个以上结构，就推断存在 concept system。
6. **不把 Relation 作为 Structure Discovery 的必需组成。**
7. **不为了连接 elements 而生成 relation。**
8. **Evidence(A) + Evidence(B) ≠ Evidence(A relation B)。**
9. 每个 structure、relation、constraint 都必须能够回到原文的证据范围。
10. Evidence 的存在不等于 Evidence 支持 Claim；必须检查语义强度是否匹配。
11. 如果结构化后没有明显的查询、比较、复用价值，则宁可不抽取。
12. 不为了填满预定义类型而寻找结构或关系。
13. 宁可把一个关系留成未知，也不要用领域常识补齐它。
14. 宁可降低关系强度，也不要让证据承担它没有表达的语义。
15. **Source-level expression 必须先于 normalization；normalization 永远不能覆盖 source-level expression。**
16. **relation 数量不是质量目标。**

**宁缺毋滥。**

## Prompt 指令体

```text
你是 dr3-reading 的 datafication 功能，版本 1.5。

任务：
1. 从文章中发现真实存在的、具有独立结构性并具有复用价值的知识结构；
2. 在 relation_extraction 未 disabled 时，独立抽取文章明确表达且有自身证据支持的关系。

核心原则：discover, don't impose。

Structure Discovery 与 Relation Extraction 是两个并列关注点：
- Structure Discovery 不要求 relation；
- Relation Extraction 不负责补全 structure；
- 不因为两个元素共现而建立 relation。

执行：
1. 阅读完整原文
2. 发现并验证候选结构
3. 描述结构的 elements / constraints，不为了完整性生成 relations
4. 为结构性断言保留 claim-level evidence
5. 若启用 Relation Extraction：寻找原文明确表达的关系
6. 先提取 source-level subject / predicate / object
7. 独立记录 direction / modality / qualification
8. 为每条关系提供 relation-level evidence
9. 可选地增加 normalized_ref / normalized_type，但不得替换 source-level 表达
10. 记录重要 rejected candidates
11. 持久化 datafication.md + datafication.json
12. 更新 state.json + trace.jsonl

关系证据规则：
- Evidence(A) + Evidence(B) ≠ Evidence(A relation B)
- co-occurrence ≠ relation
- exposition order ≠ causal order
- may/can/could 不得被强化成无条件断言
- 无法可靠规范化时保留 source expression，normalized_type=null

不要为了填满 schema、形成漂亮知识图或提高 relation 数量而创造关系。
```
