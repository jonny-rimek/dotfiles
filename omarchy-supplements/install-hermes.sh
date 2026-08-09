#!/usr/bin/env bash
#
# install-hermes.sh
# Install Hermes Agent (Nous Research AI agent) using the official installer.
# Source: https://hermes-agent.nousresearch.com/docs/
#
# Notes:
# - Installs user-level into ~/.hermes/hermes-agent (venv) with a launcher at
#   ~/.local/bin/hermes. Does not require root.
# - Idempotent: if `hermes` is already on PATH, it is left untouched and its
#   version is reported. Re-run safely at any time.
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

require_non_root

HERMES_INSTALLER_URL="https://hermes-agent.nousresearch.com/install.sh"

print_info "Checking Hermes Agent installation..."

# 1. Already installed? Skip reinstall and just report the version.
if command_exists hermes; then
  INSTALLED_VERSION=$(hermes --version 2>/dev/null | head -n1)
  print_success "Hermes Agent already installed (${INSTALLED_VERSION:-version unknown})"
else
  print_info "Installing Hermes Agent..."
  curl -fsSL "$HERMES_INSTALLER_URL" | bash
fi

# 2. Ensure the launcher landed on PATH before claiming success.
if ! command_exists hermes; then
  print_error "Hermes Agent installation failed: 'hermes' not found on PATH"
  print_info "Check you PATH includes ~/.local/bin, then re-run this script."
  exit 1
fi

echo
INSTALLED_VERSION=$(hermes --version 2>/dev/null | head -n1)
print_success "Hermes Agent is ready (${INSTALLED_VERSION:-version unknown})"
print_info "Get started with: hermes setup"