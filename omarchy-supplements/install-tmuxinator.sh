#!/usr/bin/env bash
#
# install-tmuxinator.sh
# Install tmuxinator - tmux session manager via Ruby gem
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

GEM_NAME="tmuxinator"

print_info "Checking tmuxinator installation..."

# Check if gem is already installed
if gem list -i "^${GEM_NAME}$" &>/dev/null; then
  INSTALLED_VERSION=$(gem list "^${GEM_NAME}$" | grep -oP '\(\K[^\)]+')
  print_success "tmuxinator already installed (version: $INSTALLED_VERSION)"
else
  print_info "Installing tmuxinator via gem..."

  # Check if Ruby is available
  if ! command_exists ruby; then
    print_error "Ruby not found"
    print_info "Install Ruby first (mise should handle this)"
    exit 1
  fi

  # Check if gem is available
  if ! command_exists gem; then
    print_error "gem command not found"
    print_info "Ensure Ruby is properly installed"
    exit 1
  fi

  # Install the gem
  gem install "$GEM_NAME"

  # Verify installation
  if gem list -i "^${GEM_NAME}$" &>/dev/null; then
    INSTALLED_VERSION=$(gem list "^${GEM_NAME}$" | grep -oP '\(\K[^\)]+')
    print_success "tmuxinator installed successfully (version: $INSTALLED_VERSION)"
  else
    print_error "tmuxinator installation failed"
    exit 1
  fi
fi

echo
print_success "tmuxinator is ready to use!"
echo
print_info "Quick start:"
echo "  • Create project: tmuxinator new myproject"
echo "  • Edit project: tmuxinator edit myproject"
echo "  • Start project: tmuxinator start myproject"
echo "  • List projects: tmuxinator list"
echo "  • Delete project: tmuxinator delete myproject"
echo
print_info "Config location: ~/.config/tmuxinator/"
echo
print_info "Example project file (YAML):"
echo "  name: myproject"
echo "  root: ~/dev/myproject"
echo "  windows:"
echo "    - editor: nvim ."
echo "    - server: bin/rails server"
echo "    - console: bin/rails console"
echo
print_info "Shortcuts:"
echo "  • Start: tmuxinator start myproject"
echo "  • Or: tmuxinator s myproject"
echo "  • Or: mux myproject (if alias configured)"
