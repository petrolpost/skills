# synthesis 功能模板

module: synthesis
version: dr3-reading/1.0
stage: B
requires: [structured_data.completed]
enhanced_by: [immersion_notes.completed]
produces: synthesis_pkg
outputs_to: [".petrelpost/articles/[slug]/synthesis/", ".petrelpost/articles/[slug]/trace.jsonl", ".petrelpost/articles/[slug]/state.json"]

---

## 输入

- `.petrelpost/articles/[slug]/analysis/structured_extraction.json`（结构化抽取）
- `.petrelpost/articles/[slug]/immersion/immersion_neutral.md`（neutral 视角沉浸）
- `.petrelpost/articles/[slug]/immersion/immersion_author.md`（author 视角沉浸）
- `.petrelpost/articles/[slug]/immersion/immersion_skeptic.md`（skeptic 视角沉浸）
- `.petrelpost/articles/[slug]/immersion/immersion_index.json`（沉浸索引）
- `.petrelpost/articles/[slug]/original/metadata.yaml`（元数据）

## 默认参数（用户可覆盖）

- `fusion_strategy`: `structure_first`（可选 structure_first / context_first / balanced）
- `include_evidence_map`: `true`

## 执行流程

严格按以下 6 步执行。

### Step 1: 读取输入

读取所有前置功能的输出。若关键文件缺失：
- 缺 structured_extractor → 报错，提示先运行（硬依赖）
- 缺 immersion_reader → 允许继续，以结构化抽取结果降级融合，产出标注"未增强"

### Step 2: 确定融合策略

默认 `structure_first`；用户明确指定时采用用户值。

三种策略差异：

| 策略 | 主干来源 | 丰富来源 | 叙事逻辑 | 适合文章类型 |
|------|---------|---------|---------|------------|
| structure_first | 结构化抽取 | 沉浸结果作注解 | 按主张层级组织 | 论证严密的学术/战略文章 |
| context_first | 沉浸式语境 | 结构化作证据锚点 | 按语境叙事组织 | 叙事性强、背景依赖重的文章 |
| balanced | 两者并重 | 交替穿插 | 双线索交织 | 通用 |

### Step 3: 执行融合

根据选定策略，将 structured_extractor 与 immersion_reader 的结果融合为一份连贯的综合分析包。

#### 3.1 structure_first 策略

以结构化抽取的四维度为主骨架，沉浸结果作为深层注解嵌入：

```markdown
# 综合分析：{title}

## 文章定位

{从 immersion neutral 中提取领域定位与语境，2-3 段中文概述}

## 核心目的

{从 structured_extraction.purpose 融合 immersion author 的写作意图分析}

## 主张体系

### C1: {核心主张}

**主张强度**：{strength} | **论证方法**：{method}

{从 immersion 中选取与该主张最相关的语境注解，1-2 段中文}

**子主张与证据**：
- C1.1: {子主张}
  - 证据：P{段落号} — "{英文引文}"
  - 语境注解：{从 immersion 补充的背景理解}

{重复至所有主张}

## 论证架构

{从 structured_extraction.methods 融合 immersion 中的论战脉络}

**推理链路**：
1. {前提} → {推理} → {结论}

**作者修辞策略**：{从 immersion author 提取}

## 数据支撑

| 指标 | 数值 | 上下文 | 来源 |
|------|------|--------|------|
| {metric} | {value} | {中文上下文说明} | P{段落号} |

## 关键假设

| 假设 | 类型 | 支撑主张 | 语境说明 |
|------|------|---------|---------|
| {assumption} | {type} | {claim_ids} | {从 immersion 补充的假设语境} |

## 潜在关注点

{从 immersion skeptic 提取的盲区与替代解释，仅客观列出，不做批判判定}

## 证据链总览

{evidence_map 的综合视图，每个主张的可追溯路径}
```

#### 3.2 context_first 策略

以沉浸式语境为主叙事线，结构化结果作为证据锚点嵌入：

```markdown
# 综合分析：{title}

## 语境与背景

{从 immersion neutral 构建完整语境叙事，3-5 段}

## 作者与意图

{从 immersion author 还原写作动机与立场，2-3 段}

## 核心论证

{按叙事逻辑重新组织主张体系，每个主张后附结构化证据锚点}

### 论点一：{叙述式标题}

{语境叙事，中文}

> **结构化锚点**：C1 ({strength}) — "{英文原文引文}"
> **证据段落**：P{段落号}

{继续叙事...}

## 数据与支撑

{同 structure_first，但按叙事顺序而非主张层级排列}

## 未言明之处

{从 immersion skeptic 提取，以叙事方式呈现}

## 论证结构概览

{简要呈现 structured_extraction 的逻辑链路}
```

#### 3.3 balanced 策略

双线索交织：每节同时呈现结构化骨架与沉浸语境：

```markdown
# 综合分析：{title}

## 概览

{一段中文概述，融合 purpose + 语境定位}

## 主张与语境交织

### C1: {核心主张}

**【结构化】** {主张内容} | 强度: {strength} | 方法: {method}
**【语境】** {该主张的历史/行业/学术语境，从 immersion 提取}

**证据与注解**：
- 证据：P{段落号} — "{引文}"
- 语境注解：{沉浸式理解补充}

{交替继续}

## 论证脉络

**【逻辑链路】** {structured_extraction 逻辑链}
**【论战背景】** {immersion 中的对话与论战脉络}

## 数据与假设

{同 structure_first 格式，增加语境注解列}

## 关注视角

| 视角 | 关键发现 |
|------|---------|
| Neutral | {immersion neutral 的核心发现} |
| Author | {immersion author 的核心发现} |
| Skeptic | {immersion skeptic 的核心发现，仅客观列出} |
```

