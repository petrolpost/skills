---
name: loop-agent-okr-pdca
description: Use this skill whenever the user wants to run a long, multi-step, self-correcting task as an autonomous loop — e.g. "keep working on X until it's done", "build me a loop agent for Y", "iterate on this until the tests pass / the metric hits target / the draft is polished", or any open-ended goal that can't be finished in one shot and needs repeated plan-execute-check-adjust cycles. Also trigger when the user explicitly mentions "OKR", "PDCA", "task decomposition", "self-regulating agent", or "loop agent" in the context of getting Claude to autonomously break down and drive a goal to completion. Do NOT use this for single-step tasks that finish in one turn — only for goals that plausibly need multiple iterations with checkpoints.
---

# Loop Agent: OKR + PDCA 双层任务分解与自动调控

## 核心思路

这个 Skill 把"长任务的自动执行"拆成两层：

- **OKR 层**（跨迭代，管"要做成什么"）：把用户的目标写成一个 Objective + 2~5 条可判定的 Key Result。这一层几乎不变，只在双环学习触发时修订。
- **PDCA 层**（每轮迭代，管"这一轮怎么推进"）：每次循环只做一件事——找出当前离 KR 目标最近的一个 gap，Plan → Do → Check → Act，把 gap 缩小一点，然后决定要不要继续下一轮。

两层的关系：OKR 是静态的"北极星 + 度量尺"，PDCA 是动态的"每一步怎么走"。不要在每轮循环里重新讨论 Objective 是什么——那是双环学习触发时才做的事，平时只看 gap。

在 PDCA 基础上还借鉴了两处补充：Plan 之前加一个 **Orient**（源自 OODA 循环）步骤，专门检查"情境有没有变"，为要不要触发双环学习提供依据；KR 标记 `done` 之后加一个 **Control**（源自 DMAIC）复查节奏，防止已完成的 KR 被遗忘后又劣化回退。

## 何时不要用这个 Skill

- 用户的请求一步就能完成（写个函数、回答一个问题）——不需要循环，直接做。
- 用户已经给出完整、明确的步骤列表，只是要求按顺序执行——直接执行，不需要 OKR 包装。

## 工作流程

### Phase 0：Objective 与 KR 生成（只做一次，除非触发双环修订）

**心智框架：用户代言人。** 这一步要带着"这真的是用户想要的吗"的怀疑视角去追问，而不是"怎么翻译成我方便执行的 KR"的视角。把模糊目标偷偷简化成执行者顺手的 KR（比如把"写一篇有说服力的文章"简化成"字数够了就算数"），是这一步最常见、也最隐蔽的失败模式——因为它不会在 Check 阶段报错，只会让最终交付物"技术上达标但没解决真问题"。

把用户的目标转写成：

```json
{
  "objective": "一句话描述最终想要的状态（定性，方向性）",
  "key_results": [
    {
      "id": "KR1",
      "description": "可客观判定完成与否的具体指标",
      "success_criteria": "写清楚判定方法：数值阈值 / 通过条件 / 谁来判定",
      "status": "not_started",
      "progress_note": ""
    }
  ],
  "constraints": {
    "max_iterations": 8,
    "stagnation_limit": 2
  }
}
```

（`iteration_log` 不在这个文件里，见下方"日志文件的位置"单独说明。）

**KR 的硬性要求**：必须是 Claude 自己（或调用的工具）能客观判断"完成/未完成/进展了多少"的形式。禁止写"提升质量""让用户满意"这类无法判定的 KR——如果目标本身模糊，先跟用户确认一版可判定的 KR，再进入循环。

跟用户过一遍这版 Objective/KR，确认后再进入循环（除非用户明确说"不用确认，直接开始"）。

## 状态文件的位置与命名

**先判断当前环境有没有可写文件系统(能否调用 bash/文件工具)**,再决定状态怎么存:

