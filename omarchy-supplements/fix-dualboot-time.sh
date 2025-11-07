#!/usr/bin/env bash
#
# fix-dualboot-time.sh
# Fix Windows dual-boot time sync issue
# Linux uses UTC for hardware clock, Windows uses local time
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

print_info "Fixing dual-boot time synchronization..."

# Check current RTC setting
CURRENT_RTC=$(timedatectl show --property=LocalRTC --value)

if [ "$CURRENT_RTC" = "yes" ]; then
  print_success "RTC already set to local time (Windows-compatible)"
  exit 0
fi

print_info "Current RTC mode: UTC"
print_info "Setting RTC to local time for Windows compatibility..."

# Requires root
if ! is_root; then
  print_warning "Root privileges required, using sudo..."
  sudo timedatectl set-local-rtc 1 --adjust-system-clock
else
  timedatectl set-local-rtc 1 --adjust-system-clock
fi

# Verify the change
NEW_RTC=$(timedatectl show --property=LocalRTC --value)

if [ "$NEW_RTC" = "yes" ]; then
  print_success "RTC set to local time"
  print_info "Windows dual-boot time sync fixed"
  echo
  print_warning "Note: This may cause issues if you also boot other Linux distros"
  print_info "Alternative: Configure Windows to use UTC instead"
else
  print_error "Failed to set RTC to local time"
  exit 1
fi
