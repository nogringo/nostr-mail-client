import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';

/// Asks for the device's own lock (pattern, PIN, password or biometrics)
/// before a sensitive action.
///
/// Returns true when the platform has no device authentication (web, Linux)
/// or the device has no lock set, since there is nothing to check against.
abstract class DeviceAuth {
  static final _auth = LocalAuthentication();

  /// Whether the platform can actually verify the user. False on web and
  /// Linux, and `confirm` then returns true unconditionally — callers that
  /// guard something highly sensitive should say so explicitly (see
  /// CopySyncCodeTile).
  static bool get isSupported => _isSupported;

  static bool get _isSupported {
    if (kIsWeb) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS ||
      TargetPlatform.windows => true,
      _ => false,
    };
  }

  /// [macosReason] completes the system sentence "Nmail is trying to ...".
  static Future<bool> confirm({
    required String title,
    required String hint,
    required String reason,
    required String macosReason,
  }) async {
    if (!_isSupported) return true;
    try {
      return await _auth.authenticate(
        localizedReason: defaultTargetPlatform == TargetPlatform.macOS
            ? macosReason
            : reason,
        authMessages: [
          AndroidAuthMessages(signInTitle: title, signInHint: hint),
        ],
      );
    } on LocalAuthException catch (e) {
      return e.code == LocalAuthExceptionCode.noCredentialsSet;
    }
  }
}