**有文件系统的环境(如 Claude Code、Claude.ai 的电脑工具、Cowork 等):**
- 遵循跨 Skill 通用约定，状态文件统一放在 **`.petrolpost/loop-agent-okr-pdca/`** 目录下（与其他 Skill 共用同一套顶层命名空间，避免各 Skill 各建一套目录），命名为 `<task-name>_okr_state.json`。
  - 优先以当前项目/工作区根目录为基准：`<项目根目录>/.petrolpost/loop-agent-okr-pdca/<task-name>_okr_state.json`。
  - 没有明确项目根目录时（如 Claude.ai 电脑工具里的一次性任务），退回当前工作目录：`/home/claude/.petrolpost/loop-agent-okr-pdca/<task-name>_okr_state.json`。
  - 目录不存在时直接创建，不需要向用户确认。
- **每次命中终止条件、触发双环学习修订、或用户主动要求查看进度时**,把状态文件复制一份到面向用户的输出位置(如 Claude.ai 环境的 `/mnt/user-data/outputs/`),再展示/交付给用户——`.petrolpost/` 是工作区内部约定目录，用户默认不会主动去翻，不能只把文件留在那里就算完成同步。
- 循环中途(未终止)不需要每轮都同步到输出目录,避免刷屏;但文件本身必须真实落盘在 `.petrolpost/loop-agent-okr-pdca/` 下,不能只在对话里口头维护。

**无文件系统的环境(纯文字对话,没有代码执行能力):**
- 状态只能维持在当前对话上下文里,每轮迭代都要把完整状态(Objective/KR/当前进度)显式写在回复中,不能"记在脑子里"含糊维护。
- 结束循环、或用户要求保存进度时,把状态内容整体输出为一段可复制的 JSON,并提示用户："请保存这段内容,下次对话开头把它贴回来即可从这里继续。"

**日志文件的位置(与状态文件同目录，独立存放):**
- `iteration_log` 不放进 `okr_state.json`，单独存成 `.petrolpost/loop-agent-okr-pdca/<task-name>_iteration_log.jsonl`（JSON Lines，每轮迭代追加一行，不是整体覆盖）。
- 原因：`okr_state.json` 是覆盖式更新（每轮改字段、整体重写，体积恒定），而 `iteration_log` 是只增不减的历史记录，混在一起会导致每轮都要重写越来越长的数组，也会让 Plan/Check 阶段读取状态时被迫带上不需要的完整历史。
- 读取粒度：Plan/Check 通常只需要最近一条记录的 `note`/`check_result`（可以直接读 `okr_state.json` 里的 `progress_note` 即可，不必读日志文件）；只有在判断"连续 `stagnation_limit` 轮无进展"或做终止总结时，才需要读取 `iteration_log.jsonl` 的最近若干行或全量。
- 写入方式：每轮结束时用追加写入（append），不要读出全文件、拼接、再整体覆盖写回。

把这个结构写入状态文件（例如 `okr_state.json`，具体位置见上文），后续每轮迭代读取和更新它。

### Phase 1~4：每轮迭代的 PDCA

每一轮从状态文件里挑出**当前最需要推进、且未完成**的一个 KR（通常按依赖顺序或用户给的优先级），只针对这一个 KR 的 gap 执行下面四步：

**0. Orient（情境复核，借鉴 OODA，做 Plan 前先做）**
- 花一两句话确认：从上一轮到现在，外部情况有没有变化——比如用户补充了新要求、依赖的外部信息/接口/文件变了、之前的假设被证明不成立。
- 如果没有变化 → 直接进入 Plan，正常按 gap 推进（这是大多数轮次的情况，Orient 不应该拖慢节奏）。
- 如果发现有实质变化 → 不要当作"这轮任务没做好"处理，而是把这个变化记下来，作为下面 Act 阶段判断"是否要触发双环学习"的依据之一（真正变化的是情境本身，不是执行力）。

**1. Plan（拆解 gap，不是重拆全部目标）** 与 **2. Do（执行）** 用同一种心智完成即可，不需要切换人设——这两步是连续的"提出方案→执行方案"，刻意切换反而增加不必要的成本。真正需要切换立场的是下面的 Check 和 Act。

**1. Plan（拆解 gap，不是重拆全部目标）**
- 对照该 KR 的 `success_criteria` 和当前 `progress_note`，找出差距。
- 把差距拆成本轮要做的具体任务（1~5 个动作项即可，不要贪多）。
- 任务要具体到"调什么工具/写什么文件/跑什么命令"级别，不要停留在"研究一下"这种模糊描述。

