# Experiment 5 — Explicit Relation Datafication

> 模块: datafication | 版本: dr3-reading/1.4-experiment-5
> 实验约束: Relations are optional. Generate a Relation only when the source independently provides evidence for the relation itself.

## 发现摘要

| 指标 | 数值 |
|------|------|
| 发现结构数 | 5 |
| 显式结构 | 5 |
| 重构结构 | 0 |
| 推断结构 | 0 |
| 拒绝候选 | 0 |
| 范围分布 | local: 0, section: 3, article: 2 |
| 重要性分布 | central: 2, supporting: 3 |

---

## 结构对象

### DS-01: 因果理解的定义与功能

```yaml
id: DS-01
name: "因果理解的定义与功能"
scope:
  type: article
  paragraphs: [1, 2, 3, 4]
importance:
  role: central
origin: explicit
status: author_asserted
subject: "因果理解是什么以及它如何使人类能够理解世界"
structure:
  elements:
    - id: E1-1
      name: "因果理解能力"
      type: cognitive_capacity
      description: "思考事物如何相互影响和作用的认知能力"
      origin: explicit
      evidence:
        - paragraphs: [1]
          quote: "Causal understanding is the cognitive capacity that enables you to think about how things affect and influence each other"
    - id: E1-2
      name: "因果概念"
      type: concept
      description: "making, doing, generating, producing, causing等概念"
      origin: explicit
      evidence:
        - paragraphs: [1]
          quote: "It is your concept of making, doing, generating and producing – of causing – that allows you to grasp..."
    - id: E1-3
      name: "因果关系实例"
      type: examples
      description: "月球导致潮汐、病毒使人生病、关税改变贸易等"
      origin: explicit
      evidence:
        - paragraphs: [1]
          quote: "how the Moon causes the tides, how a virus makes you sick, why tariffs change international trade"
    - id: E1-4
      name: "因果理解的基础作用"
      type: foundation
      description: "因果理解是所有why, how, because, what if思想的基础"
      origin: explicit
      evidence:
        - paragraphs: [1]
          quote: "Causal understanding is the foundation of all thoughts why, how, because, and what if"
  relations:
    - from: E1-1
      relation: enables
      to: E1-3
      origin: explicit
      evidence:
        - paragraphs: [1]
          quote: "It is your concept of making, doing, generating and producing – of causing – that allows you to grasp how the Moon causes the tides, how a virus makes you sick"
    - from: E1-1
      relation: is_foundation_of
      to: E1-4
      origin: explicit
      evidence:
        - paragraphs: [1]
          quote: "Causal understanding is the foundation of all thoughts why, how, because, and what if"
```

---

### DS-02: 干预主义框架

```yaml
id: DS-02
name: "干预主义框架"
scope:
  type: section
  paragraphs: [7, 8, 9, 10]
importance:
  role: supporting
origin: explicit
status: author_asserted
subject: "如何通过干预定义因果关系的哲学框架"
structure:
  elements:
    - id: E2-1
      name: "干预主义"
      type: framework
      description: "定义因果关系的哲学框架"
      origin: explicit
      evidence:
        - paragraphs: [7]
          quote: "Psychological research on causal understanding is widely guided by a framework called 'interventionism'"
    - id: E2-2
      name: "变量与值"
      type: concept
      description: "原因和结果是具有可变值的变量"
      origin: explicit
      evidence:
        - paragraphs: [8]
          quote: "causes and effects are thought of as variables with values that can change"
    - id: E2-3
      name: "干预"
      type: mechanism
      description: "通过有针对性的改变来定义因果关系"
      origin: explicit
      evidence:
        - paragraphs: [8]
          quote: "a causal relation is defined in terms of interventions – targeted changes"
    - id: E2-4
      name: "差异制造"
      type: definition
      description: "原因是使其他事物产生差异的东西"
      origin: explicit
      evidence:
        - paragraphs: [9]
          quote: "a 'cause' is something that makes a difference to something else: wiggle the cause, and the effect wiggles, too"
  relations:
    - from: E2-1
      relation: uses
      to: E2-2
      origin: explicit
      evidence:
        - paragraphs: [8]
          quote: "causes and effects are thought of as variables with values that can change"
    - from: E2-1
      relation: defines_through
      to: E2-3
      origin: explicit
      evidence:
        - paragraphs: [8]
          quote: "a causal relation is defined in terms of interventions – targeted changes"
    - from: E2-4
      relation: is_also_known_as
      to: E2-1
      origin: explicit
      evidence:
        - paragraphs: [9]
          quote: "This interventionist way of defining causation is often referred to as 'difference-making'"
```

---

### DS-03: 统计学习与干预学习

```yaml
id: DS-03
name: "统计学习与干预学习"
scope:
  type: section
  paragraphs: [9, 10, 11, 12]
importance:
  role: supporting
origin: explicit
status: author_asserted
subject: "两种学习方式的区别：统计学习与干预学习"
structure:
  elements:
    - id: E3-1
      name: "统计学习"
      type: learning_type
      description: "被动和自动地提取模式，产生统计知识和预测能力"
      origin: explicit
      evidence:
        - paragraphs: [9]
          quote: "This is statistical (or associative) learning, and it results in statistical knowledge – knowledge of correlations"
    - id: E3-2
      name: "干预学习"
      type: learning_type
      description: "通过实践学习，产生因果知识和控制能力"
      origin: explicit
      evidence:
        - paragraphs: [9]
          quote: "Interventional learning, by contrast, is active learning – learning by doing. It results in causal knowledge, and it gives us the power to control"
  relations:
    - from: E3-1
      relation: contrasts_with
      to: E3-2
      origin: explicit
      evidence:
        - paragraphs: [9]
          quote: "Interventional learning, by contrast, is active learning"
```

