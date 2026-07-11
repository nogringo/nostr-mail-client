import 'package:nmail_core/app/bootstrap.dart';

import 'push/unified_push.dart';

void main(List<String> args) {
  if (args.contains('--unifiedpush-bg')) {
    UnifiedPushHandler.runBackground();
  } else {
    runNmailApp(onReady: UnifiedPushHandler.init);
  }
}
