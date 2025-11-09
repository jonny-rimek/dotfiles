#!/usr/bin/env bash
# install-bash-aliases.sh - Configure .bashrc to source modular bash aliases

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/helpers.sh"

BASHRC="${HOME}/.bashrc"
ALIASES_DIR="${HOME}/.config/bash_aliases.d"

MARKER_START="# Source modular bash aliases (managed by dotfiles)"
MARKER_END="# End modular bash aliases"

print_header "Configuring Bash Aliases"

if [[ ! -f "${BASHRC}" ]]; then
  print_error ".bashrc not found at ${BASHRC}"
  exit 1
fi

# Check if our configuration block already exists
if grep -q "${MARKER_START}" "${BASHRC}"; then
  print_success "Bash aliases sourcing already configured in .bashrc"
else
  print_info "Adding bash aliases sourcing to .bashrc..."
  cat >>"${BASHRC}" <<'EOF'

# Source modular bash aliases (managed by dotfiles)
if [[ -d "${HOME}/.config/bash_aliases.d" ]]; then
  for alias_file in "${HOME}/.config/bash_aliases.d"/*.sh; do
    # shellcheck source=/dev/null
    source "$alias_file"
  done
fi
# End modular bash aliases
EOF
  print_success "Successfully configured .bashrc to source .config/bash_aliases.d/"
fi

# Verify directory will exist after stowing
if [[ ! -d "${ALIASES_DIR}" ]]; then
  print_warning ".config/bash_aliases.d not found yet - remember to run stow!"
fi

print_info "Reload your shell or run: source ~/.bashrc"
