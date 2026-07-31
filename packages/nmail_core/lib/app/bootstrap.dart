import 'dart:async';

import 'package:blossom_cache/blossom_cache.dart';
import 'package:blossom_upload_queue_shim_for_ndk/blossom_upload_queue_shim_for_ndk.dart';
import 'package:broadcast_queue_shim_for_ndk/broadcast_queue_shim_for_ndk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk_flutter/ndk_flutter.dart';
import 'package:ndk_flutter/l10n/app_localizations.dart' as ndk_flutter;
import 'package:nmail_core/utils/responsive_helper.dart';
import 'package:system_theme/system_theme.dart';
import 'package:toastification/toastification.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:nmail_core/app/bindings/initial_binding.dart';
import 'package:nmail_core/app/config/distribution_config.dart';
import 'package:nmail_core/app/widgets/pending_requests_overlay.dart';
import 'package:nmail_core/config/nostr_config.dart';
import 'package:nmail_core/app/routes/app_router.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/controllers/auth_controller.dart';
import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/services/account_local_data_service.dart';
import 'package:nmail_core/services/blossom_cache_factory_io.dart'
    if (dart.library.html) 'package:nmail_core/services/blossom_cache_factory_web.dart'
    as blossom_cache_factory;
import 'package:nmail_core/services/metadata_service.dart';
import 'package:nmail_core/services/ndk_cache_service.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/services/notification_service.dart';
import 'package:nmail_core/services/push_registration_service.dart';
import 'package:nmail_core/services/push_subscription_service.dart';
import 'package:nmail_core/services/storage_service.dart';
import 'package:nmail_core/services/theme_service.dart';
import 'package:nmail_core/utils/platform_helper.dart';

Future<void> runNmailApp({
  Future<void> Function()? onReady,
  String? privacyPolicyUrl,
  UnifiedPushDistributorChecker? hasUnifiedPushDistributor,
  String? unifiedPushDistributorInstallUrl,
}) async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  // Navigation is go_router's, so GetX never sees a route change: its
  // "current route" stays whatever `Get.dialog` / `Get.bottomSheet` opened
  // last, and closing that popup would delete every controller registered
  // since. onlyBuilder disables that route-linked disposal.
  Get.smartManagement = SmartManagement.onlyBuilder;

  Get.put(
    DistributionConfig(
      privacyPolicyUrl: privacyPolicyUrl,
      hasUnifiedPushDistributor: hasUnifiedPushDistributor,
      unifiedPushDistributorInstallUrl: unifiedPushDistributorInstallUrl,
    ),
    permanent: true,
  );

  // Initialize window manager for desktop
  if (PlatformHelper.isDesktop) {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(titleBarStyle: TitleBarStyle.hidden);
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // Initialize system theme
  try {
    await SystemTheme.accentColor.load();
  } catch (e) {
    //
  }

  // Initialize storage service
  final storageService = StorageService();
  await storageService.init();
  Get.put(storageService, permanent: true);

  // Initialize NDK with event verification enabled.
  final cacheManager = await NdkCacheService.createCacheManager(storageService);
  final ndk = Ndk(
    NdkConfig(
      eventVerifier: NdkEventVerifier(),
      eventSignerFactory: NdkEventSignerFactory(),
      cache: cacheManager,
      bootstrapRelays: NostrConfig.bootstrapRelays,
      fetchedRangesEnabled: true,
    ),
  );
  Get.put(ndk, permanent: true);
  final ndkFlutter = NdkFlutter(ndk: ndk);
  Get.put(ndkFlutter, permanent: true);

  // Reactive in-RAM metadata cache so avatars/names resolve without flashing.
  Get.put(MetadataService(), permanent: true);

  // Initialize Blossom cache and offline queues as app-level singletons.
  // These persist across login/logout — they hold pending work in storageService.db.
  final blossomCache = await blossom_cache_factory.createBlossomCache();
  Get.put<BlossomCache>(blossomCache, permanent: true);

  final broadcastQueue = OfflineBroadcast.withNdk(ndk, db: storageService.db)
    ..start();
  Get.put(broadcastQueue, permanent: true);

  final blossomUploadQueue = OfflineBlossomUpload.withNdk(
    ndk,
    cache: blossomCache,
    db: storageService.db,
  )..start();
  Get.put(blossomUploadQueue, permanent: true);

  // Initialize Services and Controllers early for Middlewares
  Get.put(AccountLocalDataService(), permanent: true);
  // Reads storage only until a transport exists, so it can be registered
  // before SettingsController loads the per-account notification settings.
  final pushSubscriptions = PushSubscriptionService();
  Get.put(pushSubscriptions, permanent: true);
  unawaited(pushSubscriptions.flushPendingDisables());
  await Get.putAsync(() => NostrMailService().init(), permanent: true);
  final authController = AuthController();
  await authController.init();
  Get.put(authController, permanent: true);

  // Initialize theme service
  await Get.putAsync(() => ThemeService().init(), permanent: true);

  // SettingsController is awaited (not put inside InitialBinding) so the
  // saved theme mode and locale are available before the first frame.
  await Get.putAsync(() => SettingsController().init(), permanent: true);

  await Get.putAsync(() => NotificationService().init(), permanent: true);
  Get.put(
    PushRegistrationService(
      languageProvider: () =>
          Get.find<SettingsController>().notificationLanguageTag,
    ),
    permanent: true,
  );

  // Run InitialBinding (ContactsService) before the router boots - the
  // router's redirect reads SettingsController on first navigation.
  InitialBinding().dependencies();

  // Flavor-specific setup (e.g. FCM on nmail_standard), kept out of core.
  await onReady?.call();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    final settingsController = Get.find<SettingsController>();

    return Obx(() {
      final systemAccent = SystemTheme.accentColor.accent;

      final lightScheme =
          themeService.lightColorScheme.value ??
          ColorScheme.fromSeed(seedColor: systemAccent);
      final darkScheme =
          themeService.darkColorScheme.value ??
          ColorScheme.fromSeed(
            seedColor: systemAccent,
            brightness: Brightness.dark,
          );

      final sharedInputDecorationTheme = InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

      return ToastificationWrapper(
        child: MaterialApp.router(
          title: 'Nmail',
          locale: settingsController.locale.value,
          theme: ThemeData.from(
            colorScheme: lightScheme,
          ).copyWith(inputDecorationTheme: sharedInputDecorationTheme),
          darkTheme: ThemeData.from(
            colorScheme: darkScheme,
          ).copyWith(inputDecorationTheme: sharedInputDecorationTheme),
          themeMode: settingsController.themeMode.value,
          localizationsDelegates: [
            AppLocalizations.delegate,
            ndk_flutter.AppLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales.toList()
            ..remove(const Locale('en'))
            ..insert(0, const Locale('en')),
          routerConfig: AppRouter.init(),
          builder: (context, child) {
            if (PlatformHelper.isDesktop) {
              return DragToResizeArea(
                child: ColoredBox(
                  color: Theme.of(context).colorScheme.surface,
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: ResponsiveHelper.isMobile(context) ? 32 : 0,
                        ),
                        child: child!,
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 32,
                        child: Row(
                          children: [
                            Expanded(child: DragToMoveArea(child: Container())),
                            if (!GetPlatform.isMacOS)
                              SizedBox(
                                width: 154,
                                child: WindowCaption(
                                  brightness: Theme.of(context).brightness,
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const PendingRequestsOverlay(),
                    ],
                  ),
                ),
              );
            }
            return Stack(children: [child!, const PendingRequestsOverlay()]);
          },
        ),
      );
    });
  }
}
