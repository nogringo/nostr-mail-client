import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../controllers/drafts_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/toast_helper.dart';

/// Actions shown in the toolbar while drafts are selected, mirroring
/// [SelectionActionsBar]. The only bulk action is deleting them.
class DraftsSelectionActionsBar extends StatelessWidget {
  const DraftsSelectionActionsBar({super.key});

  Future<void> _deleteSelected(BuildContext context) async {
    try {
      await GetIt.I<DraftsController>().deleteSelected();
    } catch (e) {
      if (context.mounted) {
        ToastHelper.error(
          context,
          AppLocalizations.of(context).draftsDeleteFailed,
          description: e.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final controller = GetIt.I<DraftsController>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.select_all),
          tooltip: l.inboxSelectAll,
          onPressed: controller.selectAll,
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: l.actionDelete,
          color: colorScheme.error,
          onPressed: () => _deleteSelected(context),
        ),
      ],
    );
  }
}
