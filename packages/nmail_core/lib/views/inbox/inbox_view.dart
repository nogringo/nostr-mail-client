import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_mail/nostr_mail.dart';

import '../../app/routes/app_routes.dart';
import '../../controllers/inbox_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/compose_mode.dart';
import 'package:nmail_core/models/mailbox.dart';
import 'package:nmail_core/utils/mailbox_title.dart';
import 'package:nmail_core/utils/toast_helper.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import '../shared/app_bar_account_avatar.dart';
import '../mailboxes/widgets/show_move_to_picker.dart';
import '../mailboxes/widgets/show_tags_picker.dart';
import '../shared/layout_constants.dart';
import 'widgets/app_drawer.dart';
import 'widgets/email_tile.dart';
import 'widgets/inbox_desktop_app_bar.dart';
import 'widgets/search_field.dart';
import 'widgets/selection_actions_bar.dart';
import 'widgets/trash_banner.dart';

class InboxView extends GetView<InboxController> {
  /// Mailbox this route represents (driven by the URL: `/inbox`, `/sent`,
  /// `/folder/<id>`, ...). Synced to `InboxController.currentMailbox` on build
  /// so the rest of the view (toolbar title, email list source, action
  /// behaviors) stays driven by the controller.
  final Mailbox mailbox;

  const InboxView({super.key, required this.mailbox});

  Widget _buildEmailList(BuildContext context, {double bottomPadding = 0}) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(() {
      if (controller.emails.isEmpty) {
        final (icon, message) = switch (controller.currentMailbox.value) {
          SystemMailbox(folder: MailFolder.inbox) => (
            Icons.inbox,
            l.inboxEmptyInbox,
          ),
          SystemMailbox(folder: MailFolder.sent) => (
            Icons.send,
            l.inboxEmptySent,
          ),
          SystemMailbox(folder: MailFolder.trash) => (
            Icons.delete_outline,
            l.inboxEmptyTrash,
          ),
          SystemMailbox(folder: MailFolder.archive) => (
            Icons.archive_outlined,
            l.inboxEmptyArchive,
          ),
          FolderMailbox() => (Icons.folder_outlined, l.mailboxEmptyFolder),
          TagMailbox() => (Icons.label_outline, l.mailboxEmptyTag),
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
          const TrashBanner(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.sync,
              child: GetBuilder<InboxController>(
                builder: (controller) => ListView.builder(
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  itemCount: controller.emails.length,
                  itemBuilder: (context, index) {
                    final email = controller.emails[index];
                    return Obx(
                      () => EmailTile(
                        key: ValueKey(email.id),
                        email: email,
                        onTap: () =>
                            context.go(AppRoutes.emailPath(mailbox, email.id)),
                        isSelected: controller.isSelected(email.id),
                        onToggleSelect: () =>
                            controller.toggleSelection(email.id),
                        onExtendSelect: () =>
                            controller.extendSelectionTo(email.id),
                        onReply: () => _replyTo(context, email),
                        onForward: () => _forward(context, email),
                        onDelete: () => _deleteEmail(context, email),
                        onArchive: () => _archiveEmail(context, email),
                        onRestore: () => _restoreEmail(context, email),
                        onMoveTo: () => _moveEmail(context, email),
                        onTag: () => _tagEmail(context, email),
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

    // Sync URL-driven mailbox to the shared controller after build settles.
    // Skipping when already aligned avoids redundant notifications.
    if (controller.currentMailbox.value != mailbox) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.setMailbox(mailbox);
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
                return Text(controller.currentMailbox.value.title(l));
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
              // AppBar only centers a leading that is itself an IconButton,
              // so a wrapped one needs its own Center or it fills the 56px slot.
              return Builder(
                builder: (context) => Center(
                  child: IconButton(
                    icon: const Icon(Icons.menu),
                    tooltip: l.inboxMenu,
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              );
            }(),
            actionsPadding: .only(right: 8),
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
                    const AppBarAccountAvatar(),
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
          Expanded(
            child: _buildEmailList(
              context,
              bottomPadding: LayoutConstants.fabClearance,
            ),
          ),
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

  Future<void> _moveEmail(BuildContext context, EmailSummary email) async {
    final folder = await showMoveToPicker(
      context,
      current: controller.currentMailbox.value,
    );
    if (folder != null) await controller.moveTo([email.id], folder);
  }

  Future<void> _tagEmail(BuildContext context, EmailSummary email) async {
    final changes = await showTagsPicker(context, emails: [email]);
    if (changes == null) return;
    await controller.applyTags(
      [email],
      add: changes.add,
      remove: changes.remove,
    );
  }

  void _restoreEmail(BuildContext context, EmailSummary email) {
    if (controller.currentMailbox.value.isArchive) {
      controller.restoreFromArchive(email.id);
    } else {
      controller.restoreFromTrash(email.id);
    }
  }
}
