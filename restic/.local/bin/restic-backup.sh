#!/usr/bin/env bash
set -uo pipefail

source "$HOME/.config/restic/env"

JSONL=$(mktemp /tmp/restic-backup.XXXXXX.jsonl)
FORGET_LOG=$(mktemp /tmp/restic-forget.XXXXXX.log)
trap 'rm -f "$JSONL" "$FORGET_LOG"' EXIT

notify() {
  command -v notify-send >/dev/null 2>&1 || return 0
  notify-send -a restic "$@" 2>/dev/null || true
}

notify -t 5000 -u normal "Restic backup starting" "omarchy-desktop → Storage Box"

# Self-heal stale locks left by killed/crashed runs (restic 0.19+: removes
# stale locks only — fresh locks from concurrent runs are left alone).
UNLOCK_OUT=$(restic unlock 2>&1) || true
if [ -n "$UNLOCK_OUT" ]; then
  echo "restic unlock: $UNLOCK_OUT"
  notify -t 10000 -u normal "Restic backup" "Removed stale repository lock from a previous crashed run"
fi

START_EPOCH=$(date +%s)
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
DURATION_SEC=$(( $(date +%s) - START_EPOCH ))

PSQL_CMD="ssh jonny@raspberry5-8gb psql -d backup_metrics" \
  "$HOME/.local/bin/record-backup-run" \
    --host omarchy-desktop --tag desktop \
    --started "$STARTED" --finished "$FINISHED" \
    --exit "$EXIT_CODE" --jsonl "$JSONL" || true

if [ "$EXIT_CODE" -ne 0 ]; then
  SUMMARY=$(grep '"message_type":"exit_error"' "$JSONL" | tail -n1 || true)
  ERR=$(jq -r '.message // empty' <<<"$SUMMARY" | head -c 300 || true)
  notify -u critical "Restic backup FAILED" "exit $EXIT_CODE: ${ERR:-unknown — journalctl --user -u restic-backup}"
  exit "$EXIT_CODE"
fi

DURATION=$(printf '%dm%02ds' $((DURATION_SEC / 60)) $((DURATION_SEC % 60)))
SUMMARY=$(grep '"message_type":"summary"' "$JSONL" | tail -n1)
[ -n "$SUMMARY" ] || SUMMARY="{}"
BYTES_ADDED=$(jq -r '.data_added // 0' <<<"$SUMMARY")
SNAPSHOT_ID=$(jq -r '.snapshot_id // empty' <<<"$SUMMARY")
notify -t 10000 -u normal "Restic backup OK" \
  "took $DURATION, $(numfmt --to=iec --suffix=B "$BYTES_ADDED") added, snapshot ${SNAPSHOT_ID:0:8}"

restic forget \
  --host omarchy-desktop \
  --tag desktop \
  --keep-daily 7 \
  --keep-weekly 4 \
  --keep-monthly 12 \
  --keep-yearly 3 \
  --prune > "$FORGET_LOG" 2>&1
PRUNE_EXIT=$?
if [ "$PRUNE_EXIT" -ne 0 ]; then
  ERR=$(tail -n2 "$FORGET_LOG" | tr '\n' ' ' | tr -s ' ' | cut -c1-300)
  notify -u critical "Restic backup" "Backup OK, but forget/prune FAILED (exit $PRUNE_EXIT): $ERR"
  exit "$PRUNE_EXIT"
fi

exit 0
