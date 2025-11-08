#!/usr/bin/env bash
#
# install-tmux.sh
# Install tmux terminal multiplexer
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

PACKAGE_NAME="tmux"

print_info "Checking tmux installation..."

# Check if already installed
if package_installed "$PACKAGE_NAME"; then
  INSTALLED_VERSION=$(pacman -Qi "$PACKAGE_NAME" | grep Version | awk '{print $3}')
  print_success "tmux already installed (version: $INSTALLED_VERSION)"
  exit 0
fi

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

  echo
  print_info "tmux is now installed"
else
  print_error "tmux installation failed"
  exit 1
fi
