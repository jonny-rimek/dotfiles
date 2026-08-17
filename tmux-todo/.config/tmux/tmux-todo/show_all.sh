#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
# shellcheck source=todo_lib.sh
source "$DIR/todo_lib.sh"

print_section() {
  local file="$1" label lineno line text
  if [ ! -f "$file" ]; then
    return
  fi
  label="~/${file/#$HOME\//}"
  printf '%s\n' "$label"
  lineno=0
  while IFS= read -r line; do
    lineno=$((lineno + 1))
    case "$line" in
      "- [ ] "*)
        text="${line#- [ ] }"
        text="${text% <!-- created_at *}"
        printf '  %s\n' "$text"
        ;;
    esac
  done < "$file"
  printf '\n'
}

print_section "$HOME/TODO.md"

while IFS= read -r f; do
  [ "$f" = "$HOME/TODO.md" ] && continue
  print_section "$f"
done < <(find "$HOME/dev" -maxdepth 3 -name TODO.md 2>/dev/null | sort)
