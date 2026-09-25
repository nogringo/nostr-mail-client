import 'dart:async';
import 'dart:convert';
import 'dart:ui' show Color;

import 'package:get/get.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/models/mailbox.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/utils/string_color.dart';
import 'auth_controller.dart';

/// The user folders and tags of the active account, as its private settings
/// name them, and the unread count of each mailbox the sidebar lists.
class MailboxesController extends GetxController {
  final _nostrMailService = Get.find<NostrMailService>();
  final _auth = Get.find<AuthController>();

  final RxList<MailEntry> folders = <MailEntry>[].obs;
  final RxList<MailEntry> tags = <MailEntry>[].obs;
  final RxMap<Mailbox, int> unread = <Mailbox, int>{}.obs;

  final List<StreamSubscription<int>> _unreadSubscriptions = [];
  Worker? _accountWorker;
  String? _appliedKey;

  NostrMailClient get _client => _nostrMailService.client;

  @override
  void onInit() {
    super.onInit();
    applyCached();
    _accountWorker = ever(_auth.activePubkey, (_) => applyCached());
  }

  @override
  void onClose() {
    _accountWorker?.dispose();
    _cancelUnread();
    super.onClose();
  }

  /// Reads the entries from the private-settings cache of the active account.
  /// `SettingsController.reloadSyncedSettings` calls it again once the relays
  /// answered, which is how an edit made on another device lands here.
  void applyCached() {
    final settings = _nostrMailService.hasAccount
        ? _client.cachedPrivateSettings()
        : null;
    final nextFolders = sortEntries(settings?.folders ?? const []);
    final nextTags = sortEntries(settings?.tags ?? const []);

    final key = jsonEncode([
      _auth.publicKey,
      [for (final entry in nextFolders) entry.toJson()],
      [for (final entry in nextTags) entry.toJson()],
    ]);
    if (key == _appliedKey) return;
    _appliedKey = key;

    folders.assignAll(nextFolders);
    tags.assignAll(nextTags);
    _watchUnread();
  }

  RxList<MailEntry> entriesOf(MailEntryKind kind) => switch (kind) {
    MailEntryKind.folder => folders,
    MailEntryKind.tag => tags,
  };

  MailEntry? folderById(String id) =>
      folders.firstWhereOrNull((entry) => entry.id == id);

  MailEntry? tagById(String id) =>
      tags.firstWhereOrNull((entry) => entry.id == id);

  /// The entry's own color, else the one the spec derives from its id.
  static Color colorOf(MailEntry entry) =>
      parseEntryColor(entry.color) ?? getStringColor(entry.id);

  static Color? parseEntryColor(String? hex) {
    if (hex == null || hex.length != 7) return null;
    final value = int.tryParse(hex.substring(1), radix: 16);
    return value == null ? null : Color(0xFF000000 | value);
  }

  Future<MailEntry> create(
    MailEntryKind kind,
    String name, {
    String? color,
    MailMatch? match,
  }) async {
    final entry = switch (kind) {
      MailEntryKind.folder => await _client.createFolder(
        name,
        color: color,
        match: match,
      ),
      MailEntryKind.tag => await _client.createTag(
        name,
        color: color,
        match: match,
      ),
    };
    applyCached();
    return entry;
  }

  Future<MailEntry> edit(
    MailEntryKind kind,
    String id, {
    required String name,
    required String? color,
    required MailMatch? match,
  }) async {
    final entry = switch (kind) {
      MailEntryKind.folder => await _client.updateFolder(
        id,
        name: name,
        color: color,
        match: match,
        clearColor: color == null,
        clearMatch: match == null,
      ),
      MailEntryKind.tag => await _client.updateTag(
        id,
        name: name,
        color: color,
        match: match,
        clearColor: color == null,
        clearMatch: match == null,
      ),
    };
    applyCached();
    return entry;
  }

  /// Publishes the new order in one settings event, not one per moved entry.
  Future<void> reorder(MailEntryKind kind, int oldIndex, int newIndex) async {
    final list = entriesOf(kind);
    final entries = [...list];
    entries.insert(newIndex, entries.removeAt(oldIndex));
    final positioned = [
      for (final (index, entry) in entries.indexed)
        entry.copyWith(position: index),
    ];
    list.assignAll(positioned);
    try {
      await switch (kind) {
        MailEntryKind.folder => _client.updatePrivateSettings(
          folders: positioned,
        ),
        MailEntryKind.tag => _client.updatePrivateSettings(tags: positioned),
      };
    } finally {
      _appliedKey = null;
      applyCached();
    }
  }

  /// Emails a deletion affects: those the entry holds, outside trash and spam.
  Future<int> countHeld(MailEntryKind kind, String id) async {
    final held = await _heldBy(kind, id);
    return held.total;
  }

  /// Takes the entry's labels off the emails first: a folder label naming no
  /// entry would leave its emails in no mailbox the sidebar lists.
  Future<void> delete(MailEntryKind kind, String id) async {
    final held = await _heldBy(kind, id);
    switch (kind) {
      case MailEntryKind.folder:
        await Future.wait([
          for (final email in held.items) _removeFolderLabel(email.id, id),
        ]);
        await _client.deleteFolder(id);
      case MailEntryKind.tag:
        await Future.wait([
          for (final email in held.items)
            if (email.labels.contains('tag:$id'))
              _client.removeTag(email.id, id),
        ]);
        await _client.deleteTag(id);
    }
    applyCached();
  }

  Future<PaginatedResult<EmailSummary>> _heldBy(
    MailEntryKind kind,
    String id,
  ) => switch (kind) {
    MailEntryKind.folder => _client.getSummaries(folder: id),
    MailEntryKind.tag => _client.getSummaries(tag: id),
  };

  /// An email the folder holds by its match condition carries no label, and
  /// falls back to its natural mailbox once the folder is gone.
  Future<void> _removeFolderLabel(String emailId, String folderId) async {
    final label = 'folder:$folderId';
    if ((await _client.getLabels(emailId)).contains(label)) {
      await _client.removeLabel(emailId, label);
    }
  }

  void _watchUnread() {
    _cancelUnread();
    unread.clear();
    if (!_nostrMailService.hasAccount) return;

    final mailboxes = <Mailbox>[
      Mailbox.inbox,
      for (final entry in folders) FolderMailbox(entry.id),
      for (final entry in tags) TagMailbox(entry.id),
    ];
    for (final mailbox in mailboxes) {
      _unreadSubscriptions.add(
        _client
            .watchUnreadCount(
              folder: mailbox.folderParam,
              tag: mailbox.tagParam,
            )
            .listen((count) => unread[mailbox] = count, onError: (_) {}),
      );
    }
  }

  void _cancelUnread() {
    for (final subscription in _unreadSubscriptions) {
      subscription.cancel();
    }
    _unreadSubscriptions.clear();
  }
}
