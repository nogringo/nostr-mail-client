import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../email_controller.dart';
import 'email_actions.dart';

class MobileActionsBar extends StatelessWidget {
  const MobileActionsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final emailController = Get.find<EmailController>();
    final actions = buildEmailActions(
      l,
      emailController,
      emailController.folder,
    );

    const buttonWidth = 68.0;
    // Always reserve space for delete + more_vert buttons (2 buttons).
    const spaceForFixedButtons = buttonWidth * 2;
    final remainingWidth =
        MediaQuery.sizeOf(context).width - spaceForFixedButtons;
    final maxButtons = ((remainingWidth - 16) / buttonWidth).floor();

    final visibleCount = maxButtons.clamp(0, actions.primary.length);
    final visibleActions = actions.primary.take(visibleCount).toList();
    final overflowActions = actions.primary.skip(visibleCount).toList();

    return BottomAppBar(
      child: Row(
        children: [
          ...visibleActions.map(
            (action) => Expanded(child: _buildButton(action)),
          ),
          Expanded(child: _buildButton(actions.delete)),
          if (overflowActions.isNotEmpty)
            Expanded(child: _MoreButton(actions: overflowActions)),
        ],
      ),
    );
  }

  Widget _buildButton(EmailAction action) {
    return IconButton(
      icon: Icon(action.icon),
      tooltip: action.label,
      onPressed: action.onPressed,
    );
  }
}

class _MoreButton extends StatelessWidget {
  final List<EmailAction> actions;

  const _MoreButton({required this.actions});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return IconButton(
      icon: const Icon(Icons.more_vert),
      tooltip: l.emailMoreOptions,
      onPressed: () => _showBottomSheet(context),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: actions.map((action) {
            return ListTile(
              leading: Icon(action.icon),
              title: Text(action.label),
              onTap: () {
                Navigator.pop(context);
                action.onPressed();
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
