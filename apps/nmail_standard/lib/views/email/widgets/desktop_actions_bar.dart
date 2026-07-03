import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../email_controller.dart';
import 'email_actions.dart';

class DesktopActionsBar extends StatelessWidget {
  const DesktopActionsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final emailController = Get.find<EmailController>();
    final actions = buildEmailActions(
      l,
      emailController,
      emailController.folder,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Conservative estimates: longest labels (e.g. "NIP-59 Events",
        // "Download email") render around ~150px with icon + padding.
        const buttonWidth = 150.0;
        const deleteButtonWidth = 110.0;
        const moreButtonWidth = 48.0;

        // Always reserve space for delete + more button so we never overflow.
        final reservedSpace = deleteButtonWidth + moreButtonWidth;
        final availableWidth = constraints.maxWidth - reservedSpace;

        final maxButtons = (availableWidth / buttonWidth).floor();
        final visibleCount = maxButtons.clamp(0, actions.primary.length);

        final visibleActions = actions.primary.take(visibleCount).toList();
        final overflowActions = actions.primary.skip(visibleCount).toList();

        return Row(
          children: [
            ...visibleActions.map(_buildButton),
            const Spacer(),
            _buildButton(actions.delete),
            if (overflowActions.isNotEmpty)
              _MoreButton(actions: overflowActions),
          ],
        );
      },
    );
  }

  Widget _buildButton(EmailAction action) {
    return TextButton.icon(
      onPressed: action.onPressed,
      icon: Icon(action.icon, size: 20),
      label: Text(action.label),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

class _MoreButton extends StatelessWidget {
  final List<EmailAction> actions;

  const _MoreButton({required this.actions});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return MenuAnchor(
      alignmentOffset: const Offset(-110, 4),
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
          tooltip: l.emailMoreActions,
          onPressed: () {
            if (menuController.isOpen) {
              menuController.close();
            } else {
              menuController.open();
            }
          },
        );
      },
      menuChildren: actions.map((action) {
        return MenuItemButton(
          leadingIcon: Icon(action.icon, size: 20),
          onPressed: action.onPressed,
          child: Text(action.label),
        );
      }).toList(),
    );
  }
}
