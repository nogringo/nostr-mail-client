import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:nmail_core/app/routes/app_routes.dart';
import 'package:nmail_core/services/notification_service.dart';
import 'package:nmail_core/services/push_registration_service.dart';
import 'package:nmail_core/services/push_subscription_service.dart';
import 'package:nmail_core/utils/nostr_utils.dart';
import 'package:unifiedpush/unifiedpush.dart';

/// UnifiedPush delivery for the FOSS flavor (no Google). Unlike FCM, the
/// distributor hands the app raw bytes, so we build and show the notification
/// ourselves. The push server POSTs a JSON body `{ title, body, nevent }`.
///
/// The distributor delivers messages through a separate Flutter engine started
/// with `--unifiedpush-bg`; [runBackground] is that lightweight entry point,
/// while [init] runs in the normal app to register and obtain the endpoint.
class UnifiedPushHandler {
  static Future<void>? _initializeFuture;

  /// Foreground: register with a distributor and obtain the endpoint. Messages
  /// arriving while the app is alive are shown via the shared core service.
  static Future<void> init() async {
    if (!_isSupportedPlatform) {
      return;
    }

    if (GetIt.I.isRegistered<PushRegistrationService>()) {
      GetIt.I<PushRegistrationService>().configureTransportLifecycle(
        requestPermission: () async => true,
        prepareTransport: _prepareTransport,
      );
    }

    await _ensureInitialized();

    if (await _hasEnabledAccount() &&
        GetIt.I.isRegistered<PushRegistrationService>()) {
      await GetIt.I<PushRegistrationService>().prepareCurrentTransport();
      await _syncSubscriptions();
    }
  }

  /// Background entry point (app closed): initialise only what is needed to
  /// receive one message and show a notification, without the full app. No
  /// register() here, so an incoming push does not re-run registration.
  static Future<void> runBackground() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (!_isSupportedPlatform) {
      return;
    }

    final notifications = await NotificationService().init();
    await UnifiedPush.initialize(
      onMessage: (message, instance) =>
          _showFromMessage(notifications, message),
    );
  }

  /// A new endpoint invalidates every account subscribed with the old one.
  static void _onNewEndpoint(PushEndpoint endpoint, String instance) {
    final keys = endpoint.pubKeySet;
    if (!GetIt.I.isRegistered<PushRegistrationService>()) return;

    GetIt.I<PushRegistrationService>().setCurrentTransport(
      PushTransport.unifiedPush(
        endpoint: endpoint.url,
        p256dh: keys?.pubKey,
        auth: keys?.auth,
        instance: instance,
      ),
    );

    unawaited(_syncSubscriptions());
  }

  static Future<void> _prepareTransport() async {
    if (!_isSupportedPlatform) return;
    await _ensureInitialized();
    if (await UnifiedPush.tryUseCurrentOrDefaultDistributor()) {
      await UnifiedPush.register();
    }
  }

  static Future<void> _ensureInitialized() {
    return _initializeFuture ??= UnifiedPush.initialize(
      onNewEndpoint: _onNewEndpoint,
      onMessage: (message, instance) =>
          _showFromMessage(GetIt.I<NotificationService>(), message),
      onRegistrationFailed: (reason, instance) {},
      onUnregistered: (instance) {},
    );
  }

  static void _showFromMessage(
    NotificationService notifications,
    PushMessage message,
  ) {
    // Any delivered push means new mail; fall back to a generic notification
    // when the body is empty or not our JSON. The id derives from the event so
    // the foreground and background engines dedupe instead of double-notifying.
    Map<String, dynamic>? data;
    try {
      final text = utf8.decode(message.content);
      if (text.isNotEmpty) data = jsonDecode(text) as Map<String, dynamic>;
    } catch (_) {}

    final nevent = data?['nevent'];
    final eventId = nevent is String ? eventIdFromNevent(nevent) : null;

    notifications.show(
      id:
          (eventId ?? DateTime.now().microsecondsSinceEpoch.toString())
              .hashCode &
          0x7fffffff,
      title: data?['title'] as String? ?? 'New email',
      body: data?['body'] as String? ?? '',
      payload: nevent is String && nevent.isNotEmpty
          ? '${AppRoutes.inbox}/email/$nevent'
          : AppRoutes.inbox,
    );
  }

  static bool get _isSupportedPlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  static Future<void> _syncSubscriptions() async {
    if (!GetIt.I.isRegistered<PushSubscriptionService>()) return;
    await GetIt.I<PushSubscriptionService>().syncAll();
  }

  static Future<bool> _hasEnabledAccount() async {
    if (!GetIt.I.isRegistered<PushSubscriptionService>()) return false;
    return GetIt.I<PushSubscriptionService>().hasEnabledAccount();
  }
}
