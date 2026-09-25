enum MailFolder { inbox, sent, trash, archive }

enum MailEntryKind { folder, tag }

/// What a mail listing shows: a folder every mailbox has, or a user folder or
/// tag named by its id in the private settings.
sealed class Mailbox {
  const Mailbox();

  static const inbox = SystemMailbox(MailFolder.inbox);
  static const sent = SystemMailbox(MailFolder.sent);
  static const trash = SystemMailbox(MailFolder.trash);
  static const archive = SystemMailbox(MailFolder.archive);

  /// The `folder` argument of `getSummaries` and `watchUnreadCount`.
  String? get folderParam => switch (this) {
    SystemMailbox(:final folder) => folder.name,
    FolderMailbox(:final id) => id,
    TagMailbox() => null,
  };

  /// The `tag` argument of `getSummaries` and `watchUnreadCount`.
  String? get tagParam => switch (this) {
    TagMailbox(:final id) => id,
    _ => null,
  };

  bool get isInbox => this == inbox;
  bool get isTrash => this == trash;
  bool get isArchive => this == archive;

  /// Unread is a state of the email, so an archived one keeps it. Sent mail
  /// and trash are never unread in any useful sense.
  bool get showsUnread => switch (this) {
    SystemMailbox(:final folder) =>
      folder == MailFolder.inbox || folder == MailFolder.archive,
    _ => true,
  };
}

final class SystemMailbox extends Mailbox {
  final MailFolder folder;

  const SystemMailbox(this.folder);

  @override
  bool operator ==(Object other) =>
      other is SystemMailbox && other.folder == folder;

  @override
  int get hashCode => folder.hashCode;
}

final class FolderMailbox extends Mailbox {
  final String id;

  const FolderMailbox(this.id);

  @override
  bool operator ==(Object other) => other is FolderMailbox && other.id == id;

  @override
  int get hashCode => Object.hash(MailEntryKind.folder, id);
}

final class TagMailbox extends Mailbox {
  final String id;

  const TagMailbox(this.id);

  @override
  bool operator ==(Object other) => other is TagMailbox && other.id == id;

  @override
  int get hashCode => Object.hash(MailEntryKind.tag, id);
}
