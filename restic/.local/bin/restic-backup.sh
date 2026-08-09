#!/usr/bin/env bash
set -uo pipefail

source "$HOME/.config/restic/env"

JSONL=$(mktemp /tmp/restic-backup.XXXXXX.jsonl)
trap 'rm -f "$JSONL"' EXIT

STARTED=$(date -Iseconds)
restic backup --json \
  --host omarchy-desktop \
  --tag desktop \
  --files-from "$HOME/.config/restic/includes.txt" \
  --exclude-file "$HOME/.config/restic/excludes.txt" \
  --exclude-caches \
  --one-file-system > "$JSONL"
EXIT_CODE=$?
FINISHED=$(date -Iseconds)

PSQL_CMD="ssh jonny@raspberry5-8gb psql -d backup_metrics" \
  "$HOME/.local/bin/record-backup-run" \
    --host omarchy-desktop --tag desktop \
    --started "$STARTED" --finished "$FINISHED" \
    --exit "$EXIT_CODE" --jsonl "$JSONL" || true

if [ "$EXIT_CODE" -ne 0 ]; then exit "$EXIT_CODE"; fi

restic forget \
  --host omarchy-desktop \
  --tag desktop \
  --keep-daily 7 \
  --keep-weekly 4 \
  --keep-monthly 12 \
  --keep-yearly 3 \
  --prune
