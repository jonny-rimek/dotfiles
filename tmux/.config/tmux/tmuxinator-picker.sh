#!/usr/bin/env bash
set -euo pipefail

[ -n "${TMUX:-}" ] || exit 1

export PATH="$HOME/.local/share/mise/shims:$PATH"

command -v tmuxinator >/dev/null 2>&1 || exit 1

entries=$(
	tmuxinator list |
		tail -n +2 |
		tr -s '[:space:]' '\n' |
		sed '/^$/d' |
		while IFS= read -r project; do
			tmux has-session -t "=$project" 2>/dev/null || printf '%s\n' "$project"
		done |
		sort
)
[ -n "$entries" ] || exit 0

fz() {
	if command -v fzf-tmux >/dev/null 2>&1; then
		fzf-tmux -p -w 30% -h 38% "$@"
	else
		fzf "$@"
	fi
}

selection=$(
	printf '%s\n' "$entries" |
		fz --prompt 'mux> ' --header 'enter: start session | esc: cancel'
) || exit 0

[ -n "$selection" ] || exit 0

if tmux has-session -t "=$selection" 2>/dev/null; then
	tmux switch-client -t "=$selection"
	exit 0
fi

tmuxinator start "$selection" -d
tmux switch-client -t "=$selection"
