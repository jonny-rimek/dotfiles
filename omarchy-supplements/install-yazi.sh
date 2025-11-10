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

# Install relative-motions plugin
print_header "Relative Line Numbers Plugin"
print_info "The relative-motions plugin enables vim-like relative line navigation (5j, 3k, etc.)"

if ! command_exists ya; then
  print_error "ya (Yazi package manager) is not available"
  print_warning "You may need to restart your shell or log out/in for ya to be available"
  exit 1
fi

# Check if plugin is already installed
if ya pkg list 2>/dev/null | grep -q "relative-motions"; then
  print_success "relative-motions plugin already installed"
else
  print_info "Installing relative-motions plugin..."
  if ya pkg add dedukun/relative-motions; then
    print_success "Plugin installed successfully"
  else
    print_error "Failed to install plugin"
    print_warning "You can install it later with: ya pkg add dedukun/relative-motions"
  fi
fi

# Print usage information
print_header "Configuration Required"
print_info ""
print_info "Add this to ~/.config/yazi/init.lua:"
print_info ""
echo '  require("relative-motions"):setup({
    show_numbers = "relative",
    show_motion = true,
  })'
print_info ""
print_info "Add keybindings to ~/.config/yazi/keymap.toml:"
print_info "  See example in your stowed yazi config"
print_info ""
print_info "Then stow the config: stow yazi"
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
print_info "With relative-motions plugin:"
print_info "  5j                - Move down 5 files (type 5 then j)"
print_info "  3k                - Move up 3 files"
print_info "  10gg              - Jump to line 10"
print_info ""

print_success "Yazi installation complete!"
