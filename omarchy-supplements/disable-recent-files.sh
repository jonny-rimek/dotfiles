#!/usr/bin/env bash
#
# disable-recent-files.sh
# Stop XDG recent-files tracking by making recently-used.xbel an empty
# immutable file. A plain symlink to /dev/null is not enough because apps
# like Dolphin do atomic writes (write tempfile + rename), which replaces
# the symlink with a real file.
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

require_non_root

TARGET="$HOME/.local/share/recently-used.xbel"

print_info "Disabling XDG recent files tracking..."

mkdir -p "$(dirname "$TARGET")"

# If already immutable and empty, nothing to do.
if [ -f "$TARGET" ] && ! [ -L "$TARGET" ] && lsattr "$TARGET" 2>/dev/null | awk '{print $1}' | grep -q 'i'; then
  print_success "recently-used.xbel already immutable"
  exit 0
fi

# Drop immutability if set, so we can replace the file.
if [ -e "$TARGET" ] && lsattr "$TARGET" 2>/dev/null | awk '{print $1}' | grep -q 'i'; then
  sudo chattr -i "$TARGET"
fi

rm -f "$TARGET"
: > "$TARGET"
sudo chattr +i "$TARGET"

print_success "recently-used.xbel is now empty and immutable"
