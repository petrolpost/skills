# evaluator 功能模板

module: evaluator
version: dr3-reading/1.0
stage: D
requires: [note_final]
produces: optimization_report
on_blocked_requirement:
  mode: block
outputs_to: [".petrelpost/articles/[slug]/optimization_report.md", ".petrelpost/articles/[slug]/trace.jsonl", ".petrelpost/articles/[slug]/state.json"]

---

## 输入

- `.petrelpost/articles/[slug]/trace.jsonl`（全流程追踪记录）
- `.petrelpost/articles/[slug]/state.json`（各功能状态与参数快照）
- `.petrelpost/articles/[slug]/original/metadata.yaml`（原文元数据）
- `.petrelpost/articles/[slug]/analysis/structured_extraction.json`（结构化抽取）
- `.petrelpost/articles/[slug]/immersion/immersion_index.json`（沉浸索引，可选）
- `.petrelpost/articles/[slug]/synthesis/synthesis.json`（综合分析）
- `.petrelpost/articles/[slug]/critique/critique.json`（批判分析，可选）
- `.petrelpost/articles/[slug]/reconstruction/reconstruction.json`（重构数据）
- `.petrelpost/articles/[slug]/outputs/[slug].md`（最终笔记）

## 默认参数（用户可覆盖）

- `auto_suggest`: `true`（是否自动提出改进建议）
- `metrics`: 全部 5 项（traceability_score / insight_depth / coherence / user_edit_ratio / overall_quality）

## 执行流程

严格按以下 6 步执行。

### Step 1: 读取全流程输出

读取所有前置功能的输出与 trace.jsonl。若某些功能未运行（state.json 中无条目），标注 `module_skipped` 并跳过该功能相关指标的计算。

### Step 2: 计算五项评估指标

#### 2.1 traceability_score（可追溯性评分）

**评估对象**：每条洞见是否有完整的证据链指向原文

**计算方法**：

```
traceability_score = 有完整证据链的洞见数 / 总洞见数

证据链完整性判定：
- 有原文段落引用 → +0.4
- 有引文摘录 → +0.3
- 有 Critic 评估 → +0.3
满分 1.0 = 三项齐全
```

**评级**：
- 0.9-1.0：优秀（几乎全部洞见可追溯）
- 0.7-0.89：良好
- 0.5-0.69：一般（需改进证据链）
- < 0.5：不足（严重缺乏追溯性）

---

#### 2.2 insight_depth（洞见深度评分）

**评估对象**：洞见的深度与价值，非简单复述原文

**计算方法**：

```
insight_depth = 加权平均(各洞见深度分)

洞见深度分评定：
- 仅复述原文观点 → 0.3
- 重新组织原文观点 → 0.5
- 融合多观点产生新理解 → 0.7
- 提出原文未明言的深层洞见 → 0.9
- 洞见改变读者认知框架 → 1.0
```

**评级**：
- 0.8-1.0：深刻
- 0.6-0.79：有深度
- 0.4-0.59：一般
- < 0.4：浅层

---

#### 2.3 coherence（逻辑连贯性评分）

**评估对象**：synthesis → critic → reconstructor → note 的逻辑一致性

**计算方法**：

```
coherence = (synthesis_integrity + critique_integration + reconstruction_consistency) / 3

synthesis_integrity：synthesis 中各主张间的逻辑自洽程度（0-1）
critique_integration：critic 发现是否被 reconstructor 回应（已回应数/总发现数）
reconstruction_consistency：重构方案与 synthesis 主张的对应完整性（0-1）
```

**评级**：
- 0.9-1.0：高度连贯
- 0.7-0.89：连贯
- 0.5-0.69：部分断裂
- < 0.5：明显断裂

---

#### 2.4 user_edit_ratio（用户修改比例）

**评估对象**：用户在 reconstructor 阶段的参与程度

**计算方法**：

```
user_edit_ratio = 用户修改次数 / (生成方案数 + 用户修改次数)

数据来源：reconstruction.json 的 iteration_count 和 user_modifications
```

