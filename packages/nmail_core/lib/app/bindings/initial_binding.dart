import 'package:get/get.dart';

import 'package:nmail_core/controllers/mailboxes_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Services/Controllers already initialized in main():
    // - StorageService
    // - NostrMailService
    // - AuthController
    // - SettingsController (via Get.putAsync, awaited before runApp)

    Get.put(MailboxesController(), permanent: true);
  }
}
