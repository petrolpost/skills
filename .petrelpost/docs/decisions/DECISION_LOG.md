# 决策历史日志

> 本文件由 `decisions.yaml` 渲染出的可读摘要。源真值为 `decisions.yaml`。

## DEC-20260905-01 · Datafication 从 Type-driven 转向 Structure-driven

**状态**: 已确认

**变更**: 以预定义结构类型作为主要发现入口 → 以结构发现为主要入口；结构类型仅作为事后描述/建议标签

**触发**: 发现并非所有文章都有完整概念系统，但文章仍可能包含局部可数据化结构。

**理由**: Datafication 应首先忠实发现文章中真实存在、具有独立结构性和复用价值的结构，而不是为了匹配预定义类型而创造结构。

**关联**: `dr3-reading` · `datafication`

---

## DEC-20260905-02 · Datafication 不等同于“正确的 Ontology”

**状态**: 已确认

**变更**: 将 Datafication 的结构化结果理解为本体化、正确的概念系统 → 将其视为对文章表达结构的忠实还原；仅在文章确实形成概念系统时描述其 conceptualization

**触发**: 区分“文章存在概念系统”和“所有文章都应被读成概念系统”。

**理由**: Datafication 首先记录作者实际表达的结构，而不是替作者建立一个被认为正确的世界模型。

**关联**: `dr3-reading` · `datafication` · `ontology`

---

## DEC-20260905-03 · 引入 Claim-level Evidence Validation

**状态**: 已确认

**变更**: 结构化结果只需具有可追溯 evidence → 每一个 structural claim 都必须检查 evidence 是否以相同语义强度支持该 claim

**核心原则**:

> Evidence exists ≠ Evidence supports claim

**触发**: Mimo 2.5 在测试中把“因素影响”升级成“独立/充分”，并建立原文未明确支持的结构关系。

**理由**: 仅有 evidence 引用并不能保证 evidence 真正支持 claim 的语义强度。

**关联**: `dr3-reading` · `datafication`

---

## DEC-20260905-04 · Relation 不再是 Structure 的必需组成部分

**状态**: 已确认

**变更**: 将 Relation 作为 Structure 构建过程中的默认生成结果 → Relation 不是 Datafication Structure 的必需组成部分；仅当原文对关系本身提供独立且足够强的证据时才建立 Relation

**触发**: Experiment 3 的 relation-level audit 将生成的 11 条 relation 全部判定为缺乏独立文本支持；Experiment 4 关闭 relation generation 后，Structure 与 Element 等核心 Datafication 结果保持不变。

**理由**: Experiment 3 的 11 条 relation 经独立审查后全部删除，而 Experiment 4 直接关闭 relation generation 后，4 个 structures、16 个 elements、section scope、1 central + 3 supporting importance、4 explicit origins 以及 5 个 rejected candidates 均保持不变。这表明 relation generation 并非 Structure Discovery 的必要中间步骤，并支持将 relation 从结构发现的必需输出中分离出来。

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

**关联**: `dr3-reading` · `datafication` · `DEC-20260905-03`

**后续**:
- [ ] 保持当前 1.4 canonical specification 不立即修改；观察后续实验是否需要形成 1.5 规范变更
- [ ] 继续验证：对于原文明确表达关系的文章，是否需要独立的 Relation Extraction 阶段，以及其证据阈值如何定义
