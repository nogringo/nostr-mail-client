import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';

import 'package:nmail_core/services/nostr_mail_service.dart';

class SyncStatusController extends ChangeNotifier {
  SyncStatusController() {
    loadData();
  }

  List<EmailSyncStatus>? syncStatus;
  bool isLoading = true;
  bool isSyncing = false;
  bool _isDisposed = false;

  Future<void> loadData() async {
    final nostrMailService = GetIt.I<NostrMailService>();
    syncStatus = await nostrMailService.getEmailSyncStatus();
    if (_isDisposed) return;
    isLoading = false;
    notifyListeners();
  }

  Future<void> resync() async {
    if (isSyncing) return;
    isSyncing = true;
    notifyListeners();
    try {
      await GetIt.I<SyncEngine>().clearAllLocalData();
      // Waits for the walk from scratch the clear just started.
      await GetIt.I<NostrMailService>().client.fetchRecent();
      await loadData();
    } finally {
      if (!_isDisposed) {
        isSyncing = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
