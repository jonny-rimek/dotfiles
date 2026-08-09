kp() {
  keepassxc-cli open \
    --no-password \
    --key-file "$HOME/Documents/noninteractive" \
    "$HOME/Documents/noninteractive.kdbx"
}
