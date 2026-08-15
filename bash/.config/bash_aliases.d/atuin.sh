# Atuin shell history - initialize the shell plugin
# Only Ctrl+R invokes atuin; Up arrow keeps normal shell history behaviour
if command -v atuin &>/dev/null; then
  eval "$(atuin init bash --disable-up-arrow)"
fi
