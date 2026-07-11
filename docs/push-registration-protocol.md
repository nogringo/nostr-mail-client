# Push Registration Protocol

Push subscriptions are registered with an HTTP POST authenticated by
[NIP-98](https://github.com/nostr-protocol/nips/blob/master/98.md).

The server URL and route are deployment config, not part of this protocol.

## Request

```http
POST <configured push endpoint>
Content-Type: application/json
Authorization: Nostr <base64(nip98_event_json)>
```

NIP-98 requirements for Nmail:

- `method` is `POST`.
- `payload` is the SHA-256 hash of the exact UTF-8 JSON body.

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
- `disable` deletes by authenticated pubkey, transport type, and push
  destination.
- Invalid or expired push destinations should be pruned when FCM or the
  UnifiedPush distributor reports delivery failure.
