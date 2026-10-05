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

class InboxController extends ChangeNotifier with WidgetsBindingObserver {
  InboxController() {
    WidgetsBinding.instance.addObserver(this);
    // A changed match condition moves emails without any label event.
    final mailboxes = Get.find<MailboxesController>();
    _mailboxesSubscriptions = [
      mailboxes.folders.listen((_) => _loadEmails()),
      mailboxes.tags.listen((_) => _loadEmails()),
    ];
    if (_nostrMailService.hasAccount) {
      activateForCurrentAccount();
    }
  }

  final _nostrMailService = Get.find<NostrMailService>();
  final _notifications = Get.find<NotificationService>();

  List<EmailSummary> emails = [];
  String searchQuery = '';
  bool isSearchMode = false;
  bool isSyncing = false;
  bool isDeletingPermanently = false;
  Mailbox currentMailbox = Mailbox.inbox;
  int oldEmailsCount = 0;
  final selectedIds = <String>{};
  DateTime? _backgroundTime;
  final readEmailIds = <String>{};
  final hoveredEmailId = ValueNotifier<String?>(null);

  /// Row a shift-click extends the selection from: the last one toggled on
  /// its own, and whether that toggle checked or unchecked it.
  String? _selectionAnchorId;
  bool _selectionAnchorChecked = false;

  StreamSubscription? _notifySubscription;
  StreamSubscription? _reloadSubscription;
  late final List<StreamSubscription<Object?>> _mailboxesSubscriptions;
  int _accountGeneration = 0;
  AppLifecycleState _lifecycleState = AppLifecycleState.resumed;
  DateTime? _watchStartedAt;
  bool _isLoadingEmails = false;
  bool _pendingReload = false;

  bool get isSearching => searchQuery.isNotEmpty;
  int get unreadCount => emails.length - readEmailIds.length;

  // Read/unread status management
  bool isEmailRead(String emailId) => readEmailIds.contains(emailId);

  /// The full message behind a row, for the paths a summary cannot serve
  /// (reply and forward need the MIME).
  Future<Email?> loadEmail(String id) => _nostrMailService.client.getEmail(id);

  Future<void> markAsRead(String emailId) async {
    await _nostrMailService.markEmailAsRead(emailId);
    readEmailIds.add(emailId);
    notifyListeners();
  }

  Future<void> markAsUnread(String emailId) async {
    await _nostrMailService.markEmailAsUnread(emailId);
    readEmailIds.remove(emailId);
    notifyListeners();
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
    if (searchQuery == query) return;

    searchQuery = query;
    notifyListeners();
    _loadEmails();
  }

  void enterSearchMode() {
    isSearchMode = true;
    notifyListeners();
  }

  void exitSearchMode() {
    isSearchMode = false;
    notifyListeners();
    clearSearch();
  }

  void clearSearch() {
    if (searchQuery.isEmpty) return;

    searchQuery = '';
    notifyListeners();
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
    notifyListeners();
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
    notifyListeners();
  }

  void selectAll() {
    selectedIds
      ..clear()
      ..addAll(emails.map((e) => e.id));
    _selectionAnchorId = null;
    notifyListeners();
  }

  void clearSelection() {
    selectedIds.clear();
    _selectionAnchorId = null;
    notifyListeners();
  }

  Future<void> deleteSelected() async {
    final ids = selectedIds.toList();
    if (currentMailbox.isTrash) {
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
    if (currentMailbox.isTrash) {
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

  /// Applies [verdict] to every sender of [senderKeys] in one event, so a
  /// remote signer asks once for the lot.
  Future<void> setSenderVerdict(
    Iterable<String> senderKeys,
    SenderVerdict verdict,
  ) async {
    final keys = senderKeys.toSet();
    if (keys.isEmpty) return;
    await _nostrMailService.client.setSenderVerdicts({
      for (final key in keys) key: verdict,
    });
    await _loadEmails();
  }

  /// The account's own mail is never routed by a verdict, so it is skipped.
  Future<void> setSelectedSendersVerdict(SenderVerdict verdict) async {
    final me = _nostrMailService.getPublicKey();
    final keys = [
      for (final email in selectedEmails)
        if (email.senderPubkey != me) email.senderKey,
    ];
    clearSelection();
    await setSenderVerdict(keys, verdict);
  }

  Future<void> acceptAllRequests() async {
    final requests = await _nostrMailService.client.getSummaries(
      folder: Mailbox.requests.folderParam,
    );
    await setSenderVerdict(
      requests.items.map((email) => email.senderKey),
      SenderVerdict.allow,
    );
  }

  List<EmailSummary> get selectedEmails =>
      emails.where((e) => selectedIds.contains(e.id)).toList();

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final subscription in _mailboxesSubscriptions) {
      subscription.cancel();
    }
    _notifySubscription?.cancel();
    _reloadSubscription?.cancel();
    hoveredEmailId.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
    switch (state) {
      case AppLifecycleState.paused:
        // App went to background, record the time
        _backgroundTime = DateTime.now();
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
    final backgroundTime = _backgroundTime;
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

    emails = [];
    readEmailIds.clear();
    clearSelection();
    oldEmailsCount = 0;
    isSyncing = false;
    isDeletingPermanently = false;
    isSearchMode = false;
    searchQuery = '';
    _backgroundTime = null;
    if (mailbox != null) currentMailbox = mailbox;
    notifyListeners();
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
      final loaded = await client.getSummaries(search: searchQuery);
      if (generation != _accountGeneration) return;
      oldEmailsCount = 0;
      _applyLoaded(loaded.items);
      return;
    }

    final mailbox = currentMailbox;
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
      oldEmailsCount = count;
    } else {
      oldEmailsCount = 0;
    }
    notifyListeners();
  }

