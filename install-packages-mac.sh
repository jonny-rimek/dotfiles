#!/usr/bin/env bash
#
# install-packages-mac.sh
# Installs essential development tools on macOS for dotfiles management
#

set -e
source "$(dirname "$0")/helpers.sh"

print_header "macOS Development Environment Setup"

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
  print_error "This script is for macOS only"
  exit 1
fi

# Install Homebrew if not present
if ! command_exists brew; then
  print_info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to PATH for Apple Silicon Macs
  if [[ $(uname -m) == "arm64" ]]; then
    print_info "Detected Apple Silicon - configuring Homebrew path..."
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  print_success "Homebrew installed"
else
  print_success "Homebrew already installed"
  print_info "Updating Homebrew..."
  brew update
fi

echo

print_header "Installing Development Tools"

# CLI tools (formulas)
CLI_TOOLS=(
  "stow"       # Dotfile symlink manager
  "neovim"     # Terminal text editor
  "tmux"       # Terminal multiplexer
  "lazygit"    # Terminal git client
  "tmuxinator" # tmux session manager
  "yazi"       # Terminal file manager
)

# Optional dependencies for enhanced functionality
OPTIONAL_DEPS=(
  "ffmpegthumbnailer" # Video thumbnails for yazi
  "fd"                # Fast file searching
  "ripgrep"           # Fast content searching
  "fzf"               # Fuzzy finder
  "zoxide"            # Smart directory navigation
  "imagemagick"       # Image processing/thumbnails
  "poppler"           # PDF previews
  "jq"                # JSON processing
)

# Install CLI tools
print_info "Installing core development tools..."
for tool in "${CLI_TOOLS[@]}"; do
  if command_exists "$tool"; then
    print_success "$tool already installed"
  else
    print_info "Installing $tool..."
    if brew install "$tool"; then
      print_success "Installed $tool"
    else
      print_error "Failed to install $tool"
      exit 1
    fi
  fi
done

echo

# Install optional dependencies
print_info "Installing optional dependencies for enhanced functionality..."
for pkg in "${OPTIONAL_DEPS[@]}"; do
  if command_exists "$pkg" || brew list "$pkg" &>/dev/null; then
    print_success "$pkg already installed"
  else
    print_info "Installing $pkg..."
    if brew install "$pkg"; then
      print_success "Installed $pkg"
    else
      print_warning "Failed to install optional dependency: $pkg (continuing)"
    fi
  fi
done

echo

# Install TPM (Tmux Plugin Manager)
print_header "Tmux Plugin Manager (TPM)"
if [ ! -d ~/.tmux/plugins/tpm ]; then
  print_info "Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  print_success "TPM installed"
else
  print_success "TPM already installed"
fi

echo

# Install yazi plugins
print_header "Yazi Plugins"
if command_exists yazi; then
  if [ -f ~/.config/yazi/package.toml ]; then
    if command_exists ya; then
      print_info "Found ~/.config/yazi/package.toml - installing packages..."
      if ya pkg install; then
        print_success "Yazi packages installed from package.toml"
      else
        print_error "Failed to install yazi packages"
      fi
    else
      print_warning "ya (Yazi package manager) not available yet - restart your shell and run: ya pkg install"
    fi
  else
    print_warning "~/.config/yazi/package.toml not found"
    print_info "To install yazi plugins, first stow the yazi config:"
    print_info "  cd ~/dotfiles && stow yazi"
    print_info "Then run: ya pkg install"
  fi
else
  print_warning "yazi not found - skipping plugins"
fi

echo

# Verification
print_header "Installation Verification"
print_info "Installed versions:"
echo "  • Homebrew:   $(brew --version | head -n1)"
echo "  • Stow:       $(stow --version | head -n1)"
echo "  • Neovim:     $(nvim --version | head -n1 | cut -d' ' -f1-2)"
echo "  • tmux:       $(tmux -V)"
echo "  • Lazygit:    $(lazygit --version 2>&1 | head -n1)"
echo "  • tmuxinator: $(tmuxinator version 2>&1 | head -n1)"
if command_exists yazi; then
  echo "  • yazi:       $(yazi --version)"
fi

echo

# Next steps
print_header "Next Steps"
print_info "1. Stow your dotfiles:"
print_info "   cd ~/dotfiles && stow --dry-run ."
print_info "   Review, then: stow ."
echo
print_info "2. Configure tmux plugins:"
print_info "   - Launch tmux and press: prefix + I (Ctrl+B + I by default)"
echo
print_info "3. Install yazi plugins (if not done):"
print_info "   - Run: ya pkg install"
echo

print_success "macOS setup complete!"
