import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:nmail_core/app/routes/app_router.dart';
import 'package:nmail_core/utils/platform_helper.dart';
import 'package:nmail_core/utils/system_app_localizations.dart';

/// Displays local notifications. This is the presentation layer only; the
/// wake-up source (FCM on nmail_standard, UnifiedPush on nmail_foss) lives in
/// the app flavor and calls [show].
class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();

  late final AndroidNotificationChannel _channel;

  Future<NotificationService> init() async {
    final l = systemAppLocalizations();
    _channel = AndroidNotificationChannel(
      'emails',
      l.notificationChannelName,
      description: l.notificationChannelDescription,
      importance: Importance.high,
    );

    // Permission flags are false here: we prompt explicitly via
    // requestPermissions() from the enable-notifications flow, not at startup.
    final settings = InitializationSettings(
      android: const AndroidInitializationSettings('ic_stat_email'),
      iOS: const DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      macOS: const DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      linux: LinuxInitializationSettings(defaultActionName: l.actionOpen),
      windows: const WindowsInitializationSettings(
        appName: 'Nmail',
        appUserModelId: 'Org.Nostrmail.App',
        // Never change: Windows registers notification activation under it.
        guid: 'acf19ad1-c4c1-43a8-8e51-8df54898ea0b',
      ),
      web: const WebInitializationSettings(),
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
    if (kIsWeb) {
      final web = _plugin
          .resolvePlatformSpecificImplementation<
            WebFlutterLocalNotificationsPlugin
          >();
      if (web == null) return false;
      if (web.permissionStatus != WebNotificationPermission.granted) {
        await web.requestNotificationsPermission();
      }
      return web.permissionStatus == WebNotificationPermission.granted;
    }

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
        web: const WebNotificationDetails(),
      ),
      payload: payload,
    );
  }

  void _onTap(NotificationResponse response) {
    final route = response.payload;
    if (route != null && route.isNotEmpty) AppRouter.router.go(route);
  }
}
