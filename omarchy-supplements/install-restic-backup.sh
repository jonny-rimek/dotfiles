#!/usr/bin/env bash
#
# install-restic-backup.sh
# Set up restic nightly backup of ~/Documents, Pictures, dev, .ssh, .gnupg
# to the Hetzner Storage Box (sftp:u575677@u575677.your-storagebox.de:restic-desktop).
#
# Password lives in ~/Documents/noninteractive.kdbx under entry desktop/restic-password
# and is fetched at runtime via RESTIC_PASSWORD_COMMAND (see ~/.config/restic/env).
#
# SSH pubkey for the Storage Box is managed as IaC in
# ~/dev/tn4/infrastructure/tofu/hetzner/storage_box.tf — this script prints the
# pubkey and pauses until the user has added it there and run `make apply`.
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

require_non_root

DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
KDBX="$HOME/Documents/noninteractive.kdbx"
KDBX_KEYFILE="$HOME/Documents/noninteractive"
KDBX_ENTRY="desktop/restic-password"
SSH_KEY="$HOME/.ssh/restic_storagebox_ed25519"
STORAGEBOX_HOST="u577362.your-storagebox.de"
STORAGEBOX_USER="u577362"

# --- 1. restic package ------------------------------------------------------
print_info "Checking restic installation..."
if package_installed restic; then
  print_success "restic already installed ($(pacman -Qi restic | awk '/^Version/ {print $3}'))"
else
  print_info "Installing restic..."
  sudo pacman -Sy --noconfirm restic
  print_success "restic installed"
fi

# --- 2. stow the restic package --------------------------------------------
if ! command_exists stow; then
  print_error "GNU stow is required but not installed"
  exit 1
fi

print_info "Stowing restic package from $DOTFILES_DIR..."
(cd "$DOTFILES_DIR" && stow --target="$HOME" --restow restic)
print_success "restic package stowed"

# --- 3. KeePassXC noninteractive db sanity ---------------------------------
if [ ! -f "$KDBX" ] || [ ! -f "$KDBX_KEYFILE" ]; then
  print_error "Missing $KDBX or keyfile $KDBX_KEYFILE"
  print_error "Restore these from your personal vault before running this script."
  exit 1
fi

if ! command_exists keepassxc-cli; then
  print_error "keepassxc-cli not found — run install-keepassxc.sh first"
  exit 1
fi

print_info "Checking for KeePassXC entry $KDBX_ENTRY..."
if keepassxc-cli show --quiet --no-password \
     --key-file "$KDBX_KEYFILE" "$KDBX" "$KDBX_ENTRY" >/dev/null 2>&1; then
  print_success "Entry $KDBX_ENTRY already present"
else
  KDBX_GROUP="${KDBX_ENTRY%/*}"
  print_info "Ensuring group $KDBX_GROUP exists..."
  keepassxc-cli mkdir --quiet --no-password \
    --key-file "$KDBX_KEYFILE" \
    "$KDBX" "$KDBX_GROUP" >/dev/null 2>&1 || true

  print_info "Entry not found, generating new 40-char password..."
  keepassxc-cli add --quiet --no-password \
    --key-file "$KDBX_KEYFILE" \
    --generate --length 40 \
    "$KDBX" "$KDBX_ENTRY"
  print_success "Created $KDBX_ENTRY"
  echo
  print_warning "A new restic password was generated in $KDBX_ENTRY."
  print_warning "Export it and store it OFFLINE (paper / offline vault) before continuing."
  print_warning "Losing this password = losing all desktop backups. Permanently."
  echo
  read -rp "Press Enter when the password has been stored offline... " _
fi

# --- 4. SSH keypair for the Storage Box -------------------------------------
if [ ! -f "$SSH_KEY" ]; then
  print_info "Generating ed25519 keypair at $SSH_KEY..."
  ssh-keygen -t ed25519 -N "" -C "restic-desktop@$(hostname)" -f "$SSH_KEY"
  print_success "Keypair generated"
