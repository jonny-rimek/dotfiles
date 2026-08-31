#!/usr/bin/env bash
set -uo pipefail

ENV_FILE="${RESTIC_ENV_FILE:-$HOME/.config/restic/env}"
HOST="${RESTIC_HOST:-omarchy-desktop}"
TAG="${RESTIC_TAG:-desktop}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/restic-restore"
DEFAULT_ROOT="$HOME/restic-restores"
SELF=$(readlink -f "${BASH_SOURCE[0]}")

DEST=""
FLATTEN=1
NOTIFY=1
SNAP_ARG=""

usage() {
  cat <<EOF
usage: restic-restore.sh [options] [snapshot-id|latest]

Download a restic snapshot from $HOST to this machine, flatten it,
verify the restored content against the repository and report sizes.

With no snapshot-id an fzf picker is shown (preview: size + paths).

options:
  -d, --dest DIR      restore into DIR (default: $DEFAULT_ROOT/<ts>-<id>)
      --no-flatten    keep restic's full path layout instead of unpacking
      --no-notify     skip desktop notifications
      --stat ID       print snapshot size/details (used as fzf preview)
      --list          print picker entries and exit
  -h, --help          this help

env overrides: RESTIC_ENV_FILE, RESTIC_HOST, RESTIC_TAG, RESTIC_REPOSITORY
EOF
}

die() {
  echo "error: $*" >&2
  exit 2
}

while [ $# -gt 0 ]; do
  case "$1" in
    -d|--dest) DEST="${2:?}"; shift 2 ;;
    --no-flatten) FLATTEN=0; shift ;;
    --no-notify) NOTIFY=0; shift ;;
    --stat) [ -n "${2:-}" ] || die "--stat needs a snapshot id"; MODE_STAT="$2"; shift 2 ;;
    --list) MODE_LIST=1; shift ;;
    -h|--help) usage; exit 0 ;;
    -*) usage >&2; die "unknown option: $1" ;;
    *) [ -z "$SNAP_ARG" ] || die "only one snapshot id allowed"; SNAP_ARG="$1"; shift ;;
  esac
done

[ -f "$ENV_FILE" ] && source "$ENV_FILE"
[ -n "${RESTIC_REPOSITORY:-}" ] || die "no repository configured (set $ENV_FILE or RESTIC_REPOSITORY)"
CACHE_DIR="$CACHE_DIR/$(printf '%s' "${RESTIC_REPOSITORY}" | md5sum | cut -c1-8)"

notify() {
  [ "$NOTIFY" = 1 ] || return 0
  command -v notify-send >/dev/null 2>&1 || return 0
  notify-send -a restic "$@" 2>/dev/null || true
}

mkdir -p "$CACHE_DIR"

snapshots_json() {
  local f="$CACHE_DIR/snapshots.json"
  if [ ! -f "$f" ] || [ $(( $(date +%s) - $(stat -c %Y "$f") )) -gt 120 ]; then
    restic snapshots --no-lock --json --host "$HOST" --tag "$TAG" > "$f" 2>"$CACHE_DIR/snapshots.err" || {
      cat "$CACHE_DIR/snapshots.err" >&2
      die "restic snapshots failed (repo unreachable? Nitrokey plugged in?)"
    }
  fi
  cat "$f"
}

entry_for() {
  local id="$1"
  if [ "$id" = "latest" ]; then
    restic snapshots --no-lock --json --host "$HOST" --tag "$TAG" | jq -c '.[-1]'
  else
    local json
    json=$(snapshots_json)
    jq -c --arg id "$id" '[.[] | select(.short_id == $id or .id == $id)] | if length == 1 then .[0] elif length == 0 then null else . end' <<<"$json"
  fi
}

stats_json() {
  local id="$1" f="$CACHE_DIR/stats-$1.json"
  if [ ! -f "$f" ]; then
    restic stats --no-lock --mode restore-size --json "$id" > "$f" || die "restic stats failed for $id"
  fi
  cat "$f"
}