---

### DS-04: 因果理解的发展轨迹

```yaml
id: DS-04
name: "因果理解的发展轨迹"
scope:
  type: section
  paragraphs: [12, 13, 14, 15, 16, 17, 18]
importance:
  role: central
origin: explicit
status: author_asserted
subject: "因果理解如何在儿童期发展"
structure:
  elements:
    - id: E4-1
      name: "点做"
      type: concept
      description: "第一人称的、目标导向的行动视角"
      origin: explicit
      evidence:
        - paragraphs: [12]
          quote: "I'm going to call this: your point of do"
    - id: E4-2
      name: "我因"
      type: developmental_stage
      description: "婴儿期的自我中心因果理解"
      origin: explicit
      evidence:
        - paragraphs: [13]
          quote: "Nonhuman animals' causal understanding is largely egocentric. It is 'I-', or 'me-causation'"
    - id: E4-3
      name: "他们因"
      type: developmental_stage
      description: "理解他人行动的因果能力"
      origin: explicit
      evidence:
        - paragraphs: [14]
          quote: "infants seem to have not only first-personal, 'me-causal' understanding, but also third-personal, 'they-causal' understanding"
    - id: E4-4
      name: "它因"
      type: developmental_stage
      description: "客观的因果理解，因果性被视为世界本身的一部分"
      origin: explicit
      evidence:
        - paragraphs: [17]
          quote: "the shift from a causal understanding grounded in actions to an objective one where causality is seen as part of the world itself"
  relations:
    - from: E4-1
      relation: precedes
      to: E4-2
      origin: explicit
      evidence:
        - paragraphs: [12, 13]
          quote: "The development of causal understanding depends precisely on this 'insider perspective' on your own actions"
    - from: E4-2
      relation: precedes
      to: E4-3
      origin: explicit
      evidence:
        - paragraphs: [13, 14]
          quote: "By three months old, infants seem to have not only first-personal, 'me-causal' understanding, but also third-personal, 'they-causal' understanding"
    - from: E4-3
      relation: precedes
      to: E4-4
      origin: explicit
      evidence:
        - paragraphs: [16, 17]
          quote: "Until about age four, children's causal understanding remains tightly tied to their own and others' goal-directed actions"
```

---

### DS-05: 因果理解的应用与后果

```yaml
id: DS-05
name: "因果理解的应用与后果"
scope:
  type: article
  paragraphs: [23, 24, 25, 26]
importance:
  role: supporting
origin: explicit
status: author_asserted
subject: "因果理解在科学、工程和社会中的应用及其双面后果"
structure:
  elements:
    - id: E5-1
      name: "科学与工程基础"
      type: application
      description: "因果理解是科学和工程的基础"
      origin: explicit
      evidence:
        - paragraphs: [23]
          quote: "Our causal understanding is the foundation of science and engineering"
    - id: E5-2
      name: "社会技术基础"
      type: application
      description: "因果理解是道德责任、贸易协定和交通法规等社会技术的基础"
      origin: explicit
      evidence:
        - paragraphs: [23]
          quote: "It's the basis of social technologies like moral accountability, trade agreements and traffic laws"
    - id: E5-3
      name: "黑暗面"
      type: consequence
      description: "因果理解也被用于操纵和破坏"
      origin: explicit
      evidence:
        - paragraphs: [23]
          quote: "But it can be a dark magic, too. Our immense power to manipulate our physical and social environments has produced the industrial pollutants transforming the climate"
    - id: E5-4
      name: "自我干预"
      type: possibility
      description: "我们可以用因果理解来干预自己的行为"
      origin: explicit
      evidence:
        - paragraphs: [24]
          quote: "I think we can use our causal understanding to intervene in our own behaviour"
  relations:
    - from: E5-1
      relation: has_enabled
      to: E5-2
      origin: explicit
      evidence:
        - paragraphs: [23]
          quote: "Our causal understanding is the foundation of science and engineering. It has given us plumbing, electricity and sanitation... It's the basis of social technologies like moral accountability, trade agreements and traffic laws"
    - from: E5-4
      relation: uses
      to: E1-1
      origin: explicit
      evidence:
        - paragraphs: [24]
          quote: "we can use our causal understanding to intervene in our own behaviour"
```

---

## 结构间关系

```yaml
inter_structure_relations:
  - from: DS-01
    relation: provides_foundation_for
    to: DS-04
    origin: explicit
    evidence:
      - paragraphs: [1, 12]
        quote: "Causal understanding is the cognitive capacity... The development of causal understanding depends precisely on this 'insider perspective'"
  - from: DS-02
    relation: explains
    to: DS-01
    origin: explicit
    evidence:
      - paragraphs: [7, 1]
        quote: "Psychological research on causal understanding is widely guided by a framework called 'interventionism'... Interventionism offers a neat way of defining 'cause'"
  - from: DS-04
    relation: results_in
    to: DS-05
    origin: explicit
    evidence:
      - paragraphs: [17, 23]
        quote: "the shift from a causal understanding grounded in actions to an objective one... Our causal understanding is the foundation of science and engineering"
```

---

## 概念化检测

```yaml
conceptualization:
  detected: true
  scope: article
  coherence: high
  description: "文章围绕'因果理解'这一核心概念构建，从定义、框架、发展轨迹到应用形成完整的概念体系"
```
