import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:nostr_mail/nostr_mail.dart';
import 'package:rxdart/rxdart.dart' hide Rx;

import '../app/config/app_config.dart';
import 'mailboxes_controller.dart';
import 'settings_controller.dart';
import 'package:nmail_core/app/routes/app_routes.dart';
import 'package:nmail_core/models/mailbox.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/services/notification_service.dart';
import 'package:nmail_core/utils/selection_range.dart';

class InboxController extends GetxController with WidgetsBindingObserver {
  final _nostrMailService = Get.find<NostrMailService>();
  final _notifications = Get.find<NotificationService>();

  final RxList<EmailSummary> emails = <EmailSummary>[].obs;
  final searchQuery = ''.obs;
  final isSearchMode = false.obs;
  final isSyncing = false.obs;
  final isDeletingFromTrash = false.obs;
  final Rx<Mailbox> currentMailbox = Rx<Mailbox>(Mailbox.inbox);
  final oldEmailsCount = 0.obs;
  final selectedIds = <String>{}.obs;
  final Rx<DateTime?> _backgroundTime = Rx<DateTime?>(null);
  final RxSet<String> readEmailIds = <String>{}.obs;
  final hoveredEmailId = RxnString();

  /// Row a shift-click extends the selection from: the last one toggled on
  /// its own, and whether that toggle checked or unchecked it.
  String? _selectionAnchorId;
  bool _selectionAnchorChecked = false;

  StreamSubscription? _notifySubscription;
  StreamSubscription? _reloadSubscription;
  Worker? _mailboxesWorker;
  int _accountGeneration = 0;
  AppLifecycleState _lifecycleState = AppLifecycleState.resumed;
  DateTime? _watchStartedAt;
  bool _isLoadingEmails = false;
  bool _pendingReload = false;

  bool get isSearching => searchQuery.value.isNotEmpty;
  int get unreadCount => emails.length - readEmailIds.length;

  // Read/unread status management
  bool isEmailRead(String emailId) => readEmailIds.contains(emailId);

  /// The full message behind a row, for the paths a summary cannot serve
  /// (reply and forward need the MIME).
  Future<Email?> loadEmail(String id) => _nostrMailService.client.getEmail(id);

  Future<void> markAsRead(String emailId) async {
    await _nostrMailService.markEmailAsRead(emailId);
    readEmailIds.add(emailId);
  }

  Future<void> markAsUnread(String emailId) async {
    await _nostrMailService.markEmailAsUnread(emailId);
    readEmailIds.remove(emailId);
  }

  Future<void> markAllAsRead() async {
    await Future.wait(emails.map((e) => markAsRead(e.id)));
  }

  Future<void> markAllAsUnread() async {
    await Future.wait(emails.map((e) => markAsUnread(e.id)));
  }

  Future<void> markSelectedAsRead() async {
    await Future.wait(selectedIds.map((id) => markAsRead(id)));
  }

  Future<void> markSelectedAsUnread() async {
    await Future.wait(selectedIds.map((id) => markAsUnread(id)));
  }

  void setSearchQuery(String query) {
    if (searchQuery.value == query) return;

    searchQuery.value = query;
    _loadEmails();
  }

  void enterSearchMode() {
    isSearchMode.value = true;
  }

  void exitSearchMode() {
    isSearchMode.value = false;
    clearSearch();
  }

