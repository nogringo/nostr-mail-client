import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:nostr_mail/nostr_mail.dart';

import '../../../controllers/inbox_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/run_sender_verdict.dart';
import '../../mailboxes/widgets/show_move_to_picker.dart';
import '../../mailboxes/widgets/show_tags_picker.dart';
import 'delete_permanently_dialog.dart';

/// Adaptive widget that manages selection actions intelligently
/// Shows actions directly if possible, otherwise puts them in a "more_vert" menu
class SelectionActionsBar extends StatelessWidget {
  const SelectionActionsBar({super.key, required this.toolbarWidth});

  /// AppBar gives its actions unbounded width, so the caller measures it.
  final double toolbarWidth;

  /// Determines available actions based on current folder
  List<_ActionItem> _getActions(
    BuildContext context,
    AppLocalizations l,
    InboxController controller,
  ) {
    final mailbox = controller.currentMailbox;
    final canRestore = mailbox.isTrash || mailbox.isArchive;
    final isScreened = mailbox.isRequests || mailbox.isSpam;
    final hasUnread = controller.selectedIds.any(
      (id) => !controller.isEmailRead(id),
    );

    return [
      if (mailbox.isRequests) ...[
        _ActionItem(
          icon: const Icon(Icons.how_to_reg),
          label: l.senderAccept,
          onPressed: () => _judgeSelected(context, SenderVerdict.allow),
          isPrimary: true,
        ),
        _ActionItem(
          icon: const Icon(Icons.block),
          label: l.senderBlock,
          onPressed: () => _judgeSelected(context, SenderVerdict.block),
          isPrimary: true,
        ),
      ] else if (mailbox.isSpam)
        _ActionItem(
          icon: const Icon(Icons.how_to_reg),
          label: l.senderUnblock,
          onPressed: () => _judgeSelected(context, SenderVerdict.allow),
          isPrimary: true,
        )
      else
        _ActionItem(
          icon: Icon(canRestore ? Icons.restore_from_trash : Icons.archive),
          label: canRestore ? l.emailRestore : l.emailArchive,
          onPressed: canRestore
              ? controller.restoreSelected
              : controller.archiveSelected,
          isPrimary: true,
        ),
      _ActionItem(
        icon: const Icon(Icons.delete_outline),
        label: l.actionDelete,
        onPressed: mailbox.isTrash
            ? () => _confirmDeleteSelected(context, l, controller)
            : controller.deleteSelected,
        isPrimary: true,
      ),
      if (mailbox.showsUnread)
        hasUnread
            ? _ActionItem(
                icon: const Icon(Icons.mark_email_read),
                label: l.emailMarkAsRead,
                onPressed: controller.markSelectedAsRead,
                isPrimary: true,
              )
            : _ActionItem(
                icon: const Icon(Icons.mark_email_unread),
                label: l.emailMarkAsUnread,
                onPressed: controller.markSelectedAsUnread,
                isPrimary: true,
              ),
      if (!mailbox.isTrash && !isScreened) ...[
        _ActionItem(
          icon: const Icon(Icons.drive_file_move_outlined),
          label: l.mailboxMoveTo,
          onPressed: () => _moveSelected(context, controller),
          isPrimary: true,
        ),
        _ActionItem(
          icon: const Icon(Icons.label_outline),
          label: l.mailboxTags,
          onPressed: () => _tagSelected(context, controller),
          isPrimary: true,
        ),
      ],
      _ActionItem(
        icon: const Icon(Icons.select_all),
        label: l.inboxSelectAll,
        onPressed: controller.selectAll,
        isPrimary: false,
      ),
      if (!isScreened && !mailbox.isSent)
        _ActionItem(
          icon: const Icon(Icons.block),
          label: l.senderBlock,
          onPressed: () => _judgeSelected(context, SenderVerdict.block),
          isPrimary: false,
        ),
    ];
  }

  Future<void> _moveSelected(
    BuildContext context,
    InboxController controller,
  ) async {
    final folder = await showMoveToPicker(
      context,
      current: controller.currentMailbox,
    );
    if (folder != null) await controller.moveSelectedTo(folder);
  }

  Future<void> _judgeSelected(BuildContext context, SenderVerdict verdict) =>
      runSenderVerdict(
        context,
        () => GetIt.I<InboxController>().setSelectedSendersVerdict(verdict),
      );

  Future<void> _tagSelected(
    BuildContext context,
    InboxController controller,
  ) async {
    final emails = controller.selectedEmails;
    final changes = await showTagsPicker(context, emails: emails);
    if (changes == null) return;
    await controller.applyTags(
      emails,
      add: changes.add,
      remove: changes.remove,
    );
  }

  Future<void> _confirmDeleteSelected(
    BuildContext context,
    AppLocalizations l,
    InboxController controller,
  ) {
    return DeletePermanentlyDialog.confirmAndDelete(
      context,
      title: l.emailDeletePermanentlyTitle,
      message: l.inboxDeleteSelectedMessage(controller.selectedIds.length),
      confirmLabel: l.actionDelete,
      delete: controller.deleteSelected,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = GetIt.I<InboxController>();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final actions = _getActions(context, l, controller);
        final primaryActions = actions.where((a) => a.isPrimary).toList();
        final secondaryActions = actions.where((a) => !a.isPrimary).toList();

        const buttonWidth = kMinInteractiveDimension;
        const reservedWidth =
            kToolbarHeight + NavigationToolbar.kMiddleSpacing + buttonWidth;
        final slots = ((toolbarWidth - reservedWidth) / buttonWidth)
            .floor()
            .clamp(1, actions.length);

        final shownCount = primaryActions.length < slots
            ? primaryActions.length
            : slots - 1;
        final shown = primaryActions.take(shownCount);
        final menu = [...primaryActions.skip(shownCount), ...secondaryActions];

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...shown.map(_buildActionButton),
            if (menu.length == 1)
              _buildActionButton(menu.single)
            else if (menu.isNotEmpty)
              _buildMoreMenu(context, l, menu),
          ],
        );
      },
    );
  }

  Widget _buildActionButton(_ActionItem action) {
    return IconButton(
      icon: action.icon,
      tooltip: action.label,
      onPressed: action.onPressed,
    );
  }

  Widget _buildMoreMenu(
    BuildContext context,
    AppLocalizations l,
    List<_ActionItem> actions,
  ) {
    return MenuAnchor(
      alignmentOffset: const Offset(-8, 0),
      style: MenuStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              width: 2,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
      ),
      builder: (context, menuController, child) {
        return IconButton(
          icon: const Icon(Icons.more_vert),
          tooltip: l.inboxMoreActions,
          onPressed: () {
            if (menuController.isOpen) {
              menuController.close();
            } else {
              menuController.open();
            }
          },
        );
      },
      menuChildren: actions
          .map(
            (action) => MenuItemButton(
              leadingIcon: action.icon,
              onPressed: action.onPressed,
              child: Text(action.label),
            ),
          )
          .toList(),
    );
  }
}

/// Internal class to represent an action
class _ActionItem {
  final Icon icon;
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  _ActionItem({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.isPrimary,
  });
}
