#!/usr/bin/env bash
#
# install-packages-mac.sh
# Installs essential development tools on macOS for dotfiles management
#
# Usage: ./install-packages-mac.sh
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_info() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is for macOS only"
    exit 1
fi

print_info "Starting macOS development environment setup..."
echo

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    print_success "Homebrew installed"
else
    print_success "Homebrew already installed"
    print_info "Updating Homebrew..."
    brew update
fi

echo

# Install Stow
if ! command -v stow &> /dev/null; then
    print_info "Installing GNU Stow..."
    brew install stow
    print_success "Stow installed"
else
    print_success "Stow already installed ($(stow --version | head -n1))"
fi

# Install Neovim
if ! command -v nvim &> /dev/null; then
    print_info "Installing Neovim..."
    brew install neovim
    print_success "Neovim installed"
else
    print_success "Neovim already installed ($(nvim --version | head -n1))"
fi

# Install Lazygit
if ! command -v lazygit &> /dev/null; then
    print_info "Installing Lazygit..."
    brew install lazygit
    print_success "Lazygit installed"
else
    print_success "Lazygit already installed ($(lazygit --version | head -n1))"
fi

# Install tmux
if ! command -v tmux &> /dev/null; then
    print_info "Installing tmux..."
    brew install tmux
    print_success "tmux installed"
else
    print_success "tmux already installed ($(tmux -V))"
fi

# Install tmuxinator
if ! command -v tmuxinator &> /dev/null; then
    print_info "Installing tmuxinator..."
    brew install tmuxinator
    print_success "tmuxinator installed"
else
    print_success "tmuxinator already installed ($(tmuxinator version))"
fi

echo
print_success "All tools installed successfully!"
echo
print_info "Next steps:"
echo "  1. Run stow-mac.sh to symlink your dotfiles"
echo "  2. Configure tmuxinator projects: tmuxinator new <project-name>"
echo
print_info "Installed tools:"
echo "  • Homebrew:   $(brew --version | head -n1)"
echo "  • Stow:       $(stow --version | head -n1)"
echo "  • Neovim:     $(nvim --version | head -n1)"
echo "  • Lazygit:    $(lazygit --version 2>&1 | head -n1)"
echo "  • tmux:       $(tmux -V)"
echo "  • tmuxinator: $(tmuxinator version)"