human_age() {
  local secs=$(( $(date +%s) - $1 ))
  if [ "$secs" -lt 86400 ]; then
    echo "today"
  else
    local days=$(( secs / 86400 ))
    if [ "$days" -lt 14 ]; then
      echo "${days}d ago"
    else
      echo "$(( days / 7 ))w ago"
    fi
  fi
}

fmt_time() {
  date -d "$1" "+%Y-%m-%d %H:%M"
}

fmt_entry() {
  local sid="$1" time="$2" paths="$3"
  printf '%-10s %-16s %-8s %s\n' "$sid" "$(fmt_time "$time")" "$(human_age "$(date -d "$time" +%s)")" "$(echo "$paths" | sed "s|$HOME|~|g")"
}

list_entries() {
  snapshots_json | jq -r '.[] | [.short_id, .time, (.paths | join(" "))] | @tsv'
}

MODE_STAT="${MODE_STAT:-}"
MODE_LIST="${MODE_LIST:-}"

if [ -n "$MODE_LIST" ]; then
  while IFS=$'\t' read -r sid time paths; do
    fmt_entry "$sid" "$time" "$paths"
  done < <(list_entries)
  exit 0
fi

if [ -n "$MODE_STAT" ]; then
  ENTRY=$(entry_for "$MODE_STAT") || true
  [ -n "$ENTRY" ] && [ "$ENTRY" != "null" ] || die "no snapshot $MODE_STAT for host=$HOST tag=$TAG"
  STATS=$(stats_json "$(jq -r .short_id <<<"$ENTRY")")
  [ -n "$STATS" ] || die "restic stats failed for $MODE_STAT"
  {
    echo "snapshot  $(jq -r .short_id <<<"$ENTRY")"
    echo "time      $(fmt_time "$(jq -r .time <<<"$ENTRY")")  ($(human_age "$(date -d "$(jq -r .time <<<"$ENTRY")" +%s)"))"
    echo "size      $(numfmt --to=iec --suffix=B "$(jq -r .total_size <<<"$STATS")")  ($(printf "%'d" "$(jq -r .total_file_count <<<"$STATS")") files)"
    echo "tags      $(jq -r '.tags | join(", ")' <<<"$ENTRY")"
    echo "paths"
    jq -r '.paths[]' <<<"$ENTRY" | sed "s|$HOME|  ~|"
  } || echo "failed to build snapshot info"
  exit 0
fi

if [ -z "$SNAP_ARG" ]; then
  command -v fzf >/dev/null 2>&1 || die "fzf not found; pass a snapshot id instead"
  [ -t 0 ] || die "no tty for fzf; pass a snapshot id instead"
  SEL=$(list_entries | while IFS=$'\t' read -r sid time paths; do
    fmt_entry "$sid" "$time" "$paths"
  done | fzf --layout=reverse-list --info=inline \
    --header 'enter: download + verify   esc: cancel' \
    --preview "$SELF --stat {1}" --preview-window 'right:55%:wrap') || exit 0
  SNAP_ARG=$(awk '{print $1}' <<<"$SEL")
fi

notify -t 5000 -u normal "Restic restore starting" "$SNAP_ARG → downloading from Storage Box"

ENTRY=$(entry_for "$SNAP_ARG") || true
[ -n "$ENTRY" ] && [ "$ENTRY" != "null" ] || die "no snapshot '$SNAP_ARG' for host=$HOST tag=$TAG"
SHORT_ID=$(jq -r .short_id <<<"$ENTRY")
PJSON="$CACHE_DIR/snap-$SHORT_ID.json"
printf '%s' "$ENTRY" > "$PJSON"

STATS=$(stats_json "$SHORT_ID")
[ -n "$STATS" ] || die "restic stats failed for $SHORT_ID"
TOTAL_SIZE=$(jq -r .total_size <<<"$STATS")
TOTAL_FILES=$(jq -r .total_file_count <<<"$STATS")

if [ -z "$DEST" ]; then
  mkdir -p "$DEFAULT_ROOT"
  DEST="$DEFAULT_ROOT/$(date +%Y%m%d-%H%M%S)-$SHORT_ID"
