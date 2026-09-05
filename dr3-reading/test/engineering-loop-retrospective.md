# dr3-reading 1.5：相对完整的工程闭环复盘

## 1. 为什么这次值得单独总结

这次工作的直接产物是 `dr3-reading/1.5`，但真正值得保留的成果不是某一个字段或某一条 Relation Extraction 规则，而是一条相对完整的、可以迁移到其他 Agent / Skill 工程的反馈闭环：

```text
已有实现
  ↓
真实样本实验
  ↓
发现输出异常
  ↓
建立独立审计标准
  ↓
区分“实现问题”与“设计问题”
  ↓
用反事实/对照实验验证是否真的需要该机制
  ↓
重新划分职责边界
  ↓
提出最小架构变化
  ↓
实现
  ↓
严格验证
  ↓
发现“验证方法本身”存在缺陷
  ↓
修复 validation protocol
  ↓
重新验证
  ↓
进入 main
  ↓
停止过度优化，进入 observation / usage
```

这与通常的“需求 → 设计 → 实现 → 测试”不同。它形成了至少两层反馈：

1. **系统反馈**：实现是否符合设计目标；
2. **认识论反馈**：我们用来判断系统是否正确的方法本身是否成立。

第二层是这次最重要的发现。

---

## 2. 第一层发现：输出错误不一定意味着实现需要修补

最初的问题来自 Relation generation。

Experiment 3 中，1.4 生成了 11 条 relation。独立审计后 11 条全部删除。错误并非简单的“模型漏抽了某些关系”，而是模型主动完成了语义连接：

- 两个 endpoint 同时出现，被连接成 relation；
- 多个因素同时出现，被强化为独立/充分关系；
- 叙述顺序被解释成因果或时间关系；
- 相邻或协调分句被组合成原文不存在的单一命题。

关键转折不是“把 relation prompt 写得更好”，而是问：

> **Relation generation 是 Structure Discovery 的必要步骤吗？**

Experiment 4 关闭 relation generation 后，Structure / Elements / Scope / Importance / Origin / Rejected candidates 均保持不变。

因此得到的不是一个局部修补，而是职责重新划分：

```text
Structure Discovery
    ↓
独立完成结构发现

Relation Extraction
    ↓
可选、独立、证据驱动
```

这是一种非常普遍的工程判断方式：

> 当某个中间机制持续产生错误时，不要立即问“怎样让它更聪明”；先问“系统是否真的需要它”。

---

## 3. 第二层发现：需要区分 Generation、Extraction 与 Normalization

后续 Experiments 5–7 进一步证明，Relation 问题不是一个单一问题。

至少存在三层：

```text
Generation
  ↓
“这里是否应该存在一条 relation？”

Extraction
  ↓
“原文究竟表达了什么 relation？”

Normalization
  ↓
“能否把 source expression 映射成 canonical relation type？”
```

如果把三者揉成一个步骤，错误会互相污染。

例如：

```text
A helps define B.
```

如果一开始就 canonicalize 成 `A defines B`，normalization 同时改变了 extraction 的结果。

因此形成了 source-first 原则：

```text
Source sentence
      ↓
Faithful extraction
      ↓
Source-level Relation
      ↓
Optional normalization
```

这不是 Relation Extraction 的局部技巧，而是一个一般性的知识工程原则：

> **先保存观察到的东西，再保存对观察结果的解释。**

解释不能覆盖观察。

---

## 4. 第三层发现：Evidence 有两种完全不同的含义

这次逐渐形成了一个很重要的区分：

```text
Evidence exists
      ≠
Evidence supports claim
```

“原文里有 A 和 B”并不意味着“原文支持 A 与 B 存在某种关系”。

同样：

- 多个因素影响 X ≠ 多个独立因素；
- 两个端点 ≠ 中间没有其他状态；
- 列出若干类别 ≠ 类别穷尽；
- 叙述先后 ≠ 因果先后；
- 共现 ≠ requires / causes；
- 有相关句子 ≠ 当前写下的 stronger claim 被支持。

因此 evidence 不应只是“引用来源”的元数据，而应该成为**claim-level validation 的输入**。

这可以迁移到任何 LLM 数据化工作：

```text
Claim
  ↓
What semantic strength does this claim assert?
  ↓
Evidence
  ↓
Does the evidence support that same strength?
```

如果答案是否定的，就必须：

1. 降低 claim 强度；
2. 改成 reconstructed；或
3. 删除。

---

## 5. 第四层发现：Validation 不是最后一道闸门，而是工程对象

这是本轮最值得推广的部分。

第一次 implementation validation 看起来全部通过，但深入检查后发现两个问题：

### 5.1 Baseline 不成立

所谓 1.4 baseline 实际运行时关闭了 relation generation，因此得到的“0 relations”根本不能证明 1.5 消除了 1.4 的 over-generation。

### 5.2 Audit 自身制造了错误

独立 relation audit 把协调分句中的两个独立命题拼成了一个 relation：

```text
The customer journey is broken
and
experience suffers.
```

不能因为共享上下文，就把它们组合成：

```text
customer journey --is broken--> experience
```

所以出现了一个非常重要的工程原则：

> **测试发现的错误，不一定是被测试系统的错误；也可能是测试方法的错误。**

因此必须区分：

```text
Implementation defect
        vs.
Validation / protocol defect
```

这意味着 validation protocol 本身也需要：

- 明确输入条件；
- 明确 baseline；
- 明确 control；
- 明确 reference set；
- 明确判定标准；
- 检查 proposition boundary；
- 检查 audit 是否引入额外语义。