**2. Do（执行）**
- 实际执行 Plan 里的任务：写代码、调工具、检索资料等。
- 记录实际产出和过程中遇到的障碍。

**3. Check（对照 success_criteria 打分）**

**心智框架：对抗性审核者，不是刚才做事的那个执行者。** 切换到 Check 阶段时，默认假设"还没做完"，主动去找不达标的证据，而不是去找"看起来还不错"的证据。这一步最大的风险是自评偏差——刚执行完任务的心智天然倾向于认可自己的产出，如果不刻意切换立场，"应该差不多了"会在没有真正验证的情况下被写成 `done`。

- 客观核对这一轮的产出是否满足 KR 的 `success_criteria`。
- 给出明确判定：`done` / `partial（附带百分比或具体差距）` / `blocked（附带原因）`。
- 这一步不能自我感觉良好地"应该差不多了"，必须真的去验证（跑测试、量指标、逐条核对），能用工具验证的绝不用主观判断代替。

**4. Act（决定下一步）**

**心智框架：项目负责人做止损决策，不是执行者想"再试一次"。** 执行者心态天然倾向于觉得"再来一轮应该就行了"，容易拖延该止损或该升级给用户的判断。这一步要主动问自己："如果我是要为结果负责的人，现在该继续投入，还是该承认卡住了/目标设错了？"

根据 Check 的结果四选一：
- **done** → 该 KR 标记完成，写回状态文件，记录完成时的迭代序号（供下方"已完成 KR 的复查节奏"使用），进入下一个未完成的 KR。
- **partial 且有进展** → 更新 `progress_note`，回到 Plan，针对剩余 gap 再来一轮。
- **partial 但连续 `stagnation_limit` 轮无实质进展，或 Orient 阶段发现情境已变化** → 触发**双环学习**：停下来，重新审视这条 KR 本身是否设定有问题（不可达/度量错了/其实已经在事实上完成了但判据写歪了/外部情境已不同于当初设定时）。这一步不再只是记一行日志——按下方"决策记录（双环学习专用）"的四要素写结构化记录，再跟用户同步、必要时修订 KR，而不是继续硬冲。
- **blocked** → 记录阻塞原因，如果是需要用户决策/权限/信息的阻塞，直接升级给用户，不要自己瞎猜替用户做决定。

每轮结束后，把这一轮的 Plan/Do/Check/Act 摘要以追加写入的方式写进 `<task-name>_iteration_log.jsonl`（格式见下方"iteration_log 单条记录格式"），同时更新 `okr_state.json` 里对应 KR 的 `status`/`progress_note`，再决定是否继续下一轮。

### 终止条件（任一触发即停止循环，向用户汇报）

- 所有 KR 状态为 `done`。
- 达到 `max_iterations`。
- 某 KR 连续触发双环学习后，用户确认目标需要重新讨论。
- 出现需要用户决策的 blocked 且无法自行解决。

## 决策记录（双环学习专用）

双环学习不是"这轮又失败了"的普通记录，而是"KR/Objective 本身可能设错了"的重大判断，值得单独结构化留档——参考同类 skill `decision-archivist` 的四要素模型，而不是塞进 `iteration_log` 的一行摘要里。

**存储位置**：`.petrolpost/loop-agent-okr-pdca/<task-name>_decisions.yaml`（与状态文件、日志文件同级），配套渲染一份人类可读的 `<task-name>_DECISION_LOG.md`。

**四要素**（触发双环学习时必须逐条填写，缺失的字段填 `null` 并标注 `待补全: true`，不要替用户编造）：

| 要素 | 说明 |
|---|---|
| 触发因素 | 是什么引发了这次重新审视？（连续 N 轮无进展 / Orient 阶段发现的情境变化 / 用户临时提出的新约束等，尽量具体） |
| 变更理由 | 为什么原 KR 不合适？为什么新 KR（如果有）更合适？ |
| 关联元素 | 这个决策影响哪些其他 KR、之前的任务产出、或后续计划？ |
| 计划后续措施 | 决定之后打算怎么做？（继续沿用旧 KR 硬推 / 改用新 KR / 升级给用户决定） |

