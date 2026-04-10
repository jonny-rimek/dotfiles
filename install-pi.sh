#!/usr/bin/env bash
#
# install-pi.sh
# Run Pi setup scripts remotely via SSH
#
# Usage: ./install-pi.sh [user@pi-host]
#   Defaults to jonny@raspberry5-8gb
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PI_SETUP_DIR="$SCRIPT_DIR/pi-setup"
REMOTE_TMP="/tmp/pi-setup"

source "$PI_SETUP_DIR/helpers.sh"

PI_HOST="${1:-jonny@raspberry5-8gb}"

# Scripts to run (in order)
SETUP_SCRIPTS=(
  "install-tailscale.sh"
)

print_header "Raspberry Pi Setup"
print_info "Target: $PI_HOST"
print_info "Scripts to run: ${#SETUP_SCRIPTS[@]}"
echo

# Copy setup scripts to the Pi
print_info "Copying setup scripts to $PI_HOST:$REMOTE_TMP..."
ssh "$PI_HOST" "mkdir -p $REMOTE_TMP"
scp -r "$PI_SETUP_DIR/"* "$PI_HOST:$REMOTE_TMP/"
ssh "$PI_HOST" "chmod +x $REMOTE_TMP/*.sh"
print_success "Scripts copied"
echo

# Track results
SUCCEEDED=()
FAILED=()

# Run each script
for SCRIPT_NAME in "${SETUP_SCRIPTS[@]}"; do
  echo
  print_header "Running: $SCRIPT_NAME"
  echo

  if ssh -t "$PI_HOST" "sudo $REMOTE_TMP/$SCRIPT_NAME"; then
    print_success "Completed: $SCRIPT_NAME"
    SUCCEEDED+=("$SCRIPT_NAME")
  else
    print_error "Failed: $SCRIPT_NAME"
    FAILED+=("$SCRIPT_NAME")
  fi
done

# Cleanup
ssh "$PI_HOST" "rm -rf $REMOTE_TMP"

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

if [ ${#FAILED[@]} -gt 0 ]; then
  print_error "Failed (${#FAILED[@]}):"
  for script in "${FAILED[@]}"; do
    echo "  ✗ $script"
  done
  echo
  exit 1
fi

print_success "All Pi setup scripts completed successfully!"
