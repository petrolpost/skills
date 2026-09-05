# 状态与留痕协议

本文定义 dr3-reading 的状态判定、级联失效与留痕规则。执行任何功能前后必须遵循。

## 1. state.json

**路径**：`.petrelpost/articles/[slug]/state.json`（每篇文章一份）

这是“某功能能否执行 / 是否过期”的**唯一判定依据**。依赖矩阵只是生成此表的规则，不直接对外展示。

### 记录结构

artifact id 包括：

`raw_content / structured_data / datafication / immersion_notes / synthesis_pkg / critique_report / reconstruction / note_final / optimization_report`

Datafication 使用普通 `completed / failed` 状态，不需要 human confirmation。Relation Extraction 1.5 仍属于 Datafication 的可选操作，不新增独立 artifact 或 hard dependency。

```json
{
  "datafication": {
    "status": "completed",
    "run_at": "2026-09-03T22:00:00+08:00",
    "stale": false,
    "stale_soft": false,
    "blocking": false,
    "reason": "",
    "produced_by": { "module": "datafication", "version": "dr3-reading/1.5" },
    "preview": "3 structures, 8 relations"
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
| stale_soft | bool | 软依赖上游已重跑，本产出“未增强” |
| blocking | bool | 因硬依赖过期而被阻塞 |
| reason | string | 触发 stale 的具体事件 |
| produced_by | object | `{module, version}`，保留溯源 |
| preview | string | 一句话产出摘要（功能菜单展示用） |
| override | object | 仅用户强制放行时写入 |

## 2. 状态判定（执行前计算）

对目标功能 F，令 A = F 的 produces：

**A 存在于 state.json**：

- `status=failed` → `F`
- `stale=true` → `!`
- 其余 → `x`

**A 不存在**：

- 任一 requires 的产出缺失 → `L`
- 任一 requires 的产出 `stale=true`：若允许 override 则 `!`，否则 `L`
- requires 全满足，任一 enhanced_by 的产出缺失或 stale → `~`
- 全部满足 → `·`

Datafication 因 `raw_content` 是硬依赖而 `structured_data` 是软依赖：

- 只有 raw_content → `~`（可执行，但未使用 structured_data 增强）
- raw_content + 有效 structured_data → `·`

## 3. 级联失效

**触发时机**：功能 F 重新执行完成的瞬间，同步级联并写入 state.json。

1. **硬依赖边（requires）**：依赖 F.produces 的下游 D → `stale=true, blocking=true`，继续沿硬依赖传播。
2. **软依赖边（enhanced_by）**：依赖 F.produces 的下游 D → `stale_soft=true, blocking=false`，仅标注，不阻塞，不继续传播。
3. **confirmed 保护**：下游为 confirmed（reconstruction）时，保留 status 与 confirmed_at，仅追加 stale + reason，交用户裁决。
4. **override 有效期**：新的级联发生在 `override.decided_at` 之后时，必须重新提示用户。

### 传播边速查表

| 上游重跑 | 下游 | 关系 | 动作 |
|---|---|---|---|
| importer | structured_extractor | requires | stale + blocking，向下传播 |
| importer | immersion_reader | requires | stale + blocking，向下传播 |
| importer | datafication | requires | stale + blocking，向下传播 |
| structured_extractor | synthesis | requires | stale + blocking，向下传播 |
| structured_extractor | datafication | enhanced_by | stale_soft，不阻塞 |
| immersion_reader | synthesis | enhanced_by | stale_soft，不阻塞 |
| datafication | synthesis | enhanced_by | stale_soft，不阻塞 |
| synthesis | critic | requires | stale + blocking，向下传播 |
| synthesis | reconstructor | requires | stale + blocking；confirmed 时仅标记不覆盖 |
| critic | reconstructor | enhanced_by | stale_soft，不阻塞 |
| reconstructor | note_generator | requires | stale + blocking；可 override |
| note_generator | evaluator | requires | stale + blocking，向下传播 |

**重要：** datafication 重跑不会使 synthesis / reconstructor / note_generator 进入 hard stale；它只会使直接增强依赖 synthesis 标记 `stale_soft=true`。因此 Datafication 是可选知识产出，不改变 DR3 核心链路。

## 4. Override 与数据新鲜度水印

仅 note_generator 声明 `allow_override`。

1. note_generator 因 reconstruction 过期被阻塞时，向用户呈现过期原因，提供强制生成选项。
2. 用户确认后写入：

```json
"override": {
  "decided_by": "user",
  "decided_at": "<ISO8601>",
  "action": "proceed_with_stale"
}
```

3. 生成笔记正文必须写入数据新鲜度水印。

## 5. trace.jsonl

**路径**：`.petrelpost/articles/[slug]/trace.jsonl`（追加式）。

```json
{"module":"datafication","timestamp":"2026-09-03T22:00:00+08:00","status":"success","input":".petrelpost/articles/[slug]/original/article.md","config":{"discovery_depth":"high","allow_reconstruction":true,"inference_policy":"restricted","relation_extraction":"optional"},"stats":{"structures":3,"relations_extracted":8,"relations_retained":8}}
```

`module` 可为：`importer / structured_extractor / datafication / immersion_reader / synthesis / critic / reconstructor / note_generator / evaluator`。

`trace.jsonl` 永不修改或删除已有行；状态变更与用户裁决必须可追溯。
