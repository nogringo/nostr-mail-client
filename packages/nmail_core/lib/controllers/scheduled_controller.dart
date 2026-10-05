import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/utils/scheduled_email_extensions.dart';

class ScheduledController extends ChangeNotifier {
  ScheduledController() {
    _clock = Timer.periodic(const Duration(minutes: 1), (_) {
      now = DateTime.now();
      notifyListeners();
    });
    if (_nostrMailService.hasAccount) {
      _activate();
    }
  }

  final _nostrMailService = Get.find<NostrMailService>();

  List<ScheduledEmail> scheduled = [];
  bool isLoading = false;
  bool isSyncing = false;
  final selectedIds = <String>{};
  final hoveredId = ValueNotifier<String?>(null);

  /// Ticks so an email turns overdue on screen without waiting for feedback.
  DateTime now = DateTime.now();

  StreamSubscription<List<ScheduledEmail>>? _watchSubscription;
  Timer? _clock;
  bool _isDisposed = false;

  bool get hasSelection => selectedIds.isNotEmpty;
  bool get allSelected =>
      selectedIds.length == scheduled.length && scheduled.isNotEmpty;
  bool isSelected(String id) => selectedIds.contains(id);

  @override
  void dispose() {
    _isDisposed = true;
    _watchSubscription?.cancel();
    _clock?.cancel();
    hoveredId.dispose();
    super.dispose();
  }

  Future<void> _activate() async {
    final client = _nostrMailService.client;
    isLoading = true;
    notifyListeners();
    try {
      final loaded = await client.getScheduledEmails();
      if (_isDisposed) return;
      _onScheduled(loaded);
    } finally {
      if (!_isDisposed) {
        isLoading = false;
        notifyListeners();
      }
    }
    _watchSubscription = client.watchScheduledEmails().listen(
      _onScheduled,
      onError: (_) {},
    );
    // Live DVM status feedback and multi-device schedule sync; best-effort.
    client.startScheduling().ignore();
  }

  void _onScheduled(List<ScheduledEmail> list) {
    scheduled = list.where((e) => !e.isFinished).toList();
    final ids = scheduled.map((e) => e.packageId).toSet();
    selectedIds.removeWhere((id) => !ids.contains(id));
    notifyListeners();
  }

  void toggleSelection(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
    notifyListeners();
  }

  void selectAll() {
    selectedIds
      ..clear()
      ..addAll(scheduled.map((e) => e.packageId));
    notifyListeners();
  }

  void clearSelection() {
    selectedIds.clear();
    notifyListeners();
  }

  /// Cancel a scheduled email; the watch stream removes it from [scheduled].
  Future<void> cancel(String packageId) =>
      _nostrMailService.client.cancelScheduledEmail(packageId);

  /// Cancel every selected scheduled email.
  Future<void> cancelSelected() async {
    final ids = selectedIds.toList();
    clearSelection();
    await Future.wait(ids.map(_nostrMailService.client.cancelScheduledEmail));
  }

  /// Pull the latest schedules and DVM statuses from relays; the watch stream
  /// re-emits with the result.
  Future<void> resync() async {
    if (isSyncing) return;
    isSyncing = true;
    notifyListeners();
    try {
      await _nostrMailService.client.resyncScheduledEmails();
    } finally {
      if (!_isDisposed) {
        isSyncing = false;
        notifyListeners();
      }
    }
  }
}
