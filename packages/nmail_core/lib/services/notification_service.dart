import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import 'package:nmail_core/app/routes/app_router.dart';
import 'package:nmail_core/utils/platform_helper.dart';

/// Displays local notifications. This is the presentation layer only; the
/// wake-up source (FCM on nmail_standard, UnifiedPush on nmail_foss) lives in
/// the app flavor and calls [show].
class NotificationService extends GetxService {
  final _plugin = FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'emails',
    'Emails',
    description: 'Notifications for new emails',
    importance: Importance.high,
  );

  Future<NotificationService> init() async {
    // Web notifications go through the FCM service worker, not this plugin.
    if (kIsWeb) return this;

    // Permission flags are false here: we prompt explicitly via
    // requestPermissions() from the enable-notifications flow, not at startup.
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('ic_stat_email'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      linux: LinuxInitializationSettings(defaultActionName: 'Open'),
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onTap,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    return this;
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) return true;

    if (PlatformHelper.isAndroid) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      return granted ?? false;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }

    if (defaultTargetPlatform == TargetPlatform.macOS) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }

    return true;
  }

  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) {
    if (kIsWeb) return Future.value();

    return _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_stat_email',
        ),
        iOS: const DarwinNotificationDetails(),
        macOS: const DarwinNotificationDetails(),
        linux: const LinuxNotificationDetails(),
      ),
      payload: payload,
    );
  }

  void _onTap(NotificationResponse response) {
    final route = response.payload;
    if (route != null && route.isNotEmpty) AppRouter.router.go(route);
  }
}