  void clearSearch() {
    if (searchQuery.value.isEmpty) return;

    searchQuery.value = '';
    _loadEmails();
  }

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
    _selectionAnchorId = id;
    _selectionAnchorChecked = selectedIds.contains(id);
  }

  /// Applies the anchor's own state to every row between it and [id], so a
  /// shift-click picks a whole run at once, and undoes one just as fast.
  void extendSelectionTo(String id) {
    final anchor = _selectionAnchorId;
    final range = anchor == null
        ? const <String>[]
        : idsInRange(emails.map((e) => e.id).toList(), anchor, id);
    if (range.isEmpty) {
      toggleSelection(id);
      return;
    }
    if (_selectionAnchorChecked) {
      selectedIds.addAll(range);
    } else {
      selectedIds.removeAll(range);
    }
  }

  void selectAll() {
    selectedIds.assignAll(emails.map((e) => e.id));
    _selectionAnchorId = null;
  }

  void clearSelection() {
    selectedIds.clear();
    _selectionAnchorId = null;
  }

  Future<void> deleteSelected() async {
    final ids = selectedIds.toList();
    if (currentMailbox.value.isTrash) {
      await _nostrMailService.client.delete(ids);
    } else {
      await Future.wait(
        ids.map((id) => _nostrMailService.client.moveToTrash(id)),
      );
    }
    clearSelection();
    await _loadEmails();
  }

  Future<void> archiveSelected() async {
    final ids = selectedIds.toList();
    await Future.wait(
      ids.map((id) => _nostrMailService.client.moveToArchive(id)),
    );
    clearSelection();
    await _loadEmails();
  }

  Future<void> restoreSelected() async {
    final ids = selectedIds.toList();
    if (currentMailbox.value.isTrash) {
      await Future.wait(
        ids.map((id) => _nostrMailService.client.restoreFromTrash(id)),
      );
    } else {
      await Future.wait(
        ids.map((id) => _nostrMailService.client.restoreFromArchive(id)),
      );
    }
    clearSelection();
    await _loadEmails();
  }

  /// Moves [ids] to a reserved folder (`inbox`, `archive`...) or to a user
  /// folder id.
  Future<void> moveTo(Iterable<String> ids, String folder) async {
    final client = _nostrMailService.client;
    await Future.wait(ids.map((id) => client.moveToFolder(id, folder)));
    await _loadEmails();
  }

  Future<void> moveSelectedTo(String folder) async {
    final ids = selectedIds.toList();
    clearSelection();
    await moveTo(ids, folder);
  }

  /// Labels [emails] with the tags of [add] and takes the labels of [remove]
  /// off, skipping the emails already in that state. A tag its match
  /// condition holds needs no label.
  Future<void> applyTags(
    Iterable<EmailSummary> emails, {
    Set<String> add = const {},
    Set<String> remove = const {},
  }) async {
    final client = _nostrMailService.client;
    await Future.wait([
      for (final email in emails) ...[
        for (final tag in add)
          if (!email.tags.contains(tag)) client.addTag(email.id, tag),
        for (final tag in remove)
          if (email.labels.contains('tag:$tag'))
            client.removeTag(email.id, tag),
      ],
    ]);
    await _loadEmails();
  }

  List<EmailSummary> get selectedEmails =>
      emails.where((e) => selectedIds.contains(e.id)).toList();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    // A changed match condition moves emails without any label event.
    final mailboxes = Get.find<MailboxesController>();
    _mailboxesWorker = everAll([
      mailboxes.folders,
      mailboxes.tags,
    ], (_) => _loadEmails());
    if (_nostrMailService.hasAccount) {
      activateForCurrentAccount();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _mailboxesWorker?.dispose();
    _notifySubscription?.cancel();
    _reloadSubscription?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
    switch (state) {
      case AppLifecycleState.paused:
        // App went to background, record the time
        _backgroundTime.value = DateTime.now();
        break;
      case AppLifecycleState.resumed:
        // App came back from background, sync if needed
        _syncIfNecessary();
        break;
      default:
        break;
    }
  }

  /// Sync only if app was in background for more than debounce duration
  void _syncIfNecessary() {
    final backgroundTime = _backgroundTime.value;
    if (backgroundTime == null) return;

    final now = DateTime.now();
    if (now.difference(backgroundTime) >= AppConfig.syncDebounceDuration) {
      sync();
    }
  }

  Future<void> resetForAccountChange({Mailbox? mailbox}) async {
    _accountGeneration++;
    await _notifySubscription?.cancel();
    await _reloadSubscription?.cancel();
    _notifySubscription = null;
    _reloadSubscription = null;

    emails.clear();
    readEmailIds.clear();
    clearSelection();
    oldEmailsCount.value = 0;
    isSyncing.value = false;
    isDeletingFromTrash.value = false;
    isSearchMode.value = false;
    searchQuery.value = '';
    _backgroundTime.value = null;
    if (mailbox != null) currentMailbox.value = mailbox;
  }

  Future<void> activateForCurrentAccount({Mailbox? mailbox}) async {
    await resetForAccountChange(mailbox: mailbox);
    if (!_nostrMailService.hasAccount) return;

    await _loadEmails();
    _startWatching();
    sync(); // Auto-sync from relays on startup/login
  }

  /// Serialized so overlapping reloads cannot land out of order and leave the
  /// list on an older snapshot. A request arriving mid-load runs right after.
  Future<void> _loadEmails() async {
    if (_isLoadingEmails) {
      _pendingReload = true;
      return;
    }

    _isLoadingEmails = true;
    try {
      do {
        _pendingReload = false;
        await _queryEmails();
      } while (_pendingReload);
    } finally {
      _isLoadingEmails = false;
    }
  }

  Future<void> _queryEmails() async {
    final generation = _accountGeneration;
    final client = _nostrMailService.client;

    if (isSearching) {
      final loaded = await client.getSummaries(search: searchQuery.value);
      if (generation != _accountGeneration) return;
      _applyLoaded(loaded.items);
      oldEmailsCount.value = 0;
      return;
    }

    final mailbox = currentMailbox.value;
    final loaded = await client.getSummaries(
      folder: mailbox.folderParam,
      tag: mailbox.tagParam,
    );
    if (generation != _accountGeneration) return;
    _applyLoaded(loaded.items);

    // Update old emails count if in trash folder
    if (mailbox.isTrash) {
      final count = await getOldEmailsCount();
      if (generation != _accountGeneration) return;
      oldEmailsCount.value = count;
    } else {
      oldEmailsCount.value = 0;
    }
  }

  void _applyLoaded(List<EmailSummary> loaded) {
    emails.assignAll(loaded);
    readEmailIds.assignAll([
      for (final email in loaded)
        if (email.isRead) email.id,
    ]);
  }

  void setMailbox(Mailbox mailbox) {
    if (currentMailbox.value != mailbox) {
      currentMailbox.value = mailbox;
      clearSelection();
      isSearchMode.value = false;
      searchQuery.value = ''; // Clear search when switching mailboxes
      _loadEmails();
    }
  }

  void _startWatching() {
    _watchStartedAt = DateTime.now();
    final client = _nostrMailService.client;

    _notifySubscription = client.onEmail.listen(
      _notifyIncomingEmail,
      onError: (e) {},
    );

    // Cross-device sync: label add/remove events from other devices arrive
    // via the label subscription in WatchManager. Reload so read/unread,
    // trash, archive and star state stay in sync without a manual refresh.
    //
    // Throttled, not debounced: a bulk sync emits continuously for seconds, so
    // waiting for silence would leave the list empty until the very end.
    // leading gives an immediate first paint, trailing the final state.
    _reloadSubscription = MergeStream<Object>([client.onEmail, client.onLabel])
        .throttleTime(
          AppConfig.watchReloadThrottle,
          leading: true,
          trailing: true,
        )
        .listen((_) => _loadEmails(), onError: (e) {});
  }

  /// Surface a system notification for a genuinely new incoming email, but only
  /// while the app is not in the foreground, where the inbox already updates.
  void _notifyIncomingEmail(Email email) {
    if (!Get.find<SettingsController>().notificationsEnabled.value) return;
    if (_lifecycleState == AppLifecycleState.resumed) return;

    final startedAt = _watchStartedAt;
    if (startedAt != null && email.createdAt.isBefore(startedAt)) return;

    if (email.senderPubkey == _nostrMailService.getPublicKey()) return;

    final from = email.sender;
    final title = (from?.personalName?.trim().isNotEmpty ?? false)
        ? from!.personalName!.trim()
        : (from?.email ?? '');

    _notifications.show(
      id: email.id.hashCode & 0x7fffffff,
      title: title,
      body: email.subject?.trim() ?? '',
      payload: '${AppRoutes.inbox}/email/${email.id}',
    );
  }

  Future<void> sync() async {
    if (isSyncing.value) return;

    final generation = _accountGeneration;
    isSyncing.value = true;
    try {
      await _nostrMailService.client.fetchRecent();
      if (generation == _accountGeneration) {
        await _loadEmails();
      }
    } finally {
      if (generation == _accountGeneration) {
        isSyncing.value = false;
      }
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
    if (currentMailbox.value.isTrash) {
      // Permanent delete
      await _nostrMailService.client.delete([id]);
    } else {
      // Move to trash
      await _nostrMailService.client.moveToTrash(id);
    }
    await _loadEmails();
  }

  Future<void> moveToArchive(String id) async {
    await _nostrMailService.client.moveToArchive(id);
    await _loadEmails();
  }

  Future<void> restoreFromArchive(String id) async {
    await _nostrMailService.client.restoreFromArchive(id);
    await _loadEmails();
  }

  /// Get count of emails in trash older than 30 days
  Future<int> getOldEmailsCount() async {
    if (!currentMailbox.value.isTrash) return 0;

    final client = _nostrMailService.client;
    final thirtyDaysAgo = const Duration(days: 30);
    final oldEmails = await client.getTrashedEmailsOlderThan(thirtyDaysAgo);
    return oldEmails.length;
  }

  /// Delete all emails in trash older than 30 days
  Future<void> deleteOldEmails() async {
    if (!currentMailbox.value.isTrash) return;

    isDeletingFromTrash.value = true;
    try {
      final client = _nostrMailService.client;
      final thirtyDaysAgo = const Duration(days: 30);
      final oldEmails = await client.getTrashedEmailsOlderThan(thirtyDaysAgo);
      final oldEmailIds = oldEmails.map((email) => email.id).toList();

      if (oldEmailIds.isEmpty) return;

      // Batch delete all old emails
      await client.delete(oldEmailIds);

      // Update old emails count
      oldEmailsCount.value = await getOldEmailsCount();
      await _loadEmails();
    } finally {
      isDeletingFromTrash.value = false;
    }
  }

  Future<void> emptyTrash() async {
    if (!currentMailbox.value.isTrash) return;

    isDeletingFromTrash.value = true;
    try {
      final client = _nostrMailService.client;
      final trashed = await client.getSummaries(folder: 'trash');
      await client.delete(trashed.items.map((email) => email.id));

      clearSelection();
      oldEmailsCount.value = 0;
      await _loadEmails();
    } finally {
      isDeletingFromTrash.value = false;
    }
  }
}
