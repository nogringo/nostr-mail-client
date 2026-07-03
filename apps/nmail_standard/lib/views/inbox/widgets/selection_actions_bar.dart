import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/inbox_controller.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Adaptive widget that manages selection actions intelligently
/// Shows actions directly if possible, otherwise puts them in a "more_vert" menu
class SelectionActionsBar extends StatelessWidget {
  const SelectionActionsBar({super.key});

  /// Determines available actions based on current folder
  List<_ActionItem> _getActions(
    AppLocalizations l,
    InboxController controller,
  ) {
    final actions = <_ActionItem>[
      _ActionItem(
        icon: const Icon(Icons.select_all),
        label: l.inboxSelectAll,
        onPressed: controller.selectAll,
        isPrimary: true,
      ),
    ];

    // Add mark as read/unread actions only for inbox folder
    if (controller.currentFolder.value == MailFolder.inbox) {
      actions.addAll([
        _ActionItem(
          icon: const Icon(Icons.mark_email_read),
          label: l.emailMarkAsRead,
          onPressed: controller.markSelectedAsRead,
          isPrimary: true,
        ),
        _ActionItem(
          icon: const Icon(Icons.mark_email_unread),
          label: l.emailMarkAsUnread,
          onPressed: controller.markSelectedAsUnread,
          isPrimary: true,
        ),
      ]);
    }

    actions.addAll([
      _ActionItem(
        icon: Icon(
          controller.currentFolder.value == MailFolder.trash ||
                  controller.currentFolder.value == MailFolder.archive
              ? Icons.restore_from_trash
              : Icons.archive,
        ),
        label:
            controller.currentFolder.value == MailFolder.trash ||
                controller.currentFolder.value == MailFolder.archive
            ? l.emailRestore
            : l.emailArchive,
        onPressed:
            controller.currentFolder.value == MailFolder.trash ||
                controller.currentFolder.value == MailFolder.archive
            ? controller.restoreSelected
            : controller.archiveSelected,
        isPrimary: true,
      ),
      _ActionItem(
        icon: const Icon(Icons.delete_outline),
        label: l.actionDelete,
        onPressed: controller.deleteSelected,
        isPrimary: true,
      ),
    ]);

    return actions;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = Get.find<InboxController>();
    final actions = _getActions(l, controller);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final primaryActions = actions.where((a) => a.isPrimary).toList();
        final secondaryActions = actions.where((a) => !a.isPrimary).toList();

        // Calculate required space for primary actions
        const iconButtonWidth = 56.0; // 48px + 8px margin
        final primaryActionsWidth = primaryActions.length * iconButtonWidth;

        // Determine if we can show all primary actions
        final canShowAllPrimary = primaryActionsWidth <= availableWidth;

        // If we can show all primary actions
        if (canShowAllPrimary) {
          // If no secondary actions, return just the buttons
          if (secondaryActions.isEmpty) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: primaryActions
                  .map((action) => _buildActionButton(action))
                  .toList(),
            );
          }

          // If there are secondary actions, show menu with only those
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...primaryActions.map((action) => _buildActionButton(action)),
              _buildMoreMenu(l, secondaryActions),
            ],
          );
        }

        // Otherwise, move some primary actions to the menu
        final overflowActions = <_ActionItem>[];
        final displayActions = <_ActionItem>[];

        for (final action in primaryActions) {
          if (displayActions.length * iconButtonWidth <= availableWidth) {
            displayActions.add(action);
          } else {
            overflowActions.add(action);
          }
        }

        // If the menu will have less than 2 items, don't show more_vert
        if (overflowActions.length + secondaryActions.length < 2) {
          final allActions = [
            ...displayActions,
            ...overflowActions,
            ...secondaryActions,
          ];
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: allActions
                .map((action) => _buildActionButton(action))
                .toList(),
          );
        }

        // Otherwise show buttons + menu
        final menuActions = [...overflowActions, ...secondaryActions];
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...displayActions.map((action) => _buildActionButton(action)),
            _buildMoreMenu(l, menuActions),
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

  Widget _buildMoreMenu(AppLocalizations l, List<_ActionItem> actions) {
    return MenuAnchor(
      alignmentOffset: const Offset(-8, 0),
      style: MenuStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              width: 2,
              color: Theme.of(Get.context!).colorScheme.outlineVariant,
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
