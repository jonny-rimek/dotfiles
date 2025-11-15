#!/usr/bin/env bash
#
# tmuxinator-startup.sh
# Automatically start tmuxinator sessions on Hyprland login
#

# Sessions to start (edit this array)
SESSIONS=(
  "dotfiles"
  "config"
  "tn4"
)

PRIMARY="dotfiles"

# Check if tmux server is running
if ! pgrep -x tmux >/dev/null; then
  # Start first session normally to create tmux server
  tmuxinator start "${SESSIONS[0]}" -d

  # Start remaining sessions
  for session in "${SESSIONS[@]:1}"; do
    tmuxinator start "$session" -d
  done
else
  # Tmux server exists, only start missing sessions
  for session in "${SESSIONS[@]}"; do
    if ! tmux has-session -t "$session" 2>/dev/null; then
      tmuxinator start "$session" -d
    fi
  done
fi

alacritty -e tmux attach-session -t "$PRIMARY"
