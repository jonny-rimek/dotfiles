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

## Manual steps after successful install

- proton login 
- firefox login
- obsidian login 
- kagi default search engine kagi default seach engine https://help.kagi.com/kagi/getting-started/setting-default/firefox-desktop.html

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
  <!-- - obsidian -->
  <!-- -  -->


<!-- TODO: nvim -->
<!-- - remove time, lines and % from nvim theme -->
<!-- - use youtuber thing where it shows recent files -->
<!-- - increase notification timeout and window size -->
<!-- - rebind autocomplete to tab not return-->
<!-- - never hide markdown code shit -->
<!-- - remove spellcheck -->
<!-- - no auto complete in .md -->

<!-- - move old config into stowed files -->
<!-- - hide tabs completely -->
<!-- - don't start with neo tree open -->
<!-- - fix theme breaking on every config change -->

<!-- TODO: obsidian  -->
<!-- - move plugins to stow -->
<!-- - switch minimal theme based on os theme -->

<!-- - update font to same as omarchy -->
<!-- - install community plugins, via config files if possible -->
  <!-- Advanced Tables -->
  <!-- Automatic Table Of Contents -->
  <!-- Better Command Palette -->
  <!-- BRAT -->
  <!-- Checkbox Reorder -->
  <!-- Improved VimCursor -->
  <!-- Lazy Plugin Loader -->
  <!-- Mini Vimrc -->
  <!-- Remember cursor position -->
  <!-- Style Settings -->
  <!-- Update time on edit -->
  <!-- Vimium -->
  <!-- Vimrc Support -->
  <!-- Zen -->


<!-- TODO: LOW PRIO  -->
<!-- - auto open protonpass as a web app in a dedicated workspace always -->
<!-- - use ai to regenerate background image with solarized light colours -->
<!-- - fix vimium j going up and vice versa map <s-j> NextTab didn''t change the behaviour (or the other one)'-->
<!-- - sync zathora to omarchy/os theme  -->
<!-- - veracrypt alias  -->
  <!-- sudo mkdir -p /mnt/veracrypt1 -->
  <!-- veracrypt /run/media/jonny/Elements/p2 /mnt/veracrypt1 -->
  <!-- cd /mnt/veracrypt1 -->
  <!-- nautilus . -->
<!-- - import old dotfiles  -->
<!-- - integrate stow as a last step and do steps to clean up potentially existing config, only ask for confirmation if there are planned changes -->
<!-- - remove all other themes or not, not sure its a good idea probably gonna break shit-->
<!-- - download all repos to ~/dev if they don't exist yet -->
<!-- - install solarized themes https://github.com/Gazler/omarchy-solarized-theme and light via cli -->
<!-- - remap ctrl a to super a -->
<!-- - proton drive? -->
<!-- firefox -->
  <!-- https://kagi.com/assistant/d07a235a-8b08-4aaa-9cfb-8299e8c4beb4 -->
  <!-- widget.content.gtk-theme-override → Should be empty (not set) -->
  <!-- ui.systemUsesDarkTheme → Should be unset or match your preference (0=light, 1=dark) -->
  <!-- layout.css.prefers-color-scheme.content-override → Should be 2 (system) not 0 (dark) -->

<!-- - install ruby and shit via script and via mise   -->

<!-- TODO: yazi  -->

<!-- TODO: hyprland -->
<!-- - switch light theme in the morning -->
