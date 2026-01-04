import 'dart:async';

import 'package:get/get.dart';
import 'package:nostr_mail/nostr_mail.dart';

import '../services/nostr_mail_service.dart';

enum MailFolder { inbox, sent }

class InboxController extends GetxController {
  final _nostrMailService = Get.find<NostrMailService>();

  final _allEmails = <Email>[];
  final emails = <Email>[].obs;
  final isLoading = false.obs;
  final isSyncing = false.obs;
  final currentFolder = MailFolder.inbox.obs;
  final selectedIds = <String>{}.obs;

  StreamSubscription? _watchSubscription;

  String? get _myPubkey => _nostrMailService.getPublicKey();

  bool get hasSelection => selectedIds.isNotEmpty;
  bool get allSelected => selectedIds.length == emails.length && emails.isNotEmpty;

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
    for (final id in ids) {
      await _nostrMailService.client.delete(id);
      _allEmails.removeWhere((e) => e.id == id);
    }
    selectedIds.clear();
    _applyFilter();
  }

  @override
  void onInit() {
    super.onInit();
    _loadEmails();
    _startWatching();
  }

  @override
  void onClose() {
    _watchSubscription?.cancel();
    super.onClose();
  }

  Future<void> _loadEmails() async {
    isLoading.value = true;
    try {
      final cached = await _nostrMailService.client.getEmails();
      _allEmails.clear();
      _allEmails.addAll(cached);
      _applyFilter();
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilter() {
    final pubkey = _myPubkey;
    if (pubkey == null) {
      emails.assignAll(_allEmails);
      return;
    }

    if (currentFolder.value == MailFolder.inbox) {
      emails.assignAll(_allEmails.where((e) => e.senderPubkey != pubkey));
    } else {
      emails.assignAll(_allEmails.where((e) => e.senderPubkey == pubkey));
    }
  }

  void setFolder(MailFolder folder) {
    if (currentFolder.value != folder) {
      currentFolder.value = folder;
      selectedIds.clear();
      _applyFilter();
    }
  }

  void _startWatching() {
    _watchSubscription = _nostrMailService.client.watchInbox().listen(
      (email) {
        _allEmails.insert(0, email);
        _applyFilter();
      },
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

  Future<void> deleteEmail(String id) async {
    await _nostrMailService.client.delete(id);
    _allEmails.removeWhere((e) => e.id == id);
    emails.removeWhere((e) => e.id == id);
  }
}
