# Push Notification Protocol

This document defines the push payload sent by the push server.

The push contains the text displayed by the notification and an optional event
reference. The complete email is fetched and decrypted through Nostr.

## Payload

```json
{
  "title": "<notification title>",
  "body": "<notification body>",
  "nevent": "nevent1..."
}
```

- `title`: notification title.
- `body`: notification text.
- `nevent`: optional NIP-19 event reference used to open the email.

The push server decides the content of `title` and `body`.

## FCM

Send an FCM notification message and put `nevent` in `data`:

```json
{
  "message": {
    "token": "<FCM token>",
    "notification": {
      "title": "<notification title>",
      "body": "<notification body>"
    },
    "data": {
      "nevent": "nevent1..."
    }
  }
}
```

## UnifiedPush

POST the UTF-8 JSON payload to the registered UnifiedPush endpoint:

```json
{
  "title": "<notification title>",
  "body": "<notification body>",
  "nevent": "nevent1..."
}
```
