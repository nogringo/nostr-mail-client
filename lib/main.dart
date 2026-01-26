import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:nostr_widgets/l10n/app_localizations.dart' as nostr_widgets;
import 'package:system_theme/system_theme.dart';
import 'package:toastification/toastification.dart';
import 'package:window_manager/window_manager.dart';

import 'app/bindings/initial_binding.dart';
import 'app/routes/app_routes.dart';
import 'controllers/auth_controller.dart';
import 'services/storage_service.dart';
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

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final accentColor = SystemTheme.accentColor.accent;

    return ToastificationWrapper(
      child: GetMaterialApp(
        title: 'Nmail',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: accentColor),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: accentColor,
            brightness: Brightness.dark,
          ),
        ),
        // themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
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
