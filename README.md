# Git repo to manage config files and setup scripts

## Add a new dotfile to the repo to be consumed by GNU stow 

```
# Change into this directory, path might be different
cd ~/dev/dotfiles

# 1. Find where the config actually lives
ls -la ~/.config/TOOLNAME

# 2. Create the matching structure in dotfiles
mkdir -p TOOLNAME/.config

# 3. Move the config
mv ~/.config/TOOLNAME TOOLNAME/.config/

# 4. Prepare to stow it, inspect the plan!
stow --verbose --simulate --target=$HOME TOOLNAME

# 5. Actually stow it, if the plan looks good
stow --verbose --target=$HOME TOOLNAME
```


## Setup for mac

```
install-packages-mac.sh
stow-packages-mac.sh
```


<!-- TODO:  -->
<!-- - install tmux -->
<!-- - save my solarized dark background image in this repo-->
<!-- - create tmux cheatsheet -->
<!-- - always show hidden files neotree -->
<!-- - no border by default if window is maximized? -->
<!-- - move nvim config back and modularize it-->
<!-- - remove time and date from tmux theme -->
<!-- - increase notification timeout and window size -->
<!-- - remove time, lines and % from nvim theme -->
<!-- - tmux theme solarized dark -->
<!-- - always hide status bar of hyprland -->
<!-- - fix vimium j going up and vice versa map <s-j> NextTab didn''t change the behaviour (or the other one)'-->
<!-- - rebind autocomplete to tab not return-->
<!-- - move nvim config back and modularize it-->
<!-- - remove time and date from tmux theme -->
<!-- - remove time, lines and % from nvim theme -->
<!-- - tmux theme solarized dark -->
<!-- - always hide status bar of hyprland -->
<!-- - fix vimium j going up and vice versa map <s-j> NextTab didn''t change the behaviour (or the other one)'-->
<!-- - rebind autocomplete to tab not return-->
<!-- - hide tabs completely -->
<!-- - rebind space space to recent files in neovim -->
<!-- - never hide markdown code shit -->
<!-- - alias for stow simulate and for realz -->
<!-- - move all hyprland config to dedicated file, managed by stow, and create a script that adds the import idempotently   -->
<!-- - switch light theme in the morning -->
<!-- - integrate stow as a last step and do steps to clean up potentially existing config, only ask for confirmation if there are planned changes -->
<!-- - sync zathora to omarchy theme  -->
<!-- - import old dotfiles  -->
<!-- - veracrypt alias  -->
<!-- - remove spellcheck from nvim-->
<!-- - no auto complete in .md -->
<!-- - -->
<!-- - -->
<!-- - -->

<!-- TODO: LOW PRIO  -->
<!-- - install ruby and shit via script and via mise   -->
