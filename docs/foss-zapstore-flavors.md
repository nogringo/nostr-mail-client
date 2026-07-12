# FOSS and ZapStore Flavor Direction

This document captures the intended direction for the Android FOSS distributions of Nmail.

## Decision

Keep two Flutter app wrappers:

```text
apps/
  nmail_standard/
  nmail_foss/
```

Remove `apps/nmail_zapstore` as a separate Flutter app wrapper and replace it with an Android flavor inside `apps/nmail_foss`.

The target model is:

```text
packages/
  nmail_core/              # shared product code

apps/
  nmail_standard/          # standard app, allowed to use Firebase/FCM
  nmail_foss/              # FOSS app, no Firebase dependency
    android/
      app/
        build.gradle.kts   # foss/zapstore Android flavors
```

## Rationale

`nmail_standard` must stay separate from `nmail_foss` because Flutter dependencies are declared at the app level in `pubspec.yaml`.

The standard app can depend on packages such as:

- `firebase_messaging`
- other future non-FOSS or store-specific packages

Those dependencies must not be present in the FOSS app wrapper if the FOSS build promises to stay Google-free.

By contrast, `nmail_foss` and `nmail_zapstore` should share the same app-level dependencies and behavior. The important shared dependency is UnifiedPush:

- F-Droid/FOSS builds should use UnifiedPush.
- ZapStore builds should also use UnifiedPush.
- Both should keep the same FOSS feature set.

If ZapStore is only a different distribution channel with a different Android `applicationId`, duplicating a whole Flutter app wrapper creates unnecessary maintenance work.

## Flavor Shape

`apps/nmail_foss/android/app/build.gradle.kts` should define Android product flavors, for example:

```kotlin
android {
    flavorDimensions += "distribution"

    productFlavors {
        create("foss") {
            dimension = "distribution"
            applicationId = "org.nostrmail.app.foss"
        }

        create("zapstore") {
            dimension = "distribution"
            applicationId = "app.nostrmail.client"
        }
    }
}
```

The Android `namespace` can remain shared for the FOSS wrapper. The user-visible and store-visible package identity is the flavor `applicationId`.

## Expected Builds

From `apps/nmail_foss`:

```bash
flutter build apk --flavor foss -t lib/main.dart
flutter build apk --flavor zapstore -t lib/main.dart
```

For app bundles, if needed:

```bash
flutter build appbundle --flavor foss -t lib/main.dart
flutter build appbundle --flavor zapstore -t lib/main.dart
```

`apps/nmail_standard` remains built separately:

```bash
flutter build apk -t lib/main.dart
flutter build appbundle -t lib/main.dart
```

## Migration Plan

1. Move any ZapStore-only Android identity from `apps/nmail_zapstore` into a `zapstore` product flavor in `apps/nmail_foss`.
2. Keep UnifiedPush initialization in `apps/nmail_foss/lib/main.dart`.
3. Ensure both `foss` and `zapstore` flavors compile with the same Dart entrypoint.
4. Update release scripts and CI to build ZapStore from `apps/nmail_foss` with `--flavor zapstore`.
5. Update `zapstore.yaml` if it references the old `apps/nmail_zapstore` path.
6. Remove `apps/nmail_zapstore` after the flavor build is verified.

## Non-Goals

Do not merge `nmail_standard` and `nmail_foss` into one Flutter app wrapper while their `pubspec.yaml` dependencies must differ.

Android flavors are useful for native build metadata such as `applicationId`, manifest placeholders, signing, resources, and distribution-specific Gradle configuration. They are not a clean way to remove Flutter plugins from the dependency graph.

## Guiding Principle

Use separate Flutter app wrappers when dependencies differ.

Use Android flavors when the same FOSS app is distributed through different Android channels.
