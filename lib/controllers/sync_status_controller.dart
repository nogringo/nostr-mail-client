import 'package:get/get.dart';

import '../services/nostr_mail_service.dart';

class SyncStatusController extends GetxController {
  List<EmailSyncStatus>? syncStatus;
  bool isLoading = true;
  bool isSyncing = false;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    final nostrMailService = Get.find<NostrMailService>();
    syncStatus = await nostrMailService.getEmailSyncStatus();
    isLoading = false;
    update();
  }

  Future<void> resync() async {
    if (isSyncing) return;
    isSyncing = true;
    update();
    try {
      final nostrMailService = Get.find<NostrMailService>();
      await nostrMailService.client.resync();
      await loadData();
    } finally {
      isSyncing = false;
      update();
    }
  }
}
