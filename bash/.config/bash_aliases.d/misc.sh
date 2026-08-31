unalias ls
unalias lt
unalias lsa
unalias lta
unalias c
unalias cx cy t ic ix icx 2>/dev/null
unset -f fip dip lip tdl tdlm tsl 2>/dev/null

alias l=" eza --long --header -all --group-directories-first --icons=auto --colour=always --git |  less -R"
alias lt="eza --long --header -all --group-directories-first --icons=auto --colour=always --tree --level=2 --git --ignore-glob='.git' | less -R"
alias lt3="eza --long --header -all --group-directories-first --icons=auto --colour=always --tree --level=3 --git --ignore-glob='.git' | less -R"
alias lt4="eza --long --header -all --group-directories-first --icons=auto --colour=always --tree --level=4 --git --ignore-glob='.git' | less -R"

alias c="clear"

alias y="yazi"

alias yt="yt-dlp --cookies-from-browser firefox"

alias sba="source ~/.bashrc"

alias pu="pacman -Syu"

alias yu="ya pkg upgrade"

alias vn="make -C ~/dev/homelab/infrastructure/opnsense vpn-on"
alias vf="make -C ~/dev/homelab/infrastructure/opnsense vpn-off"
