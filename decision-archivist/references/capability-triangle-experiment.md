# Capability Triangle Experiment v0

## Purpose

验证 `decision-archivist` 在 Decision Reconstruction 过程中对 `decision-context` / `decision-analyzer` 的按需协作。

## Scenario

假设三个不同时间的讨论：

- T1：决定采用方案 A。
- T2：出现新约束，讨论改为方案 B。
- T3：重新讨论 A 与 B，并出现“先保留 B，但以后可能恢复 A”的判断。

目标不是把三段文字简单整理成时间线，而是重建：

- Decision
- Alternative
- DecisionRelation
- 当前状态
- 未决 / 可重新考虑的选择

## Expected interaction

```text
Conversation fragments
        |
        v
decision-archivist
        |
        +-- needs historical relevance --> decision-context
        |                                     |
        |                                     +--> DecisionContext
        |
        +-- uncertain about lineage/state --> decision-analyzer
                                              |
                                              +--> DecisionAnalysis
        |
        v
Decision + Alternative + Relation
```

## Rules

1. Context / Analyzer 的结果只能作为 Archivist 的分析输入，不能直接改变 canonical Decision。
2. Analyzer 可以指出“可能是同一 lineage / 可能冲突”，但不能把推断升级成历史事实。
3. Archivist 最终负责 Decision 的 canonical 写入。
4. 如果一次任务不需要 Context / Analyzer，则不调用它们。
5. 实验重点记录“什么时候调用了谁，以及调用结果改变了哪个判断”，而不是追求调用次数。

## Success criteria

实验完成后，应能回答：

- Alternative 是否需要成为独立 Artifact？
- Relation 是否需要成为独立 Artifact？
- Context / Analysis 是否应保持过程性结果？
- 哪些协作关系应该进入 Capability contract？
- 是否出现需要实体化 `DecisionGraph` 的真实需求？
