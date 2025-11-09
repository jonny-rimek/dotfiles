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


<!-- TODO: misc -->
<!-- - create tmux cheatsheet -->
  <!-- - rebind eza aliases -->

<!-- - save my solarized dark background image in this repo-->
<!-- - put solarized themes in stow repo to symlink em -->
<!-- - fix vimium j going up and vice versa map <s-j> NextTab didn''t change the behaviour (or the other one)'-->
<!-- - sync zathora to omarchy theme  -->
<!-- - veracrypt alias  -->
<!-- - import old dotfiles  -->
<!-- - integrate stow as a last step and do steps to clean up potentially existing config, only ask for confirmation if there are planned changes -->
<!-- - remove all other themes or not, not sure its a good idea probably gonna break shit-->

<!-- TODO: nvim -->
<!-- - increase notification timeout and window size -->
<!-- - fix theme breaking on every config change -->
<!-- - rebind space space to recent files in neovim -->
<!-- - rebind autocomplete to tab not return-->
<!-- - remove time, (git?), lines and % from nvim theme -->
<!-- - never hide markdown code shit -->
<!-- - remove spellcheck from -->
<!-- - no auto complete in .md -->
<!-- - hide tabs completely -->
<!-- - modularize config, so that omarchy shit stays in place and we only add new stuff via stow -->

<!-- TODO: hyprland -->
<!-- - move all hyprland config to dedicated file, managed by stow, and create a script that adds the import idempotently   -->
<!-- - increase notification timeout and window size -->
<!-- - always hide status bar of -->
<!-- - switch light theme in the morning -->
<!-- - -->
<!-- - -->

<!-- TODO: LOW PRIO  -->
<!-- - install ruby and shit via script and via mise   -->
