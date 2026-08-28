# critic 功能模板

module: critic
version: dr3-reading/1.0
stage: B
requires: [synthesis_pkg.completed]
produces: critique_report
optional: true
outputs_to: [".petrelpost/articles/[slug]/critique/", ".petrelpost/articles/[slug]/trace.jsonl", ".petrelpost/articles/[slug]/state.json"]

---

## 输入

- `.petrelpost/articles/[slug]/synthesis/synthesis.md`（综合分析包）
- `.petrelpost/articles/[slug]/synthesis/synthesis.json`（综合分析数据）
- `.petrelpost/articles/[slug]/original/article.md`（原文，用于证据校验参照）

## 默认参数（用户可覆盖）

- `critique_mode`: `red_team_primary`（可选 red_team_primary / socratic / collaborative）
- `depth`: `medium`（可选 shallow / medium / deep）
- `focus_areas`: `[logical_gaps, assumptions, evidence_strength, practical_implications]`

## 执行流程

严格按以下 6 步执行。

### Step 1: 读取输入

读取 synthesis 输出与原文。若 synthesis 文件不存在，报错提示先运行 synthesis（硬依赖）。

### Step 2: 确定参数

- `critique_mode`：默认 `red_team_primary`
- `depth`：默认 `medium`
- `focus_areas`：默认全部四个维度

**深度差异**：

| 维度 | shallow | medium | deep |
|------|---------|--------|------|
| 每主张批判点数 | 1-2 | 2-4 | 3-6 |
| 证据校验 | 抽查关键主张 | 校验多数主张 | 逐条校验全部主张 |
| 假设审查 | 仅显性假设 | 显性 + 部分隐性 | 全部假设 + 推导隐含假设 |
| 替代解释 | 不生成 | 每主张 1 个 | 每主张 2-3 个 |

### Step 3: 按模式执行批判

#### 3.1 red_team_primary（红队对抗模式）

**策略**：假设自己是主张的对立方，主动寻找反驳论据，试图推翻每一条主张。

**执行方法**：

对每个 Claim 执行以下对抗流程：

```
对于 C{n}: "{主张内容}"
1. 反驳尝试：能否找到反例、反面证据或逻辑矛盾？
2. 证据挑战：支撑证据是否充分？是否有选择性引用？
3. 假设攻击：该主张依赖的假设是否可被否定？
4. 替代解释：是否存在同样合理但相反的解释？
5. 强度重新评估：基于以上，原始 strength 评估是否合理？
```

**输出特征**：
- 每条主张至少 1 个反驳点（即使最终认为论证坚实，也需说明为何反驳失败）
- 反驳必须基于逻辑/证据，不能仅凭直觉
- 使用"反方论据"、"然而"、"从对立面看"等对抗性措辞

---

#### 3.2 socratic（苏格拉底追问模式）

**策略**：通过连续追问揭示论证中的薄弱环节，不直接否定，而是通过问题引导发现矛盾。

**执行方法**：

对每个 Claim 执行追问链：

```
对于 C{n}: "{主张内容}"
1. 定义追问：该主张中关键概念的定义是否清晰？有无歧义？
2. 边界追问：该主张的适用边界在哪里？在什么条件下失效？
3. 证据追问：为什么这些证据足以支撑该主张？是否忽略了不利证据？
4. 推论追问：从证据到主张的推理步骤是否每步都成立？
5. 一致性追问：该主张与其他主张是否一致？有无内部矛盾？
6. 实践追问：如果按此主张行动，实际会遇到什么困难？
```

**输出特征**：
- 以问题链形式呈现，每个问题推动更深一层
- 不直接给出结论，让问题本身揭示矛盾
- 使用"如果...那么..."、"为何..."、"在什么条件下..."等探询性措辞

---

#### 3.3 collaborative（协作审视模式）

**策略**：建设性审视，先肯定论证的价值，再指出可改进之处，提出加强建议。

**执行方法**：

对每个 Claim 执行建设性审视：

```
对于 C{n}: "{主张内容}"
1. 价值肯定：该主张的核心价值与贡献是什么？
2. 论证亮点：哪些部分的论证最为有力？
3. 改进空间：哪些部分可以进一步加强？
4. 缺失视角：从哪些视角补充可以更完整？
5. 加强建议：如何修改/补充使该主张更 robust？
```

**输出特征**：
- 先肯定后建议，基调建设性
- 每条改进建议必须附带具体操作方案
- 使用"值得肯定"、"可以加强"、"建议补充"等建设性措辞

---

### Step 4: 按 focus_areas 组织批判结果

将批判结果按配置的 `focus_areas` 维度组织。四个维度定义：

| 维度 | 关注点 | 输出内容 |
|------|--------|---------|
| logical_gaps | 逻辑漏洞 | 推理链断裂、跳跃、循环论证 |
| assumptions | 假设风险 | 不可靠假设、未验证假设、假设间冲突 |
| evidence_strength | 证据强度 | 证据不充分、选择性引用、数据局限 |
| practical_implications | 实践影响 | 难以落地、条件苛刻、现实约束 |

**组织结构**：

```markdown
## 批判维度分析

### 逻辑漏洞（Logical Gaps）

{该维度下的所有批判发现，按主张 ID 关联}

### 假设风险（Assumptions）

{该维度下的所有批判发现}

### 证据强度（Evidence Strength）

{该维度下的所有批判发现}

### 实践影响（Practical Implications）

{该维度下的所有批判发现}
```

若 `focus_areas` 仅包含部分维度，只输出指定维度。

### Step 5: 持久化输出

