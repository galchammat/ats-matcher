#!/usr/bin/env bash
# build.sh — Compile a Typst resume source file to PDF.
# Usage: build.sh <input.typ> <output.pdf>

set -euo pipefail

INPUT="${1:?Usage: build.sh <input.typ> <output.pdf>}"
OUTPUT="${2:?Usage: build.sh <input.typ> <output.pdf>}"

if ! command -v typst &>/dev/null; then
  echo "ERROR: typst is not installed." >&2
  echo "Install: curl -fsSL https://github.com/typst/typst/releases/latest/download/typst-x86_64-unknown-linux-musl.tar.xz | tar -xJ && mv typst-*/typst ~/.local/bin/" >&2
  exit 1
fi

typst compile "$INPUT" "$OUTPUT"
echo "PDF compiled: $OUTPUT"
