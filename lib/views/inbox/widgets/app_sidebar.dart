import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'sidebar_folder_item.dart';

/// Desktop sidebar. Folder selection is URL-driven: tapping a folder calls
/// `context.go(<folder-path>)` and the `selected` state is derived from
/// the current matched location. The InboxController stays alive across
/// folder switches because it lives in the ShellRoute scope.
class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final loc = GoRouterState.of(context).matchedLocation;

    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.push(AppRoutes.compose),
                icon: const Icon(Icons.edit),
                label: Text(l.inboxCompose),
              ),
            ),
          ),
          SidebarFolderItem(
            icon: Icons.inbox_outlined,
            selectedIcon: Icons.inbox,
            label: l.folderInbox,
            path: AppRoutes.inbox,
            currentLocation: loc,
          ),
          SidebarFolderItem(
            icon: Icons.send_outlined,
            selectedIcon: Icons.send,
            label: l.folderSent,
            path: AppRoutes.sent,
            currentLocation: loc,
          ),
          SidebarFolderItem(
            icon: Icons.schedule_outlined,
            selectedIcon: Icons.schedule,
            label: l.folderScheduled,
            path: AppRoutes.scheduled,
            currentLocation: loc,
          ),
          SidebarFolderItem(
            icon: Icons.archive_outlined,
            selectedIcon: Icons.archive,
            label: l.folderArchive,
            path: AppRoutes.archive,
            currentLocation: loc,
          ),
          SidebarFolderItem(
            icon: Icons.delete_outlined,
            selectedIcon: Icons.delete,
            label: l.folderTrash,
            path: AppRoutes.trash,
            currentLocation: loc,
          ),
        ],
      ),
    );
  }
}
