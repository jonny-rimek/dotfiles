#!/usr/bin/env bash
#
# install-tmuxinator.sh
# Install tmuxinator - tmux session manager via Ruby gem with shell completion
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

# Install shell completion
print_info "Installing shell completion..."

# Detect shell
if [ -n "$ZSH_VERSION" ] || [ -f "$HOME/.zshrc" ]; then
  SHELL_TYPE="zsh"
  COMPLETION_DIR="/usr/local/share/zsh/site-functions"
  COMPLETION_FILE="_tmuxinator"
  COMPLETION_URL="https://raw.githubusercontent.com/tmuxinator/tmuxinator/master/completion/tmuxinator.zsh"
elif [ -n "$BASH_VERSION" ] || [ -f "$HOME/.bashrc" ]; then
  SHELL_TYPE="bash"
  COMPLETION_DIR="/etc/bash_completion.d"
  COMPLETION_FILE="tmuxinator.bash"
  COMPLETION_URL="https://raw.githubusercontent.com/tmuxinator/tmuxinator/master/completion/tmuxinator.bash"
else
  print_warning "Could not detect shell type, skipping completion installation"
  SHELL_TYPE="unknown"
fi

if [ "$SHELL_TYPE" != "unknown" ]; then
  COMPLETION_PATH="$COMPLETION_DIR/$COMPLETION_FILE"

  if [ -f "$COMPLETION_PATH" ]; then
    print_success "Completion already installed for $SHELL_TYPE"
  else
    print_info "Installing $SHELL_TYPE completion..."

    # Create completion directory if it doesn't exist
    if [ ! -d "$COMPLETION_DIR" ]; then
      if is_root; then
        mkdir -p "$COMPLETION_DIR"
      else
        sudo mkdir -p "$COMPLETION_DIR"
      fi
    fi

    # Download completion file
    if is_root; then
      wget -q "$COMPLETION_URL" -O "$COMPLETION_PATH"
    else
      sudo wget -q "$COMPLETION_URL" -O "$COMPLETION_PATH"
    fi

    if [ -f "$COMPLETION_PATH" ]; then
      print_success "Completion installed for $SHELL_TYPE"

      if [ "$SHELL_TYPE" = "zsh" ]; then
        print_info "Reload zsh: exec zsh"
      else
        print_info "Reload bash: source ~/.bashrc"
      fi
    else
      print_error "Failed to install completion"
    fi
  fi
fi

echo
print_success "tmuxinator is ready to use!"
echo
rint_info "Quick start:"
echo "  • Create project: tmuxinator new myproject"
echo "  • Edit project: tmuxinator edit myproject"
echo "  • Start project: tmuxinator start myproject"
echo "  • List projects: tmuxinator list"
echo "  • Delete project: tmuxinator delete myproject"
echo
print_info "Tab completion:"
echo "  • Type 'tmuxinator ' and press TAB to see available commands"
echo "  • Type 'tmuxinator start ' and press TAB to see your projects"
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