写入 `.petrelpost/articles/[slug]/critique/` 目录。

**critique/critique.md**：

```markdown
# 批判分析：{title}

> 模式：{critique_mode} | 深度：{depth} | 关注维度：{focus_areas}

---

## 批判概览

{对整篇文章论证质量的整体评价，2-3 段中文}

## 逐主张批判

### C1: {核心主张}

**原始强度**：{strength} → **批判后评估**：{revised_strength}

{按选定模式生成的批判内容}

---

{重复至所有主张}

## 批判维度分析

{按 focus_areas 组织的维度分析}

## 盲点与局限性总结

{跨主张的共性盲点与局限性}

## 反驳点汇总

{所有主张的反驳点/追问点/改进建议的汇总表}

| 主张 | 关键批判点 | 维度 | 严重程度 |
|------|-----------|------|---------|
| C1 | {批判点} | {维度} | high |
| C1.1 | {批判点} | {维度} | medium |
| ... | ... | ... | ... |

**严重程度**：high（可能颠覆结论）/ medium（削弱论证力）/ low（细节瑕疵）
```

**critique/critique.json**：

```json
{
  "module": "critic",
  "slug": "[slug]",
  "critique_mode": "red_team_primary",
  "depth": "medium",
  "focus_areas": ["logical_gaps", "assumptions", "evidence_strength", "practical_implications"],
  "generated_at": "[ISO时间]",
  "claims_critiqued": [
    {
      "claim_id": "C1",
      "original_strength": "strong",
      "revised_strength": "moderate",
      "critique_points": [
        {
          "dimension": "evidence_strength",
          "severity": "medium",
          "content": "批判内容",
          "evidence_ref": "P7"
        }
      ]
    }
  ],
  "summary": {
    "total_critique_points": 0,
    "high_severity": 0,
    "medium_severity": 0,
    "low_severity": 0,
    "claims_weakened": 0,
    "claims_upheld": 0
  }
}
```

**更新 state.json**（按 `references/protocol.md` 结构）：

```json
"critique_report": {
  "status": "completed",
  "run_at": "[ISO时间]",
  "stale": false,
  "produced_by": { "module": "critic", "version": "dr3-reading/1.0" },
  "preview": "{mode} {depth}, [N] critique points ([N] high / [N] medium / [N] low), [N] claims weakened, [N] upheld"
}
```

若为重新执行：先写入本条目，再按级联规则标记下游（reconstructor 获 stale_soft，不阻塞）。

### Step 6: 追加 trace + 输出摘要

追加 `trace.jsonl`：

```json
{"module": "critic", "timestamp": "[ISO时间]", "status": "success", "input": ".petrelpost/articles/[slug]/synthesis/", "config": {"critique_mode": "red_team_primary", "depth": "medium", "focus_areas": ["logical_gaps", "assumptions", "evidence_strength", "practical_implications"]}, "stats": {"total_critique_points": 0, "high_severity": 0, "claims_weakened": 0, "claims_upheld": 0}}
```

输出摘要：

```
✅ critic 完成

- 批判模式：{mode} | 深度：{depth}
- 批判主张：[N] 条
- 批判点总计：[N]（high: [N], medium: [N], low: [N]）
- 强度重评估：[N] 条主张被削弱，[N] 条维持原判
- 存储路径：.petrelpost/articles/[slug]/critique/
```

完成后重新展示功能菜单，等待用户选择下一步。不自动执行后续功能。

---

## 输出语言规则

延续中英混合规则：
- 批判分析内容：**中文**
- 引用原文段落：**保留英文原文**
- 专业术语：**英文 + 中文注释**
- 主张 ID、维度标签：**英文**

---

## 错误处理

| 场景 | 处理方式 |
|------|---------|
| Synthesis 文件缺失 | 报错，提示先运行 synthesis（硬依赖） |
| 批判模式无效 | 回退至 red_team_primary 并警告 |
| 某主张无法批判（信息不足） | 标注 `insufficient_for_critique`，不阻断 |
| depth 参数无效 | 回退至 medium |

---

## Prompt 指令体

```
你是 dr3-reading 的 critic 功能。

任务：对 synthesis 结果进行批判性质询，输出盲点、局限性、反驳点，为 reconstructor 提供批判基础。

输入文件：
- .petrelpost/articles/[slug]/synthesis/synthesis.md
- .petrelpost/articles/[slug]/synthesis/synthesis.json
- .petrelpost/articles/[slug]/original/article.md（证据校验参照）

配置：
- 批判模式：{critique_mode}（red_team_primary / socratic / collaborative）
- 深度：{depth}（shallow / medium / deep）
- 关注维度：{focus_areas}

请严格按以下步骤执行：
1. 读取 synthesis 输出与原文
2. 确定批判配置
3. 按模式执行批判：
   - red_team_primary：主动反驳每条主张，尝试推翻
   - socratic：苏格拉底追问链，揭示薄弱环节
   - collaborative：建设性审视，先肯定后建议
4. 按 focus_areas 维度组织批判结果
5. 持久化：critique/critique.md + critique.json + 更新 state.json + 级联
6. 追加 trace.jsonl + 输出摘要

关键规则：
- 只做批判，不做重构——不提出重构方案
- 批判必须基于逻辑/证据，不能仅凭直觉
- 每条批判点必须标注严重程度（high/medium/low）和所属维度
- 对每条主张给出强度重评估（original → revised）
- 批判时参照原文验证 synthesis 中的证据引用是否准确

输出语言：中文为主，引用保留英文，术语英文+中文注释
```
