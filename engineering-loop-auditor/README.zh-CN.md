# Engineering Loop Auditor

**Engineering Loop Auditor（工程循环审计器）** 是一个用于审计 AI / Agent 工程推理过程的 Skill。

它关注的不是“答案是否看起来正确”，而是：**Agent 是如何从问题走到判断、实现和验证的，以及这条工程循环是否真的闭合。**

> 当前状态：**Prototype — 从跨案例迁移验证进入真实集成应用阶段。**
>
> 本 README 描述的是当前已观察到的使用边界，而不是最终规范。后续集成应用会继续修正和收窄这些边界。

## 为什么需要它

在 Agent 工程中，一个失败的结果很容易诱导我们直接修改机制：

```text
结果失败
  ↓
增强机制
  ↓
再次失败
  ↓
继续增强机制
```

但失败可能来自完全不同的原因：

- 机制本身不必要；
- 问题定义错误；
- 不同语义任务被混在了一起；
- Evidence 与 Claim 并不匹配；
- 实现有缺陷；
- Validation 方法本身有缺陷；
- 被拒绝的方案其实包含了重要的决策边界。

Engineering Loop Auditor 的作用，是在 Agent 进入“继续修改机制”之前，强迫工程循环重新经过这些判断。

## 它审计什么

核心不是审计代码风格，而是审计**工程判断链**：

```text
Current System
      ↓
Real Evidence
      ↓
Observe Failure
      ↓
Separate Hypotheses
      ↓
Minimal Change
      ↓
Controlled Test
      ↓
Validate Result
      ↓
Validate Validation
      ↓
Evidence Stable?
   ┌──┴──┐
  Yes    No
   ↓      ↓
Promote  Repair / Re-run
   ↓
Observation / Usage
```

最基本的四个问题是：

1. **Problem 是观察，还是已经混入了解释？**
2. **是否存在能够区分不同解释的 Alternative / Hypothesis？**
3. **Evidence 是否真的支持 Claim，而不只是与 Claim 同时出现？**
4. **Validation 本身是否经过验证？**

## 使用场景

目前比较适合以下场景。

### 1. Agent / AI 工程机制出现异常

例如：

- Agent 没有完成预期任务；
- 某个 Skill 没有按预期工作；
- Extraction / Normalization 结果异常；
- Capability Discovery 没有找到合适能力；
- 一个新机制似乎能改善结果，但不知道是否真的必要。

此时 Auditor 用来避免把“结果问题”直接等同于“机制问题”。

### 2. 正在比较多个工程解释

当一个现象可能来自：

- Design；
- Implementation；
- Data；
- Protocol；
- Validation；
- Runtime 环境；

可以让 Auditor 帮助保持这些假设之间的边界，并要求存在具有区分能力的实验或证据。

### 3. 正在设计或审查实验

尤其适合：

- Ablation / removal experiment；
- Counterfactual experiment；
- A/B 或 baseline / control；
- Provider replacement；
- 机制替换；
- 最小变更后的回归验证。

重点不是要求“实验越复杂越好”，而是判断实验是否真的能够回答当前问题。

### 4. 结果看起来成立，但证据链可疑

例如：

> “加入 Registry 后发现能力成功，因此 Registry 是必要的。”

Auditor 会要求区分：

```text
Registry 存在时成功
        ≠
Registry 是成功的必要条件
```

并寻找能够真正区分该假设的实验，例如 removal / ablation。

### 5. Validation 通过，但工程师怀疑验证方式本身

这是 Auditor 特别关注的场景。

例如：

```text
Implementation
      ↓
Test
      ↓
PASS
```

并不自动意味着实现正确，因为 Test 本身可能：

- 测错了对象；
- 使用了错误的预期结果；
- 与 Claim 的语义强度不一致；
- 泄漏了被验证对象的信息；
- 无法区分 competing hypotheses。

因此 Auditor 会把 **Validation 当成一个需要被工程化、也需要被审计的对象。**

## 不适合什么

当前不建议把它当作以下东西：

### 不是自动架构师

它不会自动告诉你“正确架构应该是什么”。

### 不是通用测试框架

它不会替代 pytest、CI、benchmark 或其他执行型测试工具。

### 不是事实裁判

它不能凭空判断某个 Claim 在现实世界中一定为真。它审计的是 Claim、Evidence、Hypothesis 和 Validation 之间的工程关系。

### 不是自动优化器

它不会因为发现问题就默认增加机制、增加抽象或增加复杂度。

### 不是 Decision Archivist

两者职责不同：

- **Engineering Loop Auditor**：为什么当前工程判断有足够证据？
- **Decision Archivist**：最终决定了什么，以及这个决定从哪里来？

两者可以组合使用，但不应混为一个职责。

## 四种工作模式

### Mode A — Loop Audit

审计完整工程循环：

