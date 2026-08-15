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

# Configure shell plugin (bash uses the stowed bash_aliases.d mechanism)
ALIASES_FILE="$HOME/.config/bash_aliases.d/atuin.sh"
print_info "Checking atuin shell plugin configuration..."

if [ -f "$ALIASES_FILE" ] && grep -q "atuin init" "$ALIASES_FILE"; then
  print_success "atuin shell plugin already configured"
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