**解读**：
- 高比例（> 0.5）：用户大量修改，说明自动重构与用户预期差距大 → 重构策略需优化
- 中比例（0.2-0.5）：用户适度参与，正常范围
- 低比例（< 0.2）：用户基本接受自动方案，系统重构质量高

---

#### 2.5 overall_quality（综合质量评分）

**加权计算**：

```
overall_quality =
  traceability_score × 0.30 +
  insight_depth × 0.30 +
  coherence × 0.25 +
  (1 - user_edit_ratio) × 0.15
```

**权重说明**：
- 可追溯性与洞见深度各占 30%，是核心质量指标
- 连贯性占 25%，确保流程产出一致
- 用户修改比例取反占 15%，用户修改少说明产出质量高

**综合评级**：
- 0.85-1.0：A（优秀）
- 0.70-0.84：B（良好）
- 0.55-0.69：C（一般）
- 0.40-0.54：D（需改进）
- < 0.40：F（需重构）

---

**override 场景修正**：若 note_final 以 override 模式生成（state.json 中含 override 字段、笔记带数据新鲜度水印），在报告评估概览中明确标注"基于过期上游数据评估"，且 overall_quality 不参与跨文章对比。

### Step 3: 判断是否触发进化建议

根据评估结果，判断是否在三个进化层面触发改进建议：

| 进化层 | 触发条件 | 优先级 |
|--------|---------|--------|
| **技术层** | 任一指标 < 0.5，或 trace.jsonl 中有 error/failure 记录 | 最高 |
| **流程效率层** | user_edit_ratio > 0.5，或 coherence < 0.7，或功能间存在重复操作 | 高 |
| **架构层** | overall_quality < 0.4，或用户深度反馈指出根本性问题 | 战略级 |

若 `auto_suggest = false`，跳过进化建议生成。

### Step 4: 生成 Optimization Report

**`.petrelpost/articles/[slug]/optimization_report.md`**：

```markdown
# 优化报告：{title}

> 生成时间：{ISO时间} | 版本：dr3-reading/1.0

---

## 评估概览

| 指标 | 评分 | 评级 |
|------|------|------|
| 可追溯性（traceability_score） | {score} | {grade} |
| 洞见深度（insight_depth） | {score} | {grade} |
| 逻辑连贯性（coherence） | {score} | {grade} |
| 用户修改比例（user_edit_ratio） | {ratio} | {interpretation} |
| **综合质量（overall_quality）** | **{score}** | **{grade}** |

{若 note_final 为 override 生成，此处标注：⚠️ 本次评估基于 override（过期上游）数据}

---

## 指标详情

### 可追溯性

- 总洞见数：{n}
- 有完整证据链：{n} 条
- 证据链缺失：{n} 条
- 评分：{score} / 1.0

{若存在证据链缺失，列出缺失洞见}

### 洞见深度

- 深刻洞见（≥0.8）：{n} 条
- 有深度洞见（0.6-0.79）：{n} 条
- 一般洞见（0.4-0.59）：{n} 条
- 浅层洞见（<0.4）：{n} 条
- 评分：{score} / 1.0

### 逻辑连贯性

- synthesis 内部自洽度：{score}
- critic 发现被回应比例：{ratio}（{n}/{n}）
- 重构与主张对应完整性：{score}
- 评分：{score} / 1.0

### 用户参与

- reconstructor 迭代轮数：{n}
- 用户修改次数：{n}
- 修改比例：{ratio}
- 解读：{interpretation}

---

## 流程执行统计

{从 trace.jsonl 提取}

| 功能 | 状态 | 备注 |
|------|------|------|
| importer | ✅ | {备注} |
| structured_extractor | ✅/⏭️ | {备注} |
| immersion_reader | ✅/⏭️ | {备注} |
| synthesis | ✅ | {备注} |
| critic | ✅/⏭️ | {备注} |
| reconstructor | ✅ | {备注} |
| note_generator | ✅/⚠️(override) | {备注} |
| evaluator | ✅ | 本功能 |

---

## 进化建议

{若未触发任何进化，显示"本次流程质量良好，无进化建议触发。"}

### 技术层进化

{若触发}

**触发原因**：{原因}

**改进建议**（针对本文重跑或后续文章）：
1. {建议1，如"以 `structured_extractor` 更高 depth 参数重跑"} — 预期效果：{效果}
2. {建议2} — 预期效果：{效果}

**对应调整**：下次调用 `{功能}` 时传入参数 `{参数名} = {值}`

---

### 流程效率层进化

{若触发}

**触发原因**：{原因}

**改进建议**：
1. {建议1，如"critic 切换为 targeted 模式减少全量批判"} — 预期效果：{效果}
2. {建议2} — 预期效果：{效果}

**对应调整**：后续文章调用时调整 `{功能}` 的 `{参数名}` 默认值

---

### 架构层进化

{若触发}

**触发原因**：{原因}

**改进建议**（涉及 skill 本身的修改）：
1. {建议1} — 影响范围：{范围}
2. {建议2} — 影响范围：{范围}

⚠️ 架构层进化需修改 skill 模板文件（`references/` 下对应文件），必须由用户确认并手动执行。

---

## 下一步

- 若有技术层/流程效率层建议：在下次调用对应功能时应用参数调整
- 若有架构层建议：与用户讨论确认后修改 skill 模板
- 若无建议：本次流程质量良好，可继续处理下一篇文章
```