```yaml
- decision_id: DEC-<task-name>-01
  iteration: 5
  kr_id: KR2
  trigger: "连续2轮进展为0%，Check阶段发现依赖的外部API已在本轮迭代中变更返回格式"
  rationale: "原KR的success_criteria基于旧API字段名，已不可达；不是执行力问题"
  related_elements: ["KR3依赖KR2的输出，需同步调整", "iteration 3的产出需要重新核对"]
  planned_followup: "将KR2的success_criteria更新为适配新API字段名，已与用户同步"
  supersedes: null   # 若此决策取代了更早的一条决策，填写被取代的 decision_id
```

**只增不改**：KR 又变了不是去改这条记录，而是新增一条并用 `supersedes` 指向被取代的旧记录——决策历史本身也是要保留的信息，不要覆盖。

**不打断原则不适用于这里**：双环学习本身就是"停下来重新审视"的时刻，四要素里任何一项在当前上下文里找不到依据，直接跟用户确认，不要为了不打断而编造理由。

## 已完成 KR 的复查节奏（Control）

`done` 不等于"以后都不用管了"——如果任务本身是长期维护型（比如"测试覆盖率≥80%"这种会随后续改动劣化的目标），需要定期复查：

- 每完成一个新 KR、或每隔 `stagnation_limit` 轮（可复用同一个阈值，不必新增配置项），从已 `done` 的 KR 里挑一个，快速对照其 `success_criteria` 复核一次是否仍然达标。
- 复查用轻量方式（能自动化验证的直接跑一下核验，不需要走完整 Plan→Do→Check→Act）。
- 若发现已 `done` 的 KR 劣化：状态改回 `partial`，按普通 gap 处理（回到 Plan），不必然触发双环学习——只有当同一个 KR **反复**劣化时，才说明这条 KR 的判据本身立不住，这时才升级为双环学习。
- 一次性交付型任务（没有"后续会不会劣化"这个问题的）可以跳过 Control，不必强行套用。

## iteration_log 单条记录格式

写入 `<task-name>_iteration_log.jsonl` 时，每轮迭代对应文件里**一行**（一个完整的单行 JSON 对象，不要把所有轮次包成一个大数组），格式如下：

```json
{
  "iteration": 3,
  "kr_id": "KR2",
  "plan": "本轮要做的 1~5 个具体任务",
  "do_summary": "实际执行了什么，产出是什么",
  "check_result": "done | partial(60%) | blocked",
  "act_decision": "continue | mark_done | escalate | revise_okr",
  "note": "供下一轮或人类回看的关键信息"
}
```

## 与用户沟通的原则

- Phase 0 完成后，把 Objective/KR 简要展示给用户确认一次，不要默默开始跑几十轮再汇报。
- 每次触发双环学习（修订 KR）或 blocked 升级时，必须显式告诉用户"为什么要改目标/为什么卡住了"，不要静默调整——具体依据是刚写好的那条结构化决策记录，直接引用其中的"触发因素"和"变更理由"即可，不用重新组织语言。
- 循环过程中的中间轮次可以简洁汇报（比如"第3轮：KR2 从40%推进到70%，还差xx"），不需要每轮都长篇大论。
- 达到终止条件时，给一个整体总结：哪些 KR 完成了、花了几轮、有没有 KR 被重新定义过（如果有，指向 `<task-name>_DECISION_LOG.md` 里对应的决策记录，不要重复展开）、当前最终状态是什么。

## 状态文件补充说明

- 不要把状态藏在脑子里口头维护——KR 一多、轮次一多就会记混，务必按上文"状态文件的位置与命名"真的写入 `.petrolpost/loop-agent-okr-pdca/` 或显式列出。
- 跨会话续跑时，用户带回的状态文件字段结构必须和 Phase 0 生成的 schema 一致，如果字段对不上（比如用户手动改过），先跟用户确认差异再继续循环，不要静默按自己的理解覆盖。
