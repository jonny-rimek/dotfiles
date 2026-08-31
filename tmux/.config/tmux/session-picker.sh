#!/usr/bin/env bash
set -euo pipefail

[ -n "${TMUX:-}" ] || exit 1
[ "$(tmux list-sessions -F '#S' | wc -l)" -gt 1 ] || exit 0

current=$(tmux display-message -p '#S')

entries=$(
	tmux list-sessions -F $'#{session_activity}\t#S' |
		sort -t $'\t' -k1,1nr -k2,2 |
		cut -f2- |
		grep -v -x -F -- "$current"
)

fz() {
	if command -v fzf-tmux >/dev/null 2>&1; then
		fzf-tmux -p -w 30% -h 38% "$@"
	else
		fzf "$@"
	fi
}

selection=$(
	printf '%s\n' "$entries" |
		fz --prompt 'session> ' --header 'recently used first | enter: switch | esc: cancel'
) || exit 0

target=$(printf '%s' "$selection" | cut -f1)
[ -n "$target" ] && tmux switch-client -t "$target"
