#!/usr/bin/env bash
#
# install-firefox.sh
# Install Firefox browser
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

PACKAGE_NAME="firefox"

print_info "Checking Firefox installation..."

# Check if already installed
if package_installed "$PACKAGE_NAME"; then
  INSTALLED_VERSION=$(pacman -Qi "$PACKAGE_NAME" | grep Version | awk '{print $3}')
  print_success "Firefox already installed (version: $INSTALLED_VERSION)"
  exit 0
fi

print_info "Installing Firefox..."

# Install using pacman
if is_root; then
  pacman -Sy --noconfirm "$PACKAGE_NAME"
else
  sudo pacman -Sy --noconfirm "$PACKAGE_NAME"
fi

# Verify installation
if package_installed "$PACKAGE_NAME"; then
  INSTALLED_VERSION=$(pacman -Qi "$PACKAGE_NAME" | grep Version | awk '{print $3}')
  print_success "Firefox installed successfully (version: $INSTALLED_VERSION)"
else
  print_error "Firefox installation failed"
  exit 1
fi
