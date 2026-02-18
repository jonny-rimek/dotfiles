#!/usr/bin/env bash
#
# install-postgres.sh
# Install and configure PostgreSQL
# Reference: https://wiki.archlinux.org/title/PostgreSQL
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

PACKAGE_NAME="postgresql"

print_info "Checking PostgreSQL installation..."

# Check if already installed
if package_installed "$PACKAGE_NAME"; then
  INSTALLED_VERSION=$(pacman -Qi "$PACKAGE_NAME" | grep Version | awk '{print $3}')
  print_success "PostgreSQL already installed (version: $INSTALLED_VERSION)"
else
  print_info "Installing PostgreSQL..."

  if is_root; then
    pacman -Sy --noconfirm "$PACKAGE_NAME"
  else
    sudo pacman -Sy --noconfirm "$PACKAGE_NAME"
  fi

  if package_installed "$PACKAGE_NAME"; then
    INSTALLED_VERSION=$(pacman -Qi "$PACKAGE_NAME" | grep Version | awk '{print $3}')
    print_success "PostgreSQL installed successfully (version: $INSTALLED_VERSION)"
  else
    print_error "PostgreSQL installation failed"
    exit 1
  fi
fi

echo

# Initialize the database cluster if not already done
DATA_DIR="/var/lib/postgres/data"

print_info "Checking PostgreSQL data directory..."

if sudo test -f "$DATA_DIR/PG_VERSION"; then
  print_success "Database cluster already initialized at $DATA_DIR"
else
  print_info "Initializing database cluster..."

  sudo -iu postgres initdb \
    --locale=C.UTF-8 \
    --encoding=UTF8 \
    --data-checksums \
    -D "$DATA_DIR"

  if sudo test -f "$DATA_DIR/PG_VERSION"; then
    print_success "Database cluster initialized successfully"
  else
    print_error "Database cluster initialization failed"
    exit 1
  fi
fi

echo

# Enable and start the PostgreSQL service
print_info "Enabling and starting PostgreSQL service..."

sudo systemctl enable --now postgresql.service

if systemctl is-active --quiet postgresql; then
  print_success "PostgreSQL service is running"
else
  print_error "PostgreSQL service failed to start"
  exit 1
fi

echo

# Create a database user matching the current username
CURRENT_USER="$(whoami)"

print_info "Checking for PostgreSQL user '$CURRENT_USER'..."

if sudo -iu postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$CURRENT_USER'" | grep -q 1; then
  print_success "PostgreSQL user '$CURRENT_USER' already exists"
else
  print_info "Creating PostgreSQL user '$CURRENT_USER'..."

  sudo -iu postgres createuser --superuser "$CURRENT_USER"

  print_success "PostgreSQL user '$CURRENT_USER' created as superuser"
fi

echo
print_success "PostgreSQL installation and setup complete!"
