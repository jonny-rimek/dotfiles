#!/usr/bin/env bash
#
# install-bluetui.sh
# Install bluetui - TUI for managing Bluetooth on Linux
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# Packages needed
PACKAGES=(
  "bluez"       # Bluetooth protocol stack
  "bluez-utils" # Bluetooth utilities (bluetoothctl)
  "bluetui"     # TUI for Bluetooth management
)

print_info "Checking bluetui installation..."

# Track what needs to be installed
TO_INSTALL=()
ALREADY_INSTALLED=()

for PACKAGE in "${PACKAGES[@]}"; do
  if package_installed "$PACKAGE"; then
    VERSION=$(pacman -Qi "$PACKAGE" | grep Version | awk '{print $3}')
    ALREADY_INSTALLED+=("$PACKAGE ($VERSION)")
  else
    TO_INSTALL+=("$PACKAGE")
  fi
done

# Show what's already installed
if [ ${#ALREADY_INSTALLED[@]} -gt 0 ]; then
  print_success "Already installed:"
  for pkg in "${ALREADY_INSTALLED[@]}"; do
    echo "  ✓ $pkg"
  done
  echo
fi

# Install missing packages
if [ ${#TO_INSTALL[@]} -eq 0 ]; then
  print_success "All Bluetooth packages already installed"
else
  print_info "Installing ${#TO_INSTALL[@]} package(s): ${TO_INSTALL[*]}"

  # Install using pacman
  if is_root; then
    pacman -Sy --noconfirm "${TO_INSTALL[@]}"
  else
    sudo pacman -Sy --noconfirm "${TO_INSTALL[@]}"
  fi
fi

# Enable and start bluetooth service
print_info "Checking Bluetooth service..."

if systemctl is-enabled bluetooth.service &>/dev/null; then
  print_success "Bluetooth service already enabled"
else
  print_info "Enabling Bluetooth service..."
  if is_root; then
    systemctl enable bluetooth.service
  else
    sudo systemctl enable bluetooth.service
  fi
  print_success "Bluetooth service enabled"
fi

if systemctl is-active bluetooth.service &>/dev/null; then
  print_success "Bluetooth service is running"
else
  print_info "Starting Bluetooth service..."
  if is_root; then
    systemctl start bluetooth.service
  else
    sudo systemctl start bluetooth.service
  fi
  print_success "Bluetooth service started"
fi

# Verify installation
echo
print_info "Verifying installation..."
ALL_INSTALLED=true

for PACKAGE in "${PACKAGES[@]}"; do
  if package_installed "$PACKAGE"; then
    VERSION=$(pacman -Qi "$PACKAGE" | grep Version | awk '{print $3}')
    print_success "$PACKAGE ($VERSION)"
  else
    print_error "$PACKAGE installation failed"
    ALL_INSTALLED=false
  fi
done

if $ALL_INSTALLED; then
  echo
  print_success "bluetui installed successfully!"
else
  print_error "Some packages failed to install"
  exit 1
fi
