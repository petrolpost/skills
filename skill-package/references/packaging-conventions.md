# Packaging Conventions

Rules for `.skill` archive creation and release directory layout.

## Archive Format

- `.skill` files are standard ZIP archives (magic bytes: `50 4B 03 04`).
- Extension is `.skill` instead of `.zip` for semantic clarity.
- Compression: Deflate (standard ZIP compression).

## Archive Structure

Files are stored **flattened to the archive root** — no top-level directory wrapping the contents:

```
✅ Correct:
loop-agent-okr-pdca.skill
├── SKILL.md
└── references/
    └── observed-phases.md

❌ Incorrect (nested directory):
loop-agent-okr-pdca.skill
└── loop-agent-okr-pdca/
    ├── SKILL.md
    └── references/
        └── observed-phases.md
```

## Included Files

Everything inside the skill directory is included, recursively:

- `SKILL.md` — required, must be present.
- `references/` — supplementary documentation.
- `assets/` — templates, images, or other supporting files.
- `scripts/` — helper scripts.
- `README.md` — if present.

## Excluded Files

These patterns are always excluded from the archive:

- `.DS_Store` (macOS)
- `Thumbs.db` (Windows)
- `*.tmp`
- `.release-manifest.json` (if present inside the skill directory)
- `.git/` directories
- `node_modules/` directories

## Release Directory Layout

```
skills/
├── releases/
│   ├── loop-agent-okr-pdca.skill
│   ├── loop-agent-okr-pdca.manifest.json
│   ├── attention-guardian.skill
│   ├── attention-guardian.manifest.json
│   ├── TheoryEvolutionAuditor.skill
│   ├── TheoryEvolutionAuditor.manifest.json
│   └── ...
```

Each `.skill` archive has a sibling `.manifest.json` file with the same base name. This 1:1 pairing makes it easy to:
- Check if a skill needs repackaging (read one manifest, not a global file).
- Delete a release cleanly (remove both `.skill` and `.manifest.json`).
- Spot orphans (a `.skill` without a manifest, or vice versa).

## Naming

- Archive filename: `<directory-name>.skill` (uses the **directory name**, not the frontmatter `name` field, for filesystem consistency).
- Manifest filename: `<directory-name>.manifest.json`.
- If directory name and frontmatter `name` differ, the report should note the discrepancy but packaging proceeds with the directory name.
