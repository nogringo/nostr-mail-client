import 'package:flutter/foundation.dart';

abstract class PlatformHelper {
  static bool get isDesktop {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows;
  }

  /// Returns true for desktop and mobile (not web)
  static bool get isNative => !kIsWeb;
}
