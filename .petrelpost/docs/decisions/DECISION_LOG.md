# 决策历史日志

> 本文件由 `decisions.yaml` 渲染出的可读摘要。源真值为 `decisions.yaml`。

## DEC-20260905-01 · Datafication 从 Type-driven 转向 Structure-driven

**状态**: 已确认

**变更**: 以预定义结构类型作为主要发现入口 → 以结构发现为主要入口；结构类型仅作为事后描述/建议标签

**触发**: 发现并非所有文章都有完整概念系统，但文章仍可能包含局部可数据化结构。

**理由**: Datafication 应首先忠实发现文章中真实存在、具有独立结构性和复用价值的结构，而不是为了匹配预定义类型而创造结构。

---

## DEC-20260905-02 · Datafication 不等同于“正确的 Ontology”

**状态**: 已确认

**变更**: 将 Datafication 的结构化结果理解为本体化、正确的概念系统 → 将其视为对文章表达结构的忠实还原；仅在文章确实形成概念系统时描述其 conceptualization

**触发**: 区分“文章存在概念系统”和“所有文章都应被读成概念系统”。

**理由**: Datafication 首先记录作者实际表达的结构，而不是替作者建立一个被认为正确的世界模型。

---

## DEC-20260905-03 · 引入 Claim-level Evidence Validation

**状态**: 已确认

**变更**: 结构化结果只需具有可追溯 evidence → 每一个 structural claim 都必须检查 evidence 是否以相同语义强度支持该 claim

**核心原则**:

> Evidence exists ≠ Evidence supports claim

**触发**: Mimo 2.5 在测试中把“因素影响”升级成“独立/充分”，并建立原文未明确支持的结构关系。

---

## DEC-20260905-04 · Relation 不再是 Structure 的必需组成部分

**状态**: 已确认

**变更**: 将 Relation 作为 Structure 构建过程中的默认生成结果 → Relation 不是 Datafication Structure 的必需组成部分；仅当原文对关系本身提供独立且足够强的证据时才建立 Relation

**证据链**:

```text
Experiment 3
    ↓
11 relations generated
    ↓
Relation Audit
    ↓
11/11 rejected
    ↓
Experiment 4: no relation generation
    ↓
Structure / Elements unchanged
    ↓
Relation is optional
```

---

## DEC-20260906-01 · Relation Extraction 采用 Source-first

**状态**: 已确认

**变更**: 将 relation 抽取与 normalization 视为连续过程 → 先保留 source-level subject/predicate/object、direction、modality、qualification 与 evidence，再可选 normalization

**触发**: Experiments 5–7 显示 generation、extraction、normalization 是不同层次的问题。

**理由**: canonicalization 不应覆盖或强化原文表达；解释不能替换观察。

**证据**: Relation Schema Sanity Check 18/18 通过；主要剩余错误集中在 scope/subject，而非 direction/modality。

---

## DEC-20260906-02 · Validation Protocol 本身成为工程对象

**状态**: 已确认

**变更**: 把实现验证视为实现代码的单向检查 → 把 validation protocol 本身也作为待验证对象

**触发**: 初次 1.5 validation 发现 historical 1.4 baseline 实际没有执行 relation generation；独立 audit 还出现了把协调分句拼接成单一命题的方法错误。

**理由**: 如果 baseline、control 或命题边界不成立，即使最终指标全部通过，也可能没有真正测到目标。

**修复后的证据**:

```text
A: 1.4 historical path
  3 structures / 12 elements / 11 generated / 0 retained

B: 1.5 candidate
  3 structures / 12 elements / 37 retained

C: structure-only control
  3 structures / 12 elements / 0 relations

8 acceptance criteria → PASS
```

**后续**: validation protocol 在后续重要变更中也需要被复核。

---

## DEC-20260906-03 · 1.5 完成并进入 Observation / Usage

**状态**: 已确认

**变更**: 1.4 中 relation generation 与 Structure Discovery 的操作耦合 → 1.5 中 Structure Discovery 独立完成，Relation Extraction 作为 optional / relations_only 操作存在

**触发**: 修复 validation protocol 后，1.5 严格验证全部通过，并正式 merge 到 main。

**理由**: 当前职责边界已有实验和实现证据支持；在没有新证据时继续设计会转向过度优化。

**结论**:

> 当前阶段不是“停止研究”，而是把研究对象从设计稿转为真实使用产生的新证据。

---

## 本轮工程闭环的核心认识

```text
发现问题
  ↓
不要立即增强机制
  ↓
先判断机制是否必要
  ↓
建立独立证据与对照实验
  ↓
重新划分职责边界
  ↓
最小实现变化
  ↓
严格验证
  ↓
验证验证方法本身
  ↓
必要时修复 validation
  ↓
重新验证
  ↓
证据稳定 → promote
  ↓
observation / usage
```

> **现在停下来，是完成，而不是暂停。**
