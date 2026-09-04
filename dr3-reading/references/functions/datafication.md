# datafication 功能模板

module: datafication
version: dr3-reading/1.4
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

---

## 输入

- `.petrelpost/articles/[slug]/original/article.md`
- `.petrelpost/articles/[slug]/original/metadata.yaml`
- `.petrelpost/articles/[slug]/analysis/structured_extraction.json`（若已存在，作为辅助输入；不得覆盖原文证据）

## 默认参数

- `discovery_depth`: `high`（可选 standard / high）
- `allow_reconstruction`: `true`（允许对紧邻原文的显式结构进行忠实重构）
- `inference_policy`: `restricted`（默认禁止仅凭推断创建结构）

---

## 什么算“可数据化结构”

一个候选结构至少应满足：

1. **结构性**：元素之间存在可描述的组织关系，而不仅是若干事实的集合。
2. **边界性**：可以指出结构覆盖的段落、章节或局部范围。
3. **复用价值**：结构化后明显比自然语言连续叙述更便于比较、查询、复用或后续分析。
4. **证据性**：能够回指原文；不能主要依靠模型常识补全。

典型类型（非穷举）：

| type | 识别对象 | 常见形式 |
|---|---|---|
| process | 流程、步骤、生命周期 | A → B → C |
| classification | 分类体系 | Subject → Category A/B/C |
| criteria | 判断/评价标准 | Subject → Criteria |
| decision_rule | 条件—行动规则 | If X → Y |
| framework | 框架、模型 | Dimensions / Components |
| comparison | 对象间系统比较 | A × B × Dimensions |
| scale | 等级、成熟度、阶段尺度 | Level 1 → Level 2 → Level 3 |
| enumeration | 有明确共同边界的列举 | Item A/B/C |
| relationship | 明确表达的关系结构 | A → relates_to → B |

不要因为文章有标题、列表或多个名词就自动创建结构。形式上的列表只有在作者赋予它稳定语义或组织关系时才算候选结构。

---

## 执行流程

### Step 1: 读取原文

读取完整正文。必须以原文为第一证据来源。若 raw_content 不存在，停止并提示先运行 importer。

### Step 2: 候选结构发现

扫描全文，寻找：

- 显式步骤、阶段、顺序、输入/输出
- 显式分类、层级、分组
- 显式判断标准、维度、阈值
- 显式条件—行动关系
- 显式框架、模型、矩阵
- 显式比较维度
- 显式等级、成熟度或阶段
- 具有共同语义边界的枚举
- 作者明确建立的实体关系

同时记录每个候选的最小证据范围。

### Step 3: 候选验证

逐个判断：

- 是否由作者明确表达？
- 如果不是完全显式，是否能通过局部、忠实的结构重构表达？
- 是否需要模型常识才能补齐缺失关系？
- 是否结构化后具有明显复用价值？

若主要依赖模型推断，则丢弃候选，除非用户明确允许推断；即使允许，也必须标记 `origin: inferred`。

### Step 4: 判断范围

每个结构必须标记 `scope`：

```yaml
scope:
  type: local       # local / section / article
  paragraphs: [12, 18]
```

只有当多个局部结构被文章本身明确组织为一个整体时，才使用 `scope.type: article`。

不要因为文章中存在多个结构，就自动声称它们构成一个统一概念系统。

### Step 5: 结构化

使用最小充分 schema。不要为了填充字段而发明字段。

通用对象：

```yaml
- id: DS-01
  type: process
  name: "AI Adoption Lifecycle"
  scope:
    type: local
    paragraphs: [12, 18]
  origin: explicit       # explicit / reconstructed / inferred
  status: author_asserted
  subject: "AI adoption"
  structure:
    steps:
      - id: S1
        name: "Pilot"
        order: 1
      - id: S2
        name: "Deployment"
        order: 2
      - id: S3
        name: "Scaling"
        order: 3
  evidence:
    - paragraph: 12
      quote: "..."
      role: structure_definition
```

`status: author_asserted` 表示“这是作者在文章中表达的结构”，**不表示 DR3 认可其正确性**。

### Step 6: 结构之间的关系

只有原文存在足够证据时才建立关系，例如：

```yaml
relations:
  - from: DS-01
    relation: supports
    to: C3
    origin: explicit
```

不要为了形成漂亮的图而添加关系。

### Step 7: 判断是否形成概念体系

仅作描述，不作本体化判断。可输出：

```yaml
conceptualization:
  detected: true
  scope: article
  coherence: high
```

其中 `conceptualization` 表示文章中是否存在相互组织的概念结构，不代表“正确 ontology”。

### Step 8: 持久化

写入：

**`.petrelpost/articles/[slug]/datafication/datafication.md`**

包含：
- 发现摘要
- 每个结构对象
- scope / origin / status
- 原文证据
- 结构之间的显式关系
- 未结构化的候选及拒绝原因（仅列重要候选）

**`.petrelpost/articles/[slug]/datafication/datafication.json`**：

```json
{
  "module": "datafication",
  "version": "dr3-reading/1.1",
  "slug": "[slug]",
  "discovery_depth": "high",
  "applicable": true,
  "structures": [
    {
      "id": "DS-01",
      "type": "process",
      "name": "AI Adoption Lifecycle",
      "scope": {"type": "local", "paragraphs": [12, 18]},
      "origin": "explicit",
      "status": "author_asserted",
      "structure": {}
    }
  ],
  "relations": [],
  "conceptualization": {
    "detected": false,
    "scope": null,
    "coherence": null
  },
  "rejected_candidates": [],
  "stats": {
    "structures": 1,
    "explicit": 1,
    "reconstructed": 0,
    "inferred": 0
  }
}
```

