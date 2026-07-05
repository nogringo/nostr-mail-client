import 'package:nmail_core/app/bootstrap.dart';

import 'push/unified_push.dart';

void main() => runNmailApp(onReady: UnifiedPushHandler.init);
