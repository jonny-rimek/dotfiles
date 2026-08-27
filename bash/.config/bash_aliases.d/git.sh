unset -f ga gd 2>/dev/null
unalias gcm gcam gcad 2>/dev/null

gd() { git diff "$@"; }
alias gs="git status"
alias lg="lazygit"
