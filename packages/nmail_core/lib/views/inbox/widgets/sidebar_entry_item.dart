import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/app/routes/app_routes.dart';
import 'package:nmail_core/controllers/mailboxes_controller.dart';
import 'package:nmail_core/models/mailbox.dart';
import '../../mailboxes/widgets/show_mail_entry_menu.dart';
import 'sidebar_folder_item.dart';

/// A user folder or tag in the desktop sidebar.
class SidebarEntryItem extends StatelessWidget {
  final MailEntryKind kind;
  final MailEntry entry;
  final String currentLocation;

  const SidebarEntryItem({
    super.key,
    required this.kind,
    required this.entry,
    required this.currentLocation,
  });

  @override
  Widget build(BuildContext context) {
    final mailboxes = Get.find<MailboxesController>();
    final mailbox = switch (kind) {
      MailEntryKind.folder => FolderMailbox(entry.id),
      MailEntryKind.tag => TagMailbox(entry.id),
    };
    return Obx(
      () => SidebarFolderItem(
        icon: switch (kind) {
          MailEntryKind.folder => Icons.folder_outlined,
          MailEntryKind.tag => Icons.label_outline,
        },
        selectedIcon: switch (kind) {
          MailEntryKind.folder => Icons.folder,
          MailEntryKind.tag => Icons.label,
        },
        iconColor: MailboxesController.colorOf(entry),
        label: entry.name,
        path: AppRoutes.mailboxPath(mailbox),
        currentLocation: currentLocation,
        unreadCount: mailboxes.unread[mailbox],
        onSecondaryTapUp: (details) => showMailEntryMenu(
          context,
          kind: kind,
          entry: entry,
          position: details.globalPosition,
        ),
        onLongPress: () => showMailEntryMenu(context, kind: kind, entry: entry),
      ),
    );
  }
}
