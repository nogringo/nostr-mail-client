# Nostr mail: Backup

This document defines the backup file of a Nostr mail account, how it is restored, and the readable mail export.

## Backup File

A backup is a ZIP archive holding one account:

```text
manifest.json
events.jsonl
blobs/<sha256>
```

### manifest.json

```json
{
  "format": "nostr-mail-backup",
  "version": 1,
  "pubkey": "<account hex pubkey>",
  "created_at": <unix seconds of the export>
}
```

### events.jsonl

One signed event per line, as its NIP-01 JSON (`id`, `pubkey`, `created_at`, `kind`, `tags`, `content`, `sig`), in UTF-8, lines separated by `\n`. Each event appears once, in any order.

The file holds every event the exporting client stores locally that matches one of these filters, `<pk>` being the account's hex pubkey:

| Filter | Events |
|--------|--------|
| `{"kinds": [1059], "#p": ["<pk>"]}` | Gift wraps: received emails, self-copies of sent emails, labels |
| `{"kinds": [1301], "#p": ["<pk>"]}` | Public emails |
| `{"kinds": [5], "authors": ["<pk>"], "#k": ["1059", "1301", "1985", "16", "1990", "1991", "38522"]}` | Deletions |
| `{"kinds": [1985], "authors": ["<pk>"], "#L": ["mail"]}` | Labels |
| `{"kinds": [1990, 1991], "authors": ["<pk>"], "#d": ["nostr-mail/senders"]}` | Senders list |
| `{"kinds": [16], "authors": ["<pk>"]}` | Reposts |
| `{"kinds": [30078], "authors": ["<pk>"], "#d": ["nostr-mail/settings/private"]}` | Private settings |
| `{"kinds": [31234], "authors": ["<pk>"], "#k": ["1301"]}` | Drafts |
| `{"kinds": [38522], "authors": ["<pk>"]}` | Contacts |
| `{"kinds": [0, 10002, 10013, 10050, 10063], "authors": ["<pk>"]}` | Profile, relay lists, Blossom server list |

### blobs/

One file per Blossom blob named by the `x` tag of an email rumor or a draft rumor of the account. The file name is the blob's lowercase hex sha256. The content is the blob bytes as a Blossom server serves them, still encrypted.

A blob the exporting client can neither read locally nor download is absent from the archive.

## Restore

A backup is restored into the account whose pubkey is `manifest.pubkey`. When the active account has another pubkey, the restore is refused.

1. The backup is refused when `format` is not `nostr-mail-backup` or `version` is greater than `1`.
2. Each event is dropped unless its `id` and `sig` are valid and it matches one of the filters of [events.jsonl](#eventsjsonl) for `manifest.pubkey`. The others are stored in the local event store, as if a relay had served them.
3. Each blob is dropped unless the sha256 of its bytes equals its file name. The others are stored in the local blob cache, pinned for the account.
4. The mailbox and the contacts are rebuilt from the local event store, as after a sync.

A restore sends nothing to relays or Blossom servers. Restoring the same backup twice gives the same result as restoring it once. Gift wraps are decrypted through the account's signer, as during a sync.

## Mail Export

A mail export is a ZIP archive with one file per folder of the account:

```text
Inbox.mbox
Sent.mbox
Archive.mbox
Trash.mbox
Spam.mbox
Requests.mbox
<folder name>.mbox
```

- `<folder name>` is the name of a user folder, with the characters `/ \ : * ? " < > |` replaced by `_`.
- Files are named in the order above, then in the display order of the user folders. A file name equal to an earlier one, ignoring case, gets a ` (2)`, ` (3)`, etc. suffix.
- An email in a folder the account no longer has goes to `Sent.mbox` when the account sent it, to `Inbox.mbox` otherwise.
- A folder without email has no file.
- Each file is in the `mboxrd` format. Each message is preceded by a `From ` line:

```text
From <sender address> <date of the email, asctime format, UTC>
```

- The message is the full MIME text of the email, attachments included, with LF line endings. Any line matching `^>*From ` gets one more leading `>`. A blank line follows the message.
- An email whose full MIME text the exporting client cannot read locally nor download is absent from the export.
