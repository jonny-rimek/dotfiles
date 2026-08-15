#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

todofile="$1"

"$DIR/list_open.sh" "$todofile" | fzf \
  --delimiter='\t' --with-nth=2.. \
  --header='Space: mark done | Esc: clear/close | Enter: close' \
  --bind "esc:cancel" \
  --bind "space:execute($DIR/mark_done.sh '$todofile' {1})+reload($DIR/list_open.sh '$todofile')+clear-query"
