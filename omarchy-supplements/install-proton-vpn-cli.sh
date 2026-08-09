#!/usr/bin/env bash
#
# install-proton-vpn-cli.sh
# Install the official Proton VPN CLI for Linux
# Source: https://github.com/ProtonVPN/proton-vpn-cli
# Package: https://archlinux.org/packages/extra/any/proton-vpn-cli/
#
# Notes:
# - Cannot run alongside the Proton VPN GUI app
# - Logs:     ~/.cache/Proton/VPN/logs/
# - Settings: ~/.config/Proton/VPN/
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

PACKAGE_NAME="proton-vpn-cli"

print_info "Checking Proton VPN CLI installation..."

if package_installed "$PACKAGE_NAME"; then
  INSTALLED_VERSION=$(pacman -Qi "$PACKAGE_NAME" | grep Version | awk '{print $3}')
  print_success "Proton VPN CLI already installed (version: $INSTALLED_VERSION)"
else
  print_info "Installing Proton VPN CLI..."

  if is_root; then
    pacman -Sy --noconfirm "$PACKAGE_NAME"
  else
    sudo pacman -Sy --noconfirm "$PACKAGE_NAME"
  fi

  if package_installed "$PACKAGE_NAME"; then
    INSTALLED_VERSION=$(pacman -Qi "$PACKAGE_NAME" | grep Version | awk '{print $3}')
    print_success "Proton VPN CLI installed successfully (version: $INSTALLED_VERSION)"
  else
    print_error "Proton VPN CLI installation failed"
    exit 1
  fi
fi

echo
print_info "Run 'protonvpn-cli login <username>' to get started"
