---
name: skill-package
description: Package skills from the skills/ directory into .skill release files (ZIP archives) with SHA-256 content-hash change detection. Trigger when the user says "package skills", "release skills", "打包发布 skill", "build .skill files", "update releases", or wants to bundle skill directories into distributable .skill archives. Also trigger when the user asks to check which skills need repackaging, or wants to verify release integrity. Do NOT trigger for installing skills into TRAE (that is a separate operation) — this skill only produces .skill files in releases/.
---

# Skill Package

Packaging skills from `skills/` into `.skill` release archives, with content-hash-based change detection.

## CRITICAL: Use the Built-in Script

This skill ships with a built-in PowerShell script at `scripts/package_skills.ps1`. **You MUST run this script directly — do NOT generate, write, or inline your own packaging code.** The script already implements all logic: discovery, hashing, comparison, packaging, manifest writing, reporting, force mode, and verify mode.

### How to Run

Locate the script relative to this skill's directory and run it with the appropriate flags:

| User intent | Command |
|---|---|
| Package (incremental, skip unchanged) | `& '<skill-dir>/scripts/package_skills.ps1'` |
| Force rebuild all | `& '<skill-dir>/scripts/package_skills.ps1' -Force` |
| Verify release integrity | `& '<skill-dir>/scripts/package_skills.ps1' -Verify` |

`<skill-dir>` is the directory containing this `SKILL.md` file. The script auto-detects the `skills/` root by going up two levels from the script's own location.

If the script cannot auto-detect the correct `skills/` root, pass it explicitly:

```
& '<skill-dir>/scripts/package_skills.ps1' -SkillsRoot 'C:\path\to\skills'
```

### After Running

- Show the script's summary table output to the user.
- If any skill has `failed` status, report the error detail.
- If any orphaned releases are detected, mention them and let the user decide.
- Do NOT re-implement any logic that the script already handles.

## Scope

Only scan **direct subdirectories of `skills/`** that contain a `SKILL.md` file. This is a hard boundary — do not recurse into the project root or other directories, because Agent-run skills may live elsewhere in the project and should not be packaged here.

**Excluded by default** (even if they appear under `skills/`):
- `releases/` — output directory
- `resources/` — supporting materials, not skills
- Any directory without a `SKILL.md`

## .skill File Format

A `.skill` file is a standard ZIP archive with a `.skill` extension. The archive contains all files from the skill directory, **flattened to the archive root** (no parent directory nesting).

## Manifest — Per-Skill, Content-Hash Based

Each skill gets its own manifest file at `releases/<skill-name>.manifest.json`. This keeps manifests self-contained: adding, removing, or updating one skill never touches another skill's manifest.

### Schema

```json
{
  "skill_name": "loop-agent-okr-pdca",
  "hash_algorithm": "sha256",
  "content_hash": "a1b2c3d4e5f6...",
  "files": [
    { "path": "SKILL.md", "hash": "f1e2d3c4...", "size": 16201 },
    { "path": "references/observed-phases.md", "hash": "b2a1c3d4...", "size": 1818 }
  ],
  "package": "loop-agent-okr-pdca.skill",
  "package_size": 7895,
  "released_at": "2026-07-17T21:30:00+08:00",
  "skill_version": "read-from-frontmatter-or-null"
}
```

### Hash Computation

1. Recursively list all files in the skill directory (excluding `.DS_Store`, `Thumbs.db`, `*.tmp`, `.release-manifest.json`, `.git/`, `node_modules/`).
2. For each file, compute SHA-256 of its raw bytes.
3. Compute the **directory-level content hash**: sort all file paths alphabetically, concatenate `path + ":" + file_hash` for each, then SHA-256 the concatenated string.
4. The directory-level hash is stored as `content_hash` in the manifest. If this hash matches the existing manifest, the skill is unchanged and packaging is skipped.

Full manifest field reference: see `references/manifest-format.md`.

## Workflow (Implemented by the Script)

1. **Discover** — Scan `skills/` for direct subdirectories containing `SKILL.md`.
2. **Hash & Compare** — Compute directory-level content hash; compare against existing manifest.
3. **Package** — ZIP changed/new skills to `releases/<skill-name>.skill`.
4. **Update Manifests** — Write `releases/<skill-name>.manifest.json`.
5. **Report** — Output summary table with status (`packaged` / `skipped` / `failed`) and package size.

## Force Flag

If the user says "force", "rebuild all", "全部重新打包", or similar: pass `-Force` to the script. This skips hash comparison and packages every skill regardless of manifest state.

## Integrity Check

If the user asks to "verify", "check", "校验" releases: pass `-Verify` to the script. It extracts each `.skill` file, recomputes the content hash, and compares against the manifest. Mismatches are reported as `CORRUPTED`.

## Edge Cases

- **New skill, no manifest**: Script packages immediately and creates manifest.
- **Skill deleted from `skills/` but manifest/package still in `releases/`**: Script reports as `orphaned` — does NOT auto-delete.
- **Skill directory is empty or has no SKILL.md**: Skipped silently.
- **`references/`, `assets/`, `scripts/` subdirectories**: Included in package and hash computation.
- **Skill name from frontmatter vs directory name**: Script uses directory name for filenames; frontmatter `name` goes in manifest's `skill_name` field.

## What This Skill Does NOT Do

- Does not install skills into TRAE or any other runtime.
- Does not publish to a marketplace or registry.
- Does not manage skill versioning beyond content-hash change detection.
- Does not modify skill source files.
