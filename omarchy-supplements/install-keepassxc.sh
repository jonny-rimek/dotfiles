#!/usr/bin/env bash
#
# install-keepassxc.sh
# Install KeePassXC password manager
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

PACKAGE_NAME="keepassxc"

print_info "Checking KeePassXC installation..."

# Check if already installed
if package_installed "$PACKAGE_NAME"; then
  INSTALLED_VERSION=$(pacman -Qi "$PACKAGE_NAME" | grep Version | awk '{print $3}')
  print_success "KeePassXC already installed (version: $INSTALLED_VERSION)"
  exit 0
fi

print_info "Installing KeePassXC..."

# Install using pacman
if is_root; then
  pacman -Sy --noconfirm "$PACKAGE_NAME"
else
  sudo pacman -Sy --noconfirm "$PACKAGE_NAME"
fi

# Verify installation
if package_installed "$PACKAGE_NAME"; then
  INSTALLED_VERSION=$(pacman -Qi "$PACKAGE_NAME" | grep Version | awk '{print $3}')
  print_success "KeePassXC installed successfully (version: $INSTALLED_VERSION)"

  echo
  print_info "KeePassXC is now installed"
else
  print_error "KeePassXC installation failed"
  exit 1
fi
