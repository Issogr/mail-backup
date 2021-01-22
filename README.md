# docker-mail-backup
![icon](https://raw.githubusercontent.com/Issogr/docker-mail-backup/master/logo.png)

OfflineIMAP is a GPLv2 software to dispose your mailbox(es) as a local Maildir(s). For example, this allows reading the mails while offline without the need for your mail reader (MUA) to support disconnected operations. OfflineIMAP will synchronize both sides via IMAP. [OfflineIMAP](http://www.offlineimap.org/about/)

## Parameters

* `-v /vol` - the base directory of the data volume (if you use docker volume)
* `-e CONFIG_PATH` (default: `/vol/config`) - where offlineimap should store config files
* `-e MAIL_PATH` (default: `/vol/mail`) - local mail folder base path
* `-e PUID` for UserID
* `-e PGID` for GroupID
* `-e PGIDS` for additional GroupIDs
* `-e TZ` for timezone information, eg. Europe/London

## Example offlineimaprc

```
[general]
# List of accounts to be synced, separated by a comma.
metadata = /vol/config/metadata
accounts = user@example.org
maxsyncaccounts = 3
ui = basic
socktimeout = 120

#Automatic mailbox generation for mutt
#Disable by default
#[mbnames]
#enabled = yes
#filename = /vol/config/email/mailboxes
#header = "mailboxes "
#peritem = "+%(accountname)s/%(foldername)s"
#sep = " "
#footer = "\n"

[Account user@example.org]
# Identifier for the local repository; e.g. the maildir to be synced via IMAP.
localrepository = user@example.org-local
# Identifier for the remote repository; i.e. the actual IMAP, usually non-local.
remoterepository = user@example.org-remote
autorefresh = 2
quick=10

[Repository user@example.org-local]
# OfflineIMAP supports Maildir, GmailMaildir, and IMAP for local repositories.
type = Maildir
# Where should the mail be placed?
localfolders = /vol/mail/user@example.org

[Repository user@example.org-remote]
# Remote repos can be IMAP or Gmail, the latter being a preconfigured IMAP.
type = IMAP
remotehost = mail.example.org
remoteuser = user@example.org
remotepass = mail-password
sslcacertfile: %(systemcacertfile)s
ssl = yes
readonly = False
remoteport = 993

[DEFAULT]
systemcacertfile = /etc/ssl/certs/ca-certificates.crt
ssl_version = tls1_2
```