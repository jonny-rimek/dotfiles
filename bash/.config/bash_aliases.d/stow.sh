# Source helpers
source ~/dev/dotfiles/omarchy-supplements/helpers.sh

# Stow check and apply function
stow-check() {
  local tool="$1"
  local stow_dir="$HOME/dev/dotfiles"

  if [[ -z "$tool" ]]; then
    print_error "Usage: stow-check <TOOLNAME>"
    return 1
  fi

  print_header "Stow Preview: $tool"

  # Capture simulate output
  local diff_output
  diff_output=$(stow --dir="$stow_dir" --verbose --simulate --target="$HOME" "$tool" 2>&1) || {
    print_error "Failed to simulate stow"
    return 1
  }

  # Check if there are changes (look for LINK in output)
  if ! echo "$diff_output" | grep -q "LINK"; then
    print_success "No changes needed for $tool"
    return 0
  fi

  # Show the diff (only LINK lines)
  print_info "Proposed changes:"
  echo "$diff_output" | grep "LINK"

  # Ask for confirmation
  echo ""
  read -p "$(echo -e ${BLUE}?${NC} Apply stow for $tool? [y/N]:)" -r
  echo ""

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Stowing $tool..."
    stow --dir="$stow_dir" --verbose --target="$HOME" "$tool" && print_success "Successfully stowed $tool"
  else
    print_warning "Stow cancelled for $tool"
    return 1
  fi
}

# Completion function for stow-check
_stow_check_completion() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local stow_dir="$HOME/dev/dotfiles"

  # Use find to list only directories, not ls
  COMPREPLY=($(compgen -W "$(find "$stow_dir" -maxdepth 1 -type d ! -name ".*" -exec basename {} \; 2>/dev/null | sort)" -- "$cur"))
}

# Register the completion function
complete -F _stow_check_completion stow-check
