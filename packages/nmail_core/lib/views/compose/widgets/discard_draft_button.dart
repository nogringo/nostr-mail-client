import 'package:flutter/material.dart';
import 'package:nmail_core/controllers/compose_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/views/compose/widgets/discard_draft_dialog.dart';

class DiscardDraftButton extends StatelessWidget {
  const DiscardDraftButton({super.key, required this.controller});

  final ComposeController controller;

  Future<void> _discard(BuildContext context) async {
    if (controller.hasDraft) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => const DiscardDraftDialog(),
      );
      if (confirmed != true || !context.mounted) return;
    }
    controller.discard();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _discard(context),
      icon: const Icon(Icons.delete_outline),
      tooltip: AppLocalizations.of(context).composeDiscardDraft,
    );
  }
}
