# Decision Capability Triangle — v0

这是 `decision-archivist`、`decision-context`、`decision-analyzer` 的最小协作原型。

## 目标

验证三件事：

1. `decision-archivist` 能否从跨对话材料中重建 Decision，并保留 Alternative / Relation。
2. Archivist 在重建过程中能否按需消费 Context / Analysis，而不形成硬耦合。
3. 哪些中间结果值得成为稳定 Artifact，哪些只应保持为过程性结果。

## Capability contract

| Capability | Requires | Consumes | May invoke | Produces |
|---|---|---|---|---|
| decision-archivist | — | conversation, existing decisions | context, analyzer | Decision, Alternative, DecisionRelation |
| decision-context | Decision data | current task, Decision, Relation, Alternative | analyzer | DecisionContext |
| decision-analyzer | Decision | Decision, Alternative, Relation, Context | context | DecisionAnalysis |

## 三种关系

- `requires`：能力成立的必要条件。
- `consumes`：执行过程中可以读取/利用的 Artifact。
- `may_invoke`：过程性交叉协作，不等于架构依赖。

## 当前 Artifact 判断

### Canonical candidates

- `Decision`
- `Alternative`
- `DecisionRelation`

### Process / derived results

- `DecisionContext`
- `DecisionAnalysis`

### 暂不实体化

- `DecisionGraph`

`DecisionGraph` 当前可以由 `Decision + DecisionRelation` 在需要时临时构造。只有真实消费者要求稳定图结构时，再考虑把它提升为正式 Artifact。

## 第一实验

使用一个跨对话 Decision 重建案例：同一个方案在多个对话中经历 A → B → A → B 的变化。

验证：

- 这是多个 Decision 还是一个 evolving Decision？
- 哪些是 Alternative？
- 哪些 Relation 可以被确认？
- Archivist 什么时候需要 Context？
- Archivist 什么时候需要 Analyzer？
- Analyzer / Context 各自需要哪些最小 Artifact？

## 非目标

本原型暂不引入：

- 通用 orchestration framework
- 完整 Decision Graph schema
- 自动决策
- 复杂 Registry 扩展
- 跨 Skill shared SDK
