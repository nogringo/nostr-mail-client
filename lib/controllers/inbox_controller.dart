import 'dart:async';

import 'package:get/get.dart';
import 'package:nostr_mail/nostr_mail.dart';

import '../services/nostr_mail_service.dart';

enum MailFolder { inbox, sent, trash }

class InboxController extends GetxController {
  final _nostrMailService = Get.find<NostrMailService>();

  final RxList<Email> emails = <Email>[].obs;
  final isSyncing = false.obs;
  final currentFolder = MailFolder.inbox.obs;
  final selectedIds = <String>{}.obs;

  StreamSubscription? _watchSubscription;

  bool get hasSelection => selectedIds.isNotEmpty;
  bool get allSelected =>
      selectedIds.length == emails.length && emails.isNotEmpty;

  bool isSelected(String id) => selectedIds.contains(id);

  void toggleSelection(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
  }

  void selectAll() {
    selectedIds.assignAll(emails.map((e) => e.id));
  }

  void clearSelection() {
    selectedIds.clear();
  }

  Future<void> deleteSelected() async {
    final ids = selectedIds.toList();
    if (currentFolder.value == MailFolder.trash) {
      await Future.wait(ids.map((id) => _nostrMailService.client.delete(id)));
    } else {
      await Future.wait(
        ids.map((id) => _nostrMailService.client.moveToTrash(id)),
      );
    }
    selectedIds.clear();
    await _loadEmails();
  }

  @override
  void onInit() {
    super.onInit();
    if (_nostrMailService.isClientInitialized) {
      _loadEmails();
      _startWatching();
      sync(); // Auto-sync from relays on startup
    }
  }

  @override
  void onClose() {
    _watchSubscription?.cancel();
    super.onClose();
  }

  Future<void> _loadEmails() async {
    final client = _nostrMailService.client;
    final loaded = switch (currentFolder.value) {
      MailFolder.inbox => await client.getInboxEmails(),
      MailFolder.sent => await client.getSentEmails(),
      MailFolder.trash => await client.getTrashedEmails(),
    };
    emails.assignAll(loaded);
  }

  void setFolder(MailFolder folder) {
    if (currentFolder.value != folder) {
      currentFolder.value = folder;
      selectedIds.clear();
      _loadEmails();
    }
  }

  void _startWatching() {
    _watchSubscription = _nostrMailService.client.onEmail.listen(
      (_) => _loadEmails(),
      onError: (e) {
        // Silent error handling for stream
      },
    );
  }

  Future<void> sync() async {
    if (isSyncing.value) return;

    isSyncing.value = true;
    try {
      await _nostrMailService.client.sync();
      await _loadEmails();
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> moveToTrash(String id) async {
    await _nostrMailService.client.moveToTrash(id);
    await _loadEmails();
  }

  Future<void> restoreFromTrash(String id) async {
    await _nostrMailService.client.restoreFromTrash(id);
    await _loadEmails();
  }

  Future<void> deleteEmail(String id) async {
    if (currentFolder.value == MailFolder.trash) {
      // Permanent delete
      await _nostrMailService.client.delete(id);
    } else {
      // Move to trash
      await _nostrMailService.client.moveToTrash(id);
    }
    await _loadEmails();
  }
}