  void _applyLoaded(List<EmailSummary> loaded) {
    emails = loaded;
    readEmailIds
      ..clear()
      ..addAll([
        for (final email in loaded)
          if (email.isRead) email.id,
      ]);
    notifyListeners();
  }

  void setMailbox(Mailbox mailbox) {
    if (currentMailbox != mailbox) {
      currentMailbox = mailbox;
      clearSelection();
      isSearchMode = false;
      searchQuery = ''; // Clear search when switching mailboxes
      notifyListeners();
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
    // A sender verdict moves mail between inbox, requests and spam with no
    // label event at all.
    //
    // Throttled, not debounced: a bulk sync emits continuously for seconds, so
    // waiting for silence would leave the list empty until the very end.
    // leading gives an immediate first paint, trailing the final state.
    _reloadSubscription =
        MergeStream<Object>([client.onEmail, client.onLabel, client.onSender])
            .throttleTime(
              AppConfig.watchReloadThrottle,
              leading: true,
              trailing: true,
            )
            .listen((_) => _loadEmails(), onError: (e) {});
  }

  /// Surface a system notification for a genuinely new incoming email, but only
  /// while the app is not in the foreground, where the inbox already updates.
  /// Spam never notifies, and requests only for the first email of a sender
  /// waiting there (docs/senders-and-spam.md).
  Future<void> _notifyIncomingEmail(Email email) async {
    if (!Get.find<SettingsController>().notificationsEnabled.value) return;
    if (_lifecycleState == AppLifecycleState.resumed) return;

    final startedAt = _watchStartedAt;
    if (startedAt != null && email.createdAt.isBefore(startedAt)) return;

    if (email.senderPubkey == _nostrMailService.getPublicKey()) return;

    final generation = _accountGeneration;
    final client = _nostrMailService.client;
    final folder = (await client.getSummary(email.id))?.folder;
    if (folder == Mailbox.spam.folderParam) return;
    final isRequest = folder == Mailbox.requests.folderParam;
    if (isRequest) {
      final fromSender = await client.getSummaries(
        folder: folder,
        senderKey: email.senderKey,
        limit: 1,
      );
      if (fromSender.total > 1) return;
    }
    if (generation != _accountGeneration) return;

    final from = email.sender;
    final title = (from?.personalName?.trim().isNotEmpty ?? false)
        ? from!.personalName!.trim()
        : (from?.email ?? '');

    _notifications.show(
      id: email.id.hashCode & 0x7fffffff,
      title: title,
      body: email.subject?.trim() ?? '',
      payload: AppRoutes.emailPath(
        isRequest ? Mailbox.requests : Mailbox.inbox,
        email.id,
      ),
    );
  }

  Future<void> sync() async {
    if (isSyncing) return;

    final generation = _accountGeneration;
    isSyncing = true;
    notifyListeners();
    try {
      await _nostrMailService.client.fetchRecent();
      if (generation == _accountGeneration) {
        await _loadEmails();
      }
    } finally {
      if (generation == _accountGeneration) {
        isSyncing = false;
        notifyListeners();
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
    if (currentMailbox.isTrash) {
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
    if (!currentMailbox.isTrash) return 0;

    final client = _nostrMailService.client;
    final thirtyDaysAgo = const Duration(days: 30);
    final oldEmails = await client.getTrashedEmailsOlderThan(thirtyDaysAgo);
    return oldEmails.length;
  }

  /// Delete all emails in trash older than 30 days
  Future<void> deleteOldEmails() async {
    if (!currentMailbox.isTrash) return;

    isDeletingPermanently = true;
    notifyListeners();
    try {
      final client = _nostrMailService.client;
      final thirtyDaysAgo = const Duration(days: 30);
      final oldEmails = await client.getTrashedEmailsOlderThan(thirtyDaysAgo);
      final oldEmailIds = oldEmails.map((email) => email.id).toList();

      if (oldEmailIds.isEmpty) return;

      // Batch delete all old emails
      await client.delete(oldEmailIds);

      // Update old emails count
      oldEmailsCount = await getOldEmailsCount();
      await _loadEmails();
    } finally {
      isDeletingPermanently = false;
      notifyListeners();
    }
  }

  Future<void> emptyTrash() => _deleteAll(Mailbox.trash);

  Future<void> emptySpam() => _deleteAll(Mailbox.spam);

  /// Permanently deletes every email of [mailbox], which must be the one
  /// shown.
  Future<void> _deleteAll(Mailbox mailbox) async {
    if (currentMailbox != mailbox) return;

    isDeletingPermanently = true;
    notifyListeners();
    try {
      final client = _nostrMailService.client;
      final held = await client.getSummaries(folder: mailbox.folderParam);
      await client.delete(held.items.map((email) => email.id));

      clearSelection();
      oldEmailsCount = 0;
      await _loadEmails();
    } finally {
      isDeletingPermanently = false;
      notifyListeners();
    }
  }
}
