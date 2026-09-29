import 'package:flutter/foundation.dart';
import 'package:nmail_core/app/bootstrap.dart';
import 'package:nmail_core/app/config/distribution_config.dart';

import 'push/fcm_push.dart';

const _appleAppStorePrivacyPolicyUrl =
    'https://legal.nostrmail.org/privacy/apple-app-store';

String? get _privacyPolicyUrl {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return null;
  return _appleAppStorePrivacyPolicyUrl;
}

void main() => runNmailApp(
  distribution: Distribution.standard,
  onReady: FcmPush.init,
  privacyPolicyUrl: _privacyPolicyUrl,
);
