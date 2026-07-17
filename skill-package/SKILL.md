---
name: skill-package
description: Package skills from the skills/ directory into .skill release files (ZIP archives) with SHA-256 content-hash change detection. Trigger when the user says "package skills", "release skills", "打包发布 skill", "build .skill files", "update releases", or wants to bundle skill directories into distributable .skill archives. Also trigger when the user asks to check which skills need repackaging, or wants to verify release integrity. Do NOT trigger for installing skills into TRAE (that is a separate operation) — this skill only produces .skill files in releases/.
---

# Skill Package

Packaging skills from `skills/` into `.skill` release archives, with content-hash-based change detection.

## Scope

Only scan **direct subdirectories of `skills/`** that contain a `SKILL.md` file. This is a hard boundary — do not recurse into the project root or other directories, because Agent-run skills may live elsewhere in the project and should not be packaged here.

```
skills/
├── loop-agent-okr-pdca/
│   └── SKILL.md          ← included
├── attention-guardian/
│   └── SKILL.md          ← included
├── releases/             ← excluded (output directory, not a skill)
├── resources/            ← excluded (no SKILL.md)
└── ...
```

**Excluded by default** (even if they appear under `skills/`):
- `releases/` — output directory
- `resources/` — supporting materials, not skills
- Any directory without a `SKILL.md`

## .skill File Format

A `.skill` file is a standard ZIP archive with a `.skill` extension. The archive contains all files from the skill directory, **flattened to the archive root** (no parent directory nesting):

```
loop-agent-okr-pdca.skill (ZIP)
├── SKILL.md
├── references/
│   ├── observed-phases.md
│   └── output-templates.md
└── assets/
    └── ...
```

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

1. Recursively list all files in the skill directory (excluding `.DS_Store`, `Thumbs.db`, and any `.release-manifest.json` if present inside the skill directory).
2. For each file, compute SHA-256 of its raw bytes.
3. Compute the **directory-level content hash**: sort all file paths alphabetically, concatenate `path + ":" + file_hash` for each, then SHA-256 the concatenated string.
4. The directory-level hash is stored as `content_hash` in the manifest. If this hash matches the existing manifest, the skill is unchanged and packaging is skipped.

## Workflow

### Step 1: Discover Skills

Scan `skills/` for direct subdirectories containing `SKILL.md`. Build the candidate list.

### Step 2: Compute Hashes & Compare

For each candidate skill:
1. Compute the current directory-level content hash (per "Hash Computation" above).
2. Read `releases/<skill-name>.manifest.json` if it exists.
3. Compare `content_hash`:
   - **Match** → skip (no changes since last release).
   - **Mismatch or no manifest** → mark for packaging.

### Step 3: Package

For each skill marked for packaging:
1. Create a ZIP archive containing all files from the skill directory, flattened to archive root.
2. Write the archive to `releases/<skill-name>.skill`.
3. If a previous `.skill` file exists, overwrite it.

### Step 4: Update Manifests

For each packaged skill, write `releases/<skill-name>.manifest.json` with the current hash, file list, package info, and timestamp.

### Step 5: Report

Output a summary table:

```
| Skill                  | Status    | Package Size |
|------------------------|-----------|-------------|
| loop-agent-okr-pdca    | packaged  | 7.9 KB      |
| attention-guardian     | packaged  | 8.8 KB      |
| TheoryEvolutionAuditor | skipped   | (unchanged) |
```

Status values: `packaged` (new or updated), `skipped` (unchanged), `failed` (error during packaging — include error detail).

## Force Flag

If the user says "force", "rebuild all", "全部重新打包", or similar: skip hash comparison and package every skill regardless of manifest state.

## Integrity Check

If the user asks to "verify", "check", "校验" releases:
1. For each `.skill` file in `releases/`, extract and recompute the content hash.
2. Compare against the corresponding manifest's `content_hash`.
3. Report any mismatches as `CORRUPTED`.

## Edge Cases

- **New skill, no manifest**: Package immediately, create manifest.
- **Skill deleted from `skills/` but manifest/package still in `releases/`**: Do NOT auto-delete the orphaned release — report it as `orphaned` and let the user decide.
- **Skill directory is empty or has no SKILL.md**: Skip silently, do not report.
- **`references/` or `assets/` subdirectories**: Include them in the package and hash computation.
- **Skill name from frontmatter vs directory name**: Use the directory name for the `.skill` filename and manifest filename; use the frontmatter `name` field for the `skill_name` field in the manifest. If they differ, note it in the report.

## What This Skill Does NOT Do

- Does not install skills into TRAE or any other runtime.
- Does not publish to a marketplace or registry.
- Does not manage skill versioning beyond content-hash change detection.
- Does not modify skill source files.
