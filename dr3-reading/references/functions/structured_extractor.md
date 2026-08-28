# structured_extractor 功能模板

module: structured_extractor
version: dr3-reading/1.0
stage: A
requires: [raw_content.completed]
produces: structured_data
outputs_to: [".petrelpost/articles/[slug]/analysis/", ".petrelpost/articles/[slug]/trace.jsonl", ".petrelpost/articles/[slug]/state.json"]

---

## 输入

- `.petrelpost/articles/[slug]/original/article.md`（清洗后正文）
- `.petrelpost/articles/[slug]/original/metadata.yaml`（元数据）

## 默认参数（用户可覆盖）

- `extraction_depth`: `high`（可选 low / medium / high）

## 执行流程

严格按以下 7 步执行。

### Step 1: 读取输入

读取 importer 输出的正文与元数据。若文件不存在，报错并提示先运行 importer。

### Step 2: 确定 extraction_depth

默认值为 `high`；用户明确指定时采用用户值。

三级差异：

| 维度 | low | medium | high |
|------|-----|--------|------|
| Claims | 仅核心主张 | 核心 + 重要子主张 | 全部主张层级树 |
| Methods | 仅主要方法 | 主要 + 辅助方法 | 完整论证链路 |
| Data | 仅关键数据 | 关键 + 支撑数据 | 全部数据点 |
| Assumptions | 不提取 | 仅显性假设 | 显性 + 隐性假设 |

### Step 3: 四维度抽取

逐一读取正文，按以下四维度进行结构化抽取。

#### 3.1 Purpose（目的）

提取以下字段：

| 字段 | 说明 | 示例 |
|------|------|------|
| core_purpose | 文章核心目的，一句话概括 | "论证简单战略优于复杂战略" |
| target_audience | 目标读者群体 | "企业高管、战略咨询师" |
| problem_addressed | 文章要解决的核心问题 | "复杂战略为何频繁失败" |
| intended_contribution | 文章试图贡献的新知或视角 | "提出战略简化的可行路径" |

#### 3.2 Claims（主张层级树）

构建主张的层级结构，从核心主张到子主张到支撑证据：

```yaml
claims:
  - id: "C1"
    claim: "核心主张内容（原文语言）"
    strength: "strong"        # strong / moderate / weak
    sub_claims:
      - id: "C1.1"
        claim: "子主张内容"
        strength: "moderate"
        supporting_evidence: ["E1", "E2"]
      - id: "C1.2"
        claim: "子主张内容"
        strength: "weak"
        supporting_evidence: ["E3"]
  - id: "C2"
    claim: "第二个核心主张"
    strength: "strong"
    sub_claims: [...]
```

**strength 判定标准**：
- `strong`：有充分数据/逻辑支撑，论证完整
- `moderate`：有部分支撑，但存在可质疑空间
- `weak`：仅凭推断或类比，缺乏直接证据

#### 3.3 Methods（方法与论证）

| 字段 | 说明 | 可选值 |
|------|------|--------|
| reasoning_type | 主要推理类型 | inductive / deductive / analogical / abductive / mixed |
| argument_structure | 论证结构 | thesis-antithesis / problem-solution / claim-evidence / narrative-driven / mixed |
| key_frameworks | 文章使用的理论框架 | 列表，如 ["Porter's Five Forces", "Resource-Based View"] |
| logical_chain | 逻辑链路步骤 | ["前提A", "→ 推理B", "→ 结论C"] |

#### 3.4 Data（数据点）

```yaml
data_points:
  - id: "D1"
    metric: "指标名称"
    value: "数值或描述"
    context: "该数据出现的上下文"
    source_paragraph: 15      # 原文段落号
  - id: "D2"
    metric: "另一指标"
    value: "75%"
    context: "..."
    source_paragraph: 23
```

### Step 4: Assumptions 提取

识别文章论证所依赖的假设，分为两类：

| 类型 | 说明 | 示例 |
|------|------|------|
| explicit | 作者明确陈述的假设 | "我们假设市场是完全竞争的" |
| implicit | 未明说但论证依赖的假设 | "假设过去趋势在未来持续"（仅 high 模式） |

```yaml
assumptions:
  - id: "A1"
    type: "explicit"
    assumption: "假设内容（原文语言）"
    supports_claims: ["C1", "C1.2"]   # 该假设支撑哪些主张
  - id: "A2"
    type: "implicit"
    assumption: "隐含假设内容"
    supports_claims: ["C2"]
```

### Step 5: 证据映射

为每个 Claim 建立指向原文的映射关系：

```yaml
evidence_map:
  - claim_id: "C1"
    evidence:
      - paragraph: 3
        quote: "原文关键引文摘录（30字以内）"
        relevance: "该引文如何支撑此主张"
      - paragraph: 7
        quote: "另一引文摘录"
        relevance: "支撑说明"
  - claim_id: "C1.1"
    evidence:
      - paragraph: 5
        quote: "..."
        relevance: "..."
```

**映射规则**：
- 段落号从正文第 1 段开始编号（不含元数据头部）
- 引文摘录不超过 30 字，保留原文语言
- 每条 Claim 至少有一个证据映射（无直接证据时标注 `inferred`）

### Step 6: 持久化输出

写入 `.petrelpost/articles/[slug]/analysis/` 目录。

