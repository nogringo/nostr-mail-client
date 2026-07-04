import 'package:get/get.dart';

import 'package:nmail_core/services/address_book_service.dart';
import 'package:nmail_core/services/contacts_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Services/Controllers already initialized in main():
    // - StorageService
    // - NostrMailService
    // - AuthController
    // - SettingsController (via Get.putAsync, awaited before runApp)

    if (!Get.isRegistered<AddressBookService>()) {
      Get.put(AddressBookService(), permanent: true);
    }
    Get.lazyPut(() => ContactsService());
  }
}
