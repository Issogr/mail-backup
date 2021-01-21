# docker-mail-backup

OfflineIMAP is a GPLv2 software to dispose your mailbox(es) as a local Maildir(s). For example, this allows reading the mails while offline without the need for your mail reader (MUA) to support disconnected operations. OfflineIMAP will synchronize both sides via IMAP. [OfflineIMAP](http://www.offlineimap.org/about/)

## Parameters

* `-v /vol` - the base directory of the data volume (if you use docker volume)
* `-e CONFIG_PATH` (default: `/vol/config`) - where offlineimap should store config files
* `-e SECRETS_PATH` (default: `/vol/secrets`) - folder for storing secrets (passwords, certificates)
* `-e MAIL_PATH` (default: `/vol/mail`) - local mail folder base path
* `-e PUID` for UserID
* `-e PGID` for GroupID
* `-e PGIDS` for additional GroupIDs
* `-e TZ` for timezone information, eg. Europe/London

It is based on alpine linux with s6 overlay, for shell access whilst the container is running do
```
docker exec -it offlineimap /bin/bash
```

## Example offlineimaprc

```
[general]
metadata = /vol/config/metadata
accounts = user@example.org
maxsyncaccounts = 3
ui = basic
socktimeout = 120

[mbnames]
enabled = yes
filename = /vol/config/email/mailboxes
header = "mailboxes "
peritem = "+%(accountname)s/%(foldername)s"
sep = " "
footer = "\n"

[Account user@example.org]
localrepository = user@example.org-local
remoterepository = user@example.org-remote
autorefresh = 2
quick=10

[Repository user@example.org-local]
type = Maildir
localfolders = /vol/mail/user@example.org

[Repository user@example.org-remote]
type = IMAP
remotehost = mail.example.org
remoteuser = user@example.org
remotepassfile = /vol/secrets/user@example.org.pass
sslcacertfile: %(systemcacertfile)s
ssl = yes
readonly = True
remoteport = 993

[DEFAULT]
systemcacertfile = /etc/ssl/certs/ca-certificates.crt
```