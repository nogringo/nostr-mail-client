import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:nmail_core/app/routes/app_routes.dart';
import 'package:nmail_core/services/notification_service.dart';
import 'package:nmail_core/utils/nostr_utils.dart';
import 'package:unifiedpush/unifiedpush.dart';

/// UnifiedPush delivery for the FOSS flavor (no Google). Unlike FCM, the
/// distributor hands the app raw bytes, so we build and show the notification
/// ourselves via the core NotificationService. The push server POSTs a JSON
/// body `{ title, body, nevent }` to the endpoint.
class UnifiedPushHandler {
  static Future<void> init() async {
    await UnifiedPush.initialize(
      onNewEndpoint: _onNewEndpoint,
      onMessage: _onMessage,
      onRegistrationFailed: (reason, instance) =>
          debugPrint('UnifiedPush registration failed: $reason'),
      onUnregistered: (instance) => debugPrint('UnifiedPush unregistered'),
    );

    if (await UnifiedPush.tryUseCurrentOrDefaultDistributor()) {
      await UnifiedPush.register();
    } else {
      debugPrint('No UnifiedPush distributor available');
    }
  }

  static void _onNewEndpoint(PushEndpoint endpoint, String instance) {
    final keys = endpoint.pubKeySet;
    debugPrint('UnifiedPush endpoint: ${endpoint.url}');
    debugPrint('UnifiedPush keys: p256dh=${keys?.pubKey} auth=${keys?.auth}');
    // TODO(push server): register endpoint + Web Push keys + user pubkey so the
    // server can encrypt and push when a giftwrap for that pubkey arrives.
  }

  static void _onMessage(PushMessage message, String instance) {
    // Any delivered push means new mail; fall back to a generic notification
    // when the body is empty or not our JSON.
    Map<String, dynamic>? data;
    try {
      final text = utf8.decode(message.content);
      if (text.isNotEmpty) data = jsonDecode(text) as Map<String, dynamic>;
    } catch (_) {}

    final nevent = data?['nevent'];
    final eventId = nevent is String ? eventIdFromNevent(nevent) : null;

    Get.find<NotificationService>().show(
      id:
          (eventId ?? DateTime.now().microsecondsSinceEpoch.toString())
              .hashCode &
          0x7fffffff,
      title: data?['title'] as String? ?? 'New email',
      body: data?['body'] as String? ?? '',
      payload: eventId != null
          ? '${AppRoutes.inbox}/email/$eventId'
          : AppRoutes.inbox,
    );
  }
}
