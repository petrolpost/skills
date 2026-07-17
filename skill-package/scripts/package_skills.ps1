<#
.SYNOPSIS
  Package skills from skills/ into .skill release archives with SHA-256 change detection.

.PARAMETER SkillsRoot
  Path to the skills/ directory. Defaults to the parent of the script's location.

.PARAMETER Force
  Skip hash comparison and package every skill regardless of manifest state.

.PARAMETER Verify
  Verify integrity of existing .skill releases against their manifests.

.EXAMPLE
  .\package_skills.ps1
  .\package_skills.ps1 -Force
  .\package_skills.ps1 -Verify
#>
param(
    [string]$SkillsRoot,
    [switch]$Force,
    [switch]$Verify
)

$ErrorActionPreference = 'Stop'

# Resolve skills root: use param, or infer from script location (../../)
if (-not $SkillsRoot) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $SkillsRoot = Split-Path -Parent $scriptDir        # skill-package/  -> skills/
    $SkillsRoot = Split-Path -Parent $SkillsRoot        # remove trailing
    $SkillsRoot = Join-Path (Split-Path -Parent $SkillsRoot) (Split-Path -Leaf $SkillsRoot)
    # Simpler: script is at skills/skill-package/scripts/, so go up 2 levels
    $SkillsRoot = Split-Path -Parent (Split-Path -Parent $scriptDir)
}

$releasesDir = Join-Path $SkillsRoot 'releases'
if (-not (Test-Path $releasesDir)) { New-Item -ItemType Directory -Path $releasesDir -Force | Out-Null }

# Excluded directories (not skills)
$excludedDirs = @('releases', 'resources')

# Excluded file patterns
$excludedFiles = @('.DS_Store', 'Thumbs.db', '.release-manifest.json')
$excludedExts = @('.tmp')

