import 'package:blossom_cache/blossom_cache.dart';
import 'package:blossom_upload_queue_shim_for_ndk/blossom_upload_queue_shim_for_ndk.dart';
import 'package:broadcast_queue_shim_for_ndk/broadcast_queue_shim_for_ndk.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk_flutter/ndk_flutter.dart';
import 'package:ndk_flutter/l10n/app_localizations.dart' as ndk_flutter;
import 'package:nostr_mail_client/utils/responsive_helper.dart';
import 'package:system_theme/system_theme.dart';
import 'package:toastification/toastification.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app/bindings/initial_binding.dart';
import 'app/config/nostr_config.dart';
import 'app/routes/app_routes.dart';
import 'l10n/generated/app_localizations.dart';
import 'controllers/auth_controller.dart';
import 'controllers/settings_controller.dart';
import 'views/local_queue/local_queue_indicator.dart';
import 'services/blossom_cache_factory_io.dart'
    if (dart.library.html) 'services/blossom_cache_factory_web.dart'
    as blossom_cache_factory;
import 'services/ndk_cache_service.dart';
import 'services/nostr_mail_service.dart';
import 'services/storage_service.dart';
import 'services/theme_service.dart';
import 'utils/platform_helper.dart';

void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window manager for desktop
  if (PlatformHelper.isDesktop) {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(titleBarStyle: TitleBarStyle.hidden);
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // Initialize system theme (not web)
  if (!kIsWeb) await SystemTheme.accentColor.load();

  // Initialize storage service
  final storageService = StorageService();
  await storageService.init();
  Get.put(storageService, permanent: true);

  // Initialize NDK with switchable verifier for hot-swap capability
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
  Get.put(NostrMailService(), permanent: true);
  final authController = AuthController();
  await authController.init();
  Get.put(authController, permanent: true);

  // Initialize theme service
  await Get.putAsync(() => ThemeService().init(), permanent: true);

  // Load theme mode before app starts
  final themeModeIndex =
      await storageService.getSetting<int>(SettingsController.themeModeKey) ??
      0;
  final initialThemeMode = ThemeMode.values[themeModeIndex];

  runApp(MainApp(initialThemeMode: initialThemeMode));
}

class MainApp extends StatelessWidget {
  final ThemeMode initialThemeMode;

  const MainApp({super.key, required this.initialThemeMode});

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();

    return Obx(() {
      final systemAccent = kIsWeb
          ? Colors.deepPurple
          : SystemTheme.accentColor.accent;

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
        child: GetMaterialApp(
          title: 'Nmail',
          theme: ThemeData.from(
            colorScheme: lightScheme,
          ).copyWith(inputDecorationTheme: sharedInputDecorationTheme),
          darkTheme: ThemeData.from(
            colorScheme: darkScheme,
          ).copyWith(inputDecorationTheme: sharedInputDecorationTheme),
          themeMode: initialThemeMode,
          localizationsDelegates: [
            AppLocalizations.delegate,
            ndk_flutter.AppLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          initialBinding: InitialBinding(),
          getPages: AppRoutes.routes,
          defaultTransition: GetPlatform.isMobile
              ? null
              : Transition.noTransition,
          initialRoute: AppRoutes.inbox,
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
                      NPendingRequests(ndkFlutter: Get.find()),
                      const LocalQueueIndicator(),
                    ],
                  ),
                ),
              );
            }
            return Stack(
              children: [
                child!,
                NPendingRequests(ndkFlutter: Get.find()),
                const LocalQueueIndicator(),
              ],
            );
          },
        ),
      );
    });
  }
}
