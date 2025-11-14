# Tmuxinator convenience function - automatically runs 'start'
mux() {
  tmuxinator start "$@"
}
# Custom completion for mux - shows projects
_mux_complete() {
  local cur
  cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=($(compgen -W "$(tmuxinator list | tail -n +2)" -- "$cur"))
}
complete -F _mux_complete mux

alias md="tmuxinator dotfiles"
alias mt="tmuxinator tn4"
alias mc="tmuxinator config"
