import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nmail_core/app/routes/app_routes.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/segmented_list_shape.dart';

/// Its own one-row group below the accounts, because adding is an action rather
/// than one of the accounts.
class AddAccountTile extends StatelessWidget {
  const AddAccountTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: segmentedListGap / 2,
      ),
      child: ListTile(
        tileColor: colorScheme.surfaceContainerHigh,
        shape: segmentedListShape(index: 0, count: 1),
        // Same width as the account avatars, so the titles line up.
        leading: const SizedBox.square(
          dimension: 40,
          child: Center(child: Icon(Icons.person_add_outlined)),
        ),
        title: Text(l.inboxAddAccount),
        onTap: () => context.go(AppRoutes.addAccount),
      ),
    );
  }
}
