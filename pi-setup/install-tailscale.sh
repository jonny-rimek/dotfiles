#!/usr/bin/env bash
#
# install-tailscale.sh
# Install Tailscale CLI and enable Tailscale SSH on the Raspberry Pi
#
# Idempotent: safe to run multiple times.
# Must be run as root on the Pi.
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

ensure_root

print_header "Tailscale Installation"

# Install Tailscale if not present
if command_exists tailscale; then
  INSTALLED_VERSION=$(tailscale version | head -1)
  print_success "Tailscale already installed ($INSTALLED_VERSION)"
else
  print_info "Installing Tailscale..."
  curl -fsSL https://tailscale.com/install.sh | sh

  if command_exists tailscale; then
    INSTALLED_VERSION=$(tailscale version | head -1)
    print_success "Tailscale installed ($INSTALLED_VERSION)"
  else
    print_error "Tailscale installation failed"
    exit 1
  fi
fi

echo

# Enable and start tailscaled service
print_info "Ensuring tailscaled service is running..."
if systemctl is-active --quiet tailscaled; then
  print_success "tailscaled is already running"
else
  systemctl enable --now tailscaled
  print_success "tailscaled enabled and started"
fi

echo

# Bring up Tailscale with SSH enabled
TS_STATUS=$(tailscale status --json 2>/dev/null | grep -o '"BackendState":"[^"]*"' | cut -d'"' -f4 || echo "unknown")

if [ "$TS_STATUS" = "Running" ]; then
  # Check if SSH is already enabled
  if tailscale status --json 2>/dev/null | grep -q '"RunSSH":true'; then
    print_success "Tailscale is up with SSH enabled"
  else
    print_info "Tailscale is running but SSH is not enabled. Re-running with --ssh..."
    tailscale up --ssh
    print_success "Tailscale SSH enabled"
  fi
else
  print_info "Bringing up Tailscale with SSH..."
  print_warning "This will open a browser/URL for authentication if not already authenticated."
  tailscale up --ssh
  print_success "Tailscale is up with SSH enabled"
fi

echo

# Show status
TS_IP=$(tailscale ip -4 2>/dev/null || echo "unknown")
TS_HOSTNAME=$(tailscale status --self --json 2>/dev/null | grep -o '"DNSName":"[^"]*"' | cut -d'"' -f4 || echo "unknown")

print_header "Tailscale Status"
print_info "Tailscale IP: $TS_IP"
print_info "DNS name: $TS_HOSTNAME"
print_info "SSH: enabled (connect with: ssh ${TS_HOSTNAME%.})"
echo
print_success "Tailscale setup complete!"
