# AGENTS.md

Guidance for AI coding agents working in this dotfiles repo.

## What this repo is

Dotfiles managed with **GNU Stow** + Git. Each top-level directory is a *stow
package* mirroring the path it should have relative to `$HOME` (typically
`TOOLNAME/.config/TOOLNAME/...`). No build system, no tests.

## Stow workflow (the core operation here)

```bash
# ALWAYS simulate first — never stow blind
stow --verbose --simulate --target=$HOME PACKAGE
stow --verbose --target=$HOME PACKAGE            # apply
stow --verbose --delete --target=$HOME PACKAGE   # unstow
```

- Stow fails on conflicts with pre-existing real files/dirs at the target.
  Move conflicting files out first, or use `--adopt` only when you understand it.
- `stow .` / `stow <package>` are different: `stow .` stows *every* top-level
  dir as a package. Prefer stowing a single named package.
- Adding a new config: `mkdir -p TOOLNAME/.config && mv ~/.config/TOOLNAME TOOLNAME/.config/`,
  then simulate → stow.

## Platform split

- Root install scripts are platform-gated and will `exit 1` off-platform:
  - `install-omarchy-supplements.sh` → Arch Linux / Omarchy only (checks
    `/etc/arch-release`).

## Install script conventions

- `omarchy-supplements/` has its **own** `helpers.sh` (color print helpers,
  `require_root`/`require_non_root`, pacman checks). Source the one next to the
  script, not a repo-root one — there is no repo-root `helpers.sh`.
- To enable/disable an Omarchy supplement, edit the `SUPPLEMENT_SCRIPTS`
  array in `install-omarchy-supplements.sh` (order matters; scripts run in
  array order). Disabled entries are commented out, e.g. `clean-nvim.sh`.
- Supplement scripts are Arch/pacman-based; many use `require_root` and are
  invoked with sudo by the runner or individually.
- Scripts are designed to be **idempotent** — re-running is safe. Preserve
  that property when editing.

## .gitignore rules worth knowing

- `yazi/.config/yazi/*` is ignored **except** `yazi.toml`, `keymap.toml`,
  `theme.toml`, `init.lua`, `package.toml`. Other yazi state is local-only.
- `tmuxinator/.config/tmuxiner/sc-*` (session layouts) are ignored.
- `/.kilo` (local Kilo plugin install / node_modules) is ignored.

## Key packages

- `hypr/` — Hyprland config. End-user edits here should follow the `omarchy`
  skill (load it for window-manager / `~/.config/hypr` work).
- `nvim/` — Neovim; Lua plugins live in `.config/nvim/lua/plugins/`.
- `tmux/`, `tmuxinator/` — tmux config and session layouts.
- `bash/` — aliases split by topic in `.config/bash_aliases.d/*.sh` (git, aws,
  rails, tmux, stow, vpn, ...). Add new aliases as a new file or extend an
  existing themed file.
- `kilo/` — Kilo CLI config (`kilo.json`) + vendored agent plugins
  (`plugins/atuin.ts`, Atuin history hook; see `ai-docs/atuin-kilo-hook.md`).
- `llamacpp/` — local llama.cpp LLM server (gemma-4-26B-A4B QAT): systemd user
  unit, model download script, `llm*` bash helpers (see
  `ai-docs/llama-cpp-local-llm.md` for ops/tuning).
- `omarchy/` — Omarchy hooks only (`~/.config/omarchy/hooks/theme-set.d/`), e.g. the
  kilo theme-sync hook that SIGUSR2s running kilo TUIs after `omarchy theme set`.
- `cheatsheets/` — **human-written** personal reference docs (`TMUX.md`, `NVIM.md`,
  `YAZI.md`), not machine config. AI agents must NEVER add or generate docs here —
  agent-written operational docs belong in `ai-docs/`.
- `ai-docs/` — operational docs written by AI agents for AI agents
  (integration notes, breakage modes, fix recipes). Repo-only, NOT a stow
  package — never stow it.

## Conventions

- Shell scripts: `set -e`, `#!/usr/bin/env bash`, source the sibling
  `helpers.sh`, use `print_*` helpers for output. Match the existing style.
- No comments unless asked (matches repo style — scripts use comment headers
  sparingly).
- When editing config that is also managed by Omarchy upstream
  (`~/.local/share/omarchy/`), prefer the user-facing `~/.config/` overrides;
  the `omarchy` skill covers what's safe to touch.
