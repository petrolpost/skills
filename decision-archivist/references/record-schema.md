# 决策记录 Schema

## 1. `staged-signals.yaml` 字段(自动感知阶段产出)

```yaml
signals:
  - signal_id: SIG-20260703-01        # 格式: SIG-YYYYMMDD-序号(当日从01开始)
    detected_at: "2026-07-03T10:20:00" # ISO 8601
    trigger_utterance: "原文摘录,1-2句"
    rough_from: "旧方案粗略描述,识别不出就填 null"
    rough_to: "新方案粗略描述"
    rationale: null                    # 若用户当场已说明理由则照实摘录,否则 null
    待补全: true
```

## 2. `decisions.yaml` 字段(全量梳理阶段产出,源真值)

```yaml
decisions:
  - id: DEC-20260703-01                # 格式: DEC-YYYYMMDD-序号(当日从01开始,与SIG编号体系独立)
    status: confirmed                  # confirmed(已确认) | pending(待补全) | superseded(已被取代) | abandoned(已废弃)
    created_at: "2026-07-03T15:00:00"
    from_signal: SIG-20260703-01       # 若源自某条轻量标记,填其ID;若为全量扫描新发现,填 null

    trigger:                           # 触发因素
      summary: "用户反馈方案A在高并发场景下响应延迟过高"
      source: "对话第42轮"             # 尽量可定位:对话轮次 / 文件名:行号 / 会议记录时间戳

    change:                            # 变更本体
      from: "采用事件驱动架构处理任务队列"
      to: "改用轮询+批处理架构"

    rationale:                         # 变更理由
      summary: "事件驱动在当前消息中间件下无法保证高并发场景的响应时延,轮询虽然吞吐略低但延迟可控"
      待补全: false

    evidence:                           # 支撑该 Decision 的证据来源与性质
      - type: explicit_statement       # 用户明确陈述
        source: "对话第42轮"
        excerpt: "原文中直接支持该 Decision 的短摘录"
      - type: acceptance               # 用户接受此前提出的方案
        source: "对话第43轮"
        excerpt: "原文中的接受/确认表达"
      # type 可选: explicit_statement | acceptance | rejection | contextual | analysis
      # evidence 只记录材料中实际存在的依据;没有依据时不创建条目

    related_elements:                  # 关联的项目元素
      - type: module                   # module | file | concept | decision | skill
        ref: "task-queue-processor"
      - type: decision
        ref: DEC-20260610-03           # 若这条决策取代/关联了之前的决策,引用其ID

    planned_follow_ups:                # 计划中的后续措施
      - action: "补充轮询架构下的压测数据"
        status: open                   # open | done | dropped
      - action: "同步给前端团队,响应时延预期从100ms调整为300ms"
        status: open

    supersedes: DEC-20260610-03        # 若明确取代了某条旧决策,填其ID,否则为 null
    superseded_by: null                # 若这条决策后来又被取代,填取代它的决策ID(全量梳理时回填)

    confidence: explicit               # explicit(用户明确表述) | inferred(通过前后文对比推断)
    source: "对话第40-45轮"
```

### 字段填写原则

- `待补全: true/false` 出现在任何字段级别,凡是无法从材料中找到依据的字段,一律标注 `待补全: true` 并置值为 `null`,不得编造
- `evidence` 只记录实际存在于材料中的依据,不得为了让 Decision 看起来完整而补造证据
- `evidence.type` 表示依据的性质,而不是简单的可信度排序:
  - `explicit_statement`: 用户明确陈述了该 Decision 或其理由
  - `acceptance`: 用户接受了此前提出的方案/判断
  - `rejection`: 用户明确否决/放弃了此前方案/判断
  - `contextual`: 通过其他历史材料对该 Decision 提供上下文支持,不等同于用户直接陈述
  - `analysis`: 由 Analyzer 等能力产生的分析依据,必须保留其分析性质,不得伪装成用户原始陈述
- `evidence` 与 `rationale` 不等价。`evidence` 回答“凭什么认为这条 Decision 成立/如何知道”,`rationale` 回答“为什么选择这个方案而不是其他方案”
- `confidence` 继续表示 Decision 本身的形成方式;不要用它替代 evidence provenance
- `related_elements` 尽量给出可检索的引用而非模糊描述,方便冲突检测阶段做重叠匹配

## 3. `DECISION_LOG.md` 渲染格式(输出示例)

由 `decisions.yaml` 全量重新生成,按时间正序排列:

```markdown
# 决策历史日志

> 本文件由 decisions.yaml 自动渲染,请勿手工编辑。

## DEC-20260610-03 · 2026-06-10 · [已被取代]
**变更**: 未采用队列方案 → 采用事件驱动架构处理任务队列
**触发**: 初期设计,需要解耦生产者与消费者
**理由**: 事件驱动能更好地支持未来的多消费者扩展
**关联**: task-queue-processor
**后续措施**: [x] 完成 POC 验证
**被取代**: → DEC-20260703-01

---

## DEC-20260703-01 · 2026-07-03 · [已确认]
**变更**: 事件驱动架构处理任务队列 → 轮询+批处理架构
**触发**: 用户反馈方案A在高并发场景下响应延迟过高（对话第42轮）
**理由**: 事件驱动在当前消息中间件下无法保证高并发场景的响应时延，轮询虽然吞吐略低但延迟可控
**关联**: task-queue-processor · 取代 DEC-20260610-03
**后续措施**:
- [ ] 补充轮询架构下的压测数据
- [ ] 同步给前端团队，响应时延预期从100ms调整为300ms

---

## ⚠️ 潜在冲突

- DEC-20260615-02 与 DEC-20260701-05 都涉及 `auth-module`，前者要求"必须无状态"，后者要求"引入会话缓存"，且无 supersedes 关系声明，需要用户确认。
```
