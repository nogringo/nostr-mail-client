import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/app/routes/app_routes.dart';
import 'package:nmail_core/models/mailbox.dart';

void main() {
  const folderId = '9f2c1a7b4d3e5f60';
  const tagId = '4b81d0e7a5c39f12';

  group('Mailbox', () {
    test('maps each mailbox to the arguments of getSummaries', () {
      expect(Mailbox.inbox.folderParam, 'inbox');
      expect(Mailbox.trash.folderParam, 'trash');
      expect(Mailbox.inbox.tagParam, isNull);
      expect(const FolderMailbox(folderId).folderParam, folderId);
      expect(const FolderMailbox(folderId).tagParam, isNull);
      expect(const TagMailbox(tagId).folderParam, isNull);
      expect(const TagMailbox(tagId).tagParam, tagId);
    });

    test('compares by value, a folder never equal to a tag of the same id', () {
      expect(const FolderMailbox(folderId), FolderMailbox(folderId));
      expect(SystemMailbox(MailFolder.archive), Mailbox.archive);
      expect(const FolderMailbox(folderId), isNot(TagMailbox(folderId)));
    });

    test('shows unread outside sent and trash', () {
      expect(Mailbox.inbox.showsUnread, isTrue);
      expect(Mailbox.archive.showsUnread, isTrue);
      expect(const FolderMailbox(folderId).showsUnread, isTrue);
      expect(const TagMailbox(tagId).showsUnread, isTrue);
      expect(Mailbox.sent.showsUnread, isFalse);
      expect(Mailbox.trash.showsUnread, isFalse);
    });

    test('has a deep-linkable path, with the email nested under it', () {
      expect(AppRoutes.mailboxPath(Mailbox.sent), '/sent');
      expect(
        AppRoutes.mailboxPath(const FolderMailbox(folderId)),
        '/folder/$folderId',
      );
      expect(
        AppRoutes.emailPath(const TagMailbox(tagId), 'abc'),
        '/label/$tagId/email/abc',
      );
    });
  });
}
