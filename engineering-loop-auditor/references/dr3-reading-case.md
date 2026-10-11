# Case #001 — dr3-reading 1.4 → 1.5

这是本 Skill 的第一个证据案例。它不是规范，而是用来检验工具能否从真实工程中重建闭环。

## 0. 初始问题

`dr3-reading` 的 Datafication 同时做 Structure Discovery 与 Relation Generation。实际输出中出现大量关系，但关系审计发现不少只是端点共现、方向错误或模型自行补出的解释。

最初最自然的解释是：

> Relation Generation 需要更好的语义校准。

## 1. 被忽略的 alternative

提出反事实问题：

> Structure Discovery 是否真的需要 Relation Generation？

于是形成至少三个假设：

- H1：Relation Generation 有必要，只是准确率不够。
- H2：Relation 有价值，但不应作为 Structure Discovery 的组成部分。
- H3：Relation 对当前 Structure Discovery 完全不必要。

## 2. 区分实验

Experiment 4 直接移除 Relation Generation，观察 Structure Discovery / Element Extraction 是否退化。

结果：结构和元素输出基本保持一致。

因此 H3 作为“总解决方案”不能成立，但 H2 获得强支持：

```text
Structure Discovery
        |
        +---- independent

Relation Extraction
        |
        +---- optional
```

## 3. 发现第二个问题

如果 Relation 不是 Structure 的完成条件，是否意味着 Relation 不值得保留？

Experiment 5 构造明确存在关系的文本，验证独立 Relation Extraction。

结果显示显式关系可以被恢复，但存在类型、范围、方向等问题。

于是问题再次变化：

> “如何生成更多关系？”
>
> → “如何忠实提取源文本已经表达的关系？”

## 4. Source-first

Experiment 6/7 与 schema review 继续区分：

```text
source expression
      ↓
faithful extraction
      ↓
source-level relation
      ↓
optional normalization
```

原因不是“schema 更完整”，而是 normalization 会在过早阶段覆盖原始语义。

## 5. Validation 也出错

第一次 1.5 validation 看似全部通过，但随后发现：

1. A 所谓 1.4 baseline 实际没有运行历史 Relation Generation；
2. audit 把两个独立 proposition 拼成了一条关系。

因此失败对象不是 1.5，而是 validation protocol。

修复后重新验证：

| Metric | A — 1.4 | B — 1.5 | C — Structure-only |
|---|---:|---:|---:|
| Structures | 3 | 3 | 3 |
| Elements | 12 | 12 | 12 |
| Relations generated | 11 | 37 | 0 |
| Relations retained | 0 | 37 | 0 |
| R0 | 0 | 37 | — |
| R2 | 8 | 0 | 0 |
| R3 | 3 | 0 | 0 |

最终 1.5 通过并进入 main。

## 6. 工程闭环中真正发生的变化

```text
异常输出
  ↓
“机制不够好？”
  ↓
提出“机制是否必要？”
  ↓
反事实实验
  ↓
重新划分职责边界
  ↓
保留真正有价值的能力
  ↓
source-first extraction
  ↓
严格 validation
  ↓
发现 validation defect
  ↓
修复 validation
  ↓
重新验证
  ↓
promote
```

## 7. 这个案例证明了什么

目前只证明：这种审计方式能忠实描述并指导这一次工程过程。

它还没有证明：

- 该方法适用于所有 Agent 工程；
- removal experiment 总是最佳实验；
- source-first 总是最佳数据化方式；
- validation-of-validation 可以无限扩展。

因此本案例是 **evidence for transferability**, 不是 transferability 已被证明。