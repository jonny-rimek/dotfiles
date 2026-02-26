#!/usr/bin/env bash
#
# install-omarchy-supplements.sh
# Run all Omarchy system supplements (installations and configurations)
#
# Usage: ./install-omarchy-supplements.sh
#

set -e

# ============================================================================
# CONFIGURATION: Scripts to run (in order)
# ============================================================================
SUPPLEMENT_SCRIPTS=(
  "remove-unwanted-software.sh"
  "fix-dualboot-time.sh"
  "install-wget.sh"
  "install-firefox.sh"
  "install-veracrypt.sh"
  "install-keepassxc.sh"
  "install-zathura.sh"
  "install-bluetui.sh"
  "install-tmux.sh"
  "install-tmuxinator.sh"
  "install-glab.sh"
  "install-bash-aliases.sh"
  "install-yazi.sh"
  "install-postgres.sh"
  "install-mkcert.sh"
  "install-hosts.sh"
  "install-awscli.sh"
)
# "clean-nvim.sh" # the config is ass i go back to omarchy default until i understand nvim better

# ============================================================================
# Script logic below
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SUPPLEMENTS_DIR="$SCRIPT_DIR/omarchy-supplements"
HELPERS_SCRIPT="$SUPPLEMENTS_DIR/helpers.sh"

# Source helpers
if [ ! -f "$HELPERS_SCRIPT" ]; then
  echo "ERROR: helpers.sh not found at $HELPERS_SCRIPT"
  exit 1
fi

source "$HELPERS_SCRIPT"

# Check if running on Arch-based system
if [ ! -f /etc/arch-release ]; then
  print_error "This script is for Arch Linux / Omarchy only"
  exit 1
fi

print_header "Omarchy System Supplements"
echo
print_info "Supplements directory: $SUPPLEMENTS_DIR"
print_info "Scripts to run: ${#SUPPLEMENT_SCRIPTS[@]}"
echo

# Track results
SUCCEEDED=()
FAILED=()
SKIPPED=()

# Run each supplement script
for SCRIPT_NAME in "${SUPPLEMENT_SCRIPTS[@]}"; do
  SCRIPT_PATH="$SUPPLEMENTS_DIR/$SCRIPT_NAME"

  echo
  print_header "Running: $SCRIPT_NAME"
  echo

  # Check if script exists
  if [ ! -f "$SCRIPT_PATH" ]; then
    print_error "Script not found: $SCRIPT_PATH"
    FAILED+=("$SCRIPT_NAME (not found)")
    continue
  fi

  # Check if script is executable
  if [ ! -x "$SCRIPT_PATH" ]; then
    print_warning "Making script executable: $SCRIPT_NAME"
    chmod +x "$SCRIPT_PATH"
  fi

  # Run the script
  if "$SCRIPT_PATH"; then
    print_success "Completed: $SCRIPT_NAME"
    SUCCEEDED+=("$SCRIPT_NAME")
  else
    EXIT_CODE=$?
    print_error "Failed: $SCRIPT_NAME (exit code: $EXIT_CODE)"
    FAILED+=("$SCRIPT_NAME")
  fi
done

# Summary
echo
print_header "Summary"
echo

if [ ${#SUCCEEDED[@]} -gt 0 ]; then
  print_success "Succeeded (${#SUCCEEDED[@]}):"
  for script in "${SUCCEEDED[@]}"; do
    echo "  ✓ $script"
  done
  echo
fi

if [ ${#SKIPPED[@]} -gt 0 ]; then
  print_warning "Skipped (${#SKIPPED[@]}):"
  for script in "${SKIPPED[@]}"; do
    echo "  • $script"
  done
  echo
fi

if [ ${#FAILED[@]} -gt 0 ]; then
  print_error "Failed (${#FAILED[@]}):"
  for script in "${FAILED[@]}"; do
    echo "  ✗ $script"
  done
  echo
  exit 1
fi

print_success "All supplements completed successfully!"
