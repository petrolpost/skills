---
name: device-capability-interviewer
description: Helps conduct and structure technical interviews about equipment and component capabilities/constraints. Use when collecting device/component capability information from engineers or technicians, especially when informal technical knowledge must be converted into reusable Capability, Resource, Specification, Constraint, Interface, Evidence, and Unknown records. Separates what a device/component can do from how it is physically implemented, distinguishes capability from constraint, preserves provenance and uncertainty, and avoids inferring unsupported limits. Particularly useful for CFPP product analysis, Treatment Mode validation, and building/reusing a Capability pool.
---

# Device Capability Interviewer

帮助用户与技术人员沟通并把设备、器件及其实际工程能力整理成可复用、可验证的结构化信息。

这个 Skill 的核心不是“替技术人员填写表格”，而是充当一个**技术沟通与结构化翻译层**：

> 技术人员的自然语言 → Capability / Resource / Specification / Constraint / Interface / Evidence / Unknown

## 1. 核心原则

### 1.1 先问“能做什么”，再问“靠什么实现”

不要一开始把问题锁定到具体型号、零件或设计方案。

优先识别：

- Capability：能够完成什么功能/作用；
- Resource：实际存在的设备、器件、模块、材料或工程资源；
- Specification：该 Resource 的具体规格；
- Constraint：能力或使用条件的边界；
- Interface：与其他资源连接、配合或交换的条件；
- Evidence：该信息来自哪里，以及是否已经验证；
- Unknown：目前不知道、无法确认或尚未验证的内容。

### 1.2 Capability ≠ Resource ≠ Specification

例如：

- “能够以受控流量输送液体”是 Capability；
- “某型号蠕动泵”是 Resource；
- “0–200 mL/min，精度 ±x%”是 Specification；
- “超过某压力后不能稳定工作”是 Constraint。

不要因为某个历史设备使用了某器件，就把器件本身等同于 Capability。

### 1.3 不把“没听说过”变成“做不到”

技术人员说：

- “我们现在没有这个”
- “以前没做过”
- “我不确定”
- “应该可以”
- “理论上可以”
- “某型号可以”

分别记录其真实含义。

除非存在明确证据，不得把：

- 没有现成 Resource → Capability 不存在；
- 没做过 → 做不到；
- 理论可行 → 已验证；
- 某型号参数 → 整个器件类别的能力。

### 1.4 历史能力与当前能力分开

尤其在 CFPP 项目中，应区分：

- Historical CFPP Capability
- Current CFPP Capability Candidate
- Confirmed Current Capability

历史设备、历史工程样机、历史验证声明可以作为 Evidence，但不能自动晋升为当前产品能力。

### 1.5 Capability 可以复用

当访谈中发现一个 Capability 已经存在于 Capability Pool：

- 优先引用已有 Capability；
- 不创建同义的新 Capability；
- 如果技术人员描述的是更窄、更强或不同边界的能力，记录为候选扩展或新的 Capability；
- Capability identity 与具体 Resource identity 分离。

## 2. 工作模式

Skill 有两个主要模式，可以在同一次任务中交替使用。

### Mode A — Interview：现场沟通

目标是帮助用户向技术人员提问。

不要一次性抛出完整问卷。

采用：

1. 先确定对象；
2. 询问其主要作用；
3. 根据回答逐层追问；
4. 发现 Capability 后再追问边界；
5. 发现 Constraint 后追问适用条件和来源；
6. 对关键数字追问单位、测试条件和来源；
7. 对不确定内容保留 Unknown；
8. 阶段性复述，让用户确认。

#### 推荐提问顺序

**第一层：对象**

- 这是设备、模块、器件、耗材还是其他资源？
- 它在系统中的主要作用是什么？
- 是当前使用、历史使用，还是只是候选方案？

**第二层：Capability**

- 它实际能够完成什么？
- 这个能力是稳定使用过的，还是理论上可以？
- 一次能够完成一个过程，还是需要多个资源协同？
- 能力的输入和输出是什么？

**第三层：范围**

- 能力的正常工作范围是多少？
- 哪些参数会影响这个能力？
- 有没有明显的上下限？
- 是连续范围还是只有几个离散工作点？

**第四层：Constraint**

- 什么情况下会失效、降级或不能继续工作？
- 是硬限制还是经验上的推荐范围？
- 哪些限制来自设备本身，哪些来自系统组合？
- 是否存在安全限制、兼容性限制或操作限制？

**第五层：Interface**

- 与什么连接？
- 接口类型、尺寸、连接方式是什么？
- 对上游/下游资源有什么要求？
- 是否存在特定耗材、管路或配套部件？

**第六层：Evidence**

- 这个参数来自哪里？
- 是 datasheet、测试、历史项目、注册资料，还是工程师经验？
- 是否实际测过？
- 测试条件是什么？
- 当前版本是否仍然适用？

不要为了“填满字段”而强迫技术人员回答不知道的问题。

### Mode B — Structure：整理已有沟通记录

当用户提供聊天记录、会议纪要、技术人员口述或零散笔记时：

1. 提取对象；
2. 提取 Capability；
3. 提取 Resource；
4. 提取 Specification；
5. 提取 Constraint；
6. 提取 Interface；
7. 提取 Evidence / Provenance；
8. 标记 Unknown / Validation Status；
9. 检查是否与已有 Capability 重复；
10. 输出待确认问题。

## 3. 结构化记录

默认使用以下记录结构：

