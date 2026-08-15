#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
# shellcheck source=todo_lib.sh
source "$DIR/todo_lib.sh"

todofile="$1"
lineno="$2"

ensure_file "$todofile"

today="$(today)"

tmpfile="$(mktemp "${todofile}.XXXXXX")"
trap 'rm -f "$tmpfile"' EXIT

awk -v target="$lineno" -v today="$today" '
  function is_open(l) { return l ~ /^\- \[ \] / }
  {
    lines[NR] = $0
  }
  END {
    nl = NR
    if (!(target >= 1 && target <= nl && is_open(lines[target]))) {
      print "mark_done.sh: line " target " is not an open todo" > "/dev/stderr"
      exit 1
    }
    done = lines[target]
    sub(/^\- \[ \] /, "- [x] ", done)
    done = done " <!-- closed_at " today " -->"
    for (i = 1; i <= nl; i++) {
      if (i == target) continue
      print lines[i]
      if (!inserted && lines[i] ~ /^## DONE/) {
        print done
        inserted = 1
      }
    }
    if (!inserted) print done
  }
' "$todofile" > "$tmpfile"

mv "$tmpfile" "$todofile"
trap - EXIT
exit 0
