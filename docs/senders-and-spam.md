# Nostr mail: Senders And Spam

This document defines how incoming email is sorted between Inbox, Requests and Spam, and the Nostr list that stores the user's decisions.

## Mailboxes

A received email with no folder label is routed by the verdict of its sender:

| Verdict | Mailbox |
|---------|---------|
| `allow` | Inbox |
| `block` | Spam |
| none | Requests |

An email with a folder label is in that folder, whatever the verdict. Spam holds the emails routed by `block` and the emails labelled `folder:spam`.

## Sender Key

The sender of an email is identified by:

- a native Nostr email: `<pubkey>`;
- a bridged email (its rumor carries a `mail-from` tag): `<pubkey>:<address>`.

`<pubkey>` is the hex pubkey of the rumor. `<address>` is the addr-spec of the MIME `From` header, lowercased. No other normalization is applied.

## Senders List

Verdicts are stored in one list following the Append-Only Lists NIP (`kind:1990` Add, `kind:1991` Remove).

- `d` tag: `nostr-mail/senders`.
- Entries are in the NIP-44 encrypted content only. The events carry no public entry tag.
- Each entry is a `sender` tag holding a sender key and its verdict:

```json
[
  ["sender", "<hex pubkey>", "allow"],
  ["sender", "<hex pubkey>:alice@example.com", "allow"],
  ["sender", "<hex pubkey>:promo@spam.example", "block"]
]
```

- Verdict: `allow` or `block`.

The events are published to the account's NIP-65 write relays.

### Verdict Resolution

The verdict of a sender is the third element of the most recent Add containing its entry, among entries that are members of the list. When two Adds share the same `created_at`, the one with the lowest event id wins.

A sender has no verdict when its entry is not a member, or when the winning Add carries no `allow` or `block`.

## User Actions

| Action | Where | Effect |
|--------|-------|--------|
| Accept | Requests | Add `allow` for the sender |
| Accept all | Requests | Add `allow` for every sender in Requests, in one event |
| Block sender | any email outside Spam | Add `block` for the sender |
| Unblock sender | Spam | Add `allow` for the sender |
| Empty Spam | Spam | Delete every email in Spam, as emptying Trash does |

Accept, Block sender and Unblock sender apply to the sender, so they move all of its routed emails at once.

## Notifications

An email routed to Spam shows no notification. An email routed to Requests shows one only when its sender has no other email in Requests.

## Navigation

- Routes: `/requests` and `/spam`.
- Sidebar: a Requests entry showing the number of senders with no verdict, and a Spam entry with no unread count.
- Inbox: a banner showing the number of pending senders while Requests is not empty. It opens `/requests`.
