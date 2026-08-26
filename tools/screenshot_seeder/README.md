# Screenshot Seeder

Seeds localized Nostr accounts for product screenshots, including GitHub,
websites, and app store listings.

The seeder reads public content from:

```text
screenshots/seed-data/<locale>.json
```

Private keys are read from a local git-ignored file:

```text
screenshots/seed-keys/screenshot-accounts.json
```

Create it from:

```text
screenshots/seed-keys/screenshot-accounts.example.json
```

The top-level `bridge` key is the shared bridge account used to forward legacy
email senders into Nostr.

## Usage

Dry run:

```bash
dart run screenshot_seeder --locale en
```

Publish:

```bash
dart run screenshot_seeder --locale en --publish
```

By default, the seeder publishes only the primary account's `kind:10002` relay
list to `wss://relay.nmail.li`. The relay list points to
`wss://test-relay.uid.ovh`, where the rest of the screenshot fixtures are
published.

The primary account's `kind:10063` server list points to
`https://blossom.nmail.li`. Override it with `--blossom-server`.

Every contact with a `key` in the seed data gets a `kind:0` profile on the data
relay and its own `kind:10002` on the bootstrap relay, so the app can route the
profile lookup to the data relay. The bridge account gets the same pair. Without
the relay list, the app queries its own bootstrap relays and never finds the
profile.

Each contact vCard carries a `UID` derived from the locale and the contact key,
so re-running the seeder replaces the address-book entries instead of adding a
second copy of each. Inbox emails are not replaceable: every run delivers a new
set.

Every attachment declared in the seed data carries the same blob,
`screenshots/seed-data/attachment.pdf`; only the file name comes from the JSON.
Emails stay inline in their rumor while the rendered message is under 32 KB, so
the Blossom upload path only kicks in with a larger blob.