fi

echo
print_header "Hetzner Storage Box SSH key — manual IaC step"
echo
print_info "Pubkey:"
echo
cat "${SSH_KEY}.pub"
echo
print_info "1. Append this line to the ssh_keys list on hcloud_storage_box.paperless_restic in:"
echo "   ~/dev/tn4/infrastructure/tofu/hetzner/storage_box.tf"
print_info "2. Apply the change:"
echo "   make -C ~/dev/tn4/infrastructure/tofu/hetzner apply"
echo
read -rp "Press Enter once tofu apply has finished... " _

# --- 5. SSH client config for the storage box -------------------------------
SSH_CONFIG="$HOME/.ssh/config"
touch "$SSH_CONFIG"
chmod 600 "$SSH_CONFIG"
if ! grep -q "^Host $STORAGEBOX_HOST\$" "$SSH_CONFIG"; then
  print_info "Adding $STORAGEBOX_HOST block to $SSH_CONFIG..."
  cat >>"$SSH_CONFIG" <<EOF

Host $STORAGEBOX_HOST
    User $STORAGEBOX_USER
    Port 23
    IdentityFile $SSH_KEY
    IdentitiesOnly yes
EOF
  print_success "SSH config updated"
else
  print_success "SSH config already has $STORAGEBOX_HOST block"
fi

# --- 5b. Refresh known_hosts (handles destroy-recreate cycles) -------------
# If the box was destroyed and recreated via tofu, its hostname changes but the
# ed25519 host key is reused across Hetzner storage boxes. OpenSSH then refuses
# the connection because it sees the same key under the old hostname. Scrub any
# storagebox entries and re-scan the current host.
print_info "Refreshing known_hosts entries for storage boxes..."
if [ -f "$HOME/.ssh/known_hosts" ]; then
  sed -i.bak '/your-storagebox\.de/d' "$HOME/.ssh/known_hosts"
fi
mkdir -p "$HOME/.ssh"
ssh-keyscan -t ed25519 -p 23 "$STORAGEBOX_HOST" 2>/dev/null >> "$HOME/.ssh/known_hosts"

# --- 6. SFTP connectivity probe --------------------------------------------
# Hetzner Storage Boxes only allow the sftp subsystem, not arbitrary command exec,
# so probing with `ssh ... true` always fails. Use sftp instead.
print_info "Probing sftp connectivity to $STORAGEBOX_HOST..."
if printf 'bye\n' | sftp -o BatchMode=yes -o ConnectTimeout=10 \
     -P 23 -i "$SSH_KEY" "$STORAGEBOX_USER@$STORAGEBOX_HOST" >/dev/null 2>&1; then
  print_success "sftp reachable"
else
  print_error "sftp to $STORAGEBOX_HOST failed — did tofu apply complete and include this pubkey?"
  exit 1
fi

# --- 7. restic init if needed ----------------------------------------------
# shellcheck source=/dev/null
source "$HOME/.config/restic/env"

print_info "Checking restic repository..."
if restic snapshots >/dev/null 2>&1; then
  print_success "restic repository already initialized"
else
  print_info "Initializing restic repository at $RESTIC_REPOSITORY..."
  restic init
  print_success "restic repository initialized"
fi

# --- 8. systemd user timers ------------------------------------------------
print_info "Enabling linger for $USER (so user timers fire when not logged in)..."
sudo loginctl enable-linger "$USER"

print_info "Enabling restic systemd user timers..."
systemctl --user daemon-reload
systemctl --user enable --now restic-backup.timer restic-check.timer
print_success "Timers enabled"

systemctl --user list-timers 'restic-*' --no-pager || true

echo
print_success "restic desktop backup setup complete."
print_info "Seed the first snapshot now with:"
echo "   ~/.local/bin/restic-backup.sh"
print_info "Then verify with:"
echo "   source ~/.config/restic/env && restic snapshots --host omarchy-desktop"
