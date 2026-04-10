#!/usr/bin/env bash
#
# install-rpi-imager.sh
# Install Raspberry Pi Imager
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

PACKAGE_NAME="rpi-imager"

print_info "Checking Raspberry Pi Imager installation..."

# Check if already installed
if package_installed "$PACKAGE_NAME"; then
  INSTALLED_VERSION=$(pacman -Qi "$PACKAGE_NAME" | grep Version | awk '{print $3}')
  print_success "Raspberry Pi Imager already installed (version: $INSTALLED_VERSION)"
else
  print_info "Installing Raspberry Pi Imager..."

  # Install using pacman
  if is_root; then
    pacman -Sy --noconfirm "$PACKAGE_NAME"
  else
    sudo pacman -Sy --noconfirm "$PACKAGE_NAME"
  fi

  # Verify installation
  if package_installed "$PACKAGE_NAME"; then
    INSTALLED_VERSION=$(pacman -Qi "$PACKAGE_NAME" | grep Version | awk '{print $3}')
    print_success "Raspberry Pi Imager installed successfully (version: $INSTALLED_VERSION)"
  else
    print_error "Raspberry Pi Imager installation failed"
    exit 1
  fi
fi
