kp() {
  keepassxc-cli open \
    --no-password \
    --key-file "$HOME/Documents/noninteractive" \
    "$HOME/Documents/noninteractive.kdbx"
}

kpm() {
  local conflict="${1:?usage: kpm <sync-conflict-file.kdbx>}"
  local db
  case "$conflict" in
    *jimbov2*)
      db="$HOME/Documents/jimbov2_2025.kdbx"
      keepassxc-cli merge "$db" "$conflict"
      ;;
    *noninteractive*)
      db="$HOME/Documents/noninteractive.kdbx"
      keepassxc-cli merge \
        --no-password \
        --key-file "$HOME/Documents/noninteractive" \
        -y 2:3704123799 \
        "$db" "$conflict"
      ;;
    *)
      echo "kpm: cannot infer target db from '$conflict' (jimbov2|noninteractive)" >&2
      return 1
      ;;
  esac && echo "merged into $(basename "$db") — verify, then delete: $conflict"
}