**analysis/structured_extraction.md**（人类可读）：

```markdown
# 结构化抽取：[title]

## Purpose
- **核心目的**：[core_purpose]
- **目标读者**：[target_audience]
- **核心问题**：[problem_addressed]
- **预期贡献**：[intended_contribution]

## Claims 主张层级

### C1: [核心主张]
> Strength: strong | 证据段落: P3, P7

- C1.1: [子主张] (moderate)
  - 证据: P5 — "引文摘录..."
- C1.2: [子主张] (weak)
  - 证据: P9 — "引文摘录..."

### C2: [核心主张]
> Strength: strong | 证据段落: P12, P15

...

## Methods 方法与论证

- **推理类型**：[reasoning_type]
- **论证结构**：[argument_structure]
- **理论框架**：[key_frameworks]
- **逻辑链路**：
  1. [步骤1] → [步骤2] → [结论]

## Data 数据点

| ID | 指标 | 数值 | 上下文 | 段落 |
|----|------|------|--------|------|
| D1 | [metric] | [value] | [context] | P15 |

## Assumptions 假设

| ID | 类型 | 假设内容 | 支撑主张 |
|----|------|---------|---------|
| A1 | explicit | [内容] | C1, C1.2 |
| A2 | implicit | [内容] | C2 |

## 证据映射

| 主张 | 段落 | 引文 | 相关性 |
|------|------|------|--------|
| C1 | P3 | "..." | ... |
```

**analysis/structured_extraction.json**（机器可解析）：

```json
{
  "module": "structured_extractor",
  "slug": "[slug]",
  "extraction_depth": "high",
  "purpose": { ... },
  "claims": [ ... ],
  "methods": { ... },
  "data_points": [ ... ],
  "assumptions": [ ... ],
  "evidence_map": [ ... ],
  "stats": {
    "total_claims": 0,
    "total_data_points": 0,
    "total_assumptions": 0,
    "avg_evidence_per_claim": 0.0
  }
}
```

**更新 state.json**（按 `references/protocol.md` 结构）：

```json
"structured_data": {
  "status": "completed",
  "run_at": "[ISO时间]",
  "stale": false,
  "produced_by": { "module": "structured_extractor", "version": "dr3-reading/1.0" },
  "preview": "[depth] depth, [N] claims ([N] core), [N] data points, [N] assumptions, [N] evidence links"
}
```

若为重新执行：先写入本条目，再按级联规则标记下游（synthesis → critic → reconstructor → note_generator → evaluator）。

### Step 7: 追加 trace + 输出摘要

追加 `trace.jsonl`：

```json
{"module": "structured_extractor", "timestamp": "[ISO时间]", "status": "success", "input": ".petrelpost/articles/[slug]/original/article.md", "config": {"extraction_depth": "high"}, "stats": {"claims": 0, "data_points": 0, "assumptions": 0, "evidence_links": 0}}
```

输出摘要：

```
✅ structured_extractor 完成

- 核心主张：[N] 条（strong: X, moderate: Y, weak: Z）
- 数据点：[N] 个
- 假设：[N] 条（explicit: X, implicit: Y）
- 证据映射：[N] 条，平均每主张 [X.X] 条证据
- 抽取深度：[depth]
- 存储路径：.petrelpost/articles/[slug]/analysis/
```

完成后重新展示功能菜单，等待用户选择下一步。不自动执行后续功能。

---

## 错误处理

| 场景 | 处理方式 |
|------|---------|
| 输入文件不存在 | 报错，提示先运行 importer |
| 正文过短无法抽取 | 警告，尝试最浅抽取 |
| 无法识别任何 Claim | 警告，输出空的 Claims 结构，标记 `needs_review` |
| 证据映射缺失 | 对无映射的 Claim 标注 `inferred`，不阻断流程 |

---

## Prompt 指令体

```
你是 dr3-reading 的 structured_extractor 功能。

任务：对清洗后的英文正文进行结构化抽取，输出四维度分析（Purpose, Claims, Methods, Data）+ 假设 + 证据映射。

输入文件：.petrelpost/articles/[slug]/original/article.md

请严格按以下步骤执行：
1. 读取正文与元数据
2. 确定 extraction_depth（默认 high）
3. 四维度抽取：
   - Purpose：核心目的、目标读者、核心问题、预期贡献
   - Claims：主张层级树（C1 → C1.1 → 证据），含 strength 评估
   - Methods：推理类型、论证结构、理论框架、逻辑链路
   - Data：所有数据点（指标、数值、上下文、段落号）
4. Assumptions 提取（显性 + 隐性假设，标注支撑的主张 ID）
5. 证据映射：每个 Claim → 段落号 + 关键引文摘录（≤30字）
6. 持久化：analysis/structured_extraction.md + .json + 更新 state.json + 级联
7. 追加 trace.jsonl + 输出摘要

关键规则：
- 所有抽取内容保留原文语言（英文），不做翻译
- 忠实抽取，不做评价或批判——那是 critic 功能的职责
- 每条 Claim 必须有 evidence_map 映射（无直接证据标注 inferred）
- Claim ID 格式：C1, C1.1, C2, C2.1... 严格按层级编号
- strength 评估基于原文证据充分性，非主观判断
```
