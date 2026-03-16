#!/usr/bin/env bash
#
# install-chromium.sh
# Install Chromium browser
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

PACKAGE_NAME="chromium"

print_info "Checking Chromium installation..."

# Check if already installed
if package_installed "$PACKAGE_NAME"; then
  INSTALLED_VERSION=$(pacman -Qi "$PACKAGE_NAME" | grep Version | awk '{print $3}')
  print_success "Chromium already installed (version: $INSTALLED_VERSION)"
else
  print_info "Installing Chromium..."

  # Install using pacman
  if is_root; then
    pacman -Sy --noconfirm "$PACKAGE_NAME"
  else
    sudo pacman -Sy --noconfirm "$PACKAGE_NAME"
  fi

  # Verify installation
  if package_installed "$PACKAGE_NAME"; then
    INSTALLED_VERSION=$(pacman -Qi "$PACKAGE_NAME" | grep Version | awk '{print $3}')
    print_success "Chromium installed successfully (version: $INSTALLED_VERSION)"
  else
    print_error "Chromium installation failed"
    exit 1
  fi
fi
