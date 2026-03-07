#!/usr/bin/env bash
#
# install-libvips.sh
# Install libvips - fast image processing library (used by Rails Active Storage)
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

PACKAGE_NAME="libvips"

print_info "Checking libvips installation..."

# Check if already installed
if package_installed "$PACKAGE_NAME"; then
  INSTALLED_VERSION=$(pacman -Qi "$PACKAGE_NAME" | grep Version | awk '{print $3}')
  print_success "libvips already installed (version: $INSTALLED_VERSION)"
else
  print_info "Installing libvips..."

  # Install using pacman
  if is_root; then
    pacman -S --needed --noconfirm "$PACKAGE_NAME"
  else
    sudo pacman -S --needed --noconfirm "$PACKAGE_NAME"
  fi

  # Verify installation
  if package_installed "$PACKAGE_NAME"; then
    INSTALLED_VERSION=$(pacman -Qi "$PACKAGE_NAME" | grep Version | awk '{print $3}')
    print_success "libvips installed successfully (version: $INSTALLED_VERSION)"
  else
    print_error "libvips installation failed"
    exit 1
  fi
fi

echo
print_success "libvips is ready to use!"