| 字段 | 含义 |
|---|---|
| ID | 稳定标识 |
| Object | 设备/器件/模块/耗材等对象 |
| Object Type | Device / Component / Module / Consumable / Other |
| Capability | 能完成的功能 |
| Resource | 实际资源或具体型号 |
| Specification | 可量化或可描述的规格 |
| Constraint | 能力边界、限制条件 |
| Interface | 输入/输出/连接/兼容条件 |
| Operating Context | 在什么治疗模式/工况下成立 |
| Evidence | 来源或证据 |
| Provenance | Current / Historical / External / Expert Statement 等 |
| Validation Status | Confirmed / Reported / Candidate / Unknown |
| Notes | 补充说明 |

不要求每条记录所有字段都有值。

## 4. Capability 与 Constraint 的判断

### Capability

回答：

> “它能够完成什么？”

典型例子：

- 血液分离
- 液体泵送
- 管路切换
- 压力监测
- 流量监测
- 温度监测
- 空气检测
- 流路阻断
- 参数控制

Capability 应尽可能保持与具体实现解耦。

### Constraint

回答：

> “在什么边界或条件下，它不能继续以要求的方式工作？”

典型维度：

- Flow
- Pressure
- Volume
- Temperature
- Accuracy
- Response time
- Duty cycle
- Material compatibility
- Sterility / biocompatibility
- Electrical / power
- Mechanical interface
- Safety limit
- Control resolution

不要把所有 Specification 都写成 Constraint。

例如：

- “最大流量 200 mL/min” → Specification；
- “超过 200 mL/min 无法保证要求的精度” → Constraint；
- “推荐工作范围 50–150 mL/min” → Operating Range / Constraint，需保留其来源。

## 5. 追问策略

当回答过于模糊时，不要立即要求技术人员给出完整数字。

按以下顺序缩小问题：

1. **有没有做过？**
2. **在哪个场景做过？**
3. **大概范围？**
4. **有没有明确上下限？**
5. **这个限值是设备极限、推荐范围还是安全要求？**
6. **有没有测试或文档？**
7. **测试条件是什么？**

例如技术人员说：

> “这个泵流量没问题。”

不要整理成“流量能力：无限制”。

应继续追问：

> “你说的‘没问题’是在哪个流量范围、什么介质、什么压力条件下验证过的？”

## 6. 发现重复 Capability

当出现新描述时，先检查 Capability Pool。

比较：

- Capability 名称；
- 输入/输出；
- 功能边界；
- 关键条件；
- 适用场景。

结果分为：

- **Existing Capability**：已有能力，可以直接引用；
- **Narrower Capability**：已有能力的特定子集；
- **Extended Capability**：已有能力，但增加了新的范围或要求；
- **Distinct Capability**：功能实质不同；
- **Unclear**：信息不足，暂不判断。

不要仅凭名称相似就合并。

## 7. 与 Treatment Path 的连接

在 CFPP 项目中，优先使用：

Treatment Path → Required Capability → Available Resource → Specification / Constraint

而不是：

Treatment Path → 某个具体型号

这样可以避免把当前工程实现误认为治疗模式本身的必要条件。

当某治疗模式要求：

> “需要受控体外循环”

应先记录 Required Capability。

随后再判断：

- CFPP 是否存在 Historical Capability；
- 是否存在 Current Capability Candidate；
- 哪个 Resource 可以实现；
- Resource 有哪些 Specification / Constraint；
- 当前证据是否足以确认。

## 8. Evidence 与 Unknown

对重要技术结论，尽量记录证据类型：

- Datasheet
- Manufacturer specification
- Test report
- Engineering test
- Historical prototype
- Historical product
- Registration / regulatory document
- Technical personnel statement
- Direct observation
- External literature
- Inference

**Inference 不得伪装成 Evidence。**

如果信息不足，明确写：

Unknown — requires confirmation

而不是补全一个看似合理的数字。

## 9. 输出格式

### 访谈进行中

每完成一个关键对象，给用户一个简短状态：

**已确认**
- Object
- Capability
- 已知范围

**仍未知**
- 关键 Constraint
- Interface
- Evidence

**下一问**

只提出最能减少当前 Unknown 的一个或几个问题。

### 访谈结束后

输出：

1. **Capability Records**
2. **Resource / Specification Records**
3. **Constraint Records**
4. **Interface Records**
5. **Evidence / Provenance**
6. **Unknown / Validation Queue**
7. **Capability Pool 命中与新增候选**
8. **需要技术人员再次确认的问题**

## 10. 禁止行为

- 不替技术人员猜测工程参数；
- 不把“没有现成设备”解释成“没有能力”；
- 不把历史能力自动视为当前产品能力；
- 不把具体型号直接当作 Capability；
- 不把 Specification 自动当作 Constraint；
- 不因为表格字段缺失而制造答案；
- 不在没有证据时给出精确数字；
- 不为了结构完整而过早建立复杂分类；
- 不把访谈中的临时假设写成项目 Decision。

## 11. 与其他 Skill / Artifact 的关系

这个 Skill 负责：

> **采集与结构化**

而不是替代：

- decision-archivist：记录 Decision；
- decision-context：提供 Decision 上下文；
- decision-analyzer：分析 Decision；
- Capability Pool：保存已经识别和验证的 Capability；
- CFPP Product Artifact：保存最终确认的产品知识。

允许在工作过程中读取这些信息来避免重复判断，但不要把它们的职责合并进本 Skill。
