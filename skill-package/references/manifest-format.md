# Manifest Format

Per-skill manifest files stored at `releases/<skill-name>.manifest.json`.

## Purpose

Track the content hash and metadata of a released skill, so that subsequent packaging runs can skip unchanged skills.

## Schema

```json
{
  "skill_name": "loop-agent-okr-pdca",
  "hash_algorithm": "sha256",
  "content_hash": "a1b2c3d4e5f6...",
  "files": [
    {
      "path": "SKILL.md",
      "hash": "f1e2d3c4b5a6...",
      "size": 16201
    },
    {
      "path": "references/observed-phases.md",
      "hash": "b2a1c3d4e5f6...",
      "size": 1818
    }
  ],
  "package": "loop-agent-okr-pdca.skill",
  "package_size": 7895,
  "released_at": "2026-07-17T21:30:00+08:00",
  "skill_version": "read-from-frontmatter-or-null"
}
```

## Field Reference

| Field | Type | Description |
|---|---|---|
| `skill_name` | string | From the frontmatter `name` field of `SKILL.md`. May differ from directory name. |
| `hash_algorithm` | string | Always `"sha256"`. |
| `content_hash` | string | Directory-level hash. See computation rules below. |
| `files` | array | Per-file records, sorted by `path` alphabetically. |
| `files[].path` | string | Relative path from the skill directory root (e.g. `"SKILL.md"`, `"references/observed-phases.md"`). |
| `files[].hash` | string | SHA-256 of the file's raw bytes. |
| `files[].size` | number | File size in bytes. |
| `package` | string | Filename of the `.skill` archive (e.g. `"loop-agent-okr-pdca.skill"`). |
| `package_size` | number | Size of the `.skill` archive in bytes. |
| `released_at` | string | ISO 8601 timestamp of the last packaging, in the local timezone. |
| `skill_version` | string \| null | Value of the `version` field in the frontmatter, if present. Otherwise `null`. |

## Content Hash Computation

The `content_hash` is a directory-level fingerprint that changes if any file content changes:

1. Recursively enumerate all files in the skill directory.
2. Exclude: `.DS_Store`, `Thumbs.db`, `*.tmp`, `.release-manifest.json`.
3. For each file, compute `SHA-256(file_bytes)` → `file_hash`.
4. Sort all files by path (ascending, case-sensitive).
5. Build the concatenation string: `path1:hash1\npath2:hash2\n...`
6. Compute `SHA-256(concatenation_string)` → this is `content_hash`.

This means renaming a file, adding a file, removing a file, or changing file content all produce a different `content_hash`. File metadata (mtime, permissions) is intentionally excluded — only content matters.
