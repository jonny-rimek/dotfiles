unalias ls
unalias lt
unalias lsa
unalias lta

alias l=" eza --long --header -all --group-directories-first --icons=auto --colour=always --git |  less -R"
alias lt="eza --long --header -all --group-directories-first --icons=auto --colour=always --tree --level=2 --git --ignore-glob='.git' | less -R"
alias lt3="eza --long --header -all --group-directories-first --icons=auto --colour=always --tree --level=3 --git --ignore-glob='.git' | less -R"
alias lt4="eza --long --header -all --group-directories-first --icons=auto --colour=always --tree --level=4 --git --ignore-glob='.git' | less -R"
