import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/services/app_update_service.dart';

/// Hamburger that opens the enclosing Scaffold's drawer, dotted while an
/// update waits behind the drawer's settings entry.
class DrawerMenuButton extends StatelessWidget {
  const DrawerMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final updates = GetIt.I<AppUpdateService>();

    return ValueListenableBuilder(
      valueListenable: updates.availableUpdate,
      builder: (context, release, _) {
        final hasUpdate = release != null;
        return IconButton(
          icon: Badge(
            isLabelVisible: hasUpdate,
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            smallSize: 8,
            child: const Icon(Icons.menu),
          ),
          tooltip: hasUpdate ? l.inboxMenuUpdateAvailable : l.inboxMenu,
          onPressed: () => Scaffold.of(context).openDrawer(),
        );
      },
    );
  }
}
