# Tmuxinator convenience function - automatically runs 'start'
mux() {
  tmuxinator start "$@"
}
# Custom completion for mux - shows projects that are not already running
_mux_complete() {
  local cur
  cur="${COMP_WORDS[COMP_CWORD]}"
  local projects
  projects=$(
    tmuxinator list |
      tail -n +2 |
      tr -s '[:space:]' '\n' |
      while IFS= read -r project; do
        tmux has-session -t "=$project" 2>/dev/null || printf '%s\n' "$project"
      done
  )
  COMPREPLY=($(compgen -W "$projects" -- "$cur"))
}
complete -F _mux_complete mux

alias ta="tmux attach"
