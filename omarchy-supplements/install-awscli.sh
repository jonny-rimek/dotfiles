#!/usr/bin/env bash
#
# install-awscli.sh
# Install AWS CLI v2
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

PACKAGE_NAME="aws-cli-v2"

print_info "Checking AWS CLI installation..."

# Check if already installed
if command_exists "aws"; then
  INSTALLED_VERSION=$(aws --version 2>&1 | awk '{print $1}' | cut -d/ -f2)
  print_success "AWS CLI already installed (version: $INSTALLED_VERSION)"
else
  print_info "Installing AWS CLI v2..."

  # Install using pacman
  if is_root; then
    pacman -Sy --noconfirm "$PACKAGE_NAME"
  else
    sudo pacman -Sy --noconfirm "$PACKAGE_NAME"
  fi

  # Verify installation
  if command_exists "aws"; then
    INSTALLED_VERSION=$(aws --version 2>&1 | awk '{print $1}' | cut -d/ -f2)
    print_success "AWS CLI installed successfully (version: $INSTALLED_VERSION)"
  else
    print_error "AWS CLI installation failed"
    exit 1
  fi
fi

echo
print_success "AWS CLI is ready to use!"
