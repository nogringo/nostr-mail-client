import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../services/nostr_mail_service.dart';
import '../../services/storage_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(StorageService(), permanent: true);
    Get.put(NostrMailService(), permanent: true);
    Get.put(AuthController(), permanent: true);
    Get.put(SettingsController(), permanent: true);
  }
}
