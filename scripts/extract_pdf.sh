#!/usr/bin/env bash
# extract_pdf.sh — Extract plain text from a PDF using pdftotext.
# Usage: extract_pdf.sh <file.pdf> [output_file]
# Outputs to stdout if no output_file is given.

set -euo pipefail

PDF="${1:?Usage: extract_pdf.sh <file.pdf> [output_file]}"
OUTPUT="${2:-}"

if [[ ! -f "$PDF" ]]; then
  echo "ERROR: File not found: $PDF" >&2
  exit 1
fi

if ! command -v pdftotext &>/dev/null; then
  echo "ERROR: pdftotext is not installed. Install via: sudo apt install poppler-utils" >&2
  exit 1
fi

text=$(pdftotext "$PDF" -)

if [[ -z "$text" ]]; then
  echo "ERROR: pdftotext produced no output. File may be scanned/image-only." >&2
  exit 1
fi

if [[ -n "$OUTPUT" ]]; then
  printf '%s' "$text" > "$OUTPUT"
  echo "Extracted $(printf '%s' "$text" | wc -c) chars → $OUTPUT" >&2
else
  printf '%s\n' "$text"
fi
