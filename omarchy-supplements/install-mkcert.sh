#!/usr/bin/env bash
#
# install-mkcert.sh
# Install mkcert for locally-trusted development certificates
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

PACKAGE_NAME="mkcert"

print_info "Checking mkcert installation..."

# Check if already installed
if package_installed "$PACKAGE_NAME"; then
  INSTALLED_VERSION=$(pacman -Qi "$PACKAGE_NAME" | grep Version | awk '{print $3}')
  print_success "mkcert already installed (version: $INSTALLED_VERSION)"
else
  print_info "Installing mkcert..."

  if is_root; then
    pacman -Sy --noconfirm "$PACKAGE_NAME"
  else
    sudo pacman -Sy --noconfirm "$PACKAGE_NAME"
  fi

  if package_installed "$PACKAGE_NAME"; then
    INSTALLED_VERSION=$(pacman -Qi "$PACKAGE_NAME" | grep Version | awk '{print $3}')
    print_success "mkcert installed successfully (version: $INSTALLED_VERSION)"
  else
    print_error "mkcert installation failed"
    exit 1
  fi
fi

echo

# Install nss for browser trust store support (Firefox/Chrome)
print_info "Checking nss (required for browser trust)..."

if package_installed "nss"; then
  print_success "nss already installed"
else
  print_info "Installing nss..."

  if is_root; then
    pacman -Sy --noconfirm nss
  else
    sudo pacman -Sy --noconfirm nss
  fi

  if package_installed "nss"; then
    print_success "nss installed successfully"
  else
    print_error "nss installation failed"
    exit 1
  fi
fi

echo

# Install the local CA into the system trust store
print_info "Installing local CA into system trust store..."

mkcert -install

print_success "Local CA installed"

echo
print_success "mkcert installation complete!"
print_info "Usage: mkcert localhost 127.0.0.1 ::1"