### Step 5: 持久化输出

写入 **`.petrelpost/articles/[slug]/optimization_report.md`**。

**更新 state.json**（按 `references/protocol.md` 结构）：

```json
"optimization_report": {
  "status": "completed",
  "run_at": "[ISO时间]",
  "stale": false,
  "produced_by": { "module": "evaluator", "version": "dr3-reading/1.0" },
  "preview": "overall {grade} ({score}); traceability {score}, depth {score}, coherence {score}; evolution: {n} suggestions"
}
```

evaluator 是依赖链末端：重新执行本功能不产生任何级联标记。

### Step 6: 追加 trace + 输出摘要

追加 `trace.jsonl`：

```json
{"module": "evaluator", "timestamp": "[ISO时间]", "status": "success", "input": [".petrelpost/articles/[slug]/ (全流程)"], "metrics": {"traceability_score": 0.0, "insight_depth": 0.0, "coherence": 0.0, "user_edit_ratio": 0.0, "overall_quality": 0.0}, "evolution_triggered": {"technical": false, "efficiency": false, "architectural": false}}
```

输出摘要：

```
✅ evaluator 完成 | 综合质量：{grade}（{score}）

指标：
- 可追溯性：{score} | 洞见深度：{score} | 连贯性：{score}
- 用户修改比例：{ratio}

进化建议：
- 技术层：{n} 条 | 流程效率层：{n} 条 | 架构层：{n} 条
- ⚠️ 所有进化建议需用户确认后才应用

优化报告：.petrelpost/articles/[slug]/optimization_report.md
```

至此本篇文章全流程（A→B→C→D）闭环。展示完成状态与后续选项（处理下一篇 / 应用进化建议重跑某功能 / 结束会话）。

---

## 三层进化机制详细定义

skill 是静态模板，无法自我修改。三层进化在本 skill 中的落地方式：

### 技术层进化

**关注**：单篇文章处理质量
**触发条件**：
- 任一评估指标 < 0.5
- trace.jsonl 中存在 error / failure 记录

**典型改进**：
- 以调整后的参数重跑某功能（如 structured_extractor 提高深度）
- 补跑被跳过的可选功能（如 immersion_reader、critic）
- 证据链补全（针对缺失洞见重新对齐证据）

**执行方式**：用户确认后，以新参数重新调用对应功能（级联规则自动标记下游）。

---

### 流程效率层进化

**关注**：流程参数与调用策略优化
**触发条件**：
- user_edit_ratio > 0.5（重构方案与用户预期差距大）
- coherence < 0.7（功能间逻辑断裂）
- 用户反馈流程冗长

**典型改进**：
- 调整后续文章的默认参数（如 critic 的 critique_mode、synthesis 的融合策略）
- 精简调用路径（对熟悉领域的文章跳过可选功能）
- 沉浸阅读视角裁剪（减少不必要的 persona）

