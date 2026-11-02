import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../controllers/drafts_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/toast_helper.dart';
import 'draft_tile.dart';

class DraftsList extends StatelessWidget {
  final double bottomPadding;

  const DraftsList({super.key, this.bottomPadding = 0});

  DraftsController get controller => GetIt.I<DraftsController>();

  Future<void> _delete(BuildContext context, String draftId) async {
    try {
      await controller.delete(draftId);
    } catch (e) {
      if (context.mounted) {
        final l = AppLocalizations.of(context);
        ToastHelper.error(
          context,
          l.draftsDeleteFailed,
          description: e.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.isLoading && controller.drafts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.drafts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.insert_drive_file_outlined,
                  size: 64,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  l.draftsEmpty,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.only(bottom: bottomPadding),
          itemCount: controller.drafts.length,
          itemBuilder: (context, index) {
            final draft = controller.drafts[index];
            return DraftTile(
              key: ValueKey(draft.draftId),
              draft: draft,
              isSelected: controller.isSelected(draft.draftId),
              selectionMode: controller.hasSelection,
              onToggleSelect: () => controller.toggleSelection(draft.draftId),
              onExtendSelect: () => controller.extendSelectionTo(draft.draftId),
              onDelete: () => _delete(context, draft.draftId),
              onOpen: () =>
                  context.push(AppRoutes.compose, extra: {'draft': draft}),
            );
          },
        );
      },
    );
  }
}
