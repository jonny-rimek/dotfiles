#!/usr/bin/env bash
#
# install-tmuxinator.sh
# Install shell completion for tmuxinator (the gem itself is managed by mise)
#
# See mise/.config/mise/config.toml -> "gem:tmuxinator" for the gem install.
# Run `mise up` after stowing the mise config to install/upgrade the gem.
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

print_info "Installing tmuxinator shell completion..."

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

    if [ ! -d "$COMPLETION_DIR" ]; then
      if is_root; then
        mkdir -p "$COMPLETION_DIR"
      else
        sudo mkdir -p "$COMPLETION_DIR"
      fi
    fi

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
      exit 1
    fi
  fi
fi

echo
print_success "tmuxinator is ready to use!"
echo
print_info "The gem is managed by mise: run 'mise up' to install/upgrade it."
echo
print_info "Quick start:"
echo "  • Create project: tmuxinator new myproject"
echo "  • Edit project: tmuxinator edit myproject"
echo "  • Start project: tmuxinator start myproject"
echo "  • List projects: tmuxinator list"
echo "  • Delete project: tmuxinator delete myproject"
echo
print_info "Config location: ~/.config/tmuxinator/"
