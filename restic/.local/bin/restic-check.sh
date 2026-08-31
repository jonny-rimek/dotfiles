#!/usr/bin/env bash
set -uo pipefail

source "$HOME/.config/restic/env"

source "$HOME/.config/restic/env"

# Self-heal stale locks left by killed/crashed runs (restic 0.19+: removes
# stale locks only — fresh locks from concurrent runs are left alone).
UNLOCK_OUT=$(restic unlock 2>&1) || true
[ -n "$UNLOCK_OUT" ] && echo "restic unlock: $UNLOCK_OUT"

LOG=$(mktemp /tmp/restic-check.XXXXXX.log)
trap 'rm -f "$LOG"' EXIT

RAN_AT=$(date -Iseconds)
START_EPOCH=$(date +%s)
restic check --read-data-subset=5% 2>&1 | tee "$LOG"
EXIT_CODE=${PIPESTATUS[0]}
END_EPOCH=$(date +%s)
DURATION=$((END_EPOCH - START_EPOCH))

PSQL_CMD="ssh jonny@raspberry5-8gb psql -d backup_metrics" \
  "$HOME/.local/bin/record-backup-check" \
    --host omarchy-desktop \
    --ran-at "$RAN_AT" \
    --duration "$DURATION" \
    --exit "$EXIT_CODE" \
    --mode "read-data-subset-5" \
    --log "$LOG" || true

exit "$EXIT_CODE"
