# WKD Publish Protocol

OpenPGP public keys are published and unpublished with `PUT` and `DELETE` on their [Web Key Directory](https://datatracker.ietf.org/doc/draft-koch-openpgp-webkey-service/) (WKD) lookup URL, authenticated by NIP-98. The lookup itself is standard WKD.

## Request

Publish:

```http
PUT <WKD lookup URL>
Content-Type: application/octet-stream
Authorization: Nostr <base64(nip98_event_json)>

<key as served by the WKD lookup>
```

Unpublish:

```http
DELETE <WKD lookup URL>
Authorization: Nostr <base64(nip98_event_json)>
```

The `l` parameter of the lookup URL is required. The address is `<l>@<domain>`.

## Authentication

`PUT` and `DELETE` are authenticated with [NIP-98](https://github.com/nostr-protocol/nips/blob/master/98.md), with a required `payload` tag on `PUT`.

The NIP-98 pubkey must own the address: the server maps the address to that pubkey, whether through a NIP-05 record or a local part that encodes the pubkey (such as its npub). An address the server maps to no pubkey cannot hold a key.

## Responses

| Status | When |
|---|---|
| `204` | `PUT`: published or replaced. `DELETE`: unpublished, whether or not a key was published |
| `400` | Missing `l`, a hash that does not match `l`, an unreadable key, a key without a user ID for the address, or secret key material |
| `401` | Missing or invalid NIP-98 event |
| `403` | The NIP-98 pubkey does not own the address, or the server does not serve its domain |

## Server Behavior

- `PUT` is an upsert by address: it replaces any key published for that address.
- The lookup serves exactly the bytes of the last `PUT`.
- `PUT` and `DELETE` take effect on the next lookup.
- A key stays published only while the server maps its address to the pubkey that published it.

## CORS

- Every response, lookups included, carries `Access-Control-Allow-Origin: *`.
- `OPTIONS` on a lookup URL answers with `Access-Control-Allow-Methods: GET, PUT, DELETE` and `Access-Control-Allow-Headers: Authorization, Content-Type`.
