import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../controllers/auth_controller.dart';
import 'package:nmail_core/controllers/mailboxes_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/mailbox.dart';
import 'package:nmail_core/utils/metadata_extensions.dart';
import '../../../widgets/nostr_avatar.dart';
import '../../mailboxes/widgets/show_mail_entry_form.dart';
import '../../shared/layout_constants.dart';
import 'account_email_copy_button.dart';
import 'sidebar_entry_item.dart';
import 'sidebar_folder_item.dart';
import 'sidebar_section_header.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Widget _buildAvatar(BuildContext context) {
    final authController = Get.find<AuthController>();
    final pubkey = authController.currentPubkey!;
    return NostrAvatar(
      pubkey: pubkey,
      metadata: authController.userMetadata.value,
      radius: 28,
    );
  }

  String _displayName() {
    final authController = Get.find<AuthController>();
    final metadata = authController.userMetadata.value;
    final pubkey = authController.currentPubkey!;

    return metadata?.getBestName() ?? getAnonName(pubkey);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final loc = GoRouterState.of(context).matchedLocation;
    final mailboxes = Get.find<MailboxesController>();

    return Drawer(
      child: Obx(
        () => ListView(
          padding: EdgeInsets.zero,
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  LayoutConstants.navigationInset,
                  16,
                  LayoutConstants.navigationInset,
                  8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => Row(
                        children: [
                          Semantics(
                            label: l.inboxEditProfile,
                            button: true,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                context.go(AppRoutes.profile);
                              },
                              child: Stack(
                                children: [
                                  _buildAvatar(context),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: colorScheme.surface,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: colorScheme.surface,
                                          width: 1,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.edit,
                                        size: 12,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _displayName(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                AccountEmailCopyButton(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          context.push(AppRoutes.compose);
                        },
                        icon: const Icon(Icons.edit),
                        label: Text(l.inboxCompose),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: LayoutConstants.navigationInset,
              ),
              child: Divider(),
            ),
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
              onAdd: () => showMailEntryForm(context, kind: MailEntryKind.tag),
            ),
            for (final tag in mailboxes.tags)
              SidebarEntryItem(
                key: ValueKey(tag.id),
                kind: MailEntryKind.tag,
                entry: tag,
                currentLocation: loc,
              ),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: LayoutConstants.navigationInset,
              ),
              child: Divider(),
            ),
            SidebarFolderItem(
              icon: Icons.contacts_outlined,
              selectedIcon: Icons.contacts,
              label: l.contactsTitle,
              path: AppRoutes.contacts,
              currentLocation: loc,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: LayoutConstants.navigationInset,
              ),
              child: ListTile(
                leading: const Icon(Icons.settings),
                title: Text(l.inboxSettings),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.go(AppRoutes.settings);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: LayoutConstants.navigationInset,
              ),
              child: ListTile(
                leading: Icon(Icons.logout, color: colorScheme.error),
                title: Text(
                  l.inboxLogout,
                  style: TextStyle(color: colorScheme.error),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                onTap: () {
                  Get.find<AuthController>().logout();
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
