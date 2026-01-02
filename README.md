# Nostr Mail Client

A Flutter email client for the Nostr protocol. Send and receive encrypted emails via NIP-59 gift-wrapped messages.

## Features

- Login with Nostr private key (nsec/hex)
- Encrypted inbox with real-time sync
- Compose and send emails to:
  - Nostr pubkeys (npub/hex)
  - NIP-05 identifiers (user@domain)
  - Legacy email addresses (via bridge)
- Local storage with Sembast database
- Cross-platform: Android, iOS, Web, macOS, Windows, Linux

## Screenshots

*Coming soon*

## Getting Started

### Prerequisites

- Flutter SDK ^3.10.4
- [nostr-mail-dart](https://github.com/nogringo/nostr-mail-dart) package

### Installation

```bash
# Clone the repository
git clone https://github.com/nogringo/nostr-mail-client.git
cd nostr-mail-client

# Get dependencies
flutter pub get

# Run the app
flutter run
```

### Build for Web

```bash
flutter build web --release --base-href "/nostr-mail-client/"
```

The build output will be in `build/web/`.

## Project Structure

```
lib/
├── main.dart
├── app/
│   ├── bindings/          # GetX dependency injection
│   └── routes/            # App navigation routes
├── controllers/
│   ├── auth_controller.dart
│   ├── inbox_controller.dart
│   └── compose_controller.dart
├── models/
│   └── recipient.dart
├── services/
│   ├── nostr_mail_service.dart
│   └── storage_service.dart
├── utils/
│   └── toast_helper.dart
└── views/
    ├── auth/              # Login screen
    ├── inbox/             # Email list
    ├── email/             # Email detail
    └── compose/           # New email
```

## Dependencies

| Package | Description |
|---------|-------------|
| `nostr_mail` | Nostr email client library |
| `ndk` | Nostr Development Kit |
| `get` | State management & routing |
| `flutter_secure_storage` | Secure key storage |
| `sembast` | Local NoSQL database |
| `toastification` | Toast notifications |

## Configuration

The app uses the `nostr_mail` package which connects to Nostr relays. Default relays are configured in the package.

## Related Projects

- [nostr-mail-dart](https://github.com/nogringo/nostr-mail-dart) - Dart/Flutter library
- [nostr-mail-bridge](https://github.com/nogringo/nostr-mail-bridge) - Email bridge server
