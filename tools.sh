#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
readonly TEMPLATE="${SCRIPT_DIR}/deploy/defaults/offlineimaprc"

usage() {
  printf '%s\n' \
    'Usage: ./tools.sh [option]' \
    '  -d  Generate ./vol/config and ./vol/mail' \
    '  -g  Generate offlineimaprc and password in the current directory' \
    '  -c  Remove downloaded mail and synchronization metadata' \
    '  -h  Display this help'
}

escape_config_value() {
  local value=$1
  value=${value//\\/\\\\}
  value=${value//&/\\&}
  value=${value//|/\\|}
  value=${value//%/%%}
  printf '%s' "$value"
}

generate_offlineimap() {
  local email host password escaped_email escaped_host

  if [[ -e offlineimaprc || -e password ]]; then
    printf 'Refusing to overwrite offlineimaprc or password\n' >&2
    return 1
  fi

  read -r -p 'Email address: ' email
  read -r -s -p 'Email password or app password: ' password
  printf '\n'
  read -r -p 'IMAP host: ' host

  if [[ -z $email || -z $password || -z $host ]]; then
    printf 'Email address, password, and IMAP host are required\n' >&2
    return 1
  fi

  escaped_email=$(escape_config_value "$email")
  escaped_host=$(escape_config_value "$host")
  sed \
    -e "s|user@example.org|${escaped_email}|g" \
    -e "s|mail.example.org|${escaped_host}|g" \
    "$TEMPLATE" > offlineimaprc
  printf '%s\n' "$password" > password
  chmod 600 offlineimaprc password
}

case "${1:-}" in
  -d)
    if [[ -e vol/config/offlineimaprc || -e vol/config/password ]]; then
      printf 'Refusing to overwrite existing configuration in ./vol/config\n' >&2
      exit 1
    fi
    generate_offlineimap
    mkdir -p vol/config vol/mail
    mv offlineimaprc password vol/config/
    ;;
  -g)
    generate_offlineimap
    ;;
  -c)
    read -r -p 'Remove downloaded mail and synchronization metadata (y/N)? ' answer
    case "${answer:-n}" in
      y|Y|yes|YES)
        rm -rf -- vol/config/metadata vol/mail
        mkdir -p vol/mail
        ;;
    esac
    ;;
  -h|--help|'')
    usage
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac
