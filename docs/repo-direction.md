# Possible Repository Direction

This document captures a possible direction for evolving Nmail without turning distribution variants into hard-to-maintain forks.

## Context

Nmail should be able to serve several audiences with different expectations:

- Android users without Google, such as GrapheneOS users, who want an APK without Firebase/Google;
- mainstream Android users, for whom FCM is convenient and reliable;
- iOS, macOS, and Web users, where `firebase_messaging` can avoid a lot of plumbing;
- Linux/Windows desktop users, with different plugin constraints.

The main problem is that `pubspec.yaml` is global to a Flutter app. Android flavors are therefore not enough when a Flutter dependency needs to exist in one distribution but not another.

## Recommended Direction

Move gradually toward a simple monorepo:

```text
nostr-mail-client/
  packages/
    nmail_core/
      lib/
      test/
      pubspec.yaml

  apps/
    nmail_foss/
      lib/main.dart
      android/
      linux/
      windows/
      pubspec.yaml

    nmail_standard/
      lib/main.dart
      android/
      ios/
      macos/
      web/
      pubspec.yaml
```

`nmail_core` would contain the shared application: UI, controllers, Nostr services, storage, routes, l10n, and email logic.

The `nmail_foss` and `nmail_standard` apps would be small wrappers that declare their own dependencies and inject distribution-specific implementations at startup.

## Why Not a Branch or Fork?

A long-lived branch or fork solves the separate-dependencies problem, but at the cost of maintaining two histories.

The risk is having to port every bug fix, Flutter migration, Nostr change, translation, or security fix across two diverging lines of history.

Here, the product remains the same. What changes are native dependencies and distribution channels. This is better modeled by structural separation inside a monorepo than by historical separation.

## Use Case 1: Push Notifications

The core package would define an abstraction:

```dart
abstract class PushBackend {
  Future<void> initialize();
  Stream<PushMessage> get messages;
  Future<PushRegistration?> register();
}
```

`nmail_foss` could provide:

- UnifiedPush on Android;
- no Firebase in its `pubspec.yaml`;
- local notification display after receiving a `sync_needed` message.

`nmail_standard` could provide:

- `firebase_messaging` for Android, iOS, macOS, and Web;
- FCM/APNs/Web Push depending on the platform;
- optionally UnifiedPush on Android.

The push server should send a minimal payload, for example `sync_needed`, without subject, sender, or content. The client then syncs through Nostr and decrypts locally.

## Use Case 2: QR/Barcode Scanning

The core package would define an abstraction:

```dart
abstract class ScannerBackend {
  Widget buildScanner({
    required void Function(String value) onResult,
  });

  Future<String?> scanImage();
}
```

`nmail_standard` could use `mobile_scanner` for Android, iOS, macOS, and Web.

`nmail_foss` could use `flutter_zxing` for Android FOSS, Linux, and Windows, while keeping in mind that desktop camera support depends on the package's actual capabilities.

This avoids imposing ML Kit/Firebase/Google on builds that promise a Google-free distribution.

## Progressive Migration

A reasonable migration could happen in several small steps:

1. Create `packages/nmail_core` without changing app behavior.
2. Gradually move shared Dart code from `lib/` to `packages/nmail_core/lib/`.
3. Turn the current app into `apps/nmail_standard`.
4. Create `apps/nmail_foss` with its own `pubspec.yaml`.
5. Introduce the `PushBackend` and `ScannerBackend` abstractions.
6. Add separate CI/builds for `nmail_foss` and `nmail_standard`.

## Guiding Principle

Variants should differ only by their dependencies, target platforms, permissions, and native integrations.

Nmail product logic should stay in `nmail_core`.
