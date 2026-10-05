import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../controllers/inbox_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/mailbox_title.dart';
import 'search_field.dart';
import 'selection_actions_bar.dart';

class InboxDesktopAppBar extends StatelessWidget {
  const InboxDesktopAppBar({super.key});

  InboxController get controller => GetIt.I<InboxController>();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final hasSelection = controller.hasSelection;
        final isSearching = controller.isSearchMode;

        return AppBar(
          automaticallyImplyLeading: false,
          centerTitle: false,
          leading: hasSelection
              ? IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: l.inboxClearSelection,
                  onPressed: controller.clearSelection,
                )
              : null,
          title: hasSelection
              ? Text(l.inboxSelectedCount(controller.selectedIds.length))
              : isSearching
              ? ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: const SearchField(),
                )
              : Text(controller.currentMailbox.title(l)),
          actionsPadding: .only(right: 8),
          actions: [
            if (hasSelection)
              const SelectionActionsBar()
            else ...[
              if (!isSearching)
                IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: l.inboxSearch,
                  onPressed: controller.enterSearchMode,
                ),
              IconButton(
                icon: controller.isSyncing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                tooltip: l.inboxSync,
                onPressed: controller.isSyncing ? null : controller.sync,
              ),
            ],
          ],
        );
      },
    );
  }
}
