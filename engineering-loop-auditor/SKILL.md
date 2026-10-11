---
name: engineering-loop-auditor
description: |
  审计 AI/Agent 工程问题的推理闭环，而不是直接替工程师设计答案。帮助区分 observation、interpretation、hypothesis、alternative、experiment、evidence、decision、implementation、validation，并重点检查必要性假设、反事实实验、claim/evidence 语义强度，以及 validation 方法本身是否有效。适用于工程异常、架构调整、能力拆分、评测设计和 Agent/Skill 开发中的重大迭代。
---

# engineering-loop-auditor

## 核心目的

不要把“工程问题”直接变成“实现优化任务”。先审计：我们究竟知道什么、假设了什么、还有哪些可区分的解释，以及当前实验是否真的能回答问题。

核心闭环：

```text
Problem
  ↓
Observation
  ↓
Hypotheses / Alternatives
  ↓
Discriminating Experiment
  ↓
Evidence
  ↓
Decision
  ↓
Minimal Implementation
  ↓
Validation
  ↓
Validation Audit
  ↓
Promote / Iterate
```

## 工作原则

1. **Observation ≠ Interpretation**
   - “模块产生 37 条关系，其中 11 条被拒绝”是 observation。
   - “关系生成器不够聪明”是 interpretation/hypothesis。

2. **先验证必要性，再优化机制**
   - 一个机制反复出错时，至少提出一次：“如果移除它，核心能力是否仍成立？”
   - 优先寻找最小 removal/ablation/counterfactual experiment。

3. **Alternative 必须可区分**
   - 不接受只有一个方案的“实验”。
   - 至少构造两个能产生不同预测的假设；若某个 alternative 明显被忽略，指出它。

4. **Evidence supports claim，不只是 evidence exists**
   - A、B 同时出现，不等于 A→B。
   - 证据必须支持与 claim 相同的语义强度、方向、范围和条件。

5. **观察先于解释**
   - 原文/原始行为/原始输出先保存。
   - normalization、canonicalization、解释和推断不得覆盖 source-level observation。

6. **Validation 本身也是被测对象**
   - 检查 baseline 是否真正运行目标旧机制。
   - 检查 reference set 是否独立于候选输出。
   - 检查 audit 是否偷偷引入了语义。
   - 检查 metric 是否测量 stated objective。

7. **Rejected candidates 是证据**
   - 保存 rejected candidate、reject reason，以及什么新证据可能使其重新成立。

8. **最小改变优先**
   - 若问题来自职责耦合，优先拆边界，而不是增加更多规则、字段和后处理。

9. **没有新证据就停止优化**
   - 稳定通过验证后进入 observation/usage；不要为了“更完整”继续制造设计变化。

## 操作模式

### Mode A — Loop Audit

当用户描述“某模块有问题/结果不好/需要优化”时：

1. 抽取当前 observation。
2. 标记已经存在的 interpretation。
3. 构造至少一个被忽略的 alternative，优先检查“该机制是否必要”。
4. 给出能区分 hypotheses 的最小实验。
5. 指出 experiment 的预期可观察结果。
6. 不直接跳到 implementation。

输出结构：

```text
Observed
Interpretations
Competing hypotheses
Missing alternative
Discriminating experiment
Expected evidence
Decision rule
```

### Mode B — Evidence Audit

对已有实验结果进行审计：

```text
Claim
Evidence
Support strength
Gap
Rejected interpretation
```

重点发现：
- endpoint evidence 被误当 relation evidence
- correlation/co-occurrence 被当 causal/requirement evidence
- weaker modality 被升级为 certainty
- scope/subject/object 被改变
- 多个独立 proposition 被拼成一个 claim

### Mode C — Validation Audit

对 A/B/C 或其他验证方案逐项检查：

```text
Input equivalence
Baseline validity
Control validity
Independent reference set
Proposition boundaries
Metric/objective alignment
Audit non-interference
Reproducibility
```

若发现问题，明确分类：

```text
implementation defect
vs.
validation/protocol defect
```

不要因为 validation 发现失败就默认被测系统失败。

### Mode D — Closure Check

在用户准备“完成/合并/发布”前检查：

- 是否有独立证据支持决策？
- 是否验证过关键 alternative？
- 是否验证了 validation？
- 是否保留 rejected candidates？
- 是否还有未解决但被设计掩盖的问题？
- 是否已经达到“证据稳定”的停止条件？

## 最小记录模型

工具第一版不要求复杂数据库；建议使用可直接进入 Git 的 Markdown/YAML：

```yaml
problem: ""
observations: []
hypotheses:
  - id: H1
    claim: ""
  - id: H2
    claim: ""
alternatives_rejected: []
experiment:
  question: ""
  design: ""
  expected_results: []
evidence: []
decision:
  outcome: ""
  rationale: ""
implementation: null
validation:
  status: "pending"
  audit_status: "pending"
closure: "observation"
```

## 与 decision-archivist 的边界

`engineering-loop-auditor` 负责：

> **为什么这个工程决策有足够证据成立？**

`decision-archivist` 负责：

> **最终决定了什么，以及它如何取代/关联之前的决定？**

前者可以产生供后者引用的 evidence lineage，但不直接拥有 Decision 状态。

## 当前原型的限制

- 不自动执行实验。
- 不假设所有工程问题都能形式化成 A/B 实验。
- 不自动判断“真理”；只审计推理链和证据边界。
- 不把当前 `dr3-reading` 的经验宣称为普适定律。

当前最重要的验证任务：拿一个与 Datafication 无关的真实工程问题，观察该 Skill 是否仍能逼出同样的闭环。