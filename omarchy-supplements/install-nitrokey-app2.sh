#!/usr/bin/env bash
#
# install-nitrokey-app2.sh
# Install Nitrokey App 2 via pipx (upstream-supported path).
#
# The AUR nitrokey-app2 package is not maintained by Nitrokey and regularly
# breaks against Arch's python-nitrokey — so we install from PyPI into an
# isolated pipx venv instead, and drop in the official udev rules.
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

require_non_root

PIPX_PACKAGE="nitrokeyapp"
UDEV_RULES_URL="https://raw.githubusercontent.com/Nitrokey/nitrokey-udev-rules/main/41-nitrokey.rules"
UDEV_RULES_DEST="/etc/udev/rules.d/41-nitrokey.rules"

# 1. Remove broken AUR package if present.
if package_installed "nitrokey-app2"; then
  print_warning "Removing broken AUR nitrokey-app2 package..."
  sudo pacman -Rns --noconfirm nitrokey-app2
  print_success "AUR nitrokey-app2 removed"
fi

# 2. Ensure pipx is installed.
if ! command_exists pipx; then
  print_info "Installing pipx..."
  sudo pacman -Sy --noconfirm python-pipx
fi
print_success "pipx available ($(pipx --version))"

# 3. Install nitrokeyapp via pipx.
if pipx list --short 2>/dev/null | awk '{print $1}' | grep -qx "$PIPX_PACKAGE"; then
  INSTALLED_VERSION=$(pipx list --short 2>/dev/null | awk -v p="$PIPX_PACKAGE" '$1==p {print $2}')
  print_success "nitrokeyapp already installed via pipx (version: $INSTALLED_VERSION)"
else
  print_info "Installing nitrokeyapp via pipx..."
  pipx install "$PIPX_PACKAGE"
  print_success "nitrokeyapp installed via pipx"
fi

# 4. Install udev rules so the device is accessible without root.
if [ -f "$UDEV_RULES_DEST" ]; then
  print_success "Nitrokey udev rules already in place"
else
  print_info "Installing Nitrokey udev rules..."
  TMP_RULES=$(mktemp)
  trap 'rm -f "$TMP_RULES"' EXIT
  curl -fsSL "$UDEV_RULES_URL" -o "$TMP_RULES"
  sudo install -o root -g root -m 644 "$TMP_RULES" "$UDEV_RULES_DEST"
  sudo udevadm control --reload-rules
  sudo udevadm trigger
  print_success "Nitrokey udev rules installed and reloaded"
fi

echo
print_success "Nitrokey App 2 is ready. Launch with: nitrokeyapp"
