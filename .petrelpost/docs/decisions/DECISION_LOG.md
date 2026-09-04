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

## DEC-20260905-04 · Relation-level Over-inference（待解决）

**状态**: 待确认

**发现**: 新文章测试表明，claim-level provenance 仍不能完全阻止模型从两个有证据支持的 elements 推导未经证实的 relation。

**典型问题**:

```text
Evidence(A) ✓
Evidence(B) ✓

≠

Evidence(A → B)
```

模型可能进一步把共现或相邻叙述升级成 `causes`、`enables`、`leads_to`、`requires` 等关系。

**当前判断**: 需要区分：

1. structure evidence
2. element evidence
3. relation evidence
4. relation semantic-strength evidence

但**暂不修改 Datafication 规范**，继续测试后再决定具体方案。

**关联**: `dr3-reading` · `datafication` · `DEC-20260905-03`

**后续**: 继续测试 relation-level semantic restraint。