如果没有足够结构：

```json
{
  "applicable": false,
  "structures": [],
  "conceptualization": {"detected": false}
}
```

### Step 9: 更新 state + trace

```json
"datafication": {
  "status": "completed",
  "run_at": "[ISO时间]",
  "stale": false,
  "stale_soft": false,
  "blocking": false,
  "reason": "",
  "produced_by": {"module": "datafication", "version": "dr3-reading/1.1"},
  "preview": "[N] structures: [types]; scope: [local/article]"
}
```

追加 trace：

```json
{"module":"datafication","timestamp":"[ISO时间]","status":"success","input":".petrelpost/articles/[slug]/original/article.md","config":{"discovery_depth":"high","allow_reconstruction":true,"inference_policy":"restricted"},"stats":{"structures":0,"explicit":0,"reconstructed":0,"inferred":0}}
```

完成后重新展示功能菜单，不自动执行 synthesis 或其他后续功能。

---

## 反过度结构化规则

这是本功能最重要的质量约束：

1. 不把文章的自然段强行变成结构。
2. 不把普通枚举自动当作 taxonomy。
3. 不把叙事顺序自动当作 process。
4. 不把作者提出的几个观点自动拼成 framework。
5. 不因为存在两个以上结构，就推断存在 concept system。
6. 不将模型推断的关系写成作者明确表达的关系。
7. 结构化结果必须能够回到原文的明确证据范围。
8. 如果结构化后没有明显的查询、比较、复用价值，则宁可不抽取。

**宁缺毋滥。** 本功能宁可漏掉一个候选，也不要为了提高结构数量而制造结构。

---

## 语义强度原则（v1.4 新增）

v1.4 版本要求明确区分断言的语义强度，防止将推断结果误标为作者明确表达。

### 原则

**语义强度决定标记**：结构内的断言必须按语义强度分级，不将推断当断言。

- **事实型（fact）**：作者明确陈述的数据或事实
- **推断型（inference）**：作者暗示但未直接陈述的含义
- **解释型（interpretation）**：对作者意图或文本含义的解读
- **假设型（assumption）**：为理解文本而假设的前提

### 反推断污染

**反推断污染**：结构中的 claim 不得将模型推断的结论写成作者明确表达的观点。

- 在 evidence.annotations 中标注每个断言的语义强度
- 推断型和解释型断言必须标注 `inferred: true`
- 不得将推断结论用作结构的核心断言（只能作为补充）

---

## Claim-level Provenance（v1.4 新增）

### 核心要求

每个 claim 必须有可追溯的证据来源，且必须区分"作者明确表达"与"模型推断"。

### Evidence 完整性规则

**断言必须有证据**：每个 claim 必须有对应的 evidence，证据必须来自原文，且不能主要依靠模型常识补全。

**证据必须可追溯**：evidence 必须包含具体的锚点信息（paragraph + quote），不能只给抽象描述。

**不能用推断代替证据**：如果 claim 本身是推断型，那么它不应使用 `author_explicit` 作为 semantic_strength。

### 结构验证链（Step 7）

**结构性断言必须有证据支持**：结构中的每个核心断言必须有对应的 evidence 条目，且 evidence 不能主要依靠模型推断。

**证据一致性验证**：结构内所有断言的 semantic_strength 必须与对应 evidence 的 semantic_strength 一致。

**结论**：

- 如果结构内的主要断言都有直接的原文证据支持，则 status 保持 `author_asserted`
- 如果结构内的主要断言中，有超过一半是推断型的（inferred: true），则 status 必须改为 `reconstructed` 或 `partially_supported`
- 如果证据链断裂严重（关键 claim 缺少 evidence 或 evidence 来源不明），则 status 必须降级

---

## Prompt 指令体

```
你是 dr3-reading 的 datafication 功能。

任务：从文章中发现真实存在的、具有独立结构性并具有复用价值的知识结构，将其显式化。

核心原则：discover, don't impose。

你不是在把整篇文章转换成数据库，也不是在建立“正确”的 ontology。
你要识别文章中哪些局部或整体知识结构值得脱离连续自然语言而独立存在。

执行：
1. 阅读完整原文
2. 发现候选结构
3. 用原文验证候选
4. 判断每个结构的最小 scope
5. 选择最小充分的结构类型
6. 结构化并保留原文证据
7. 标记 origin：explicit / reconstructed / inferred
8. 仅在原文有证据时建立结构间关系
9. 可选地描述是否存在 article-level conceptualization，但不要把它宣称为 ontology
10. 持久化 JSON + Markdown + state + trace

候选类型包括：
process / classification / criteria / decision_rule / framework / comparison / scale / enumeration / relationship

重要限制：
- 不是所有文章都有可数据化结构
- 一篇文章没有概念系统，也可能存在一个或多个局部结构
- 不要把标题、普通列表、叙事顺序自动解释为结构
- 不要用领域常识补齐作者没有表达的关系
- inference_policy=restricted 时，不得创建主要依赖推断的结构
- 每个结构必须有 scope 和 evidence
- status=author_asserted 只表示“作者表达了该结构”，不表示 DR3 认可其正确性
- 宁缺毋滥
```
