# Nostr mail: Drafts

This document defines how an unsent email is stored on Nostr as a draft, following [NIP-37](https://github.com/nostr-protocol/nips/blob/master/37.md).

## Draft Wrap

A draft is a `kind:31234` event signed by the account:

```json
{
  "kind": 31234,
  "pubkey": "<account hex pubkey>",
  "created_at": <unix seconds of the save>,
  "tags": [
    ["d", "<draft id>"],
    ["k", "1301"]
  ],
  "content": "<NIP-44 encryption of the draft rumor, to the account's own pubkey>"
}
```

- `d`: the draft id, 32 random lowercase hex characters, chosen at the first save and kept for the life of the draft.
- `k`: always `1301`.
- No other tag. In particular, no `expiration`, no `p`, no `e` and no `a`.

## Draft Rumor

The decrypted content is the JSON of the self-copy rumor: the unsigned `kind:1301` event the sender would gift wrap to itself if the email were sent at the time of the save.

```json
{
  "id": "<event id>",
  "pubkey": "<account hex pubkey>",
  "created_at": <unix seconds of the save>,
  "kind": 1301,
  "tags": [
    ["p", "<account hex pubkey>"],
    ["mail-from", "<sender address>"]
  ],
  "content": "<MIME text>"
}
```

- `pubkey` is the pubkey of the draft wrap.
- `tags` are the tags of the self-copy rumor. `mail-from` is present only when the self-copy rumor carries it.
- `content` is the full MIME text of the self-copy, Bcc header included:
  - `From` is the selected sender address.
  - `To`, `Cc` and `Bcc` hold every recipient, including the ones that are not resolved yet.
  - A reply or a forward carries `In-Reply-To` and `References`, and its quoted part.
  - Attachments and inline images are MIME parts.
- `sig` is absent.

### Large Drafts

When the MIME text is 32 KiB or more, it is stored as an encrypted Blossom blob, as for the self-copy of a sent email:

- `content` is empty.
- `tags` also holds:

```json
[
  ["x", "<sha256 of the encrypted blob>"],
  ["encryption-algorithm", "aes-gcm"],
  ["decryption-key", "<key>"],
  ["decryption-nonce", "<nonce>"]
]
```

The blob is uploaded to the account's Blossom servers (`kind:10063`). Each save of a large draft uploads a new blob.

## Relays

Draft wraps are published to and read from:

1. the account's private relays (`kind:10013`), when it publishes one;
2. otherwise, the account's NIP-65 write relays.

Never both.

## Reading Drafts

Filter:

```json
{ "kinds": [31234], "authors": ["<account hex pubkey>"], "#k": ["1301"] }
```

For each `d`, the latest draft wrap is the current version (highest `created_at`, then lowest event id). A draft wrap with an empty `content` is a deleted draft and is not listed.

Draft wraps with another `k` (such as scheduled email packages, `k` `5905`) are not drafts.

## Lifecycle

| Action | Event |
|--------|-------|
| First save | New draft wrap with a new `d` |
| Save | Draft wrap with the same `d`, replacing the previous one |
| Open | Decrypt the current version and fill the composer from its MIME |
| Send | Email sent as usual, then a draft wrap with the same `d` and an empty `content` |
| Schedule | Email scheduled as usual, then a draft wrap with the same `d` and an empty `content` |
| Discard | Draft wrap with the same `d` and an empty `content` |

The draft rumor is never sent. Sending builds a new email from the composer.
