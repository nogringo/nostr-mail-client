import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import 'package:nmail_core/controllers/mailboxes_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/mailbox.dart';
import '../../mailboxes/widgets/show_mail_entry_form.dart';
import '../../shared/layout_constants.dart';
import 'sidebar_entry_item.dart';
import 'sidebar_folder_item.dart';
import 'sidebar_section_header.dart';

/// Desktop sidebar. Folder selection is URL-driven: tapping a folder calls
/// `context.go(<folder-path>)` and the `selected` state is derived from
/// the current matched location. The InboxController stays alive across
/// folder switches because it lives in the ShellRoute scope.
class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final loc = GoRouterState.of(context).matchedLocation;
    final mailboxes = Get.find<MailboxesController>();

    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: LayoutConstants.navigationInset,
              vertical: 12,
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.push(AppRoutes.compose),
                icon: const Icon(Icons.edit),
                label: Text(l.inboxCompose),
              ),
            ),
          ),
          Expanded(
            child: Obx(
              () => ListView(
                padding: const EdgeInsets.only(bottom: 12),
                children: [
                  SidebarFolderItem(
                    icon: Icons.inbox_outlined,
                    selectedIcon: Icons.inbox,
                    label: l.folderInbox,
                    path: AppRoutes.inbox,
                    currentLocation: loc,
                    unreadCount: mailboxes.unread[Mailbox.inbox],
                  ),
                  SidebarFolderItem(
                    icon: Icons.send_outlined,
                    selectedIcon: Icons.send,
                    label: l.folderSent,
                    path: AppRoutes.sent,
                    currentLocation: loc,
                  ),
                  SidebarFolderItem(
                    icon: Icons.schedule_outlined,
                    selectedIcon: Icons.schedule,
                    label: l.folderScheduled,
                    path: AppRoutes.scheduled,
                    currentLocation: loc,
                  ),
                  SidebarFolderItem(
                    icon: Icons.archive_outlined,
                    selectedIcon: Icons.archive,
                    label: l.folderArchive,
                    path: AppRoutes.archive,
                    currentLocation: loc,
                  ),
                  SidebarFolderItem(
                    icon: Icons.delete_outlined,
                    selectedIcon: Icons.delete,
                    label: l.folderTrash,
                    path: AppRoutes.trash,
                    currentLocation: loc,
                  ),
                  SidebarSectionHeader(
                    title: l.mailboxFolders,
                    addLabel: l.mailboxNewFolder,
                    onAdd: () =>
                        showMailEntryForm(context, kind: MailEntryKind.folder),
                  ),
                  for (final folder in mailboxes.folders)
                    SidebarEntryItem(
                      key: ValueKey(folder.id),
                      kind: MailEntryKind.folder,
                      entry: folder,
                      currentLocation: loc,
                    ),
                  SidebarSectionHeader(
                    title: l.mailboxTags,
                    addLabel: l.mailboxNewTag,
                    onAdd: () =>
                        showMailEntryForm(context, kind: MailEntryKind.tag),
                  ),
                  for (final tag in mailboxes.tags)
                    SidebarEntryItem(
                      key: ValueKey(tag.id),
                      kind: MailEntryKind.tag,
                      entry: tag,
                      currentLocation: loc,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