换句话说：

> **验证系统必须先证明自己真的在测想测的东西。**

---

## 6. 第五层发现：对照实验比“继续优化”更有价值

本轮最有效的实验不是把 prompt 调得越来越复杂，而是构造了不同的条件：

```text
A: 历史 1.4 路径
B: 1.5 Relation Extraction
C: Structure-only control
```

其中 C 特别重要。

如果：

```text
B = Structure + Relation
C = Structure only
```

而 B 与 C 的 Structure 结果保持一致，那么就获得了一个非常直接的证据：

> Relation 不是 Structure Discovery 的必要条件。

这种实验思路可以广泛迁移：

> **不要只测试“加入一个机制之后系统变好了没有”，还要测试“去掉这个机制以后核心能力是否仍然成立”。**

后者更接近反事实检验。

---

## 7. 第六层发现：Rejected candidates 是工程证据，而不是垃圾

本轮多次保留 rejected candidates：

- 看起来像结构、实际只是列表；
- 看起来像关系、实际只是 endpoint 共现；
- 看起来像因果、实际只是叙述顺序；
- 看起来像完整框架、实际没有作者级支持。

这些 rejection 记录的价值在于：

```text
Positive examples
      +
Rejected candidates
      ↓
真正的 decision boundary
```

如果只保存“最后留下了什么”，以后很难知道为什么没有留下其他候选。

因此，一个成熟的 Agent/AI 工程实验记录，不应该只有：

```text
accepted output
```

还应该有：

```text
accepted
rejected
why rejected
what evidence would have changed the decision
```

这与 Decision Archivist 中把 rejected alternatives 作为重要对象的方向是一致的。

---

## 8. 第七层发现：最小改变往往来自更准确的边界，而不是更复杂的机制

最终 1.5 并没有重新设计 Datafication，也没有建立 Relation Ontology。

实际改变非常小：

```text
1.4
Structure Discovery
  └── relation generation operationally coupled

1.5
Structure Discovery
  └── independent

Relation Extraction
  └── optional
       └── source-first
            └── optional normalization
```

这体现一种重要的工程演进模式：

> **当问题来自职责耦合时，最优修复往往是拆边界，而不是增加能力。**

---

## 9. 一个更一般的闭环模型

从这次工作中，可以抽象出一个适用于 Agent / Skill 工程的循环：

```text
        ┌──────────────────────┐
        │      Current System  │
        └──────────┬───────────┘
                   ↓
             Real Evidence
                   ↓
          ┌─────────────────┐
          │ Observe Failure │
          └────────┬────────┘
                   ↓
          Separate Hypotheses
          ┌────────┼───────────┐
          ↓        ↓           ↓
      Design?   Impl.?     Validation?
          └────────┼───────────┘
                   ↓
             Minimal Change
                   ↓
              Controlled Test
                   ↓
          ┌─────────────────┐
          │ Validate Result │
          └────────┬────────┘
                   ↓
        Validate Validation
                   │
              if necessary
                   ↓
             Repair Method
                   ↓
             Re-run Test
                   ↓
             Evidence Stable?
              /           \
            yes            no
             ↓              ↓
       Promote / Use    Next iteration
             ↓
        Observation phase
```

这里有一个关键递归：

> **验证系统的过程，也应该受到被验证系统同样的证据约束。**

---

## 10. 什么具有普遍意义，什么暂时不能泛化

### 已有较强证据支持的原则

1. **不要因为一个机制产生错误，就默认需要增强这个机制。**先判断它是不是必要。
2. **Structure 与 Relation 等不同语义任务应该保持可分离性。**
3. **Source-level observation 应先于 normalization / interpretation。**
4. **Evidence 的存在不等于 Evidence 支持 Claim。**
5. **对照/去除机制的实验可以验证某机制是否必要。**
6. **Validation protocol 本身也需要接受验证。**
7. **Implementation defect 与 validation defect 必须分开定位。**
8. **Rejected candidates 可以帮助定义真正的 decision boundary。**
9. **职责边界变清楚后，往往可以用很小的实现变化解决问题。**
10. **没有新证据时停止继续设计，是工程闭环的一部分，而不是工作的失败。**

### 目前仍应保持为假设的部分

1. Source-first 是否适用于所有类型的 AI extraction，而不仅是 Relation Extraction。
2. 当前 Relation schema 是否已经足够支撑更复杂的 nested / n-ary relations。
3. 当前 proposition-boundary audit 是否可以稳定自动化。
4. 这种 validation-of-validation 模式在大型 Agent 系统中如何规模化。
5. Rejected candidates 应该在什么粒度上长期保存。

这些不应该现在继续“完善”，而应该等待真实使用产生新的 evidence。

---

## 11. 最终工程结论

这次真正完成的不是“把 Datafication 从 1.4 改成 1.5”。

完成的是一个更完整的工程认识循环：

> **我们不再只要求系统给出结果，而开始要求系统能够说明结果为什么成立；不只验证结果，也验证验证结果的方法；当发现机制本身并非必要时，优先拆除耦合而不是继续堆叠能力；最终在证据足够时停止，而不是为了设计上的完美继续迭代。**

因此，`dr3-reading 1.5` 现在适合进入 observation / usage 阶段。

下一次迭代的触发条件不应该是“还能不能优化”，而应该是：

> **真实使用是否产生了足以改变当前边界的新证据。**

这也是本次闭环最后一个工程决策：

**现在停下来，是因为当前证据已经足够，而不是因为没有东西可以继续改。**
