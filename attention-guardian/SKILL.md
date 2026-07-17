---
name: attention-guardian
description: Maintain a persistent, single-screen "Creator Dashboard" (DASHBOARD.md) for long-running personal projects (creative work, self-directed growth, multi-session research) where the user has limited attention/working-memory capacity and doesn't want to re-read discussion history to know what to do next. Trigger when the user references a "dashboard," asks "where are we" / "what should I focus on," wants to resume a long-running project, says "help me not lose track" or similar, or explicitly asks to create/update/check a dashboard. Also trigger at the start of a session continuing a previously-dashboarded project (check for staleness), and when a discussion changes what the user should do today, the project's stage, or what's now settled/deferred. Do NOT trigger just because a conversation was long — only on an actual change to Today/Stage/Next Decision/Frozen/Parked, or on resume. Not for short-lived, single-session tasks.
---

# Attention Guardian

## Mission

Protect the user's attention, not their information. This skill does not exist to remember things — the model already remembers everything in context or in the dashboard file. It exists to decide, on the user's behalf, **what does NOT need to be looked at right now.**

Success is not "the dashboard is comprehensive." Success is: the user opens the dashboard and knows, in under 30 seconds, what to do today — and trusts that everything else is safely held, not lost.

## The core failure mode this skill prevents

Left to its own devices, an assistant will respond to a rich discussion with a rich summary — timelines, decision logs, bullet-point recaps. This is optimized for AI recall, not human attention. A human re-reading a long summary has to re-load the whole discussion into working memory to extract "what do I do now" — which defeats the purpose. This skill actively resists that default.

## Principles (apply all of these, every time)

1. **Attention First.** Before adding anything to the dashboard, ask: does this change what the user does *today*? If not, it does not belong on the visible dashboard — it goes to Safe Storage, uncollapsed only on request.
2. **Dashboard, not Summary.** Never output a timeline, meeting-notes-style recap, or "here's everything we discussed" narrative as the primary artifact. The dashboard is a navigation instrument, not documentation.
3. **Decisions over knowledge.** Store the conclusion ("blog is the source, video is retelling"), not the reasoning that produced it. Reasoning can be reconstructed on demand; it should not occupy default view.
4. **Freeze aggressively.** Anything the user has settled and isn't currently contesting — a decision they've confirmed, a definition they've stopped revising — goes into Frozen and is collapsed by default. Treat repetition (the same conclusion holding across multiple discussions) as a strong signal, but don't require a fixed count before freezing something the user clearly signals as settled (e.g. "let's not revisit this," "that's decided"). When in doubt whether something is settled, it's safer to ask than to freeze prematurely off a single message with no confirmation. Do not re-surface frozen content unless the user explicitly asks to revisit it.
5. **One Active Thing.** "Today" holds exactly one item. If the conversation produces two candidate priorities, stop and ask the user which one is actually today's — do not let the dashboard hold two.
6. **Parking is safety, not a to-do list.** Deferred topics (Parking Lot) are things intentionally *not* being thought about right now — frame them that way ("safely set aside"), never as an implicit backlog of guilt.
7. **Update only on real change.** Do not regenerate the dashboard after every message. Update it only when (a) "Today" changes, (b) something newly stabilizes into Frozen, or (c) a Next Decision is resolved or created. Otherwise, leave it untouched — don't manufacture busywork.
8. **Anti-Expansion.** If the dashboard is growing (more Frozen items appearing in the default view, Parking Lot bleeding into Today), treat that as a bug in this skill's own behavior and proactively compress before adding anything new.
9. **Guardian check.** Before writing anything into the dashboard, silently run: *"Does this affect what the user does today or in the current stage? If no → Safe Storage, not Dashboard."*
10. **Recovery-first, not closure-dependent.** Do not assume the user will remember to update the dashboard at the end of a session — in practice they won't. The moment of truth is when a project is *resumed*: on resume, read the dashboard, compare it against what's actually being discussed, and if it looks stale, say so and ask a minimal confirming question before rewriting anything (see Workflow). The dashboard doesn't need to be perfectly synced in real time; it needs to be correct by the time the user actually looks at it again.

## Dashboard Schema

Always exactly these four sections, in this order, and nothing else at the top level:

```markdown
# [Project Name] — Dashboard
_Last updated: [date]_

## 🎯 Today
[Exactly one line. One action.]

## 🚧 Current Stage
[The one active project/phase this sits inside. One or two lines.]

## 📌 Next Decision
[What will need deciding, and what triggers that decision. Not decided now.]

## 💤 Safe Storage
**Frozen** (settled, don't revisit unless asked):
- [short, declarative bullets — conclusions only, no reasoning]

**Parked** (deliberately not being worked on right now):
- [short bullets]
```

That's the whole schema. Resist adding sections, sub-dashboards, or nested hierarchies. If Frozen or Parked grows past ~8-10 bullets each, that's a signal to compress language, not to add structure — merge related bullets rather than sub-categorizing.

## Workflow

**Before creating a new dashboard:** never create one silently. Confirm the project name and where the file should live first — briefly, not as a formal intake form. If a `DASHBOARD.md` already exists at that location, read it before doing anything else; don't overwrite it with a fresh one. If the user seems to be running multiple long-term projects, ask which project this dashboard is for and name the file accordingly (e.g. `dashboard-<project-slug>.md`) or place it in a shared `dashboards/` folder — don't let two unrelated projects silently share one file.

**Building it the first time:** ask what the project is, what's currently frozen vs. still open, and what today's single focus is. Don't backfill exhaustive history — start lean; frozen items accumulate naturally over subsequent sessions.

**During a normal conversation:** don't mention the dashboard unless it's relevant. Just talk normally.

**When a discussion produces something dashboard-relevant** (a new freeze, a resolved decision, a change in what "today" is): update the file, show the user only the diff or the updated dashboard itself — not a recap of how you got there — and stop. Don't add commentary explaining every principle you applied. Don't wait for the session to "end" to do this — if it's clear in the moment that a block changed, update then.

**On session resume** (user says "continue this," "where were we," "what's next," or opens a session that's clearly a continuation): this is the real checkpoint, not session-end. Read the dashboard first. Compare it against whatever the user is now saying or asking. If it looks consistent, just use it — don't narrate the check. If it looks like it might be stale (the user references something that contradicts Today/Current Stage, or enough time/discussion has passed that Today is probably done), don't silently rewrite it and don't silently keep using a dashboard you suspect is wrong — ask one short confirming question, e.g. *"Dashboard still shows Today as X — is that still current, or did something change?"* Update only after the answer, never guess.

**When the user wants to revisit something Frozen:** un-collapse it, discuss it, and when it re-stabilizes, re-freeze it (possibly with updated wording) rather than leaving two versions floating.

## What this skill is not

- Not a project management tool with tasks, deadlines, or assignees.
- Not a full session log — the underlying conversation/transcript is still the full record; the dashboard is a lens on top of it, not a replacement for it.
- Not something that runs on a timer — it updates only on real state change, per Principle 7.

## File location convention

If the user has a working directory or notes system for the project (e.g., an Obsidian vault, a repo), store the dashboard as `DASHBOARD.md` at the root of that project's folder. If no such location exists, ask once where it should live, then stop asking.
