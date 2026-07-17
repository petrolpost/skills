#!/bin/bash
# check_consistency.sh — verify ID uniqueness and cross-reference resolution
# across a requirements-architecture document set.
#
# Usage: ./check_consistency.sh <doc-directory> [prefix1 prefix2 ...]
#   If no prefixes given, checks the default set: REQ NFR CR AC BR OI SM
#   (UC- is checked separately since its format is UC-<Letter><NN>, not UC-<NN>)
#
# Known benign false positive #1: prose that talks ABOUT the numbering
# convention itself (e.g. "new rules start from BR-031") will be flagged
# as an orphaned reference even though it's not a real cross-reference.
#
# Known benign false positive #2: an Open Issue (or other item) that gets
# both a one-line summary table row AND a fuller prose section elsewhere
# in the same chapter (a legitimate "index + detail" pattern for
# high-priority items) will be flagged as a duplicate definition, because
# the script can't distinguish "this row IS the definition" from "this row
# points to a fuller definition below." Eyeball these before deciding
# whether to reformat — usually the fix, if any, is cosmetic (e.g. drop
# the bold/heading markup from the index row so only the detailed section
# is picked up as the definition), not a real content problem.
#
# Both categories are expected and cheap to eyeball-dismiss — the script
# optimizes for catching every real problem, not for zero false positives.
#
# Exit code: 0 if clean, 1 if any problem found.

set -uo pipefail
# Note: deliberately NOT using 'set -e' — grep exits non-zero when it finds
# no matches, which is an expected, normal outcome throughout this script
# (e.g. "no duplicates found"), not an error condition.

DIR="${1:-.}"
shift || true
PREFIXES=("$@")
if [ ${#PREFIXES[@]} -eq 0 ]; then
  PREFIXES=(REQ NFR CR AC BR OI SM)
fi

cd "$DIR"
PROBLEMS=0

echo "=== Checking document set in: $(pwd) ==="
echo ""

# --- 1. Duplicate definitions ---
# A "definition" is a markdown table row starting with "| PREFIX-NNN |"
# or a bold heading "**PREFIX-NNN**" — both patterns used across chapters.
echo "--- Duplicate ID definitions ---"
for p in "${PREFIXES[@]}"; do
  dups=$(grep -ohE "^\| *${p}-[0-9]+ *\||^\*\*${p}-[0-9]+[^*]*\*\*|^#+ +\*{0,2}${p}-[0-9]+" *.md 2>/dev/null \
    | grep -oE "${p}-[0-9]+" | sort | uniq -c | awk '$1>1 {print}')
  if [ -n "$dups" ]; then
    echo "  [$p] Duplicate definitions found:"
    echo "$dups" | sed 's/^/    /'
    PROBLEMS=1
  fi
done
[ "$PROBLEMS" -eq 0 ] && echo "  (none found)"
echo ""

# --- 2. Orphaned references ---
# Any mention of PREFIX-NNN anywhere should have a corresponding definition
# somewhere in the set (checked loosely: does the ID appear at all as a
# defined row/heading anywhere, not just in the "home" chapter).
echo "--- Orphaned references (mentioned but never defined) ---"
for p in "${PREFIXES[@]}"; do
  all_mentions=$(grep -ohE "${p}-[0-9]+" *.md 2>/dev/null | sort -u)
  defined=$(grep -ohE "^\| *${p}-[0-9]+ *\||^\*\*${p}-[0-9]+[^*]*\*\*|^#+ +\*{0,2}${p}-[0-9]+" *.md 2>/dev/null \
    | grep -oE "${p}-[0-9]+" | sort -u)
  orphans=$(comm -23 <(echo "$all_mentions") <(echo "$defined"))
  if [ -n "$orphans" ]; then
    echo "  [$p] Referenced but never defined:"
    echo "$orphans" | sed 's/^/    /'
    PROBLEMS=1
  fi
done
echo ""

# --- 3. UC- special case (format UC-<Letter><NN>) ---
echo "--- UC- use cases (definition = markdown heading, e.g. '**UC-P01 ...**') ---"
uc_mentions=$(grep -ohE "UC-[A-Z][0-9]+" *.md 2>/dev/null | sort -u)
uc_defined=$(grep -ohE "\*\*UC-[A-Z][0-9]+ " *.md 2>/dev/null | grep -oE "UC-[A-Z][0-9]+" | sort -u)
uc_orphans=$(comm -23 <(echo "$uc_mentions") <(echo "$uc_defined"))
if [ -n "$uc_orphans" ]; then
  echo "  Referenced but never defined:"
  echo "$uc_orphans" | sed 's/^/    /'
  PROBLEMS=1
else
  echo "  (none found)"
fi
echo ""

# --- 4. Highest number per prefix (useful when assigning new IDs) ---
echo "--- Highest existing number per prefix (use this + 1 for new IDs) ---"
for p in "${PREFIXES[@]}"; do
  highest=$(grep -ohE "${p}-[0-9]+" *.md 2>/dev/null | grep -oE "[0-9]+$" | sort -n | tail -1)
  if [ -n "$highest" ]; then
    printf "  %-5s highest = %s  (next new ID: %s-%03d)\n" "$p" "$highest" "$p" $((10#$highest + 1))
  fi
done
echo ""

if [ "$PROBLEMS" -eq 0 ]; then
  echo "=== ✅ Clean: no duplicates, no orphaned references ==="
  exit 0
else
  echo "=== ❌ Problems found — fix before presenting to the user ==="
  exit 1
fi
