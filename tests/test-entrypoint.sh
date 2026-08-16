#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
readonly ROOT
workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

mkdir -p "$workdir/bin" "$workdir/config" "$workdir/mail"
printf '[general]\n' > "$workdir/config/offlineimaprc"

printf '%s\n' '#!/bin/sh' 'printf "%s\\n" "$@"' > "$workdir/bin/offlineimap"
printf '%s\n' '#!/bin/sh' 'shift' 'exec "$@"' > "$workdir/bin/su-exec"
chmod 755 "$workdir/bin/offlineimap" "$workdir/bin/su-exec"

output=$(
  CONFIG_PATH="$workdir/config" \
  MAIL_PATH="$workdir/mail" \
  PGID="$(id -g)" \
  PUID="$(id -u)" \
  PATH="$workdir/bin:$PATH" \
    "$ROOT/deploy/entrypoint.sh" -o
)

expected=$(printf '%s\n' -c "$workdir/config/offlineimaprc" -o)
[[ $output == "$expected" ]]

printf 'Entrypoint test passed\n'
