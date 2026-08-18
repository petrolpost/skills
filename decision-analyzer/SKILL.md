---
name: decision-analyzer
description: |
  对 Decision、Alternative 与 Decision Relation 进行状态、关系、冲突和影响分析，为其他能力提供可消费的 Decision Analysis。它不是 Decision 的 canonical owner。
---

# decision-analyzer

## Purpose

回答：**已有的 Decision 结构说明了什么？**

本 Skill 是分析能力，不负责保存 canonical Decision，也不负责替用户做最终选择。

## Capability contract

### Requires

- 至少一个可分析的 Decision Artifact

### Consumes

- Decision
- Alternative（如已有）
- Decision Relation（如已有）
- DecisionContext（如调用方提供）

### May invoke

- `decision-context`：当分析需要当前问题相关的历史决策上下文时，可按需调用。

### Produces

- `DecisionAnalysis`，可包含：
  - lineage / relationship interpretation
  - conflict candidates
  - state implications
  - impact candidates
  - reconsideration candidates

## Constraints

- 不直接修改 canonical Decision。
- 分析结论与 Decision 本身分离；不得把分析推断写成历史事实。
- 不要求预先存在 `DecisionGraph` 文件；必要时可从 Decision + Relation 临时构造图。
- 分析结果应保留依据，避免把“可能关系”表述成确定关系。
