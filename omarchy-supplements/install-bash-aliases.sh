#!/usr/bin/env bash
# install-bash-aliases.sh - Configure .bashrc to source custom bash aliases

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/helpers.sh"

BASHRC="${HOME}/.bashrc"
BASH_ALIASES="${HOME}/.bash_aliases"

# Marker comments to identify our block
MARKER_START="# Source custom bash aliases (managed by dotfiles)"
MARKER_END="# End custom bash aliases"

print_header "Configuring Bash Aliases"

# Check if .bashrc exists
if [[ ! -f "${BASHRC}" ]]; then
  print_error ".bashrc not found at ${BASHRC}"
  exit 1
fi

# Check if our configuration block already exists
if grep -q "${MARKER_START}" "${BASHRC}"; then
  print_success "Bash aliases sourcing already configured in .bashrc"
  exit 0
fi

print_info "Adding bash aliases sourcing to .bashrc..."

# Append the sourcing block to .bashrc
cat >>"${BASHRC}" <<'EOF'

# Source custom bash aliases (managed by dotfiles)
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
# End custom bash aliases
EOF

print_success "Successfully configured .bashrc to source .bash_aliases"
print_info "The aliases will be available in new shell sessions"
print_info "Run 'source ~/.bashrc' to load them in the current session"

# Verify the file will exist after stowing
if [[ ! -f "${BASH_ALIASES}" ]]; then
  print_warning ".bash_aliases not found yet - remember to run stow!"
fi
