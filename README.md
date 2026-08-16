<p align="center">
  <img src="logo.png" width="150" alt="Mail Backup logo">
</p>

<h1 align="center">Mail Backup</h1>

<p align="center">
  A continuously running, containerized IMAP-to-Maildir retention mirror.
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-GPLv3-2f855a.svg" alt="GNU GPL version 3 license"></a>
  <a href="https://github.com/OfflineIMAP/offlineimap3/releases/tag/v8.0.3"><img src="https://img.shields.io/badge/OfflineIMAP-8.0.3-29a89a.svg" alt="OfflineIMAP version 8.0.3"></a>
</p>

## Purpose

Mail Backup runs [OfflineIMAP](https://github.com/OfflineIMAP/offlineimap3) in
a small container and continuously downloads an IMAP mailbox into a standard
local [Maildir](https://en.wikipedia.org/wiki/Maildir).

The project adds a retention-oriented default configuration, an interactive
configuration generator, UID/GID-aware volume access, and multi-architecture
container publishing. It is intended for unattended use on a server or NAS.

> **Important:** This is a retention mirror, not a complete backup by itself.
> Snapshot or back up `vol/` separately to protect against local deletion,
> disk failure, corruption, or compromised credentials.

## Retention Behavior

The generated configuration synchronizes every 15 minutes:

| Event | Result |
| --- | --- |
| New remote message | Downloaded to the local Maildir |
| Remote message deletion | Local message is retained |
| Local message or folder change | Never uploaded to the server |
| Local message deletion | Server copy remains, but the local file is not restored automatically |
| Container restart | Sync resumes using persisted metadata |

This behavior comes from two important settings:

```ini
readonly = true
sync_deletes = no
```

Retention causes storage use to grow until messages are removed locally.

## Quick Start

Choose either the repository workflow or the published container directly.

### Option 1: Clone Main

This option provides the configuration helper and Compose definition:

```bash
git clone --depth 1 --branch main https://github.com/Issogr/mail-backup.git
cd mail-backup
./tools.sh -d
printf 'PUID=%s\nPGID=%s\nTZ=UTC\n' "$(id -u)" "$(id -g)" > .env
docker compose up -d
```

`tools.sh` asks for the email address, IMAP password, and IMAP hostname. Use a
provider app password when normal account credentials are not accepted.

### Option 2: Run Latest Image

Prepare the [sample configuration](deploy/defaults/offlineimaprc) and password
file using the layout shown below, then run the published image directly:

```bash
docker run -d --name mail-backup --restart unless-stopped \
  -e PUID="$(id -u)" -e PGID="$(id -g)" -e TZ=UTC \
  -v "$PWD/vol:/vol" \
  ghcr.io/issogr/mail-backup:latest
```

Authenticate with `ghcr.io` first if the package is private.

### Data Layout

Both deployment options expect the same persistent structure:

```text
vol/
├── config/
│   ├── offlineimaprc   # OfflineIMAP configuration
│   ├── password        # One-line IMAP password, mode 0600
│   └── metadata/       # Generated synchronization state
└── mail/               # Downloaded Maildir data
```

The helper creates `offlineimaprc` and `password` with mode `0600`. Credentials
and downloaded mail are excluded from Git.

## Operations

Follow logs and verify the first synchronization:

```bash
docker compose logs -f mail-backup
# Container-only installation:
docker logs -f mail-backup
```

Run one synchronization while the continuous service is stopped:

```bash
docker compose run --rm mail-backup -o
```

Update the Compose installation to the latest published image:

```bash
docker compose pull && docker compose up -d
```

Helper operations:

```bash
./tools.sh -h
./tools.sh -c
```

`./tools.sh -c` preserves the configuration and password but removes all local
mail and synchronization metadata after confirmation. The next run performs a
complete download.

## Configuration

### Container Variables

| Variable | Default | Purpose |
| --- | --- | --- |
| `CONFIG_PATH` | `/vol/config` | Configuration, password, and metadata directory |
| `MAIL_PATH` | `/vol/mail` | Maildir base directory |
| `PUID` | `1000` | User ID used for mounted files |
| `PGID` | `1000` | Group ID used for mounted files |
| `TZ` | `UTC` | Container timezone |

Keep `PUID` and `PGID` aligned with the owner of `vol/`.

### Generated Defaults

The bundled configuration provides:

- IMAPS on port 993 with operating-system certificate authorities.
- A separate password file instead of an inline secret.
- A 15-minute automatic refresh interval.
- A read-only remote repository.
- Local retention of remotely deleted messages.

Edit `vol/config/offlineimaprc` for different ports, intervals, account sets,
or folder filters. OAuth and provider-specific authentication must be configured
manually using the
[OfflineIMAP configuration reference](https://github.com/OfflineIMAP/offlineimap3/blob/master/offlineimap.conf).

## Protecting the Data

- Back up both `vol/mail` and `vol/config`.
- Encrypt secondary copies because Maildir stores plaintext messages.
- Keep `vol/config/password` restricted and out of version control.
- Monitor free space because remote deletions are retained.
- Test recovery from a snapshot or secondary backup.

## Project Status

The current image contains OfflineIMAP 8.0.3 on Python 3.14 and Alpine 3.24.
GitHub Actions builds `linux/amd64` and `linux/arm64` images and publishes them
to `ghcr.io/issogr/mail-backup`.

## License

Mail Backup is distributed under the
[GNU General Public License, version 3](LICENSE) (`GPL-3.0-only`). The complete
license text is included in `LICENSE`.

OfflineIMAP is a separate upstream project distributed under GPL-2.0-or-later.
Other container dependencies retain their respective licenses.
