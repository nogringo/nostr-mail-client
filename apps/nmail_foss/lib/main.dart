import 'package:flutter/foundation.dart';
import 'package:nmail_core/app/bootstrap.dart';
import 'package:unifiedpush/unifiedpush.dart';

import 'push/unified_push.dart';

void main(List<String> args) {
  if (args.contains('--unifiedpush-bg')) {
    UnifiedPushHandler.runBackground();
  } else {
    runNmailApp(
      onReady: UnifiedPushHandler.init,
      hasUnifiedPushDistributor: _hasUnifiedPushDistributor,
    );
  }
}

Future<bool> _hasUnifiedPushDistributor() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return true;
  return (await UnifiedPush.getDistributors()).isNotEmpty;
}