**执行方式**：用户在后续调用中显式传入调整后的参数；不改 skill 文件。

---

### 架构层进化

**关注**：skill 设计本身（功能划分、依赖关系、协议）
**触发条件**：
- overall_quality < 0.4（产出质量严重不足）
- 用户深度反馈指出根本性问题
- 长期运行发现的系统性缺陷

**典型改进**：
- 功能职责重新划分（如拆分/合并功能）
- 依赖矩阵调整（requires/enhanced_by 关系变更）
- state 协议升级（新增字段或状态）

**执行方式**：
1. 生成详细重构方案（在报告中呈现）
2. ⚠️ **必须**用户深度参与讨论与确认
3. 用户手动修改 `skills/dr3-reading/` 下对应文件
4. 更新 SKILL.md 中的版本号（如 dr3-reading/1.0 → 1.1）
5. 保留旧版本归档（复制到 skills 下的版本目录或版本控制）

---

## Human-in-the-Loop 规范

evaluator 的进化建议**不可自动执行**，必须遵循：

1. **提出建议**：报告中列出改进建议与预期效果
2. **等待确认**：用户逐条确认、修改或拒绝
3. **执行修改**：
   - 技术层/流程效率层 → 以新参数重新调用对应功能
   - 架构层 → 用户手动修改 skill 文件
4. **验证效果**：下次运行时对比指标验证进化效果

---

## 输出语言规则

报告面向用户阅读，**全中文**：
- 指标名称：中文（括注英文指标名，首次出现）
- 评级、解读、建议：中文
- 功能 ID、参数名、文件路径：英文（保持可操作性）

---

## 错误处理

| 场景 | 处理方式 |
|------|---------|
| 部分功能未运行 | 跳过该功能指标，标注 `module_skipped` |
| trace.jsonl 缺失 | 警告，基于已有输出评估 |
| 评估数据不足 | 对无法计算的指标标注 `insufficient_data`，不阻断 |
| note_final 为 override 生成 | 评估照常进行，报告标注"基于过期上游数据" |

---

## Prompt 指令体

```
你是 dr3-reading 的 evaluator 功能。

任务：评估全流程质量，生成优化报告，按需提出三层进化建议。

输入文件：
- .petrelpost/articles/[slug]/trace.jsonl（全流程追踪）
- .petrelpost/articles/[slug]/state.json（功能状态与参数）
- .petrelpost/articles/[slug]/ 下所有功能输出

配置：
- 自动建议：{auto_suggest}（默认 true）
- 评估指标：{metrics}（默认全部 5 项）

请严格按以下步骤执行：
1. 读取全流程输出与 trace.jsonl
2. 计算五项评估指标：
   - traceability_score：证据链完整性
   - insight_depth：洞见深度与价值
   - coherence：synthesis→critic→reconstructor→note 逻辑连贯
   - user_edit_ratio：reconstructor 用户修改比例
   - overall_quality：加权综合质量
3. 判断是否触发三层进化建议：
   - 技术层：指标 < 0.5 或流程错误
   - 流程效率层：user_edit_ratio > 0.5 或 coherence < 0.7
   - 架构层：overall_quality < 0.4 或用户深度反馈
4. 生成优化报告（.petrelpost/articles/[slug]/optimization_report.md）
5. 持久化：更新 state.json + 追加 trace.jsonl
6. 输出摘要 + 展示全流程闭环状态

⚠️ 进化建议不可自动执行，需用户逐条确认后才应用。

关键规则：
- 评估基于客观数据（trace.jsonl + state.json + 各 JSON 输出），非主观判断
- 进化建议必须具体可操作：技术层/流程效率层落到"调用哪个功能+调什么参数"，架构层落到"改哪个文件+改什么"
- 架构层进化必须标注"需用户手动修改 skill 文件"
- override 场景下标注"基于过期上游数据评估"
- 综合质量评分 = traceability×0.30 + depth×0.30 + coherence×0.25 + (1-edit_ratio)×0.15
- evaluator 是依赖链末端，重跑不产生级联

输出语言：中文（指标名首现括注英文）
```
