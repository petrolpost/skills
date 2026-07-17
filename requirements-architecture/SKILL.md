---
name: requirements-architecture
description: Restructures a sprawling, organically-grown requirements/PRD document — user needs, UI details, business rules, compliance, and tech decisions all mixed together — into a maintainable multi-file architecture with a stable cross-referenceable ID system (BR-/REQ-/NFR-/CR-/AC-/SM-/UC-/OI-). Also governs adding new requirements or review feedback into a doc set already restructured this way, so it doesn't decay back into a monolith. Trigger when the user says a requirements doc is hard to maintain, mixes too many kinds of content, or asks for "requirements refactor" / "拆分需求文档" / "需求架构重构"; OR is adding content to a project whose docs already use this chapter+ID structure (filenames like "01-Vision与Scope.md", or prefixes like BR-XXX/REQ-XXX/OI-XXX). Trigger proactively on mixed abstraction levels — UI details next to legal citations next to encryption algorithms in one paragraph — even without the user naming "a skill".
---

# Requirements Architecture

Turns a single sprawling requirements document into a navigable, multi-file "book" — and keeps it that way as new requirements arrive. Two modes, described below. Read `references/classification-rubric.md` before doing real classification work in either mode — it's the core judgment call this skill depends on, and guessing without it produces inconsistent results.

## Why this exists

Monolithic requirements docs decay predictably: as they grow, unrelated dimensions of information (what the user needs, how the UI looks, why a law requires something, which encryption algorithm to use) end up interleaved in the same paragraphs. Early on this is fine — the doc is small enough to hold in your head. Past a certain size, every edit risks touching three unrelated concerns at once, nobody dares restructure it, and the document stops being trustworthy. The fix isn't "write less" — it's separating information by *dimension* and giving stable, reusable identifiers so different readers (developers, legal, QA, leadership) can each consume only the dimension they need, and cross-reference the rest.

## The eight dimensions (and one holding pen)

Every piece of content in a requirements doc belongs to exactly one of these. This is the backbone of both modes below.

| Dimension | ID prefix | One-line test | Chapter (default template) |
|---|---|---|---|
| Vision & Scope | — | Why does this exist, what's explicitly in/out of bounds? | Ch.1 |
| Actor | — | Who (or what system) acts, and what's their role boundary? | Ch.2 |
| Business Rule | BR- | A constraint on behavior, with a *reason* it must hold ("must", "cannot", "only if") | Ch.3 |
| Use Case | UC- | A step-by-step interaction a specific actor performs, including which UI element does it | Ch.4 |
| Functional Requirement | REQ- | "The system shall <capability>" — what the system does, actor-agnostic | Ch.5 |
| Non-Functional Requirement | NFR- | Performance/usability/deployment quality, justified by engineering judgment (not by external law) | Ch.6 |
| Compliance Requirement | CR- | Required because an external law/regulation/standard says so | Ch.7 |
| Architecture Constraint | AC- | A technology/implementation choice — swappable without changing what the system does | Ch.8 |
| State Machine | SM- | How an entity's status changes over time | Ch.9 |
| Open Issue | OI- | Undecided, needs external input, or a strategic question not yet resolved | Ch.10 |

Full decision heuristics, worked examples, and the ambiguous-case decision tree are in `references/classification-rubric.md` — open it now if you haven't internalized these distinctions from prior use.

## Mode A — Full restructuring (source doc → new architecture)

Trigger: user hands you (or references) a single sprawling document and wants it restructured.

