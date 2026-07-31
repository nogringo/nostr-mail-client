import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:nmail_core/app/routes/app_router.dart';
import 'package:nmail_core/app/routes/app_routes.dart';
import 'package:nmail_core/services/push_registration_service.dart';
import 'package:nmail_core/services/push_subscription_service.dart';

import '../firebase_options.dart';

/// FCM delivery for the standard (Play) flavor. Kept out of nmail_core so the
/// FOSS build never links Firebase. The push server sends notification
/// messages that the OS displays directly; this class only wires up init,
/// the device token, and tap-to-open routing.
class FcmPush {
  static const _webVapidKey =
      'BFMkkTYK_ToRjKT917_8pIHNO4OWeFlia6HGyHTKgGHv9jlv_3ajdSkmUT0HDeE9UcfdMkU2H034pi31e4Tm0zQ';

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

    // A new token invalidates every account subscribed with the old one.
    messaging.onTokenRefresh.listen((token) {
      _setToken(token);
      unawaited(_syncSubscriptions());
    });

    if (await _hasEnabledAccount()) {
      await pushService.prepareCurrentTransport();
      await _syncSubscriptions();
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
    if (kIsWeb && _webVapidKey.isEmpty) {
      return;
    }

    _setToken(
      await messaging.getToken(
        vapidKey: kIsWeb ? _webVapidKey : null,
        serviceWorkerScriptPath: kIsWeb ? 'firebase-messaging-sw.js' : null,
      ),
    );
  }

  static void _handleTap(RemoteMessage message) {
    final nevent = message.data['nevent'];
    AppRouter.router.go(
      nevent is String && nevent.isNotEmpty
          ? '${AppRoutes.inbox}/email/$nevent'
          : AppRoutes.inbox,
    );
  }

  static void _setToken(String? token) {
    if (token == null || token.isEmpty) return;
    if (!Get.isRegistered<PushRegistrationService>()) return;

    Get.find<PushRegistrationService>().setCurrentTransport(
      PushTransport.fcm(token: token),
    );
  }

  static Future<void> _syncSubscriptions() async {
    if (!Get.isRegistered<PushSubscriptionService>()) return;
    await Get.find<PushSubscriptionService>().syncAll();
  }

  static Future<bool> _hasEnabledAccount() async {
    if (!Get.isRegistered<PushSubscriptionService>()) return false;
    return Get.find<PushSubscriptionService>().hasEnabledAccount();
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
