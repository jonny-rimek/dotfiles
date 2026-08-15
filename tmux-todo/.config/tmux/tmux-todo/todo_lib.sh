#!/usr/bin/env bash

today() {
  date +%d.%m.%Y
}

ensure_file() {
  local file="$1" tmp
  if [[ ! -f "$file" ]]; then
    mkdir -p "$(dirname "$file")"
    printf '# TODO\n\n## DONE\n' > "$file"
    return
  fi
  if [[ ! -s "$file" ]]; then
    printf '# TODO\n\n## DONE\n' > "$file"
    return
  fi
  if ! grep -q '^# TODO' "$file"; then
    tmp="$(mktemp "${file}.XXXXXX")"
    { printf '# TODO\n\n'; cat "$file"; } > "$tmp"
    mv "$tmp" "$file"
  fi
  if ! grep -q '^## DONE' "$file"; then
    printf '\n## DONE\n' >> "$file"
  fi
}

git_root() {
  git -C "$1" rev-parse --show-toplevel 2>/dev/null
}
