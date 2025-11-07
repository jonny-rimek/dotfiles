#!/usr/bin/env bash
#
# install-veracrypt.sh
# Install VeraCrypt disk encryption software
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

PACKAGE_NAME="veracrypt"

print_info "Checking VeraCrypt installation..."

# Check if already installed
if package_installed "$PACKAGE_NAME"; then
  INSTALLED_VERSION=$(pacman -Qi "$PACKAGE_NAME" | grep Version | awk '{print $3}')
  print_success "VeraCrypt already installed (version: $INSTALLED_VERSION)"
  exit 0
fi

print_info "Installing VeraCrypt..."

# Install using pacman
if is_root; then
  pacman -Sy --noconfirm "$PACKAGE_NAME"
else
  sudo pacman -Sy --noconfirm "$PACKAGE_NAME"
fi

# Verify installation
if package_installed "$PACKAGE_NAME"; then
  INSTALLED_VERSION=$(pacman -Qi "$PACKAGE_NAME" | grep Version | awk '{print $3}')
  print_success "VeraCrypt installed successfully (version: $INSTALLED_VERSION)"

  echo
  print_info "VeraCrypt is now installed"
  print_info "Launch with: veracrypt"
  print_info "Or find it in your application menu"
else
  print_error "VeraCrypt installation failed"
  exit 1
fi
