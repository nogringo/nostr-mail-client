import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:nmail_core/app/routes/app_router.dart';
import 'package:nmail_core/app/routes/app_routes.dart';
import 'package:nmail_core/controllers/auth_controller.dart';
import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/services/push_registration_service.dart';

import '../firebase_options.dart';

/// FCM delivery for the standard (Play) flavor. Kept out of nmail_core so the
/// FOSS build never links Firebase. The push server sends notification
/// messages that the OS displays directly; this class only wires up init,
/// the device token, and tap-to-open routing.
class FcmPush {
  static Future<void> init() async {
    if (!_isSupportedPlatform) return;

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);

    // Permission and token are network/UI bound; don't block the first frame.
    unawaited(_setup());
  }

  static Future<void> _setup() async {
    final messaging = FirebaseMessaging.instance;
    if (!Get.isRegistered<PushRegistrationService>()) return;

    final pushService = Get.find<PushRegistrationService>();
    pushService.configureTransportLifecycle(
      requestPermission: () => _requestPermission(messaging),
      prepareTransport: () => _refreshToken(messaging),
    );

    messaging.onTokenRefresh.listen((t) {
      if (!_canUsePush) return;
      unawaited(_setToken(t));
    });

    if (_canUsePush) {
      await pushService.prepareCurrentTransport();
      await pushService.registerCurrentTransport();
    }

    final initial = await messaging.getInitialMessage();
    if (initial != null) _handleTap(initial);
  }

  static Future<bool> _requestPermission(FirebaseMessaging messaging) async {
    final settings = await messaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  static Future<void> _refreshToken(FirebaseMessaging messaging) async {
    final token = await messaging.getToken();
    await _setToken(token, registerIfEnabled: false);
  }

  static void _handleTap(RemoteMessage message) {
    final nevent = message.data['nevent'];
    AppRouter.router.go(
      nevent is String && nevent.isNotEmpty
          ? '${AppRoutes.inbox}/email/$nevent'
          : AppRoutes.inbox,
    );
  }

  static Future<void> _setToken(
    String? token, {
    bool registerIfEnabled = true,
  }) async {
    if (token == null || token.isEmpty) return;
    if (!Get.isRegistered<PushRegistrationService>()) return;

    final service = Get.find<PushRegistrationService>();
    service.setCurrentTransport(PushTransport.fcm(token: token));

    if (registerIfEnabled && _canUsePush) {
      await service.registerCurrentTransport();
    }
  }

  static bool get _canUsePush {
    if (!Get.isRegistered<AuthController>() ||
        !Get.find<AuthController>().isLoggedIn.value) {
      return false;
    }
    if (!Get.isRegistered<SettingsController>()) return false;
    return Get.find<SettingsController>().notificationsEnabled.value;
  }

  static bool get _isSupportedPlatform {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }
}

/// Runs in a background isolate. Notification messages are shown by the OS, so
/// there is nothing to do here yet; kept for future data-message handling.
@pragma('vm:entry-point')
Future<void> _backgroundHandler(RemoteMessage message) async {}
