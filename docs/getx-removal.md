# GetX Removal Roadmap

The `get` package is removed from `nmail_core`, `nmail_standard` and `nmail_foss`. State uses Flutter SDK primitives and dependency injection uses `get_it`.

## Mapping

| GetX | Replacement |
|---|---|
| `GetxController` | Class extending `ChangeNotifier` |
| `GetxService` | Plain class, with `dispose()` when it holds resources |
| `onInit()` | Constructor, or an awaited `init()` |
| `onClose()` | `dispose()` |
| `.obs`, `Rx<T>`, `Rxn<T>` | `ValueNotifier<T>`, or a field followed by `notifyListeners()` |
| `RxList`, `RxSet`, `RxMap` | `ValueNotifier` holding the collection, assigned a new collection on every change |
| `Obx` | `ListenableBuilder` or `ValueListenableBuilder` |
| `GetBuilder` + `update()` | `ListenableBuilder` + `notifyListeners()` |
| `GetBuilder(init: ...)` | Controller created and disposed by the widget that shows it |
| `ever`, `everAll`, `once` | `addListener` (on `Listenable.merge` for several sources), removed in `dispose()` |
| `Get.put(x, permanent: true)` | `GetIt.I.registerSingleton(x)` |
| `Get.lazyPut(() => X())` | `GetIt.I.registerLazySingleton(() => X(), dispose: (x) => x.dispose())` |
| `Get.putAsync(() => X().init())` | `GetIt.I.registerSingleton(await X().init())` |
| `Get.find<T>()` | `GetIt.I<T>()` |
| `Get.isRegistered<T>()` | `GetIt.I.isRegistered<T>()` |
| `Get.delete<T>()` | `GetIt.I.unregister<T>()` |
| `Get.reset()` | `GetIt.I.reset()` |
| `Get.put(x, tag: ...)` | No registration: the `show...` helper creates the controller, passes it to the dialog and disposes it in `finally` |
| `Get.context` | The widget's `BuildContext`; `AppRouter.rootContext` in controllers |
| `Get.key` | `GlobalKey<NavigatorState>()` |
| `GetUtils.isEmail`, `GetUtils.capitalize` | Helpers in `utils/` |
| `GetPlatform.isMacOS` | `PlatformHelper.isMacOS` |
| `firstWhereOrNull` | `package:collection` |
| `GetSingleTickerProviderStateMixin` | `SingleTickerProviderStateMixin` on the `State` that owns the animation |
| `Bindings` | Registrations in `runNmailApp()` |
| `Get.smartManagement` | Removed |

## Rules

- Every commit leaves the app working. Steps 2 to 5 may split into one commit per class or small group of classes.
- A class migrates in a single commit: lifecycle, state, registration and every reader (`Get.find`, `Obx`, `GetBuilder`), in `nmail_core`, both apps and the tests.
- `Obx` does not rebuild on a `ValueNotifier`.
- Every controller keeps its current lifetime.
- New code follows the mapping.
- `flutter analyze` and `flutter test` pass in `packages/nmail_core`, `apps/nmail_standard` and `apps/nmail_foss`.

## Steps

### 1. Utilities and context

- [x] `GetUtils.isEmail` in `compose_controller.dart`, `GetUtils.capitalize` in `sender_name_helper.dart`
- [x] `GetPlatform.isMacOS` in `bootstrap.dart`
- [x] `firstWhereOrNull` imports
- [x] `Get.context` in `compose_controller.dart`, `email_controller.dart`, `profile_controller.dart`, `create_identity_controller.dart`, `auth_controller.dart`, `selection_actions_bar.dart`
- [x] `Get.key` in `app_router.dart`

### 2. Plain objects

Objects registered with `Get.put` that are not GetX classes.

- [x] `DistributionConfig`
- [x] `Ndk`, `NdkFlutter`
- [x] `BlossomCache`
- [x] `OfflineBroadcast`, `OfflineBlossomUpload`
- [x] `SyncEngine`
- [x] `NostrMailDatabase`

### 3. Widget and dialog controllers

Created by `GetBuilder(init: ...)` or by a view:

- [ ] `AccountDeletedController`
- [ ] `BlossomServersController`
- [ ] `BridgesController`
- [ ] `CommunityThemesController`
- [ ] `CreateIdentityController`
- [ ] `DebugToolsController`
- [ ] `DeleteAccountController`
- [ ] `DmRelaysController`
- [ ] `Nip65RelaysController`
- [ ] `NostrAppsMarqueeController`
- [ ] `PlainTextBodyController`
- [ ] `RecipientAutocompleteController`
- [ ] `RelayConnectivityController`
- [ ] `RelaySetupController`
- [ ] `StartupErrorController`
- [ ] `SyncStatusController`

Created in a `show...` helper:

- [ ] `ContactFormController`
- [ ] `CustomColorController`
- [ ] `MailEntryFormController`
- [ ] `ShareThemeController`
- [ ] `TagsPickerController`

### 4. Route controllers

Disposed when leaving the route:

- [ ] `ComposeController`
- [ ] `EmailController`
- [ ] `CommunityThemeController`

Created on first use and kept:

- [ ] `AboutController`
- [ ] `BackgroundsController`
- [ ] `ContactsController`
- [ ] `IdentitiesController`
- [ ] `InboxController`
- [ ] `ProfileController`
- [ ] `ScheduledController`

### 5. App services and controllers

Registered in `runNmailApp()` or `InitialBinding`:

- [ ] `AccountLocalDataService`
- [ ] `AddressBookService`
- [ ] `AppUpdateService`
- [ ] `AuthController`
- [ ] `ContactsService`
- [ ] `DeviceConnectivityService`
- [ ] `MailboxesController`
- [ ] `MailDomainService`
- [ ] `MetadataService`
- [ ] `NostrMailService`
- [ ] `NotificationService`
- [ ] `PushRegistrationService`
- [ ] `PushSubscriptionService`
- [ ] `SettingsController`
- [ ] `StorageService`
- [ ] `ThemeService`

### 6. Removal

- [ ] `InitialBinding` and `Get.smartManagement`
- [ ] Remaining `Get.reset()` in tests
- [ ] `flutter pub remove get` in `packages/nmail_core`, `apps/nmail_standard` and `apps/nmail_foss`
- [ ] `AGENTS.md`
