# Classification Rubric — deciding which dimension a piece of content belongs to

This is the part of the skill that actually requires judgment. The one-line tests in SKILL.md's table handle maybe 80% of content instantly. This file covers the other 20%: worked examples, the ambiguous cases, and what to do when a single sentence tries to be three things at once (which is common — source documents that need this skill got messy precisely because nobody was making this distinction as they wrote).

## Worked examples, by dimension

**Business Rule (BR-)** — a constraint with a reason, phrased as "must/cannot/only if/unless":
- "驳回后此前的计算前确认签署自动失效，重新提交前须重新签署" — this is a BR: it's a constraint (signature invalidated) with an implicit reason (signature represents responsibility for *this specific* parameter set).
- Tell: if you can imagine someone asking "why does it work this way?" and the answer is a business/legal reason (not "because that's how we built it"), it's a BR.

**Use Case (UC-)** — a specific actor's step-by-step interaction, including which UI surface:
- "医生在结果复核面板查看DVH对比，点击'确认'或'驳回'" — this is a UC: named actor, named UI location, named action sequence.
- Tell: if removing the actor's name breaks the sentence ("who does this?"), it's a UC, not a REQ.

**Functional Requirement (REQ-)** — actor-agnostic capability statement:
- "系统应在计算完成后将结果置于待复核状态，禁止直接下载" — this is a REQ: no actor performs an action, it's describing what the system *is*, as a standing capability.
- Tell: rewrite it starting with "The system shall..." — if that reads naturally without naming who triggered it, it's a REQ. If a REQ and a UC describe the same feature from two angles (system capability vs. actor interaction), that's correct and expected — write both, cross-referenced, don't pick one.

**Non-Functional Requirement (NFR-) vs Compliance Requirement (CR-)** — the trap:
Both look like "system should be secure / fast / encrypted." The test is **why**:
- If the answer to "why does this requirement exist" is an external law, regulation, or standard → CR. ("AES-256 静态加密" because 数据安全法/等保 requires strong encryption for this data class → CR, or the concrete algorithm choice is AC, see below.)
- If the answer is engineering/product judgment with no external mandate → NFR. ("响应式UI，支持中英文" — nobody is legally requiring this, it's a product quality bar.)
- Corollary: CR content should cite or name the law/regulation/standard it derives from. If you can't name what regulation requires it, it's probably NFR, not CR — don't inflate NFR into CR just because it sounds serious.

**Compliance Requirement (CR-) vs Architecture Constraint (AC-)** — the other trap:
- CR states the *obligation*: "静态加密与传输加密均需采用行业认可强度的标准" (the law/standard requires strong encryption — doesn't say which algorithm).
- AC states the *chosen implementation*: "AES-256 静态加密、TLS 1.3 传输加密" (this is the specific technology chosen to satisfy the CR above — could be swapped for another algorithm of equivalent strength without changing the CR).
- Tell: ask "if we swapped the specific technology tomorrow, would the underlying obligation still be satisfied the same way?" If yes, you're looking at an AC that implements a CR — write both, with the AC referencing which CR it satisfies.

**Architecture Constraint (AC-)** — technology/implementation choice:
- "电子签名机制：自建 vs 第三方 CA 服务" — this is AC: it's a *how*, not a *what* or a *why*. Even contentious, expensive, or legally-risky implementation choices are AC if they're about *how* to build something, not *whether* it must exist.
- Watch for AC content masquerading as BR: "系统采用可插拔电子签名架构，自建优先" is AC (implementation strategy), not a BR, even though it's phrased with "should" language. The giveaway: it's about *how the team builds it*, not *how the system must behave toward users*.

**State Machine (SM-)** — status over time:
- Anything describable as `state → (trigger) → state` belongs here, and *only* here — don't re-describe the same transitions in prose inside a UC or REQ chapter; reference the SM instead. This is the single most common duplication bug in unrefactored docs: the same lifecycle described three different, slowly-diverging ways in three different sections.

**Open Issue (OI-)** — the escape valve:
- Anything you can't classify because it's genuinely undecided goes here, *not* into whichever chapter feels closest. Don't write "系统应..." (REQ language) for something the team hasn't actually decided yet, even to hold a placeholder — write it as an open question in Ch.10 and reference it from wherever it'll eventually land.
- Strategic/contested decisions (an external reviewer disagreeing with an existing BR/AC, a proposed business-model pivot) are also OI, even though they're "big" — bigness doesn't promote something out of Open Issue status. Only a project decision-maker's actual decision does that; until then, document the disagreement, not a resolution.

## The ambiguous-case decision tree

When a single source sentence seems to fit two dimensions, split it — don't force a single classification. Ask, in order:

1. **Does it describe a technology/vendor/algorithm choice?** → that part is AC, regardless of what else is in the sentence.
2. **Does it cite or clearly derive from an external law/standard?** → that part is CR.
3. **Does it name a specific actor doing a specific action in a specific UI location?** → that part is UC.
4. **Is it a constraint with a "must/cannot" and an implicit business reason, with no actor named?** → BR.
5. **Is it a standing system capability with no actor and no external mandate?** → REQ.
6. **Is it about state over time?** → SM.
7. **Is it not yet decided?** → OI, no matter how "obviously" it seems to belong somewhere else once decided.
8. **Is it about overall goals or explicit boundaries (in/out of scope)?** → Vision & Scope.

Work top-to-bottom; the first test that matches wins for that clause. A single source paragraph frequently produces 2-4 separate entries across different chapters — that's success, not over-fragmentation, as long as each entry cross-references the others it split from.

## When NOT to split (avoiding over-engineering)

Don't create an AC entry for every trivial technical detail — only for choices with real trade-offs worth recording (something a future engineer might reasonably ask "why this and not X"). A throwaway implementation detail with no real alternative doesn't need its own AC-numbered entry; fold it into the REQ or UC it supports as a parenthetical.

Similarly, don't create a separate UC for every button — group related actor actions into one UC if they're part of the same task (e.g. "参数配置" is one UC covering ROI selection, α/β entry, and model selection, not three separate UCs), and only split into multiple UCs when the actor's *goal* changes, not just the UI panel.
