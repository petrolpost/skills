# Decision Archivist

追踪 Agent 设计过程中思想/逻辑/方案的变更决策，防止版本间逻辑断层与方案冲突。

## 核心理念

决策记录不是"边聊边问清楚"，而是**两阶段**的：

```
对话进行时 → 轻量标记(不打断)  →  .petrelpost/docs/decisions/staged-signals.yaml
                                            │
用户要求梳理时 → 全量精读+补全  →  .petrelpost/docs/decisions/decisions.yaml
                                            │
                                    渲染  →  DECISION_LOG.md
```

- **自动感知**：静默检测变更信号词，做轻量标记，绝不打断讨论
- **全量梳理**：系统提取四要素，检测冲突，生成可读日志
- **证据留痕**：正式 Decision 除了记录“做了什么、为什么”，还记录“凭什么认为这条 Decision 成立”，并区分证据性质

## 工作模式

### 模式一：自动感知（默认开启）

当讨论中出现变更信号词（"改为"、"不再用"、"取消"、"换成"等），自动在 `staged-signals.yaml` 追加轻量记录，不打扰对话。

**信号词清单**：

| 类型 | 中文 | 英文 |
|------|------|------|
| 替换类 | 改为、换成、改用、替换为、转向 | instead of, change to, switch to |
| 否定类 | 不再、取消、放弃、废弃、否决 | no longer, deprecated, abandon, reject |
| 修正类 | 调整为、重新设计、重构 | redesign, refactor, correct to |
| 冲突暴露类 | 和之前说的不一样、矛盾、冲突 | contradicts, conflicts with |

### 模式二：全量梳理（手动触发）

用户说"帮我梳理决策历史"、"整理方案变更记录"、"检查方案冲突"时执行：

1. **确认材料范围** → 对话全文 / 指定文档 / 积压标记 / 已有记录
2. **识别决策点** → 先处理 staged-signals，再全文扫描补充
3. **提取四要素** → 触发因素、变更理由、关联元素、计划后续措施
4. **提取证据性质** → 区分用户明确陈述、接受/否决、上下文支持、能力分析等来源；没有依据就不补造
5. **冲突检测** → 检查关联元素是否重叠且结论矛盾
6. **写入与渲染** → 更新 `decisions.yaml`，渲染 `DECISION_LOG.md`
7. **汇报摘要** → 新增条数、待补全项、潜在冲突

## 文件结构

所有输出统一写入项目根目录下的 `.petrelpost/docs/decisions/`：

```
.petrelpost/docs/decisions/
├── config.yaml            # 开关配置(如 auto_sense_enabled)
├── decisions.yaml        # 源真值:已确认/待补全的正式决策记录
├── staged-signals.yaml   # 自动感知产生的轻量标记(待处理)
└── DECISION_LOG.md        # 渲染出的可读时间线(不要手工编辑)
```

## 决策记录 Schema

每条正式决策包含四要素，并可附带证据来源：

```yaml
- id: DEC-20260703-01
  status: confirmed          # confirmed | pending | superseded | abandoned
  trigger:
    summary: "用户反馈方案A性能不足"
    source: "对话第42轮"
  change:
    from: "事件驱动架构"
    to: "轮询+批处理架构"
  rationale:
    summary: "事件驱动在当前中间件下延迟不可控"
  evidence:
    - type: explicit_statement   # explicit_statement | acceptance | rejection | contextual | analysis
      source: "对话第42轮"
      excerpt: "原文中支持该 Decision 的短摘录"
  related_elements:          # 关联的文件/模块/概念/决策
    - type: module
      ref: "task-queue-processor"
  planned_follow_ups:        # 后续措施
    - action: "补充压测数据"
      status: open
  supersedes: DEC-20260610-03  # 若取代了旧决策
```

`evidence` 与 `rationale` 不等价：前者记录依据的来源与性质，后者记录为什么选择该方案。`evidence` 不表示简单的可信度排序；例如 `acceptance` 表示用户接受了此前提出的方案，而 `contextual` 表示由历史材料提供支持。没有依据时保持空缺，不为了完整而编造。

## 配置

首次使用自动创建默认配置：

```yaml
auto_sense_enabled: true   # 是否开启自动感知
```

可随时通过自然语言调整：
- "关闭自动感知" → `auto_sense_enabled: false`
- "打开自动感知" → `auto_sense_enabled: true`

## 使用示例

### 触发全量梳理

```
帮我梳理一下这个项目的决策历史
```

### 检查方案冲突

```
检查一下有没有方案冲突
```

### 生成决策日志

```
生成决策日志
```

### 调整自动感知开关

```
先别自动记录了
```

## 注意事项

- **不打断是自动感知的硬约束**，全量梳理时为补全信息询问用户是合理的
- **决策记录只增不改**，方案又变了就新增一条并标注 `supersedes` 指向旧记录
- **区分决策和讨论**，只有真正落地的变更才算决策，还在权衡的不算
- **证据与推断分离**，分析结果可以作为 `analysis` 类型依据，但不得伪装成用户原始陈述
- **DECISION_LOG.md 是渲染产物**，任何修正都改 `decisions.yaml` 再重新渲染

## 参考文档

- [信号词与实质性判断标准](references/signal-taxonomy.md)
- [决策记录 Schema](references/record-schema.md)
- [冲突检测规则](references/conflict-detection.md)
- [SKILL.md](SKILL.md) - 完整技能定义
