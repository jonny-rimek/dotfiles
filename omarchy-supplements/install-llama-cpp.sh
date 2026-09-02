#!/usr/bin/env bash
#
# install-llama-cpp.sh
# Install llama.cpp (server + CLI) with the CUDA backend for local LLM inference
# Model download is user-level: run `llm-model-download` afterwards (not as root)
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

if [ ! -f /etc/arch-release ]; then
  print_error "This script is for Arch Linux / Omarchy only"
  exit 1
fi

PACKAGES=("llama-cpp" "ggml-cuda" "ggml-cpu")

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
print_success "llama.cpp is ready!"
print_info "As your user, download the models once with: llm-model-download"
print_info "Then start the server with: llm-start"
