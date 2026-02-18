#!/usr/bin/env bash
#
# install-hosts.sh
# Add custom entries to /etc/hosts
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

HOSTS_FILE="/etc/hosts"

add_host_entry() {
  local entry="$1"
  if grep -qF "$entry" "$HOSTS_FILE"; then
    print_success "Already in $HOSTS_FILE: $entry"
  else
    print_info "Adding to $HOSTS_FILE: $entry"
    echo "$entry" | sudo tee -a "$HOSTS_FILE" > /dev/null
    print_success "Added: $entry"
  fi
}

print_info "Configuring $HOSTS_FILE..."

add_host_entry "127.0.0.1        retriever.localhost"
add_host_entry "::1              retriever.localhost"

echo
print_success "/etc/hosts configuration complete!"
