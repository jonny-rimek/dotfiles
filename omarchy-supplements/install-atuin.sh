#!/usr/bin/env bash
#
# install-atuin.sh
# Install atuin - magical shell history (SQLite-based, with sync)
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

PACKAGE_NAME="atuin"

print_info "Checking atuin installation..."

# Check if already installed
if command_exists "$PACKAGE_NAME"; then
  INSTALLED_VERSION=$($PACKAGE_NAME --version | awk '{print $2}')
  print_success "atuin already installed (version: $INSTALLED_VERSION)"
else
  print_info "Installing atuin..."

  # Install using pacman
  if is_root; then
    pacman -Sy --noconfirm "$PACKAGE_NAME"
  else
    sudo pacman -Sy --noconfirm "$PACKAGE_NAME"
  fi

  # Verify installation
  if command_exists "$PACKAGE_NAME"; then
    INSTALLED_VERSION=$($PACKAGE_NAME --version | awk '{print $2}')
    print_success "atuin installed successfully (version: $INSTALLED_VERSION)"
  else
    print_error "atuin installation failed"
    exit 1
  fi
fi

echo

# bash-preexec is required for atuin to record commands in bash
PREEXEC_PACKAGE="bash-preexec"

print_info "Checking bash-preexec installation..."

if package_installed "$PREEXEC_PACKAGE"; then
  print_success "bash-preexec already installed"
else
  print_info "Installing bash-preexec..."

  if is_root; then
    pacman -Sy --noconfirm "$PREEXEC_PACKAGE"
  else
    sudo pacman -Sy --noconfirm "$PREEXEC_PACKAGE"
  fi

  if package_installed "$PREEXEC_PACKAGE"; then
    print_success "bash-preexec installed successfully"
  else
    print_error "bash-preexec installation failed"
    exit 1
  fi
fi

echo

# Configure shell plugin (bash uses the stowed bash_aliases.d mechanism)
ALIASES_FILE="$HOME/.config/bash_aliases.d/atuin.sh"
print_info "Checking atuin shell plugin configuration..."

if [ -f "$ALIASES_FILE" ] && grep -q "atuin init" "$ALIASES_FILE"; then
  if grep -q "bash-preexec" "$ALIASES_FILE"; then
    print_success "atuin shell plugin already configured (with bash-preexec)"
  else
    print_warning "atuin.sh does not source bash-preexec - recording will not work!"
    print_info "  It should source /usr/share/bash-preexec/bash-preexec.sh before atuin init"
  fi
else
  print_warning "atuin.sh not found in ~/.config/bash_aliases.d/ - remember to run stow!"
  print_info "  It should contain: eval \"\$(atuin init bash)\""
fi

# Check atuin config (stowed from the atuin package)
ATUIN_CONFIG="$HOME/.config/atuin/config.toml"
if [ -f "$ATUIN_CONFIG" ] && grep -q '\[tmux\]' "$ATUIN_CONFIG"; then
  print_success "atuin config stowed (tmux popup enabled)"
else
  print_warning "atuin config not found at ~/.config/atuin/config.toml - remember to run stow!"
fi

echo

# Import existing shell history into atuin
print_info "Importing existing shell history..."
atuin import auto

if [ $? -eq 0 ]; then
  print_success "Shell history imported successfully"
else
  print_warning "History import had issues (non-fatal)"
fi

echo
print_success "atuin installation complete!"

echo
print_info "Next steps:"
echo "  • Run 'stow --target=\$HOME atuin bash' if not stowed yet"
echo "  • Restart your shell to start recording history"
