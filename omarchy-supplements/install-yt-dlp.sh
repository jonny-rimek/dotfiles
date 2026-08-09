#!/usr/bin/env bash
#
# install-yt-dlp.sh
# Install yt-dlp - command-line video downloader
# Includes ffmpeg for video post-processing (merging audio/video streams)
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

PACKAGES=("yt-dlp" "ffmpeg")

for PACKAGE_NAME in "${PACKAGES[@]}"; do
  print_info "Checking $PACKAGE_NAME installation..."

  if package_installed "$PACKAGE_NAME"; then
    INSTALLED_VERSION=$(pacman -Qi "$PACKAGE_NAME" | grep Version | awk '{print $3}')
    print_success "$PACKAGE_NAME already installed (version: $INSTALLED_VERSION)"
  else
    print_info "Installing $PACKAGE_NAME..."

    if is_root; then
      pacman -Sy --noconfirm "$PACKAGE_NAME"
    else
      sudo pacman -Sy --noconfirm "$PACKAGE_NAME"
    fi

    if package_installed "$PACKAGE_NAME"; then
      INSTALLED_VERSION=$(pacman -Qi "$PACKAGE_NAME" | grep Version | awk '{print $3}')
      print_success "$PACKAGE_NAME installed successfully (version: $INSTALLED_VERSION)"
    else
      print_error "$PACKAGE_NAME installation failed"
      exit 1
    fi
  fi
done

echo
print_success "yt-dlp is ready to use!"
