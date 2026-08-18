---
name: decision-context
description: |
  从已有 Decision Artifacts 与当前任务中组装与当前问题真正相关的决策上下文。它是一个可被其他能力按需调用的 Context Capability，而不是 decision-archivist 的下游流水线步骤。
---

# decision-context

## Purpose

回答：**哪些已有的决策信息与当前任务相关？**

本 Skill 不负责创建或修改 canonical Decision；它负责从已有 Decision Artifacts 中检索、筛选并组装可消费的上下文。

## Capability contract

### Requires

- 可读取的 Decision Records

### Consumes

- 当前任务 / 当前对话
- Decision
- Decision Relation（如已有）
- Alternative（如已有）

### May invoke

- `decision-analyzer`：当仅靠直接检索无法判断候选 Decision 的相关性时，可按需请求分析结果。

### Produces

- `DecisionContext`：面向当前任务的相关 Decision、关系、选择点及必要 provenance 的组合结果。

## Constraints

- 不修改 `decisions.yaml` 的 canonical Decision 状态。
- 不把“检索到”误认为“相关”；相关性需要给出依据。
- 不要求预先存在 Decision Graph；可以从 Decision + Relation 临时构造所需关系视图。
- 被其他 Capability 调用时，只返回完成当前 purpose 所需的最小上下文。
