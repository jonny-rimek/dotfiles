#!/usr/bin/env bash
#
# install-kilo.sh
# Install Kilo Code CLI (AI coding agent, command-line only) using the official
# installer. No GUI / IDE extension components.
# Source: https://kilo.ai/docs/code-with-ai/platforms/cli
#
# Notes:
# - Installs user-level into ~/.kilo/bin/kilo. Does not require root.
# - The official installer appends `export PATH=~/.kilo/bin:$PATH` to the shell
#   config (.bashrc), but that only affects NEW/RE-SOURCED shells (a running
#   shell keeps its old PATH until restarted). To make `kilo` resolve in any new
#   shell without depending on that shell-config edit, this script ALSO ensures
#   a `kilo` symlink in ~/.local/bin (guaranteed on PATH in omarchy). This is
#   idempotent and works even if the .bashrc PATH line is missing or the user's
#   shell config gets replaced.
# - Idempotent: if `kilo` is present in ~/.kilo/bin and the ~/.local/bin link
#   exists, it is left untouched and its version is reported. Re-run safely.
#
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

require_non_root

KILO_INSTALLER_URL="https://kilo.ai/cli/install"
KILO_BIN="$HOME/.kilo/bin/kilo"         # known install dir written by the installer
PATH_LINK="$HOME/.local/bin/kilo"       # guaranteed-on-PATH symlink for new shells

print_info "Checking Kilo Code CLI installation..."

# 1. Already installed? Skip reinstall and just report the version.
#    Check both the ambient PATH and the known install location, because the
#    installer only updates PATH in new shells.
if command_exists kilo || [ -x "$KILO_BIN" ]; then
  INSTALLED_VERSION=""
  if command_exists kilo; then
    INSTALLED_VERSION=$(kilo --version 2>/dev/null | head -n1)
  elif [ -x "$KILO_BIN" ]; then
    INSTALLED_VERSION=$("$KILO_BIN" --version 2>/dev/null | head -n1)
  fi
  print_success "Kilo Code CLI already installed (${INSTALLED_VERSION:-version unknown})"
else
  print_info "Installing Kilo Code CLI..."
  curl -fsSL "$KILO_INSTALLER_URL" | bash
fi

# 2. Ensure the binary actually landed before claiming success.
if [ ! -x "$KILO_BIN" ]; then
  print_error "Kilo Code CLI installation failed: 'kilo' not found at $KILO_BIN"
  print_info "The installer writes to ~/.kilo/bin; check it was created, then re-run."
  exit 1
fi

# 3. Ensure a guaranteed-on-PATH symlink so `kilo` resolves in ANY new shell,
#    independent of the installer's .bashrc PATH append (which can be lost or
#    replaced, and never reaches already-running shells).
mkdir -p "$HOME/.local/bin"
if [ -e "$PATH_LINK" ] && [ ! -L "$PATH_LINK" ]; then
  print_error "Refusing to overwrite non-symlink at $PATH_LINK"
  exit 1
fi
ln -sfn "$KILO_BIN" "$PATH_LINK"
print_success "Linked $PATH_LINK -> $KILO_BIN"

echo
INSTALLED_VERSION=$("$KILO_BIN" --version 2>/dev/null | head -n1)
print_success "Kilo Code CLI is ready (${INSTALLED_VERSION:-version unknown})"
print_info "Get started with: kilo  (starts working in a new or re-sourced shell)"