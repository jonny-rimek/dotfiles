#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/helpers.sh"

NVIM_CONFIG_DIR="$HOME/.config/nvim"
NVIM_DATA_DIR="$HOME/.local/share/nvim"
NVIM_STATE_DIR="$HOME/.local/state/nvim"
NVIM_CACHE_DIR="$HOME/.cache/nvim"

BACKUP_DIR="$HOME/.config/nvim-backup-$(date +%Y%m%d-%H%M%S)"

print_header "Neovim Configuration Setup"

# Check if Neovim is installed
check_neovim_installation() {
  print_info "Checking Neovim installation..."

  if command_exists nvim; then
    NVIM_VERSION=$(nvim --version | head -n1)
    print_success "Neovim is installed: $NVIM_VERSION"
    return 0
  else
    print_error "Neovim is not installed!"
    echo ""
    print_info "Install Neovim using: sudo pacman -S neovim"
    echo ""
    exit 1
  fi
}

# Backup existing user configuration
backup_user_config() {
  print_info "Checking for existing Neovim configuration..."

  local needs_backup=false

  if [[ -d "$NVIM_CONFIG_DIR" ]] || [[ -d "$NVIM_DATA_DIR" ]] ||
    [[ -d "$NVIM_STATE_DIR" ]] || [[ -d "$NVIM_CACHE_DIR" ]]; then
    needs_backup=true
  fi

  if [[ "$needs_backup" == false ]]; then
    print_success "No existing configuration found. Clean slate!"
    return 0
  fi

  print_warning "Existing Neovim configuration detected!"
  echo ""
  echo "The following directories will be backed up:"
  [[ -d "$NVIM_CONFIG_DIR" ]] && echo "  - $NVIM_CONFIG_DIR"
  [[ -d "$NVIM_DATA_DIR" ]] && echo "  - $NVIM_DATA_DIR"
  [[ -d "$NVIM_STATE_DIR" ]] && echo "  - $NVIM_STATE_DIR"
  [[ -d "$NVIM_CACHE_DIR" ]] && echo "  - $NVIM_CACHE_DIR"
  echo ""
  echo "Backup location: $BACKUP_DIR"
  echo ""

  read -p "Proceed with backup? [y/N]: " response
  case $response in
  [Yy]*) ;;
  *)
    print_warning "Backup cancelled by user"
    exit 0
    ;;
  esac

  mkdir -p "$BACKUP_DIR"

  if [[ -d "$NVIM_CONFIG_DIR" ]]; then
    print_info "Backing up config directory..."
    mv "$NVIM_CONFIG_DIR" "$BACKUP_DIR/nvim-config"
    print_success "Config backed up"
  fi

  if [[ -d "$NVIM_DATA_DIR" ]]; then
    print_info "Backing up data directory..."
    mv "$NVIM_DATA_DIR" "$BACKUP_DIR/nvim-data"
    print_success "Data backed up"
  fi

  if [[ -d "$NVIM_STATE_DIR" ]]; then
    print_info "Backing up state directory..."
    mv "$NVIM_STATE_DIR" "$BACKUP_DIR/nvim-state"
    print_success "State backed up"
  fi

  if [[ -d "$NVIM_CACHE_DIR" ]]; then
    print_info "Backing up cache directory..."
    mv "$NVIM_CACHE_DIR" "$BACKUP_DIR/nvim-cache"
    print_success "Cache backed up"
  fi

  print_success "User configuration backed up!"
}

# Main execution
main() {
  check_neovim_installation
  echo ""
  backup_user_config

  echo ""
  print_header "Setup Complete!"
  echo ""
  print_info "Next steps:"
  echo "  1. Use Stow to symlink your Neovim configuration:"
  echo "     cd ~/dotfiles && stow nvim"
  echo ""
  echo "  2. Launch Neovim to initialize plugins:"
  echo "     nvim"
  echo ""

  if [[ -d "$BACKUP_DIR" ]]; then
    print_info "User config backup: $BACKUP_DIR"
    echo ""
    print_warning "Delete the backup once you're satisfied with the new config!"
  fi

  echo ""
  print_info "Omarchy's system-wide configs are automatically ignored by your user config."
}

main "$@"
