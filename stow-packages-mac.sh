#!/usr/bin/env bash
#
# stow-packages-mac.sh
# Interactively stow multiple dotfiles packages with confirmation
#
# Usage: ./stow-packages-mac.sh
#

set -e

# ============================================================================
# CONFIGURATION: Add your packages here
# ============================================================================
PACKAGES_TO_STOW=(
  "nvim"
  "lazygit"
)

# ============================================================================
# Script logic below - no need to modify
# ============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

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

print_header() {
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${CYAN}$1${NC}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="$HOME"

print_header "Dotfiles Stow Manager"
echo
print_info "Dotfiles directory: $DOTFILES_DIR"
print_info "Target directory: $TARGET_DIR"
print_info "Packages to stow: ${PACKAGES_TO_STOW[*]}"
echo

# Track results
STOWED_PACKAGES=()
FAILED_PACKAGES=()
SKIPPED_PACKAGES=()

# Process each package
for PACKAGE in "${PACKAGES_TO_STOW[@]}"; do
  echo
  print_header "Package: $PACKAGE"
  echo

  # Check if package directory exists
  if [ ! -d "$DOTFILES_DIR/$PACKAGE" ]; then
    print_error "Package '$PACKAGE' not found in $DOTFILES_DIR"
    FAILED_PACKAGES+=("$PACKAGE (not found)")
    continue
  fi

  # Step 1: Show the stow plan (dry-run)
  print_info "Simulating stow operation (dry-run)..."
  echo
  echo "─────────────────────────────────────────────────────────"

  if stow --verbose --simulate --target="$TARGET_DIR" --dir="$DOTFILES_DIR" "$PACKAGE" 2>&1; then
    STOW_EXIT_CODE=0
  else
    STOW_EXIT_CODE=$?
  fi

  echo "─────────────────────────────────────────────────────────"
  echo

  # Check if dry-run was successful
  if [ $STOW_EXIT_CODE -ne 0 ]; then
    print_error "Stow simulation failed for '$PACKAGE' with exit code $STOW_EXIT_CODE"
    print_warning "Skipping this package - please resolve conflicts manually"
    FAILED_PACKAGES+=("$PACKAGE (conflicts)")
    continue
  fi

  # Step 2: Ask for confirmation
  print_warning "Review the plan above carefully!"
  echo
  read -p "Stow '$PACKAGE'? [y/N/q(uit)] " -n 1 -r
  echo

  if [[ $REPLY =~ ^[Qq]$ ]]; then
    print_info "Stopping at user request"
    break
  fi

  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Skipping package '$PACKAGE'"
    SKIPPED_PACKAGES+=("$PACKAGE")
    continue
  fi

  # Step 3: Actually stow the package
  print_info "Stowing package '$PACKAGE'..."
  echo

  if stow --verbose --target="$TARGET_DIR" --dir="$DOTFILES_DIR" "$PACKAGE" 2>&1; then
    echo
    print_success "Package '$PACKAGE' stowed successfully!"
    STOWED_PACKAGES+=("$PACKAGE")

    # Show what was linked
    if [ -d "$TARGET_DIR/.config/$PACKAGE" ]; then
      echo
      print_info "Symlink created:"
      ls -la "$TARGET_DIR/.config/$PACKAGE" 2>/dev/null || true
    fi
  else
    echo
    print_error "Failed to stow package '$PACKAGE'"
    FAILED_PACKAGES+=("$PACKAGE (stow failed)")
  fi
done

# Summary
echo
print_header "Summary"
echo

if [ ${#STOWED_PACKAGES[@]} -gt 0 ]; then
  print_success "Successfully stowed (${#STOWED_PACKAGES[@]}):"
  for pkg in "${STOWED_PACKAGES[@]}"; do
    echo "  • $pkg"
  done
  echo
fi

if [ ${#SKIPPED_PACKAGES[@]} -gt 0 ]; then
  print_warning "Skipped (${#SKIPPED_PACKAGES[@]}):"
  for pkg in "${SKIPPED_PACKAGES[@]}"; do
    echo "  • $pkg"
  done
  echo
fi

if [ ${#FAILED_PACKAGES[@]} -gt 0 ]; then
  print_error "Failed (${#FAILED_PACKAGES[@]}):"
  for pkg in "${FAILED_PACKAGES[@]}"; do
    echo "  • $pkg"
  done
  echo
  exit 1
fi

print_success "All done!"-mac
