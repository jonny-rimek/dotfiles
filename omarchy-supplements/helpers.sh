#!/usr/bin/env bash
#
# helpers.sh
# Shared helper functions for Omarchy supplement scripts
#

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Print functions
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

# Check if command exists
command_exists() {
  command -v "$1" &>/dev/null
}

# Check if package is installed
package_installed() {
  pacman -Qi "$1" &>/dev/null
}

# Check if running as root
is_root() {
  [ "$EUID" -eq 0 ]
}

# Require root privileges
require_root() {
  if ! is_root; then
    print_error "This script must be run as root or with sudo"
    exit 1
  fi
}

# Require non-root
require_non_root() {
  if is_root; then
    print_error "This script should not be run as root"
    exit 1
  fi
}
