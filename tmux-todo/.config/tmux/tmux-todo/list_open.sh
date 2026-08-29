#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
# shellcheck source=todo_lib.sh
source "$DIR/todo_lib.sh"

todofile="$1"
ensure_file "$todofile"

lineno=0
while IFS= read -r line; do
  lineno=$((lineno + 1))
  case "$line" in
    "- [ ] "*)
      text="${line#"- [ ] "}"
      text="${text% <!-- created_at *}"
      printf '%s\t%s\n' "$lineno" "$text"
      ;;
  esac
done < "$todofile"
