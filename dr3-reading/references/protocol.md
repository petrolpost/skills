# 状态与留痕协议

本文定义 dr3-reading 的状态判定、级联失效与留痕规则。执行任何功能前后必须遵循。

## 1. state.json

**路径**：`.petrelpost/articles/[slug]/state.json`（每篇文章一份）

这是"某功能能否执行 / 是否过期"的**唯一判定依据**。依赖矩阵只是生成此表的规则，不直接对外展示。

### 记录结构

以 8 个 artifact id 之一作为 key（raw_content / structured_data / immersion_notes / synthesis_pkg / critique_report / reconstruction / note_final / optimization_report）：

```json
{
  "structured_data": {
    "status": "completed",
    "run_at": "2026-08-28T10:35:00+08:00",
    "stale": false,
    "stale_soft": false,
    "blocking": false,
    "reason": "",
    "produced_by": { "module": "structured_extractor", "version": "dr3-reading/1.0" },
    "preview": "high depth, 16 claims (4 core), 8 data points, 6 assumptions"
  }
}
```

### 字段说明

| 字段 | 类型 | 说明 |
|---|---|---|
| status | string | `completed` / `confirmed` / `draft` / `failed` |
| run_at | ISO8601 | 本次执行完成时间 |
| confirmed_at | ISO8601 | 仅 reconstruction：用户确认时间 |
| stale | bool | 硬依赖链上的上游已重跑，本产出已过期 |
| stale_soft | bool | 软依赖上游已重跑，本产出"未增强" |
| blocking | bool | 因硬依赖过期而被阻塞 |
| reason | string | 触发 stale 的具体事件，如 "structured_extractor 重新执行于 2026-08-28T11:00" |
| produced_by | object | `{module, version}`，保留溯源 |
| preview | string | 一句话产出摘要（功能菜单展示用） |
| override | object | 仅用户强制放行时写入（见第 4 节） |

### status 语义

- `completed`：功能完成且产出有效
- `draft`：human_gate 功能已执行但等待用户确认（仅 reconstruction）
- `confirmed`：用户已确认（仅 reconstruction，附 confirmed_at）
- `failed`：执行失败（保留失败原因在 reason，可重试）

## 2. 状态判定（执行前计算）

对目标功能 F，令 A = F 的 produces：

**A 存在于 state.json**：

- `status=failed` → `F`
- `stale=true`（无论 completed 还是 confirmed）→ `!`
- 其余（completed / confirmed / draft 且未过期）→ `x`

**A 不存在**：

- 任一 requires 的产出**缺失** → `L`（锁定，向用户报告缺失项）
- 任一 requires 的产出 `stale=true`：
  - F 允许 override（仅 note_generator）→ `!`（提示可强制放行）
  - 否则 → `L`（报告过期原因）
- requires 全满足，任一 enhanced_by 的产出缺失或 stale → `~`（可执行，产出需标注"未增强"）
- 全部满足 → `·`

## 3. 级联失效

**触发时机**：功能 F 重新执行完成的瞬间，同步级联并写入 state.json，不做懒计算、不延迟不确定性。

**传播规则**（沿依赖矩阵的反向边）：

1. **硬依赖边（requires）**：依赖 F.produces 的下游 D → `stale=true, blocking=true`，reason 记录触发事件；若 D 自身有下游，**继续向下传播**。每次传播运行维护一个 visited 集合，防止菱形依赖重复处理
2. **软依赖边（enhanced_by）**：依赖 F.produces 的下游 D → `stale_soft=true, blocking=false`；仅标注、不阻塞，不强制继续向下传播
3. **confirmed 保护**：下游为 confirmed（reconstruction）时，不覆盖确认记录——保留原 status=confirmed 与 confirmed_at，仅追加 `stale=true` + reason，向用户说明并交其裁决（沿用旧确认 or 重跑 reconstructor）
4. **override 有效期**：`override.decided_at` 之后若发生新的级联（本次 stale 的触发时间晚于 decided_at），需重新提示用户，不复用旧 override

### 传播边速查表

| 上游重跑 | 下游 | 关系 | 动作 |
|---|---|---|---|
| importer | structured_extractor | requires | stale + blocking，向下传播 |
| importer | immersion_reader | requires | stale + blocking，向下传播 |
| structured_extractor | synthesis | requires | stale + blocking，向下传播 |
| immersion_reader | synthesis | enhanced_by | stale_soft，不阻塞 |
| synthesis | critic | requires | stale + blocking，向下传播 |
| synthesis | reconstructor | requires | stale + blocking；confirmed 时仅标记不覆盖 |
| critic | reconstructor | enhanced_by | stale_soft，不阻塞 |
| reconstructor | note_generator | requires | stale + blocking；可 override |
| note_generator | evaluator | requires | stale + blocking，向下传播 |

**传播链示例**：structured_extractor 重跑 → synthesis 变 stale+blocking → critic、reconstructor 沿链同样 stale+blocking → note_generator、evaluator 同理；其中 reconstruction 若已 confirmed，则保留确认记录仅追加 stale；critic 的 stale 会给 reconstructor 追加 stale_soft，但不阻塞。

## 4. Override 与数据新鲜度水印

仅 note_generator 声明 `allow_override`：

1. note_generator 因 reconstruction 过期被阻塞时，向用户呈现过期原因（reason），提供"强制生成（写入水印）"选项
2. 用户确认后：state.json 的 note_final 写入

```json
"override": {
  "decided_by": "user",
  "decided_at": "<ISO8601>",
  "action": "proceed_with_stale"
}
```

3. 生成的笔记正文**必须**在开头写入水印：

```markdown
> ⚠️ 数据新鲜度提示：本笔记基于过期的重构结果生成。
> 过期原因：{reason}
> 上游过期时间：{触发时间} | 用户放行时间：{override.decided_at}
```

## 5. trace.jsonl

**路径**：`.petrelpost/articles/[slug]/trace.jsonl`（追加式，每次执行追加一行）

```json
{"module": "structured_extractor", "timestamp": "2026-08-28T10:35:00+08:00", "status": "success", "input": "…", "config": {"extraction_depth": "high"}, "stats": {"claims": 16, "data_points": 8}}
```

- `module`：功能名（importer / structured_extractor / immersion_reader / synthesis / critic / reconstructor / note_generator / evaluator）
- `status`：success / failed
- 其余字段（input / config / stats / result）按各功能模板定义
- **永不修改或删除已有行**——trace 是审计日志，状态变更与用户裁决必须可追溯
