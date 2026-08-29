# Atuin shell history - initialize the shell plugin
# Only Ctrl+R invokes atuin; Up arrow keeps normal shell history behaviour
if command -v atuin &>/dev/null; then
  # bash-preexec is required for atuin to record new commands in bash
  [[ -r /usr/share/bash-preexec/bash-preexec.sh ]] && source /usr/share/bash-preexec/bash-preexec.sh
  eval "$(atuin init bash --disable-up-arrow)"
  # Kilo command history, recorded via the atuin agent hook plugin
  alias kh="atuin search --author opencode -- ''"

  khf() {
    local sel
    sel=$(atuin search --author opencode --print0 --cmd-only -- '' | fzf --read0 --height=60% --layout=reverse) || return
    printf '%s\n' "$sel"
    read -rep "run? [y/N] "
    [[ $REPLY == [yY] ]] && eval "$sel"
  }
fi
