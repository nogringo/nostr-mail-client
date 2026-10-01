import 'package:get/get.dart';
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';

import 'package:nmail_core/services/nostr_mail_service.dart';

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
      await Get.find<SyncEngine>().clearAllLocalData();
      // Waits for the walk from scratch the clear just started.
      await Get.find<NostrMailService>().client.fetchRecent();
      await loadData();
    } finally {
      isSyncing = false;
      update();
    }
  }
}
