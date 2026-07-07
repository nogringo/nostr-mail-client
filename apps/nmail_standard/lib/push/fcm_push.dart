import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:nmail_core/app/routes/app_router.dart';
import 'package:nmail_core/app/routes/app_routes.dart';
import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/services/push_registration_service.dart';
import 'package:nmail_core/utils/nostr_utils.dart';

import '../firebase_options.dart';

/// FCM delivery for the standard (Play) flavor. Kept out of nmail_core so the
/// FOSS build never links Firebase. The push server sends notification
/// messages that the OS displays directly; this class only wires up init,
/// the device token, and tap-to-open routing.
class FcmPush {
  static Future<void> init() async {
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
    await messaging.requestPermission();

    final token = await messaging.getToken();
    debugPrint('FCM token: $token');
    await _setToken(token);
    messaging.onTokenRefresh.listen((t) {
      debugPrint('FCM token refreshed: $t');
      unawaited(_setToken(t));
    });

    final initial = await messaging.getInitialMessage();
    if (initial != null) _handleTap(initial);
  }

  static void _handleTap(RemoteMessage message) {
    final nevent = message.data['nevent'];
    final eventId = nevent is String ? eventIdFromNevent(nevent) : null;
    AppRouter.router.go(
      eventId != null && eventId.isNotEmpty
          ? '${AppRoutes.inbox}/email/$eventId'
          : AppRoutes.inbox,
    );
  }

  static Future<void> _setToken(String? token) async {
    if (token == null || token.isEmpty) return;
    if (!Get.isRegistered<PushRegistrationService>()) return;

    final service = Get.find<PushRegistrationService>();
    service.setCurrentTransport(PushTransport.fcm(token: token));

    if (Get.find<SettingsController>().notificationsEnabled.value) {
      await service.registerCurrentTransport();
    }
  }
}

/// Runs in a background isolate. Notification messages are shown by the OS, so
/// there is nothing to do here yet; kept for future data-message handling.
@pragma('vm:entry-point')
Future<void> _backgroundHandler(RemoteMessage message) async {}