```text
Problem → Hypothesis → Experiment → Evidence → Decision → Validation
```

重点寻找缺失环节和未经验证的假设。

### Mode B — Evidence Audit

重点检查：

```text
Claim ↔ Evidence
```

判断 Evidence 的语义强度是否足以支持 Claim。

### Mode C — Validation Audit

审计验证方法本身：

- 是否验证了正确对象？
- 是否存在信息泄漏？
- baseline / control 是否成立？
- 成功标准是否与 Claim 对齐？
- 是否存在更简单的反事实实验？

### Mode D — Closure Check

判断当前工程循环是否已经足够稳定，可以：

```text
promote → observation / usage
```

而不是继续无止境地修改机制。

## 一个最小记录结构

Auditor 使用如下结构描述一次工程判断：

```yaml
problem: ""
observations: []
hypotheses:
  - id: H1
    claim: ""
  - id: H2
    claim: ""
alternatives_rejected: []
experiment:
  question: ""
  design: ""
  expected_results: []
evidence: []
decision:
  outcome: ""
  rationale: ""
implementation: null
validation:
  status: "pending"
  audit_status: "pending"
closure: "observation"
```

这个结构的目的不是建立一个新的重量级工程格式，而是让工程判断中的关键对象显式存在。

## 当前已验证的案例

### Case #001 — Datafication / Relation Extraction

该案例产生了几个目前最重要的观察：

- 输出错误不意味着机制需要增强；
- 首先判断机制是否必要；
- Generation、Extraction、Normalization 应保持语义边界；
- Source-level evidence 应先于 normalization；
- Evidence 存在不等于 Evidence 支持 Claim；
- Validation 本身也是工程对象；
- implementation defect 与 validation / protocol defect 应区分；
- rejected alternatives 能够定义决策边界；
- 最小变化往往来自责任边界的重新划分，而不是增加复杂度。

### Case #002 — Capability Discovery

第二个案例用于验证上述工程判断模式能否迁移到明显不同的问题域。

当前运行实验显示，在一个有界的、基于文件指令的 Capability Discovery 协作路径中：

- Registry 存在时可以作为索引使用；
- Registry 被移除后，Agent 仍可以依据 capability declaration 完成 discovery；
- 更换 provider 后，consumer 保持不变仍可完成任务。

这支持一个**有界结论**：该实验路径并不把 Registry 作为运行时必需依赖。

它并不支持“Registry 在一般情况下没有必要”这样的普遍结论。

尚未覆盖的因素包括：

- 多 provider；
- 大规模 discovery；
- versioning；
- dependency resolution；
- dynamic registration；
- 原生 Skill runtime 注册与调用机制。

因此 Case #002 当前进入 **Observation / Integration Application**，而不是继续从该案例推导更大的架构结论。

## 当前最重要的边界

Engineering Loop Auditor 的范围目前仍然是一个**开放问题**。

我们不预先假定它应该覆盖所有 Agent 工程问题。更合理的演进方式是：

```text
真实工程使用
      ↓
观察到重复出现的问题
      ↓
提取是否存在稳定的审计模式
      ↓
最小修改 Skill
      ↓
验证
      ↓
更新使用边界
```

因此，README 中的“适用场景”应该被理解为**当前证据支持的范围**，而不是设计者预先宣布的最终范围。

## 下一阶段：Integration Application

下一阶段不是继续制造更多抽象，而是把 Auditor 放入一个真实的 Agent 工程任务中，让它作为正常 Skill 参与工程过程。

关注的问题将从：

> “这个工程判断模式能不能迁移？”

转变为：

> **“当 Agent 真正进行工程工作时，Engineering Loop Auditor 是否改变了工程循环的质量、方向或停止条件？”**

这一区别很重要。

跨案例验证只能证明概念具有一定迁移性；真正的集成应用才能暴露 Skill 在自然工程流程中的实际边界。

## 当前限制

目前仍存在明显限制：

- 案例数量有限；
- 部分实验依赖 Agent 的过程自述，而不是完整 runtime log；
- runtime / model 组合有限；
- 尚未形成长期真实项目中的使用数据；
- 尚未证明 Auditor 对工程效率或最终质量具有普遍提升；
- 尚未证明其审计模式可以自动化到稳定程度。

这些限制不是需要立即补齐的“设计缺陷”。它们首先是下一阶段真实使用需要回答的问题。

## 开发原则

Engineering Loop Auditor 本身也遵循它所审计的工程循环：

```text
Real Engineering Use
        ↓
Observed Limitation
        ↓
Minimal Change
        ↓
Validation
        ↓
Updated Scope
        ↓
Real Engineering Use
```

因此，它不会以“设计完整”为目标，而是以**在真实工程中逐步确定自己的边界**为目标。

---

**Status: Prototype — moving from transfer validation to Integration Application.**
