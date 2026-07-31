# Push Registration Protocol

Push subscriptions are created and removed with an HTTP POST. Creating one is
authenticated, removing one is not; see [Authentication](#authentication).

The server URL and route are deployment config, not part of this protocol.

## Request

Register:

```http
POST <configured push endpoint>
Content-Type: application/json
Authorization: Nostr <base64(nip98_event_json)>
```

Disable:

```http
POST <configured push endpoint>
Content-Type: application/json
```

## Authentication

`register` binds a push destination to a pubkey, so it is authenticated with
[NIP-98](https://github.com/nostr-protocol/nips/blob/master/98.md).

NIP-98 requirements for Nmail:

- `method` is `POST`.
- `payload` is the SHA-256 hash of the exact UTF-8 JSON body.

`disable` carries no `Authorization` header. The push destination is the only
credential it needs.

## Body

The body contains only data required to create or remove a push subscription.

```json
{
  "action": "register",
  "language": "en",
  "transport": {}
}
```

Fields:

- `action`: `register` or `disable`.
- `language`: BCP 47 language tag for notification text, for example `en`,
  `fr`, or `fr-FR`. Required when `action` is `register`; omitted when
  `action` is `disable`.
- `pubkey`: 32-byte hex public key, optional and only meaningful when `action`
  is `disable`. Restricts the removal to that account's subscription; when it is
  omitted, every subscription on the destination is removed. For `register` the
  account is the authenticated NIP-98 pubkey, never a body field.
- `transport`: push destination details.

## Transports

FCM register:

```json
{ "type": "fcm", "token": "<fcm token>" }
```

FCM disable:

```json
{ "type": "fcm", "token": "<fcm token>" }
```

UnifiedPush register:

```json
{
  "type": "unifiedpush",
  "endpoint": "<push endpoint>",
  "p256dh": "<optional web push public key>",
  "auth": "<optional web push auth secret>",
  "instance": "<optional UnifiedPush instance>"
}
```

UnifiedPush disable:

```json
{
  "type": "unifiedpush",
  "endpoint": "<push endpoint>"
}
```

## Server Behavior

- `register` is an upsert by authenticated pubkey, transport type, and push
  destination. The stored notification language is updated to the submitted
  `language`.
- `disable` deletes by transport type and push destination, narrowed to
  `pubkey` when the field is present. It answers success whether or not a
  subscription matched, and stays acceptable at any time.
- Push destinations are secrets: keep them out of logs and never reveal whether
  one is known.
- Invalid or expired push destinations should be pruned when FCM or the
  UnifiedPush distributor reports delivery failure.
