#!/usr/bin/env bash
# scrape_job.sh — Fetch plain text from a job posting URL via curl.
# Usage: scrape_job.sh <url> [output_file]
# Exits non-zero if content appears to be a login wall or is too short.
# If curl misses JS-rendered content, the pipeline halts and reports it.

set -euo pipefail

URL="${1:?Usage: scrape_job.sh <url> [output_file]}"
OUTPUT="${2:-}"
MIN_CHARS=500

raw=$(curl -fsSL \
  --max-time 30 \
  --compressed \
  -A "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
  "$URL" 2>/dev/null) || {
  echo "SCRAPE_FAILED: curl failed for URL: $URL" >&2
  exit 1
}

# Strip HTML tags, collapse blank lines, trim whitespace
text=$(printf '%s' "$raw" \
  | sed 's/<[^>]*>//g' \
  | sed 's/&amp;/\&/g; s/&lt;/</g; s/&gt;/>/g; s/&nbsp;/ /g; s/&#[0-9]*;//g' \
  | sed '/^[[:space:]]*$/d' \
  | sed 's/^[[:space:]]*//')

char_count=${#text}

if [[ $char_count -lt $MIN_CHARS ]]; then
  echo "SCRAPE_FAILED: Content too short (${char_count} chars). Page likely requires JavaScript rendering or login." >&2
  exit 1
fi

# Detect login walls and JS-required pages
if printf '%s' "$text" | grep -qiE \
  "(please enable javascript|sign in to view|log in to view|access denied|login to continue|enable cookies|verify you are human)"; then
  echo "SCRAPE_FAILED: Page appears to require login or JavaScript. Provide job text manually." >&2
  exit 1
fi

if [[ -n "$OUTPUT" ]]; then
  printf '%s' "$text" > "$OUTPUT"
  echo "Scraped ${char_count} characters → $OUTPUT" >&2
else
  printf '%s\n' "$text"
fi
