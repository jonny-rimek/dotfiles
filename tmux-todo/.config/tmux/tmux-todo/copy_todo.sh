#!/usr/bin/env bash
set -euo pipefail

text="$*"

if command -v wl-copy >/dev/null 2>&1 && [ -n "${WAYLAND_DISPLAY:-}" ]; then
  printf '%s' "$text" | wl-copy
elif command -v xclip >/dev/null 2>&1 && [ -n "${DISPLAY:-}" ]; then
  printf '%s' "$text" | xclip -selection clipboard
else
  b64="$(printf '%s' "$text" | base64 | tr -d '\n')"
  printf '\033]52;c;%s\a' "$b64"
fi
