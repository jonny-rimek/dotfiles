#!/usr/bin/env bash
#
# install-wget.sh
# Install wget - network downloader
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

PACKAGE_NAME="wget"

print_info "Checking wget installation..."

# Check if already installed
if package_installed "$PACKAGE_NAME"; then
  INSTALLED_VERSION=$(pacman -Qi "$PACKAGE_NAME" | grep Version | awk '{print $3}')
  print_success "wget already installed (version: $INSTALLED_VERSION)"
else
  print_info "Installing wget..."

  # Install using pacman
  if is_root; then
    pacman -Sy --noconfirm "$PACKAGE_NAME"
  else
    sudo pacman -Sy --noconfirm "$PACKAGE_NAME"
  fi

  # Verify installation
  if package_installed "$PACKAGE_NAME"; then
    INSTALLED_VERSION=$(pacman -Qi "$PACKAGE_NAME" | grep Version | awk '{print $3}')
    print_success "wget installed successfully (version: $INSTALLED_VERSION)"
  else
    print_error "wget installation failed"
    exit 1
  fi
fi

echo
print_success "wget is ready to use!"