1. **Read the entire source document first.** Don't start classifying from a partial read — cross-references and repeated concepts only become visible once you've seen everything.
2. **Extract every stable identifier that already exists** (e.g. if the source already has "BR-001" style rules from a prior lightweight pass). Preserve those numbers exactly — do not renumber existing IDs, only assign new ones for content that doesn't have one yet.
3. **Classify every paragraph/bullet** using the table above. Most single sentences belong to exactly one dimension; if a bullet mixes two dimensions (very common — e.g. "医生需在提交前签署确认，使用第三方CA服务" mixes a Business Rule with an Architecture Constraint), split it: the rule goes to Ch.3, the technology choice goes to Ch.8, and each references the other.
4. **Assign IDs sequentially per prefix**, starting from 001 (or continuing from the highest existing number for that prefix). Never reuse a number, even if content is later deleted — mark it "deprecated" instead, per `references/id-conventions.md`.
5. **Write the chapter files.** Use the file naming pattern `NN-EnglishName中文名.md` (see `references/id-conventions.md` for the exact template and the standard 11-file skeleton: 00 index, 01 Vision, 02 Actor, 03 BusinessRule, 04 UseCase, 05 FunctionalRequirement, 06 NonFunctionalRequirement, 07 ComplianceRequirement, 08 ArchitectureConstraint, 09 StateMachine, 10 OpenIssue). **Adapt the skeleton to the project** — a non-regulated project likely doesn't need Ch.7, a project with no distinct actor roles can fold Ch.2 into Ch.1, etc. Don't force all 11 files if the source content doesn't warrant them.
6. **Write chapter 00 last**, once you know the final chapter list: it's the book's table of contents plus a reading guide by reader role (new team member / developer / legal / decision-maker) plus the maintenance rules from `references/id-conventions.md` §"Maintenance rules to put in chapter 00".
7. **Run the consistency check** (`scripts/check_consistency.sh`, see below) before presenting. Fix every duplicate definition and every cross-reference that points to a nonexistent ID.
8. **Present the full file set**, and in your summary to the user: name any content you had to split across dimensions (so they can sanity-check your split), and name anything you classified as Open Issue that they might expect to see as a settled requirement.

## Mode B — Incorporating new input into an already-restructured doc set

Trigger: the project already has the chapter+ID structure (check for a `00-*.md` index file or ID prefixes like `BR-`/`REQ-`/`OI-` in the directory), and the user gives you something new — a feature request, a decision, an external review's feedback, a meeting outcome.

1. **Locate the existing document set** and read `00-*.md` to get the current chapter map and the next-available-ID situation. Don't assume the standard 11-chapter skeleton — read what's actually there.
2. **Classify the new input** using the same table above. New input almost always touches **more than one chapter** — a genuinely new feature typically needs: a Use Case (Ch.4, how someone does it) + a Functional Requirement (Ch.5, what the system does) + at least one Business Rule (Ch.3, why it's constrained this way) + possibly a Compliance Requirement (Ch.7) or Architecture Constraint (Ch.8) if it touches regulated data or a new technology. Don't write the whole thing into one chapter because it's convenient — that's exactly the decay this skill exists to prevent.
3. **Find the actual next-available ID** for every prefix you're about to use — `grep -ohE "PREFIX-[0-9]+" *.md | sort -V | tail -1` in the doc directory, not a guess. Getting this wrong (reusing or skipping numbers) is the single most common failure mode; always verify with the script below before writing new IDs, and re-verify after writing them.
4. **Write into the existing chapter files** with `str_replace`, inserting new rows/entries in the right category-subsection (don't just append to the end of a table if it has categories — find the matching category group first, per the source doc's own convention).
5. **Cross-reference in both directions**: the new BR should reference the UC/REQ that uses it, and vice versa. If the new content conflicts with or supersedes an existing decision, don't silently overwrite it — flag it explicitly (see how OI-014 in a past run was written as "conflicts with existing BR-026, decision needed" rather than just changing BR-026).
6. **Update chapter 00's changelog/version note** if the index file tracks one.
7. **Run the consistency check** before presenting, exactly as in Mode A step 7.
8. **Tell the user which chapters you touched and why**, in one line per chapter — not a wall of text. If you made a judgment call on which chapter something belongs to and it's genuinely ambiguous, say so and name the alternative.

## Consistency check (use in both modes, always before presenting)

Run `scripts/check_consistency.sh <doc-directory>`. It checks, across all `.md` files in the directory:
- Every ID prefix (BR-, REQ-, NFR-, CR-, AC-, SM-, UC-, OI-, or whatever prefixes the project uses) is defined exactly once.
- Every cross-reference to an ID (e.g. "见 BR-014", "关联 OI-009") resolves to an ID that is actually defined somewhere in the set.
- Report duplicates and orphaned references as a plain list. Fix everything it flags before presenting to the user — an inconsistent ID system is worse than no ID system, because it looks trustworthy and isn't.

## Formatting conventions

- Cross-references always use the stable ID, not a section number ("见 BR-014", never "见第3.2节第2段") — section numbers move, IDs don't.
- When a chapter file references another chapter, name both the chapter number and the ID: "见第 7 章 CR-018" — this lets a reader locate the right file without already knowing the map.
- Tables for enumerable items (BR/REQ/NFR/CR/OI) with columns `编号 | 内容 | 关联`; narrative prose for items that need real explanation (AC trade-off discussions, SM diagrams, UC walkthroughs) — don't force everything into a table if the reasoning behind it matters as much as the conclusion.
