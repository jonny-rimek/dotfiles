# Atuin shell history - initialize the shell plugin
# Only Ctrl+R invokes atuin; Up arrow keeps normal shell history behaviour
if command -v atuin &>/dev/null; then
  # bash-preexec is required for atuin to record new commands in bash
  [[ -r /usr/share/bash-preexec/bash-preexec.sh ]] && source /usr/share/bash-preexec/bash-preexec.sh
  eval "$(atuin init bash --disable-up-arrow)"
fi
