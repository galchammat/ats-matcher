#!/usr/bin/env bash
# apply_diff.sh — Apply a diff plan to the master typst resume, producing a
# tailored working copy. Deterministic: no LLM, no Python.
# Usage: apply_diff.sh <diff_plan.json> <master.typ> <output.typ>

set -euo pipefail

DIFF_PLAN="${1:?Usage: apply_diff.sh <diff_plan.json> <master.typ> <output.typ>}"
MASTER="${2:?Usage: apply_diff.sh <diff_plan.json> <master.typ> <output.typ>}"
OUTPUT="${3:?Usage: apply_diff.sh <diff_plan.json> <master.typ> <output.typ>}"

if [[ ! -f "$DIFF_PLAN" ]]; then
  echo "ERROR: diff plan not found: $DIFF_PLAN" >&2; exit 1
fi
if [[ ! -f "$MASTER" ]]; then
  echo "ERROR: master resume not found: $MASTER" >&2; exit 1
fi
if ! command -v jq &>/dev/null; then
  echo "ERROR: jq is not installed. Install via: sudo apt install jq" >&2; exit 1
fi

mkdir -p "$(dirname "$OUTPUT")"
cp "$MASTER" "$OUTPUT"

# ── Title ─────────────────────────────────────────────────────────────────────
if jq -e '.title.changed == true' "$DIFF_PLAN" >/dev/null; then
  export PROPOSED
  PROPOSED=$(jq -r '.title.proposed' "$DIFF_PLAN")
  current=$(jq -r '.title.current' "$DIFF_PLAN")

  awk '/^#let resume-headline = / {
    print "#let resume-headline = \"" ENVIRON["PROPOSED"] "\""
    next
  } { print }' "$OUTPUT" > "${OUTPUT}.tmp" && mv "${OUTPUT}.tmp" "$OUTPUT"

  echo "Title: \"$current\" → \"$PROPOSED\""
fi

# ── Bullets ───────────────────────────────────────────────────────────────────
applied=0
missed=0
count=$(jq '.bullets | length' "$DIFF_PLAN")

for i in $(seq 0 $((count - 1))); do
  export BEFORE_LINE AFTER_LINE
  BEFORE_LINE="- $(jq -r ".bullets[$i].before" "$DIFF_PLAN")"
  AFTER_LINE="- $(jq -r ".bullets[$i].after" "$DIFF_PLAN")"

  if grep -qF -- "$BEFORE_LINE" "$OUTPUT"; then
    # ENVIRON avoids all sed/awk escape-sequence issues with \, $, &, etc.
    awk '$0 == ENVIRON["BEFORE_LINE"] { print ENVIRON["AFTER_LINE"]; next } { print }' \
      "$OUTPUT" > "${OUTPUT}.tmp" && mv "${OUTPUT}.tmp" "$OUTPUT"
    applied=$((applied + 1))
  else
    echo "WARNING: bullet not found: ${BEFORE_LINE:2:60}" >&2
    missed=$((missed + 1))
  fi
done

echo "Bullets: $applied applied, $missed not found."
echo "Tailored resume written to: $OUTPUT"
[[ $missed -eq 0 ]] || exit 1
