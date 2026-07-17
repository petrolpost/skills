# ID and File Naming Conventions

## ID prefixes

| Prefix | Dimension | Numbering style |
|---|---|---|
| BR- | Business Rule | BR-001, BR-002, ... sequential, never reused |
| REQ- | Functional Requirement | REQ-001, ... |
| NFR- | Non-Functional Requirement | NFR-001, ... |
| CR- | Compliance Requirement | CR-001, ... |
| AC- | Architecture Constraint | AC-001, ... |
| SM- | State Machine | SM-01, SM-02, ... (two digits is fine — there are rarely more than a handful of distinct lifecycles in one project) |
| UC- | Use Case | UC-<ActorLetter><NN>, e.g. UC-P01 (Patient), UC-D01 (Doctor/professional), UC-A01 (Admin), UC-X01 (cross-cutting/exception). Use the first letter of the actor role, not a generic sequence — this makes it possible to tell which chapter a UC belongs to just from its ID. |
| OI- | Open Issue | OI-001, ... sequential across the whole open-issues chapter, regardless of sub-category (regulatory / technical / commercial / strategic) — don't restart numbering per sub-category, it causes collisions when items move between sub-categories as they get triaged. |

## Rules

1. **Never renumber an existing ID.** If a rule is deprecated, mark the row "已废止 / deprecated" and leave the number retired — don't reassign it, don't delete the row (deleting it breaks any external reference like a test case name that used it).
2. **Always find the true next number before assigning new ones.** Use:
   ```bash
   grep -ohE "PREFIX-[0-9]+" *.md | sort -t- -k2 -n | tail -1
   ```
   in the document directory — never guess or assume the highest number you remember from earlier in the conversation, especially in Mode B where you didn't just write the whole doc set yourself.
3. **A prefix is defined in exactly one home chapter**, and referenced (not redefined) everywhere else. If you find yourself writing a table row for "BR-014" in two different chapter files, that's a bug — one of them should be a cross-reference, not a definition.
4. **When content in one chapter needs to describe a rule/state/requirement owned by another chapter, reference by ID and chapter number, don't restate the substance.** E.g., a Use Case chapter entry can say "医生需完成签署（BR-006）" but should not re-explain BR-006's reasoning inline — that reasoning lives in Ch.3 and only there. Restating it in two places is exactly how the two copies quietly diverge over a few revisions.
5. **"Table row + prose elaboration" is fine for high-priority items within the *same* chapter, but only the table row counts as the definition.** E.g., Ch.10 (Open Issues) commonly needs both a compact summary table (for scanning) and a fuller prose write-up for the handful of items that are genuinely strategic. When you do this, write the prose section's lead-in as plain running text referencing the ID (e.g. "关于 OI-014，电子签名机制…") rather than as a bold heading or markdown header repeating "OI-014" — a bold/heading repeat of the ID is what `check_consistency.sh` (correctly) treats as a second definition.

## File naming (Mode A default skeleton)

```
00-总览与文档地图.md              (index — no ID prefix, this is the map)
01-Vision与Scope.md
02-Actor与角色.md
03-BusinessRule业务规则.md
04-UseCase用例.md
05-FunctionalRequirement功能需求.md
06-NonFunctionalRequirement非功能需求.md
07-ComplianceRequirement合规需求.md
08-ArchitectureConstraint架构约束.md
09-StateMachine状态机.md
10-OpenIssue待确认事项与路线图.md
```

Pattern: `NN-EnglishDimensionName中文名.md`, two-digit chapter number, zero-padded, no gaps (if a chapter is dropped for a given project — e.g. no Ch.7 because nothing is regulated — renumber the remaining chapters so there's no gap, rather than leaving a hole in the sequence; a missing number reads as an error to future readers).

Adapt chapter count/order to the project. The 11-file skeleton is a *default*, not a requirement — small projects might merge Ch.1+2, or Ch.6+7 if there's minimal compliance surface; large multi-team projects might split Ch.5 (Functional Requirement) into per-subsystem files if it grows past a few hundred lines. Whatever the final shape, chapter 00 must accurately reflect it.

## Maintenance rules to put in chapter 00

Every restructured doc set's index chapter should end with a short "maintenance rules" section, customized to the project but covering at minimum:
1. How to decide which chapter new content goes into (point to this skill / this rubric, or restate the one-line tests inline if the target audience won't have access to the skill).
2. The rule that BR/REQ/etc. numbers are never reused.
3. The rule that Ch. State-Machine is the single source of truth for lifecycle/status descriptions — other chapters reference, don't restate.
4. The rule that Open Issue chapter entries get removed (or marked resolved) and backfilled into their real home chapter once decided — an Open Issues chapter that only grows is a sign the project isn't actually making decisions, not a sign of thoroughness.
