#!/usr/bin/env bash
#
# remove-unwanted-software.sh
# Remove unwanted pre-installed software
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# ============================================================================
# CONFIGURATION: Packages to remove
# ============================================================================
PACKAGES_TO_REMOVE=(
  "1password"
  "kdenlive"
  "obs-studio"
)

# ============================================================================
# Script logic below
# ============================================================================

print_info "Checking for unwanted software..."
echo

# Track what will be removed
TO_REMOVE=()
NOT_INSTALLED=()

for PACKAGE in "${PACKAGES_TO_REMOVE[@]}"; do
  if package_installed "$PACKAGE"; then
    VERSION=$(pacman -Qi "$PACKAGE" | grep Version | awk '{print $3}')
    TO_REMOVE+=("$PACKAGE ($VERSION)")
  else
    NOT_INSTALLED+=("$PACKAGE")
  fi
done

# Show what's not installed
if [ ${#NOT_INSTALLED[@]} -gt 0 ]; then
  print_info "Not installed (skipping):"
  for pkg in "${NOT_INSTALLED[@]}"; do
    echo "  • $pkg"
  done
  echo
fi

# Nothing to remove
if [ ${#TO_REMOVE[@]} -eq 0 ]; then
  print_success "No unwanted software found"
  exit 0
fi

# Show what will be removed
print_warning "The following packages will be removed:"
for pkg in "${TO_REMOVE[@]}"; do
  echo "  ✗ $pkg"
done
echo

# Show what -Rns does
print_info "Using: pacman -Rns (Remove + dependencies + skip backup)"
echo "  -R  Remove package"
echo "  -n  Skip creating backup (.pacsave files)"
echo "  -s  Remove dependencies not required by other packages"
echo

# Ask for confirmation
read -p "Remove these packages? [y/N] " -n 1 -r
echo
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  print_info "Removal cancelled"
  exit 0
fi

# Remove packages
print_info "Removing packages..."
echo

REMOVED=()
FAILED=()

for PACKAGE in "${PACKAGES_TO_REMOVE[@]}"; do
  if ! package_installed "$PACKAGE"; then
    continue
  fi

  print_info "Removing: $PACKAGE"

  if is_root; then
    if pacman -Rns --noconfirm "$PACKAGE" 2>&1; then
      print_success "$PACKAGE removed"
      REMOVED+=("$PACKAGE")
    else
      print_error "Failed to remove $PACKAGE"
      FAILED+=("$PACKAGE")
    fi
  else
    if sudo pacman -Rns --noconfirm "$PACKAGE" 2>&1; then
      print_success "$PACKAGE removed"
      REMOVED+=("$PACKAGE")
    else
      print_error "Failed to remove $PACKAGE"
      FAILED+=("$PACKAGE")
    fi
  fi
  echo
done

# Summary
print_header "Removal Summary"
echo

if [ ${#REMOVED[@]} -gt 0 ]; then
  print_success "Successfully removed (${#REMOVED[@]}):"
  for pkg in "${REMOVED[@]}"; do
    echo "  ✓ $pkg"
  done
  echo
fi

if [ ${#FAILED[@]} -gt 0 ]; then
  print_error "Failed to remove (${#FAILED[@]}):"
  for pkg in "${FAILED[@]}"; do
    echo "  ✗ $pkg"
  done
  echo
  exit 1
fi

print_success "All unwanted software removed!"

# Show disk space freed
echo
print_info "Cleaning package cache..."
if is_root; then
  pacman -Sc --noconfirm
else
  sudo pacman -Sc --noconfirm
fi

print_success "Cleanup complete!"
