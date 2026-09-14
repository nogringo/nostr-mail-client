import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_mail/nostr_mail.dart';

import '../../app/routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/inbox_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/compose_mode.dart';
import 'package:nmail_core/utils/mail_folder_extensions.dart';
import 'package:nmail_core/utils/toast_helper.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import '../../widgets/nostr_avatar.dart';
import '../shared/account_menu.dart';
import 'widgets/app_drawer.dart';
import 'widgets/email_tile.dart';
import 'widgets/inbox_desktop_app_bar.dart';
import 'widgets/old_emails_banner.dart';
import 'widgets/search_field.dart';
import 'widgets/selection_actions_bar.dart';

class InboxView extends GetView<InboxController> {
  /// Folder this route represents (driven by the URL: /inbox, /sent, ...).
  /// Synced to `InboxController.currentFolder` on build so the rest of the
  /// view (toolbar title, email list source, action behaviors) stays
  /// driven by the controller.
  final MailFolder folder;

  const InboxView({super.key, required this.folder});

  Widget _buildEmailList(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(() {
      if (controller.emails.isEmpty) {
        final (icon, message) = switch (controller.currentFolder.value) {
          MailFolder.inbox => (Icons.inbox, l.inboxEmptyInbox),
          MailFolder.sent => (Icons.send, l.inboxEmptySent),
          MailFolder.trash => (Icons.delete_outline, l.inboxEmptyTrash),
          MailFolder.archive => (Icons.archive_outlined, l.inboxEmptyArchive),
        };
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: colorScheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  fontSize: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: controller.sync,
                child: Text(l.inboxSyncFromRelays),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          OldEmailsBanner(onDelete: () => _confirmDeleteOldEmails(context)),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.sync,
              child: GetBuilder<InboxController>(
                builder: (controller) => ListView.builder(
                  itemCount: controller.emails.length,
                  itemBuilder: (context, index) {
                    final email = controller.emails[index];
                    return Obx(
                      () => EmailTile(
                        key: ValueKey(email.id),
                        email: email,
                        onTap: () =>
                            context.go(AppRoutes.emailPath(folder, email.id)),
                        isSelected: controller.isSelected(email.id),
                        onToggleSelect: () =>
                            controller.toggleSelection(email.id),
                        onReply: () => _replyTo(context, email),
                        onForward: () => _forward(context, email),
                        onDelete: () => _deleteEmail(context, email),
                        onArchive: () => _archiveEmail(context, email),
                        onRestore: () => _restoreEmail(context, email),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isWide = ResponsiveHelper.isNotMobile(context);
    final colorScheme = Theme.of(context).colorScheme;

    // Sync URL-driven folder to the shared controller after build settles.
    // Skipping when already aligned avoids redundant notifications.
    if (controller.currentFolder.value != folder) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.setFolder(folder);
      });
    }

    if (isWide) {
      // Desktop: 3-column layout (DesktopShell is provided by AuthShell)
      return Column(
        children: [
          const InboxDesktopAppBar(),
          Expanded(child: _buildEmailList(context)),
        ],
      );
    }

    // Mobile: Traditional scaffold with AppBar and drawer
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() {
          final isSearching =
              controller.isSearchMode.value && !controller.hasSelection;
          return AppBar(
            scrolledUnderElevation: 0,
            backgroundColor: colorScheme.surface,
            automaticallyImplyLeading: false,
            titleSpacing: isSearching ? 8 : null,
            title: Builder(
              builder: (context) {
                if (controller.hasSelection) {
                  return Text('${controller.selectedIds.length}');
                }
                if (controller.isSearchMode.value) {
                  return SearchField();
                }
                return Text(controller.currentFolder.value.title(l));
              },
            ),
            leading: () {
              if (isSearching) {
                return null;
              }
              if (controller.hasSelection) {
                return IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: l.inboxClearSelection,
                  onPressed: controller.clearSelection,
                );
              }
              return Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  tooltip: l.inboxMenu,
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              );
            }(),
            actionsPadding: const EdgeInsets.only(right: 8),
            actions: [
              if (controller.isSearchMode.value)
                const SizedBox.shrink()
              else if (controller.hasSelection)
                const SelectionActionsBar()
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      tooltip: l.inboxSearch,
                      onPressed: () => controller.enterSearchMode(),
                    ),
                    const SizedBox(width: 8),
                    AccountMenu(
                      alignmentOffset: const Offset(-204, 8),
                      builder: (context, menuController, child) {
                        return Semantics(
                          label: l.inboxAccount,
                          button: true,
                          child: GestureDetector(
                            onTap: () {
                              if (menuController.isOpen) {
                                menuController.close();
                              } else {
                                menuController.open();
                              }
                            },
                            child: Obx(() {
                              final authController = Get.find<AuthController>();
                              final pubkey = authController.currentPubkey!;
                              return NostrAvatar(
                                pubkey: pubkey,
                                metadata: authController.userMetadata.value,
                                radius: 18,
                              );
                            }),
                          ),
                        );
                      },
                    ),
                  ],
                ),
            ],
          );
        }),
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.compose),
        tooltip: l.inboxCompose,
        child: const Icon(Icons.edit),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 4,
            child: Obx(
              () => controller.isSyncing.value
                  ? const LinearProgressIndicator()
                  : const SizedBox.shrink(),
            ),
          ),
          Expanded(child: _buildEmailList(context)),
        ],
      ),
    );
  }

  Future<void> _replyTo(BuildContext context, EmailSummary email) =>
      _composeFrom(context, email, ComposeMode.reply);

  Future<void> _forward(BuildContext context, EmailSummary email) =>
      _composeFrom(context, email, ComposeMode.forward);

  /// A row carries a summary, but the composer needs the MIME to quote or
  /// forward, so load the message before opening it.
  Future<void> _composeFrom(
    BuildContext context,
    EmailSummary summary,
    ComposeMode mode,
  ) async {
    final l = AppLocalizations.of(context);
    final email = await controller.loadEmail(summary.id);
    if (!context.mounted) return;
    if (email == null) {
      ToastHelper.error(context, l.emailNotFound);
      return;
    }
    context.push(AppRoutes.compose, extra: {'email': email, 'mode': mode});
  }

  void _deleteEmail(BuildContext context, EmailSummary email) {
    controller.deleteEmail(email.id);
  }

  void _archiveEmail(BuildContext context, EmailSummary email) {
    controller.moveToArchive(email.id);
  }

  void _restoreEmail(BuildContext context, EmailSummary email) {
    if (controller.currentFolder.value == MailFolder.archive) {
      controller.restoreFromArchive(email.id);
    } else {
      controller.restoreFromTrash(email.id);
    }
  }

  void _confirmDeleteOldEmails(BuildContext context) {
    final l = AppLocalizations.of(context);
    final oldCount = controller.oldEmailsCount.value;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.inboxDeleteOldEmailsTitle),
        content: Text(l.inboxDeleteOldEmailsMessage(oldCount)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l.actionCancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              try {
                await controller.deleteOldEmails();
              } catch (e) {
                if (context.mounted) {
                  ToastHelper.error(
                    context,
                    l.inboxDeleteFailed,
                    description: l.inboxDeleteFailedDescription(e.toString()),
                  );
                }
              }
            },
            child: Text(
              l.actionDelete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
