#!/bin/sh

set -eu

config="${CONFIG_PATH}/offlineimaprc"

if [ ! -r "$config" ]; then
  printf 'Configuration file is not readable: %s\n' "$config" >&2
  exit 1
fi

case "$PUID" in
  ''|*[!0-9]*) printf 'PUID must be a numeric user ID\n' >&2; exit 1 ;;
esac

case "$PGID" in
  ''|*[!0-9]*) printf 'PGID must be a numeric group ID\n' >&2; exit 1 ;;
esac

umask 077
mkdir -p "$CONFIG_PATH" "$MAIL_PATH"
cd "$CONFIG_PATH"

set -- offlineimap -c "$config" "$@"

if [ "$(id -u)" -eq 0 ]; then
  chown -R "$PUID:$PGID" "$CONFIG_PATH"
  chown "$PUID:$PGID" "$MAIL_PATH"
  exec su-exec "$PUID:$PGID" "$@"
fi

exec "$@"
