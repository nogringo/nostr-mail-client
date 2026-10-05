# GetX Removal Roadmap

The `get` package is removed from `nmail_core`, `nmail_standard` and `nmail_foss`. State uses Flutter SDK primitives and dependency injection uses `get_it`.

## Mapping

| GetX | Replacement |
|---|---|
| `GetxController` | Class extending `ChangeNotifier` |
| `GetxService` | Plain class, with `dispose()` when it holds resources |
| `onInit()` | Constructor, or an awaited `init()` |
| `onClose()` | `dispose()` |
| `isClosed` | `_isDisposed` flag set in `dispose()` |
| `.obs`, `Rx<T>`, `Rxn<T>` | `ValueNotifier<T>`, or a field followed by `notifyListeners()` |
| `RxList`, `RxSet`, `RxMap` | `ValueNotifier` holding the collection, assigned a new collection on every change |
| `Obx` | `ListenableBuilder` or `ValueListenableBuilder` |
| `GetBuilder` + `update()` | `ListenableBuilder` + `notifyListeners()` |
| `GetBuilder(init: ...)` | `ControllerBuilder(create: ...)`, which creates, listens to and disposes the controller |
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

- [x] `AccountDeletedController`
- [x] `BlossomServersController`
- [x] `BridgesController`
- [x] `CommunityThemesController`
- [x] `CreateIdentityController`
- [x] `DebugToolsController`
- [x] `DeleteAccountController`
- [x] `DmRelaysController`
- [x] `Nip65RelaysController`
- [x] `NostrAppsMarqueeController`
- [x] `PlainTextBodyController`
- [x] `RecipientAutocompleteController`
- [x] `RelayConnectivityController`
- [x] `RelaySetupController`
- [x] `StartupErrorController`
- [x] `SyncStatusController`

Created in a `show...` helper:

- [x] `ContactFormController`
- [x] `CustomColorController`
- [x] `MailEntryFormController`
- [x] `ShareThemeController`
- [x] `TagsPickerController`

### 4. Route controllers

Disposed when leaving the route:

- [x] `ComposeController`
- [x] `ProfileController`

Kept until the next one opened replaces it:

- [x] `EmailController`
- [x] `CommunityThemeController`

Created on first use and kept:

- [x] `AboutController`
- [x] `BackgroundsController`
- [x] `ContactsController`
- [x] `IdentitiesController`
- [x] `InboxController`
- [x] `ScheduledController`

### 5. App services and controllers

Registered in `runNmailApp()` or `InitialBinding`:

- [x] `AccountLocalDataService`
- [x] `AddressBookService`
- [x] `AppUpdateService`
- [x] `AuthController`
- [x] `ContactsService`
- [x] `DeviceConnectivityService`
- [x] `MailboxesController`
- [x] `MailDomainService`
- [x] `MetadataService`
- [x] `NostrMailService`
- [x] `NotificationService`
- [x] `PushRegistrationService`
- [x] `PushSubscriptionService`
- [x] `SettingsController`
- [x] `StorageService`
- [x] `ThemeService`

### 6. Removal

- [ ] `InitialBinding` and `Get.smartManagement`
- [ ] Widget-local `.obs` and `Obx` in `copy_menu_item.dart`, `copy_sync_code_tile.dart`, `email_source_copy_button.dart`, `image_viewer_page.dart`, `nip59_events_dialog.dart` and `sync_code_explanation_view.dart`
- [ ] Remaining `Get.reset()` and `Get.testMode` in tests
- [ ] `flutter pub remove get` in `packages/nmail_core`, `apps/nmail_standard` and `apps/nmail_foss`
- [ ] `AGENTS.md`
