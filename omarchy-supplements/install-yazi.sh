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
else
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
  else
    print_error "Installation verification failed"
    exit 1
  fi
fi

# Install plugins from package.toml
print_header "Yazi Plugin Installation"

if ! command_exists ya; then
  print_error "ya (Yazi package manager) is not available"
  print_warning "You may need to restart your shell or log out/in for ya to be available"
  exit 1
fi

print_info "Installing plugins from ~/.config/yazi/package.toml..."
if ya pkg install; then
  print_success "Plugins installed successfully"
else
  print_warning "Plugin installation failed or no package.toml found"
  print_info "Create ~/.config/yazi/package.toml to define plugins"
fi

# Print usage information
print_header "Configuration"
print_info "Ensure your yazi config is stowed:"
print_info "  stow yazi"
print_info ""
print_info "Plugins are defined in ~/.config/yazi/package.toml"
print_info "After adding new plugins, run: ya install"
print_info ""
print_header "Usage"
print_info "  yazi              - Launch in current directory"
print_info "  yazi <path>       - Launch in specific directory"
print_info ""
print_info "Navigation (default):"
print_info "  j/k or ↓/↑        - Navigate"
print_info "  Enter             - Enter directory or open file"
print_info "  h or ←            - Go to parent directory"
print_info "  l or →            - Enter directory"
print_info "  gg/G              - Go to top/bottom"
print_info "  q                 - Quit"
print_info ""

print_success "Yazi installation complete!"
