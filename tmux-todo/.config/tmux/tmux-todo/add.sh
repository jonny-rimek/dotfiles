#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
# shellcheck source=todo_lib.sh
source "$DIR/todo_lib.sh"

todofile="$1"

# Clear the popup so each entry starts from a blank field.
clear_screen() {
  printf '\033[2J\033[H'
}

# Read one line of input. Aborts (non-zero) on Escape / EOF / Ctrl-D so the
# popup closes without adding anything. UTF-8-aware, handles Backspace.
# LC_ALL=C makes each read -n 1 return exactly one raw byte.
read_line() {
  local text="" byte c v len i b2
  while :; do
    if ! LC_ALL=C IFS= read -r -s -n 1 byte; then
      printf '\n'
      return 1
    fi
    if [[ -z "$byte" ]]; then
      printf '\n'
      break
    fi
    case "$byte" in
      $'\x1b') printf '\n'; return 1 ;;          # Escape: abort
      $'\r' | $'\n') printf '\n'; break ;;       # Enter: accept
      $'\x7f' | $'\x08')                          # Backspace
        if [[ -n "$text" ]]; then
          text="${text%?}"
          printf '\b \b'
        fi
        ;;
      *)
        v="$(printf '%s' "$byte" | od -An -tu1)"
        if   (( v < 128 )); then len=1
        elif (( v < 224 )); then len=2
        elif (( v < 240 )); then len=3
        elif (( v < 248 )); then len=4
        else                      len=1
        fi
        c="$byte"
        for (( i = 1; i < len; i++ )); do
          if ! LC_ALL=C IFS= read -r -s -n 1 b2; then
            len=1
            break
          fi
          c+="$b2"
        done
        text+="$c"
        printf '%s' "$c"
        ;;
    esac
  done
  REPLY="$text"
  return 0
}

clear_screen
while :; do
  if ! read_line; then
    exit 0
  fi
  text="$REPLY"
  if [[ -z "$text" ]]; then
    exit 0
  fi

  ensure_file "$todofile"

  today="$(today)"
  item="- [ ] ${text} <!-- created_at ${today} -->"

  tmpfile="$(mktemp "${todofile}.XXXXXX")"
  trap 'rm -f "$tmpfile"' EXIT

  awk -v item="$item" '
    /^# TODO$/ && !inserted {
      print
      print item
      inserted = 1
      next
    }
    { print }
    END {
      if (!inserted) print item
    }
  ' "$todofile" > "$tmpfile"

  mv "$tmpfile" "$todofile"
  trap - EXIT

  clear_screen
done
