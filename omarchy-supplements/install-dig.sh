#!/usr/bin/env bash
#
# install-dig.sh
# Install dig (bind) - DNS lookup utility
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

PACKAGE_NAME="bind"

print_info "Checking dig installation..."

# Check if already installed
if package_installed "$PACKAGE_NAME"; then
  INSTALLED_VERSION=$(pacman -Qi "$PACKAGE_NAME" | grep Version | awk '{print $3}')
  print_success "dig already installed (version: $INSTALLED_VERSION)"
else
  print_info "Installing dig (bind)..."

  # Install using pacman
  if is_root; then
    pacman -Sy --noconfirm "$PACKAGE_NAME"
  else
    sudo pacman -Sy --noconfirm "$PACKAGE_NAME"
  fi

  # Verify installation
  if package_installed "$PACKAGE_NAME"; then
    INSTALLED_VERSION=$(pacman -Qi "$PACKAGE_NAME" | grep Version | awk '{print $3}')
    print_success "dig installed successfully (version: $INSTALLED_VERSION)"
  else
    print_error "dig installation failed"
    exit 1
  fi
fi

echo
print_success "dig is ready to use!"