fi
[ ! -e "$DEST" ] || die "destination $DEST already exists"
mkdir -p "$DEST" || die "cannot create $DEST"

AVAIL=$(df -B1 --output=avail "$(dirname "$DEST")" | tail -1)
SLACK=$(( 512 * 1024 * 1024 ))
if [ "$TOTAL_SIZE" -gt $(( AVAIL - SLACK )) ]; then
  rmdir "$DEST"
  die "not enough space: snapshot needs $(numfmt --to=iec --suffix=B "$TOTAL_SIZE"), only $(numfmt --to=iec --suffix=B "$AVAIL") free at $(dirname "$DEST")"
fi

echo "downloading $SHORT_ID ($(fmt_time "$(jq -r .time <<<"$ENTRY")"), $(numfmt --to=iec --suffix=B "$TOTAL_SIZE"), $(printf "%'d" "$TOTAL_FILES") files)"
echo "target: $DEST"
START=$SECONDS
if ! restic restore "$SHORT_ID" --target "$DEST" --verify; then
  notify -u critical "Restic restore FAILED" "download/verify of $SHORT_ID failed — do not trust $DEST"
  echo "error: restic restore --verify failed — $DEST kept for inspection but is NOT verified" >&2
  exit 1
fi
DURATION=$(printf '%dm%02ds' $(( (SECONDS - START) / 60 )) $(( (SECONDS - START) % 60 )))

RESTORED_NODES=$(find "$DEST" -mindepth 1 | wc -l)

PREFIX=$(jq -r '.paths[]' "$PJSON" | awk -F/ 'NR==1{for(j=1;j<=NF;j++)a[j]=$j; n=NF; next} {for(i=1;i<=n;i++) if(a[i]!=$i){n=i-1; break}} END{for(i=1;i<=n;i++) printf "%s/", a[i]}')

if [ "$FLATTEN" != 1 ]; then
  echo "unpack     skipped (--no-flatten)"
elif [ -n "$PREFIX" ] && [ "$PREFIX" != "/" ]; then
  INNER="$DEST$PREFIX"
  shopt -s dotglob nullglob
  COLLISION=0
  for child in "$INNER"/*; do
    base=$(basename "$child")
    if [ -e "$DEST/$base" ]; then
      echo "warning: cannot unpack $base — already exists at destination root" >&2
      COLLISION=1
    fi
  done
  if [ "$COLLISION" = 0 ]; then
    for child in "$INNER"/*; do
      mv "$child" "$DEST/"
    done
    rmdir -p --ignore-fail-on-non-empty "$INNER" 2>/dev/null || true
    echo "unpack     flattened $PREFIX → $DEST"
  else
    echo "unpack     kept restic layout due to name collisions"
  fi
  shopt -u dotglob nullglob
else
  echo "unpack     no common root — keeping restic layout"
fi

RESTORED_FILES=$(find "$DEST" \( -type f -o -type l \) | wc -l)
SIZE_DISK=$(du -sh "$DEST" | cut -f1)

echo
echo "snapshot   $SHORT_ID  ($(fmt_time "$(jq -r .time <<<"$ENTRY")"))"
echo "location   $DEST"
echo "size       $SIZE_DISK on disk  ($(printf "%'d" "$RESTORED_FILES") files)"
if [ "$RESTORED_NODES" -ne "$TOTAL_FILES" ]; then
  echo
  echo "warning: item count mismatch — snapshot has $(printf "%'d" "$TOTAL_FILES"), restored $(printf "%'d" "$RESTORED_NODES")"
  echo "$DEST kept for inspection but NOT fully verified"
  notify -u critical "Restic restore" "$SHORT_ID: file count mismatch — see terminal"
  exit 1
fi

echo "verified   content matches repository (restic --verify)"
echo
echo "top-level:"
find "$DEST" -mindepth 1 -maxdepth 1 -exec du -sh {} + | sed "s|$DEST/||" | sort -k2

notify -t 10000 -u normal "Restic restore OK (verified)" \
  "$SHORT_ID: $SIZE_DISK, $(printf "%'d" "$RESTORED_FILES") files, $DURATION → $DEST"
