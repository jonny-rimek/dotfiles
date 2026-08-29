#!/usr/bin/env bash
# Loaded via run-shell from ~/.tmux.conf. Defines tmux-todo keybindings.
# All actions use display-popup -E (close popup when the command exits).

DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
BIN="$HOME/.local/bin/todo-tui"

# Add project TODO (prefix+a): resolve git root from current pane, fall back to $HOME
tmux bind-key a run-shell "ROOT=\$(git -C '#{pane_current_path}' rev-parse --show-toplevel 2>/dev/null); [ -z \"\$ROOT\" ] && ROOT='$HOME'; tmux display-popup -E -w 40% -h 5 -T 'Add project TODO' \"bash '$DIR/add.sh' \\\"\$ROOT/TODO.md\\\"\"; exit 0"

# Add system TODO (prefix+A): prompt in a popup, writes to ~/TODO.md
tmux bind-key A display-popup -E -w 40% -h 5 -T 'Add system TODO' "bash '$DIR/add.sh' '$HOME/TODO.md'"

# Search project TODO (prefix+t): resolve git root from current pane, fall back to $HOME
tmux bind-key t run-shell "ROOT=\$(git -C '#{pane_current_path}' rev-parse --show-toplevel 2>/dev/null); [ -z \"\$ROOT\" ] && ROOT='$HOME'; case \"\$ROOT\" in \"\$HOME\") P='~/TODO.md' ;; \"\$HOME\"/*) P=\"~/\${ROOT#\$HOME/}/TODO.md\" ;; *) P=\"\$ROOT/TODO.md\" ;; esac; tmux display-popup -E -w 50% -h 60% -T \"Search project \$P\" \"'$BIN' --file \\\"\$ROOT/TODO.md\\\"\"; exit 0"

# Search system TODO (prefix+T): modal TUI over the system TODO file
tmux bind-key T display-popup -E -w 50% -h 60% -T 'Search system ~/TODO.md' "'$BIN' --file '$HOME/TODO.md'"

# Show all open TODOs (prefix+V): System TODO first, then project TODOs
tmux bind-key V run-shell "tmux display-popup -E -w 50% -h 60% -T 'Open TODOs' \"'$BIN' --all\""
