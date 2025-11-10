#!/usr/bin/env bash
#
# install_yazi.sh
# Install yazi terminal file manager with recommended dependencies
#

set -e
source "$(dirname "$0")/helpers.sh"

print_header "Yazi Terminal File Manager Installation"

# Check if yazi is already installed
if command_exists yazi; then
  print_success "yazi is already installed ($(yazi --version))"
  exit 0
fi

print_info "Installing yazi and recommended dependencies..."

# Core package
PACKAGES=(
  "yazi" # Terminal file manager
)

# Optional dependencies for enhanced functionality
OPTIONAL_DEPS=(
  "ffmpegthumbnailer" # Video thumbnails
  "fd"                # File searching
  "ripgrep"           # Content searching
  "fzf"               # Fuzzy finding
  "zoxide"            # Smart directory jumping
  "imagemagick"       # Image processing/thumbnails
  "poppler"           # PDF previews (provides pdftoppm)
  "jq"                # JSON previews
  "unarchiver"        # Archive previews
)

# Install core packages
print_info "Installing yazi..."
if ! sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"; then
  print_error "Failed to install yazi"
  exit 1
fi

# Install optional dependencies
print_info "Installing optional dependencies for enhanced functionality..."
for pkg in "${OPTIONAL_DEPS[@]}"; do
  if package_installed "$pkg"; then
    print_success "$pkg already installed"
  else
    if sudo pacman -S --needed --noconfirm "$pkg"; then
      print_success "Installed $pkg"
    else
      print_warning "Failed to install optional dependency: $pkg (continuing)"
    fi
  fi
done

# Verify installation
print_info "Verifying installation..."
if command_exists yazi; then
  YAZI_VERSION=$(yazi --version | head -n 1)
  print_success "yazi successfully installed: $YAZI_VERSION"

  print_info ""
  print_info "Usage:"
  print_info "  yazi              - Launch in current directory"
  print_info "  yazi <path>       - Launch in specific directory"
  print_info ""
  print_info "Key bindings (default):"
  print_info "  j/k or ↓/↑       - Navigate"
  print_info "  Enter            - Enter directory or open file"
  print_info "  h or ←           - Go to parent directory"
  print_info "  l or →           - Enter directory"
  print_info "  gg/G             - Go to top/bottom"
  print_info "  q                - Quit"
  print_info ""
  print_info "Configuration directory: ~/.config/yazi/"
  print_info "For custom config, add to your dotfiles stow package"
else
  print_error "Installation verification failed"
  exit 1
fi

print_success "Yazi installation complete!"
