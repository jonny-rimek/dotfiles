#!/usr/bin/env bash
#
# install-zathura.sh
# Install Zathura document viewer with common plugins
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# Zathura core and plugins
PACKAGES=(
  "zathura"           # Core viewer
  "zathura-pdf-mupdf" # PDF and ebook support (MuPDF backend)
  # "zathura-ps"        # PostScript support
  # "zathura-djvu"      # DjVu support
  # "zathura-cb"        # Comic book support (CBZ, CBR)
)

print_info "Checking Zathura installation..."

# Track what needs to be installed
TO_INSTALL=()
ALREADY_INSTALLED=()

for PACKAGE in "${PACKAGES[@]}"; do
  if package_installed "$PACKAGE"; then
    VERSION=$(pacman -Qi "$PACKAGE" | grep Version | awk '{print $3}')
    ALREADY_INSTALLED+=("$PACKAGE ($VERSION)")
  else
    TO_INSTALL+=("$PACKAGE")
  fi
done

# Show what's already installed
if [ ${#ALREADY_INSTALLED[@]} -gt 0 ]; then
  print_success "Already installed:"
  for pkg in "${ALREADY_INSTALLED[@]}"; do
    echo "  ✓ $pkg"
  done
  echo
fi

# Install missing packages
if [ ${#TO_INSTALL[@]} -eq 0 ]; then
  print_success "All Zathura packages already installed"
  exit 0
fi

print_info "Installing ${#TO_INSTALL[@]} package(s): ${TO_INSTALL[*]}"

# Install using pacman
if is_root; then
  pacman -Sy --noconfirm "${TO_INSTALL[@]}"
else
  sudo pacman -Sy --noconfirm "${TO_INSTALL[@]}"
fi

# Verify installation
echo
print_info "Verifying installation..."
ALL_INSTALLED=true

for PACKAGE in "${PACKAGES[@]}"; do
  if package_installed "$PACKAGE"; then
    VERSION=$(pacman -Qi "$PACKAGE" | grep Version | awk '{print $3}')
    print_success "$PACKAGE ($VERSION)"
  else
    print_error "$PACKAGE installation failed"
    ALL_INSTALLED=false
  fi
done

if $ALL_INSTALLED; then
  echo
  print_success "Zathura installed successfully!"
else
  print_error "Some packages failed to install"
  exit 1
fi
