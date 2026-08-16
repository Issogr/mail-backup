#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
readonly ROOT
workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

cd "$workdir"
printf '%s\n' 'backup+tag%archive@example.org' 'p/a&ss%word' 'imap.example.org' \
  | "$ROOT/tools.sh" -g

grep -Fq 'remotehost = imap.example.org' offlineimaprc
grep -Fq 'remotepassfile = password' offlineimaprc
if grep -Fq 'p/a&ss%word' offlineimaprc; then
  printf 'Password was written to offlineimaprc\n' >&2
  exit 1
fi

[[ $(<password) == 'p/a&ss%word' ]]

python3 - <<'PY'
from configparser import ConfigParser

config = ConfigParser()
with open("offlineimaprc", encoding="utf-8") as config_file:
    config.read_file(config_file)

assert config.get("Repository backup-remote", "remoteuser") == \
    "backup+tag%archive@example.org"
assert config.get("Repository backup-local", "localfolders") == \
    "$MAIL_PATH/backup+tag%archive@example.org"
PY

printf 'Configuration generator test passed\n'
