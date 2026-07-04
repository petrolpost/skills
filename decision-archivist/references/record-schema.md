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
- `confidence: inferred` 用于第 3 节"隐式变更"的场景,提醒后续核实
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
