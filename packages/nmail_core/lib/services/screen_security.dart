import 'package:flutter/services.dart';

import 'package:nmail_core/utils/platform_helper.dart';

/// Android `FLAG_SECURE`: blocks screenshots and screen recording, and blanks
/// the app in recent apps. Other platforms have no reliable equivalent.
abstract class ScreenSecurity {
  static const _platform = MethodChannel('app.nostrmail.client/native');

  static bool get isSupported => PlatformHelper.isAndroid;

  static Future<void> apply(bool enabled) async {
    if (!isSupported) return;
    await _platform.invokeMethod('setScreenSecure', {'enabled': enabled});
  }
}