# ─── Verify mode ───────────────────────────────────────────────
if ($Verify) {
    Write-Output "Verifying release integrity..."
    Write-Output ""
    Write-Output "| Skill                    | Status      | Detail |"
    Write-Output "|--------------------------|-------------|--------|"

    $skillFiles = Get-ChildItem $releasesDir -Filter '*.skill' -File
    foreach ($sf in $skillFiles) {
        $baseName = $sf.BaseName  # e.g. "loop-agent-okr-pdca"
        $manifestPath = Join-Path $releasesDir "$baseName.manifest.json"

        if (-not (Test-Path $manifestPath)) {
            Write-Output "| $($baseName.PadRight(24)) | CORRUPTED   | No manifest found |"
            continue
        }

        $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json

        # Extract .skill (ZIP) — Expand-Archive requires .zip extension, so copy first
        $tempDir = Join-Path $env:TEMP "skill_verify_$baseName"
        $tempZip = Join-Path $env:TEMP "skill_verify_$baseName.zip"
        if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
        if (Test-Path $tempZip) { Remove-Item $tempZip -Force }
        Copy-Item $sf.FullName $tempZip -Force
        Expand-Archive -Path $tempZip -DestinationPath $tempDir -Force
        Remove-Item $tempZip -Force

        # Recompute hash
        $allFiles = Get-ChildItem $tempDir -Recurse -File | Where-Object {
            $excludedFiles -notcontains $_.Name -and $excludedExts -notcontains $_.Extension
        } | Sort-Object { $_.FullName.Substring($tempDir.Length) }

        $concatString = ''
        foreach ($f in $allFiles) {
            $relativePath = $f.FullName.Substring($tempDir.Length + 1).Replace('\','/')
            $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
            $hasher = [System.Security.Cryptography.SHA256]::Create()
            $hashBytes = $hasher.ComputeHash($bytes)
            $hasher.Dispose()
            $fileHash = [BitConverter]::ToString($hashBytes).Replace('-','').ToLower()
            $concatString += "${relativePath}:${fileHash}`n"
        }

        $contentHasher = [System.Security.Cryptography.SHA256]::Create()
        $contentBytes = [System.Text.Encoding]::UTF8.GetBytes($concatString)
        $contentHashBytes = $contentHasher.ComputeHash($contentBytes)
        $contentHasher.Dispose()
        $recomputedHash = [BitConverter]::ToString($contentHashBytes).Replace('-','').ToLower()

        Remove-Item $tempDir -Recurse -Force

        if ($recomputedHash -eq $manifest.content_hash) {
            Write-Output "| $($baseName.PadRight(24)) | OK          | Hash matches |"
        } else {
            Write-Output "| $($baseName.PadRight(24)) | CORRUPTED   | Hash mismatch (expected $($manifest.content_hash.Substring(0,12))..., got $($recomputedHash.Substring(0,12))...) |"
        }
    }

    # Check for orphans (manifest without .skill, or .skill without manifest)
    $manifests = Get-ChildItem $releasesDir -Filter '*.manifest.json' -File
    foreach ($m in $manifests) {
        $baseName = $m.BaseName -replace '\.manifest$',''
        $skillPath = Join-Path $releasesDir "$baseName.skill"
        if (-not (Test-Path $skillPath)) {
            Write-Output "| $($baseName.PadRight(24)) | ORPHANED    | Manifest exists but .skill missing |"
        }
    }

    Write-Output ""
    Write-Output "Verification complete."
    exit 0
}

# ─── Package mode ──────────────────────────────────────────────

# Discover skills: direct subdirectories containing SKILL.md
$skills = @()
Get-ChildItem $SkillsRoot -Directory | Where-Object { $excludedDirs -notcontains $_.Name } | ForEach-Object {
    if (Test-Path (Join-Path $_.FullName 'SKILL.md')) {
        $skills += $_.Name
    }
}

Write-Output "Discovered $($skills.Count) skills: $($skills -join ', ')"
Write-Output ""

$results = @()

foreach ($skillName in $skills) {
    $skillDir = Join-Path $SkillsRoot $skillName

    try {
        # Recursively list all files, excluding patterns
        $allFiles = Get-ChildItem $skillDir -Recurse -File | Where-Object {
            $excludedFiles -notcontains $_.Name -and
            $excludedExts -notcontains $_.Extension -and
            $_.DirectoryName -notmatch '[\\/]\.git[\\/]' -and
            $_.DirectoryName -notmatch '[\\/]node_modules[\\/]'
        } | Sort-Object { $_.FullName.Substring($skillDir.Length) }

        if ($allFiles.Count -eq 0) {
            $results += [PSCustomObject]@{ Skill=$skillName; Status='failed'; Size='-'; Error='No files in skill directory' }
            continue
        }

        # Compute per-file hashes and build concat string
        $fileRecords = @()
        $concatString = ''
        foreach ($f in $allFiles) {
            $relativePath = $f.FullName.Substring($skillDir.Length + 1).Replace('\','/')
            $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
            $hasher = [System.Security.Cryptography.SHA256]::Create()
            $hashBytes = $hasher.ComputeHash($bytes)
            $hasher.Dispose()
            $fileHash = [BitConverter]::ToString($hashBytes).Replace('-','').ToLower()

            $fileRecords += [PSCustomObject]@{
                path = $relativePath
                hash = $fileHash
                size = $f.Length
            }
            $concatString += "${relativePath}:${fileHash}`n"
        }

        # Compute directory-level content hash
        $contentHasher = [System.Security.Cryptography.SHA256]::Create()
        $contentBytes = [System.Text.Encoding]::UTF8.GetBytes($concatString)
        $contentHashBytes = $contentHasher.ComputeHash($contentBytes)
        $contentHasher.Dispose()
        $contentHash = [BitConverter]::ToString($contentHashBytes).Replace('-','').ToLower()

        # Check existing manifest (skip if hash matches and not Force)
        $manifestPath = Join-Path $releasesDir "$skillName.manifest.json"
        $needPackage = $true
        if (-not $Force -and (Test-Path $manifestPath)) {
            $existingManifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
            if ($existingManifest.content_hash -eq $contentHash) {
                $needPackage = $false
            }
        }

        if (-not $needPackage) {
            $results += [PSCustomObject]@{ Skill=$skillName; Status='skipped'; Size='(unchanged)'; Error='' }
            continue
        }

        # Create ZIP archive (flattened to root)
        $skillFile = Join-Path $releasesDir "$skillName.skill"
        $tempZip = Join-Path $releasesDir "${skillName}_temp.zip"

        if (Test-Path $tempZip) { Remove-Item $tempZip -Force }
        if (Test-Path $skillFile) { Remove-Item $skillFile -Force }

        # Create ZIP archive — use "$skillDir\*" to preserve subdirectory structure.
        # Passing individual file paths would flatten everything to the ZIP root.
        Compress-Archive -Path (Join-Path $skillDir '*') -DestinationPath $tempZip -Force
        Move-Item -Path $tempZip -Destination $skillFile -Force

        $packageSize = (Get-Item $skillFile).Length

        # Write manifest
        $now = Get-Date
        $tzOffset = [TimeZoneInfo]::Local.GetUtcOffset($now)
        $sign = if ($tzOffset.TotalHours -ge 0) { '+' } else { '-' }
        $isoTimestamp = $now.ToString('yyyy-MM-ddTHH:mm:ss') + "$sign$($tzOffset.ToString('hh\:mm'))"

        # Read frontmatter for version
        $skillContent = Get-Content (Join-Path $skillDir 'SKILL.md') -Raw
        $version = $null
        if ($skillContent -match '(?s)^---.*?version:\s*(.+?)\s*\n.*?---') {
            $version = $Matches[1].Trim()
        }

        $manifest = [PSCustomObject]@{
            skill_name     = $skillName
            hash_algorithm = 'sha256'
            content_hash   = $contentHash
            files          = $fileRecords
            package        = "$skillName.skill"
            package_size   = $packageSize
            released_at    = $isoTimestamp
            skill_version  = $version
        }

        $manifestJson = $manifest | ConvertTo-Json -Depth 5
        [System.IO.File]::WriteAllText($manifestPath, $manifestJson, [System.Text.Encoding]::UTF8)

        $sizeKB = [math]::Round($packageSize / 1024, 1)
        $results += [PSCustomObject]@{ Skill=$skillName; Status='packaged'; Size="${sizeKB} KB"; Error='' }

    } catch {
        $results += [PSCustomObject]@{ Skill=$skillName; Status='failed'; Size='-'; Error=$_.Exception.Message }
    }
}

# Report
Write-Output "| Skill                    | Status    | Package Size |"
Write-Output "|--------------------------|-----------|-------------|"
foreach ($r in $results) {
    $skillPadded = $r.Skill.PadRight(24)
    $statusPadded = $r.Status.PadRight(9)
    $errDetail = if ($r.Error) { " ($($r.Error))" } else { '' }
    Write-Output "| $skillPadded | $statusPadded | $($r.Size)$errDetail |"
}

# Check for orphaned releases
$skillNames = $skills
$existingSkillFiles = Get-ChildItem $releasesDir -Filter '*.skill' -File
foreach ($esf in $existingSkillFiles) {
    $baseName = $esf.BaseName
    if ($skillNames -notcontains $baseName) {
        Write-Output ""
        Write-Output "ORPHANED: $baseName.skill exists in releases/ but no source directory found. Use your judgment to remove or keep."
    }
}
