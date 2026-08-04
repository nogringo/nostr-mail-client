# AGENTS.md - Nostr Mail Client (Nmail)

This file contains project-specific context for AI coding agents. Read it before making changes.

---

## Project Overview

**Nostr Mail Client** (branded as **Nmail**) is a cross-platform Flutter email client built on the [Nostr protocol](https://github.com/nostr-protocol/nips). Users own their identity (`npub`/pubkey) and local data; messages are transported through Nostr relays instead of a central mail provider.

The repository is now a Dart/Flutter workspace with a shared core package and two app distributions:

- `packages/nmail_core` - shared Nmail app, UI, routing, services, models, localization, storage, and Nostr/mail logic.
- `apps/nmail_standard` - standard distribution with Firebase/FCM push support.
- `apps/nmail_foss` - FOSS distribution with UnifiedPush support and no Firebase dependency.

Current package metadata:

- Workspace SDK constraint: `^3.12.2`
- App version: `0.14.2+26` in both app pubspecs
- Core package version: `0.0.1`
- Primary platforms: Android, Linux, Web
- Also present: iOS, macOS, Windows runner folders

---

## Technology Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter |
| Language | Dart |
| Workspace layout | Dart pub workspace (`pubspec.yaml` with `apps/*` and `packages/*`) |
| State management / DI | `get` (GetX) |
| Routing | `go_router` via `MaterialApp.router` |
| Nostr protocol | `ndk` + `ndk_flutter` |
| Email domain logic | `nostr_mail` |
| Address book | `nostr_address_book`, `vcard_dart` |
| Local database / cache | `sembast`, `sembast_web`, `sqflite`, `sqflite_common_ffi`, `idb_shim` |
| Offline queues | `broadcast_queue_shim_for_ndk`, `blossom_upload_queue_shim_for_ndk` |
| Device connectivity | `connectivity_plus` |
| Attachments / Blossom | `blossom_cache`, `file_picker`, `file_saver` |
| Rich text editor | `flutter_quill`, `markdown_quill`, `vsc_quill_delta_to_html` |
| MIME mail construction | `enough_mail_plus` |
| HTML/PDF rendering | `flutter_widget_from_html_core`, `pdfrx` |
| Push notifications | FCM in `nmail_standard`; UnifiedPush in `nmail_foss`; shared registration logic in core |
| Local notifications | `flutter_local_notifications` |
| Toast notifications | `toastification` |
| Theming | `system_theme` + custom persisted color schemes |
| Desktop window chrome | `window_manager` |
| Localization | Flutter gen-l10n from `packages/nmail_core/lib/l10n/*.arb` |

---

## Repository Structure

```text
.
|-- pubspec.yaml                         # Workspace root (`apps/*`, `packages/*`)
|-- pubspec_overrides.yaml               # Optional local dependency overrides
|-- apps/
|   |-- nmail_standard/
|   |   |-- lib/main.dart                # Calls runNmailApp(onReady: FcmPush.init)
|   |   |-- lib/push/fcm_push.dart       # Firebase Messaging integration
|   |   |-- lib/firebase_options.dart    # Injected/validated by CI for release builds
|   |   `-- firebase.json
|   `-- nmail_foss/
|       |-- lib/main.dart                # Calls runNmailApp(onReady: UnifiedPushHandler.init)
|       `-- lib/push/unified_push.dart   # UnifiedPush foreground/background entry points
|-- packages/
|   `-- nmail_core/
|       |-- lib/app/bootstrap.dart       # Shared initialization and MainApp
|       |-- lib/app/routes/              # go_router route tree and route constants
|       |-- lib/app/config/              # App/distribution config
|       |-- lib/config/nostr_config.dart # Bootstrap relays and recommended defaults
|       |-- lib/controllers/             # GetX controllers
|       |-- lib/models/                  # Plain Dart models
|       |-- lib/services/                # Long-lived services and platform abstractions
|       |-- lib/utils/                   # Pure helpers/extensions
|       |-- lib/views/                   # Feature screens and shared shells/layouts
|       |-- lib/widgets/                 # Reusable widgets
|       |-- lib/l10n/                    # ARB files + generated localizations
|       `-- test/                        # Unit tests
|-- .github/workflows/                   # CI/CD for web, Android, Linux, macOS, releases
`-- scripts/check_android_16kb_alignment.sh
```

Approximate Dart file counts:

- `packages/nmail_core/lib`: about 207 Dart files
- app distribution `lib` folders: 5 Dart files total
- tests: 10 `*_test.dart` files in `packages/nmail_core/test`

---

## Build, Run, And Test Commands

Run commands from the directory shown in the command when possible. The CI workflows mostly run `flutter pub get` inside each app directory.

```bash
# Standard app dependencies
cd apps/nmail_standard
flutter pub get

# FOSS app dependencies
cd apps/nmail_foss
flutter pub get

# Core package tests
cd packages/nmail_core
flutter test

# Analyze core
cd packages/nmail_core
flutter analyze

# Analyze an app distribution
cd apps/nmail_standard
flutter analyze

# Run standard distribution
cd apps/nmail_standard
flutter run -d chrome
flutter run -d linux
flutter run -d android

# Run FOSS distribution
cd apps/nmail_foss
flutter run -d linux
flutter run -d android

# Build web (standard distribution)
cd apps/nmail_standard
flutter build web --release --output ../../build/web

# Build Android standard distribution
cd apps/nmail_standard
flutter build apk --release
flutter build appbundle --release

# Build Android FOSS distribution
cd apps/nmail_foss
flutter build apk --release --flavor foss
flutter build appbundle --release --flavor foss

# Build ZapStore APK
cd apps/nmail_foss
flutter build apk --release --flavor zapstore --target-platform android-arm64
```

Linux and macOS release packaging use `fastforge` in CI. There is no Fastforge config file at the repository root; workflows package from `apps/nmail_standard`.

---

## App Bootstrap And Dependency Injection

The shared entry point is `packages/nmail_core/lib/app/bootstrap.dart`.

`runNmailApp()` does the app-wide setup:

- Enables path URL strategy for web.
- Registers `DistributionConfig`.
- Initializes `window_manager` on desktop with hidden title bar style.
- Loads `system_theme` accent color.
- Initializes `StorageService`.
- Creates `Ndk` with `NdkEventVerifier`, `NdkEventSignerFactory`, cache, bootstrap relays, and fetched ranges.
- Registers `Ndk`, `NdkFlutter`, `MetadataService`, `NostrMailService`, `AuthController`, `ThemeService`, `SettingsController`, `NotificationService`, and `PushRegistrationService`.
- Initializes Blossom cache plus offline broadcast/upload queues as permanent singletons.
- Registers `DeviceConnectivityService`, which forces NDK relays past their connect backoff when the OS regains a network.
- Runs `InitialBinding` for `AddressBookService` and `ContactsService`.
- Calls the distribution-specific `onReady` hook.
- Starts `MainApp`.

Important distribution hooks:

- `apps/nmail_standard/lib/main.dart` passes `FcmPush.init` and an iOS App Store privacy policy URL.
- `apps/nmail_foss/lib/main.dart` passes `UnifiedPushHandler.init`; when launched with `--unifiedpush-bg`, it runs `UnifiedPushHandler.runBackground()` instead of the full app.

Use `Get.find<T>()` carefully. Many services are permanent and assumed to exist for the whole app lifetime. Route-scoped controllers are still registered and cleaned up in the router where needed.

---

## Routing And Navigation

Routing has migrated from `GetMaterialApp`/`GetPage` to `go_router`.

Key files:

- `packages/nmail_core/lib/app/routes/app_router.dart`
- `packages/nmail_core/lib/app/routes/app_routes.dart`

Current route model:

- `MaterialApp.router` uses `AppRouter.init()`.
- `AppRoutes` contains route constants and path helpers.
- Public routes: `/login`, `/onboarding`.
- Authenticated shell routes live under a `ShellRoute` that renders `AuthShell`.
- Folder routes are URL-driven: `/inbox`, `/sent`, `/archive`, `/trash`.
- Email details are nested under folders as `/<folder>/email/:id`.
- Scheduled mail: `/scheduled`.
- Contacts: `/contacts`, `/contacts/form`.
- Compose: `/compose`; `ComposeController` is disposed in `onExit`.
- Settings tree: `/settings`, `/settings/identities`, `/settings/identities/new`, `/settings/hosting`, `/settings/debug-tools`.
- Legacy `/email/:id` redirects through the root NIP-19 dispatcher.
- Root `/:nostrId` dispatches `npub`, `nprofile`, `nevent`, and note/event references.

GetX is still used for DI, reactivity, dialogs/snackbars, and controller ownership. `AppRouter` aliases its root navigator key to `Get.key` so legacy `Get.context`, `Get.dialog`, and `Get.snackbar` calls continue to work. There is an inline TODO to eventually remove the remaining GetX navigation coupling.

When adding routes:

- Update `AppRoutes`.
- Update the `GoRouter` tree in `AppRouter`.
- Decide where the controller is registered and disposed.
- Prefer `context.go` / `context.push` in widgets. Use `AppRouter.router` only where a controller has no `BuildContext`.

---

## Core Domains

### Nostr And Mail

The app is deeply coupled to `ndk`, `ndk_flutter`, and `nostr_mail`.

- `NostrMailService` wraps `NostrMailClient`.
- Email events are Nostr gift-wraps.
- Read/unread state uses NIP-32 labels such as `state:read`.
- DM relay lists, NIP-65 relay lists, Blossom servers, bridge settings, and recommended defaults are centralized in config/services/controllers.
- Offline Nostr event broadcast and Blossom uploads are queued through the offline queue shim packages.
- Event verification is enabled by default through `NdkEventVerifier`; the older switchable verifier/no-verifier setup is no longer present in the current bootstrap.

### Push Notifications

Shared push registration lives in `packages/nmail_core/lib/services/push_registration_service.dart`.

- Standard distribution: `FcmPush` initializes Firebase, registers the FCM token, and routes notification taps.
- FOSS distribution: `UnifiedPushHandler` registers with a UnifiedPush distributor, handles raw push payloads, and shows local notifications itself. Background delivery uses the `--unifiedpush-bg` entry point.
- `NotificationService` is shared and initializes local notification display/tap handling.

### Contacts And Address Book

Contacts are more than derived email history now.

- `AddressBookService` manages address book persistence/sync.
- `ContactsService` aggregates and exposes contact data.
- `ContactsController` and contact form widgets own the contacts UI workflow.
- vCard import/export helpers live in `utils/address_book_vcard_mapper.dart`.

### Localization

Localization lives in `packages/nmail_core/lib/l10n`.

- Template: `app_en.arb`
- Supported ARB files currently include `de`, `en`, `es`, `fi`, `fr`, `it`, `ja`, `pt`, `pt_BR`, `ru`, and `zh`.
- Generated files are committed under `lib/l10n/generated`.
- `l10n.yaml` configures output to `AppLocalizations`.

When adding user-facing strings, update `app_en.arb` and corresponding translations or clearly leave translation work visible.

---

## Testing

Tests currently live under `packages/nmail_core/test`.

Existing coverage includes utilities and services such as:

- `address_book_service_test.dart`
- `push_registration_service_test.dart`
- `address_book_vcard_mapper_test.dart`
- `blossom_utils_test.dart`
- `contact_birthday_utils_test.dart`
- `get_attachements_test.dart`
- `nostr_utils_test.dart`
- `relay_utils_test.dart`
- `scheduled_email_extensions_test.dart`
- `string_color_test.dart`

Prefer unit tests for:

- Pure utilities in `utils/`
- Model transformations
- Service/controller behavior that can be isolated from Flutter UI
- Push registration state logic
- Address book and scheduling behavior

There are no broad integration/widget test conventions established yet.

---

## Code Style And Conventions

- Linting uses `package:flutter_lints/flutter.yaml`.
- `experimental_member_use` is ignored in package analysis options.
- Controllers end with `Controller` and generally extend `GetxController`.
- Long-lived services end with `Service`; persistent app-level services are registered with `permanent: true`.
- Files use `snake_case`.
- Rx observables follow existing naming patterns (`isLoading`, `hasX`, plural collections, etc.).
- Keep platform branching explicit (`kIsWeb`, `defaultTargetPlatform`, `PlatformHelper`, conditional imports).
- Prefer existing helper APIs and local patterns over adding new abstractions.
- Keep generated localization files and platform runner changes intentional; avoid unrelated churn.

---

## CI/CD And Release Notes

Workflows live in `.github/workflows/`.

| Workflow | Purpose |
|----------|---------|
| `firebase-hosting-merge.yml` | Builds `apps/nmail_standard` web and deploys to Firebase Hosting on `main` |
| `firebase-hosting-pull-request.yml` | Builds web preview deploys for PRs |
| `build-android.yml` | Manual Android build for standard, FOSS, and ZapStore artifacts |
| `build-linux.yml` | Manual Linux packaging from `apps/nmail_standard` via Fastforge |
| `build-macos.yml` | Manual macOS packaging, signing, and notarization |
| `release.yml` | Tag/manual release across Android, Linux, macOS, then GitHub Release |
| `deploy-redirect.yml` | Deploys redirect content to GitHub Pages |

CI uses `.github/actions/inject-nmail-standard-firebase-options` to inject Firebase options for the standard app from secrets. The standard app has `apps/nmail_standard/firebase.json`; the root `firebase.json` points hosting at `build/web`.

Android release workflows build:

- Standard universal APK, arm64 APK, and AAB
- FOSS universal APK, arm64 APK, and AAB
- ZapStore arm64 APK
- 16 KB alignment verification via `scripts/check_android_16kb_alignment.sh`

---

## Current TODOs And Known Follow-Ups

Inline TODOs currently mention:

- Finish removing remaining GetX navigation/context coupling after replacing `Get.dialog`, `Get.snackbar`, and context reads.
- Debounce inbox listeners during bulk sync.
- Allow attachment renaming.
- Enforce attachment file size limits.
- Avoid deprecated `file_picker` `withData: true` usage when possible.
- Add trusted-domain handling and link-text mismatch warnings in external link confirmation.
- Refactor duplicated account popup UI between inbox/sidebar.
- Split the large settings view into smaller widgets.
- Consider encrypted profile image upload/display.
- Add more context for the resync action in settings.

There is no root `TODO.md` in the current repository.

---

## Tips For Agents

- Do not treat this as a standard SMTP/IMAP app. Mail transport and identity are Nostr-first.
- Most product code belongs in `packages/nmail_core`; distribution-specific push/Firebase/UnifiedPush code belongs under `apps/nmail_standard` or `apps/nmail_foss`.
- When changing shared behavior, check both app distributions for imports, platform support, and release implications.
- When changing routes, verify deep links and shell layout behavior on web/desktop as well as mobile.
- When changing push behavior, preserve the separation between shared registration logic and distribution transport code.
- When changing localization strings, update ARB files and generated localization output as appropriate.
- Respect existing dirty worktrees. Do not revert platform runner, generated, or screenshot changes unless explicitly asked.
