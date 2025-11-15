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
<!-- - create cheatsheet -->
  <!-- - yazi -->
  <!-- - nvim -->
  <!-- - lazygit -->
  <!-- -  -->
<!-- - manual setup steps in signal document them here or automate -->

<!-- - auto open obsidian in a dedicated workspace always -->
<!-- - auto open protonpass as a web app in a dedicated workspace always -->
<!-- - save my solarized dark background image in this repo-->
<!-- - put solarized themes in stow repo to symlink em -->
<!-- - fix vimium j going up and vice versa map <s-j> NextTab didn''t change the behaviour (or the other one)'-->
<!-- - sync zathora to omarchy/os theme  -->
<!-- - veracrypt alias  -->
<!-- - import old dotfiles  -->
<!-- - integrate stow as a last step and do steps to clean up potentially existing config, only ask for confirmation if there are planned changes -->
<!-- - remove all other themes or not, not sure its a good idea probably gonna break shit-->

<!-- TODO: lazygit  -->
<!-- - somehow overwrite colours? diff is usually fucked, because of alacritty theme -->
<!-- - it's possible, let's use the same colour that is used for nvim to indicate current line -->

<!-- TODO: hyprland -->
<!-- - start every window in fullscreen or smth -->
<!-- - hide status bar by default -->
<!-- - rebind super tab to switch to latest workspace instead of next, currently this is ctrl super tab -->
<!-- - increase notification timeout and window size -->
<!-- - shortcut for shutdown -->
<!-- - shortcut for suspend -->

<!-- - -->
<!-- - switch light theme in the morning -->

<!-- TODO: yazi  -->
<!-- - shortcut to go to ~/dev directory  -->
<!-- - unbind enter and only open with o/O -->

<!-- TODO: nvim -->
<!-- - modularize config, so that omarchy shit stays in place and we only add new stuff via stow -->
  <!-- - remove time, lines and % from nvim theme -->
  <!-- - neotree doesnt update git unless i close and open -->
  <!-- - fuzzy find is actually fucking dog shit dunno, ignores .files doesn't find new files? -->
    <!-- - rebind space space to recent files in neovim / fix up file finding recent behaviour e.g. no dotfiles? recent files from other projects etc -->
  <!-- - increase notification timeout and window size -->
  <!-- - rebind autocomplete to tab not return-->
  <!-- - never hide markdown code shit -->
  <!-- - remove spellcheck -->
  <!-- - no auto complete in .md -->

<!-- - move old config into stowed files -->
<!-- - hide tabs completely -->
<!-- - don't start with neo tree open -->
<!-- - fix theme breaking on every config change -->

<!-- TODO: LOW PRIO  -->
<!-- - install ruby and shit via script and via mise   -->
