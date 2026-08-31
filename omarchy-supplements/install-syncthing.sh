#!/usr/bin/env bash
#
# install-syncthing.sh
# Install Syncthing (KeePassXC vault sync client)
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

PACKAGE_NAME="syncthing"

print_info "Checking Syncthing installation..."

# Check if already installed
if package_installed "$PACKAGE_NAME"; then
  INSTALLED_VERSION=$(pacman -Qi "$PACKAGE_NAME" | grep Version | awk '{print $3}')
  print_success "Syncthing already installed (version: $INSTALLED_VERSION)"
  exit 0
fi

print_info "Installing Syncthing..."

# Install using pacman
if is_root; then
  pacman -Sy --noconfirm "$PACKAGE_NAME"
else
  sudo pacman -Sy --noconfirm "$PACKAGE_NAME"
fi

# Verify installation
if package_installed "$PACKAGE_NAME"; then
  INSTALLED_VERSION=$(pacman -Qi "$PACKAGE_NAME" | grep Version | awk '{print $3}')
  print_success "Syncthing installed successfully (version: $INSTALLED_VERSION)"

  echo
  print_info "Syncthing is now installed"
  print_info "Next steps:"
  print_info "  1. stow the syncthing package (seeds ~/Documents/.stignore allowlist)"
  print_info "  2. systemctl --user enable --now syncthing.service"
  print_info "  3. pair with the Pi hub in the GUI (http://127.0.0.1:8384)"
  print_info "     device address: tcp://192.168.40.10:22000"
else
  print_error "Syncthing installation failed"
  exit 1
fi
