import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk_rust_verifier/ndk_rust_verifier.dart';
import 'package:nostr_widgets/l10n/app_localizations.dart' as nostr_widgets;
import 'package:sembast_cache_manager/sembast_cache_manager.dart';
import 'package:system_theme/system_theme.dart';
import 'package:toastification/toastification.dart';
import 'package:window_manager/window_manager.dart';

import 'app/bindings/initial_binding.dart';
import 'app/config/nostr_config.dart';
import 'app/routes/app_routes.dart';
import 'controllers/auth_controller.dart';
import 'controllers/settings_controller.dart';
import 'services/storage_service.dart';
import 'services/theme_service.dart';
import 'utils/platform_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window manager for desktop
  if (PlatformHelper.isDesktop) {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      minimumSize: Size(600, 300),
      titleBarStyle: TitleBarStyle.hidden,
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // Initialize system theme
  await SystemTheme.accentColor.load();

  // Initialize storage service
  final storageService = StorageService();
  await storageService.init();
  Get.put(storageService, permanent: true);

  // Initialize NDK
  final cacheManager = SembastCacheManager(storageService.db);
  final ndk = Ndk(
    NdkConfig(
      eventVerifier: kIsWeb ? Bip340EventVerifier() : RustEventVerifier(),
      cache: cacheManager,
      bootstrapRelays: NostrConfig.bootstrapRelays,
      fetchedRangesEnabled: true,
    ),
  );
  Get.put(ndk, permanent: true);

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

      return ToastificationWrapper(
        child: GetMaterialApp(
          title: 'Nmail',
          theme: ThemeData.from(colorScheme: lightScheme),
          darkTheme: ThemeData.from(colorScheme: darkScheme),
          themeMode: initialThemeMode,
          locale: const Locale('en'),
          localizationsDelegates: [
            nostr_widgets.AppLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          initialBinding: InitialBinding(),
          getPages: AppRoutes.routes,
          home: const _InitialScreen(),
        ),
      );
    });
  }
}

class _InitialScreen extends StatelessWidget {
  const _InitialScreen();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final authController = Get.find<AuthController>();

      if (authController.isLoading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      if (authController.isLoggedIn.value) {
        Future.microtask(() => Get.offAllNamed('/inbox'));
      } else {
        Future.microtask(() => Get.offAllNamed('/login'));
      }

      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    });
  }
}
