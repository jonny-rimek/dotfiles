# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A dotfiles repository using GNU Stow for symlink management and Git for version control. Each top-level directory is a "stow package" that mirrors the structure it should have relative to `$HOME`.

## Repository Structure

```
TOOLNAME/                    # stow package (e.g., nvim/, tmux/, hypr/)
└── .config/
    └── TOOLNAME/           # configs symlinked to ~/.config/TOOLNAME
        └── ...
```

**Platform-specific packages:** `nvim-mac/` for macOS neovim config, `nvim/` for Linux.

## Stow Commands

```bash
# Preview what stow will do (always do this first)
stow --verbose --simulate --target=$HOME PACKAGE

# Actually stow a package
stow --verbose --target=$HOME PACKAGE

# Unstow (remove symlinks)
stow --verbose --delete --target=$HOME PACKAGE
```

## Adding New Configs

1. Create matching structure: `mkdir -p TOOLNAME/.config`
2. Move existing config: `mv ~/.config/TOOLNAME TOOLNAME/.config/`
3. Preview: `stow --verbose --simulate --target=$HOME TOOLNAME`
4. Apply: `stow --verbose --target=$HOME TOOLNAME`

## Setup Scripts

- **`install-omarchy-supplements.sh`**: Arch Linux setup - runs scripts from `omarchy-supplements/` to install packages and configure the system
- **`install-packages-mac.sh`** / **`stow-packages-mac.sh`**: macOS setup

The `omarchy-supplements/` directory contains individual install scripts that use shared helpers from `helpers.sh`.

## Key Packages

- **hypr/**: Hyprland window manager configs (hyprland.conf, bindings.conf, hyprlock.conf, etc.)
- **nvim/**: Neovim config with Lua plugins in `.config/nvim/lua/plugins/`
- **tmux/**: tmux configuration
- **tmuxinator/**: tmuxinator session layouts
- **bash/**: Bash aliases in `.config/bash_aliases.d/`
- **cheatsheets/**: Personal reference docs (TMUX.md, NVIM.md)
