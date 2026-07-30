# Account Local Data Cleanup

Packages that store local data should expose the same cleanup API.

## API

```dart
Future<void> clearLocalAccountData({required String pubkey});
Future<void> clearAllLocalData();
```

## Semantics

`clearLocalAccountData` removes only local data that belongs to `pubkey`.

It must be:

- local-only: no remote delete, no Nostr delete event, no server mutation;
- scoped: no data from another account should be removed;
- idempotent: calling it twice should be safe;
- independent from the active account: it must use the passed `pubkey`, not the
  currently logged-in account.

`clearAllLocalData` removes all local data owned by the package.

It is intended for full app reset flows. It must not remove remote data.

## Expected Use

Removing one account:

```dart
await cleaner.clearLocalAccountData(pubkey: pubkey);
```

Resetting the app:

```dart
await cleaner.clearAllLocalData();
```

Packages should never implement `clearLocalAccountData` by calling
`clearAllLocalData`.
