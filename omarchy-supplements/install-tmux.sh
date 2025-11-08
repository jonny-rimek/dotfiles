#!/usr/bin/env bash
#
# install-tmux.sh
# Install tmux terminal multiplexer with TPM (Tmux Plugin Manager)
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

PACKAGE_NAME="tmux"
TPM_DIR="$HOME/.tmux/plugins/tpm"

print_info "Checking tmux installation..."

# Check if already installed
if package_installed "$PACKAGE_NAME"; then
  INSTALLED_VERSION=$(pacman -Qi "$PACKAGE_NAME" | grep Version | awk '{print $3}')
  print_success "tmux already installed (version: $INSTALLED_VERSION)"
else
  print_info "Installing tmux..."

  # Install using pacman
  if is_root; then
    pacman -Sy --noconfirm "$PACKAGE_NAME"
  else
    sudo pacman -Sy --noconfirm "$PACKAGE_NAME"
  fi

  # Verify installation
  if package_installed "$PACKAGE_NAME"; then
    INSTALLED_VERSION=$(pacman -Qi "$PACKAGE_NAME" | grep Version | awk '{print $3}')
    print_success "tmux installed successfully (version: $INSTALLED_VERSION)"
  else
    print_error "tmux installation failed"
    exit 1
  fi
fi

echo

# Install TPM (Tmux Plugin Manager)
print_info "Checking TPM (Tmux Plugin Manager) installation..."

if [ -d "$TPM_DIR" ]; then
  print_success "TPM already installed at $TPM_DIR"
else
  print_info "Installing TPM..."

  # Clone TPM repository
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"

  if [ -d "$TPM_DIR" ]; then
    print_success "TPM installed successfully"
  else
    print_error "TPM installation failed"
    exit 1
  fi
fi

echo
print_success "tmux and TPM installation complete!"