### Step 4: 构建综合证据链

无论哪种策略，都必须构建完整的证据链，确保每条重要论点可追溯到原文：

```yaml
evidence_chain:
  - claim_id: "C1"
    trace:
      - source: "structured_extraction"
        field: "claims.C1"
      - source: "immersion_neutral"
        context: "相关语境段落引用"
      - source: "original_article"
        paragraph: 3
        quote: "原文引文"
  - claim_id: "C2"
    trace: [...]
```

### Step 5: 持久化输出

写入 `.petrelpost/articles/[slug]/synthesis/` 目录。

**synthesis/synthesis.md**：按选定策略生成的综合分析包（人类可读）

**synthesis/synthesis.json**：

```json
{
  "module": "synthesis",
  "slug": "[slug]",
  "fusion_strategy": "structure_first",
  "generated_at": "[ISO时间]",
  "purpose": {
    "core_purpose": "...",
    "enriched_with_immersion": true
  },
  "claims_summary": [
    {
      "id": "C1",
      "claim": "...",
      "strength": "strong",
      "evidence_count": 3,
      "immersion_enriched": true
    }
  ],
  "assumptions_count": 0,
  "data_points_count": 0,
  "evidence_chain": [ ... ],
  "perspectives_used": ["neutral", "author", "skeptic"],
  "fusion_notes": "融合策略说明与取舍记录"
}
```

**更新 state.json**（按 `references/protocol.md` 结构）：

```json
"synthesis_pkg": {
  "status": "completed",
  "run_at": "[ISO时间]",
  "stale": false,
  "produced_by": { "module": "synthesis", "version": "dr3-reading/1.0" },
  "preview": "{strategy} fusion, [N] claims, [N] assumptions, [N] evidence chains, enhanced: {true/false}"
}
```

若为重新执行：先写入本条目，再按级联规则标记下游（critic、reconstructor 及更下游）。

### Step 6: 追加 trace + 输出摘要

追加 `trace.jsonl`：

```json
{"module": "synthesis", "timestamp": "[ISO时间]", "status": "success", "input": ["structured_extraction.json", "immersion/"], "config": {"fusion_strategy": "structure_first", "include_evidence_map": true}, "stats": {"claims_synthesized": 0, "assumptions_included": 0, "evidence_links": 0, "immersion_enriched_claims": 0}}
```

输出摘要：

```
✅ synthesis 完成

- 融合策略：{strategy}
- 综合主张：[N] 条（沉浸丰富：[N] 条）
- 假设：[N] 条 | 数据点：[N] 个
- 证据链：[N] 条完整追溯路径
- 存储路径：.petrelpost/articles/[slug]/synthesis/
```

完成后重新展示功能菜单，等待用户选择下一步。不自动执行后续功能。

---

## 输出语言规则

延续 immersion_reader 的中英混合规则：
- 分析与融合内容：**中文**
- 引用原文关键段落：**保留英文原文**
- 专业术语：**英文 + 中文注释**
- 主张 ID 与结构化标签：**英文**（C1, C1.1 等）

---

## 关键约束

本功能有两条**硬性约束**，不可违反：

1. **只做融合，不做批判**：skeptic 视角的发现仅客观列出为"潜在关注点"，不做批判性判定。批判是 critic 功能的专属职责。
2. **只做融合，不提重构**：不提出任何重构方案或框架建议。重构是 reconstructor 功能的专属职责。

若在融合过程中产生批判性判断或重构倾向，必须抑制并标注"待 critic/reconstructor 处理"。

---

## 错误处理

| 场景 | 处理方式 |
|------|---------|
| StructuredExtractor 文件缺失 | 报错，提示先运行（硬依赖） |
| ImmersionReader 文件缺失 | 允许继续，降级为纯结构化融合（无沉浸注解），产出标注"未增强" |
| 部分视角文件缺失 | 用已有视角融合，标注缺失视角 |
| 融合策略无效 | 回退至 structure_first 并警告 |
| 证据链断裂 | 标注 `trace_broken`，不阻断流程 |

---

## Prompt 指令体

```
你是 dr3-reading 的 synthesis 功能。

任务：将 structured_extractor 与 immersion_reader 的结果融合为一份连贯的综合分析包。

输入文件：
- .petrelpost/articles/[slug]/analysis/structured_extraction.json
- .petrelpost/articles/[slug]/immersion/（neutral, author, skeptic）
- .petrelpost/articles/[slug]/original/metadata.yaml

配置：
- 融合策略：{fusion_strategy}（structure_first / context_first / balanced）
- 包含证据映射：{include_evidence_map}

请严格按以下步骤执行：
1. 读取所有前置功能输出
2. 确定融合策略（{fusion_strategy}）
3. 执行融合：
   - structure_first：结构化为主干 + 沉浸注解
   - context_first：沉浸为主叙事 + 结构化锚点
   - balanced：双线索交织
4. 构建综合证据链（每条论点 → 原文段落 + 沉浸来源）
5. 持久化：synthesis/synthesis.md + synthesis.json + 更新 state.json + 级联
6. 追加 trace.jsonl + 输出摘要

⚠️ 硬性约束：
- 只做融合，不做批判（skeptic 发现仅客观列出）
- 只做融合，不提重构（不提任何重构方案）

输出语言：中文为主，引用保留英文，术语英文+中文注释
```
