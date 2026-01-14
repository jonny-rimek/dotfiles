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
<!-- - switch to zsh  -->
<!-- - make hyprrland background fully opaque -->
<!-- - mpv always fullscreen  -->
<!-- - refactor solarized to work with new colour setup in omarchy -->
<!-- - alias for tmux attach  -->
<!-- - alias for shutdown pc -->
<!-- - import old dotfiles, but only the aliases i actually need  -->
<!-- - nvim 0, jump to first char, not start of the line -->
<!-- - if in tmux session, do tmux fullscreen before opening yazi -->
<!-- - make copy and paste back to ctrl c and ctrl v -->
<!-- - file manager not in full screee -->
<!-- - video player full screen-->
<!-- - https://raine.dev/blog/my-tmux-setup/#core-settings adopt some coresettings -->
<!-- - do some tmux popups e.g. move yazi to tmux popup and move lazygit to popup from tab https://www.youtube.com/watch?v=JMl-WZMCMss -->

<!-- TODO: nvim -->
<!-- - look back into test stuff that typcraft did so that it opened in another tmux pane, but make it split vertically 50/50-->

<!-- - hide tabs completely -->
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
<!-- - https://yazi-rs.github.io/docs/tips/#system-chooser -->

<!-- TODO: hyprland -->
<!-- - switch light theme in the morning -->
