import 'package:nmail_core/app/bootstrap.dart';

import 'push/fcm_push.dart';

void main() => runNmailApp(onReady: FcmPush.init);
