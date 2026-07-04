import 'dart:async';

import 'package:get/get.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/services/nostr_mail_service.dart';

class ScheduledController extends GetxController {
  final _nostrMailService = Get.find<NostrMailService>();

  final RxList<ScheduledEmail> scheduled = <ScheduledEmail>[].obs;
  final isLoading = false.obs;
  final isSyncing = false.obs;
  final selectedIds = <String>{}.obs;

  StreamSubscription<List<ScheduledEmail>>? _watchSubscription;

  bool get hasSelection => selectedIds.isNotEmpty;
  bool get allSelected =>
      selectedIds.length == scheduled.length && scheduled.isNotEmpty;
  bool isSelected(String id) => selectedIds.contains(id);

  @override
  void onInit() {
    super.onInit();
    if (_nostrMailService.isClientInitialized) {
      _activate();
    }
  }

  @override
  void onClose() {
    _watchSubscription?.cancel();
    super.onClose();
  }

  Future<void> _activate() async {
    final client = _nostrMailService.client;
    isLoading.value = true;
    try {
      scheduled.assignAll(await client.getScheduledEmails());
    } finally {
      isLoading.value = false;
    }
    _watchSubscription = client.watchScheduledEmails().listen(
      _onScheduled,
      onError: (_) {},
    );
    // Live DVM status feedback and multi-device schedule sync; best-effort.
    client.startScheduling().ignore();
  }

  void _onScheduled(List<ScheduledEmail> list) {
    scheduled.assignAll(list);
    final ids = list.map((e) => e.packageId).toSet();
    selectedIds.removeWhere((id) => !ids.contains(id));
  }

  void toggleSelection(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
  }

  void selectAll() => selectedIds.assignAll(scheduled.map((e) => e.packageId));

  void clearSelection() => selectedIds.clear();

  /// Cancel a scheduled email; the watch stream removes it from [scheduled].
  Future<void> cancel(String packageId) =>
      _nostrMailService.client.cancelScheduledEmail(packageId);

  /// Cancel every selected scheduled email.
  Future<void> cancelSelected() async {
    final ids = selectedIds.toList();
    selectedIds.clear();
    await Future.wait(ids.map(_nostrMailService.client.cancelScheduledEmail));
  }

  /// Pull the latest schedules and DVM statuses from relays; the watch stream
  /// re-emits with the result.
  Future<void> resync() async {
    if (isSyncing.value) return;
    isSyncing.value = true;
    try {
      await _nostrMailService.client.resyncScheduledEmails();
    } finally {
      isSyncing.value = false;
    }
  }
}
