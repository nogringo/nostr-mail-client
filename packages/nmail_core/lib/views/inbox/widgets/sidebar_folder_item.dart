import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import '../../shared/layout_constants.dart';

/// One folder row in the desktop sidebar.
/// Selection is derived purely from the current URL: `selected` is true
/// when `currentLocation` is the folder OR any nested child (e.g.
/// `/sent/email/<hex>` keeps Sent highlighted). Changing route is
/// enough to update the visual state.
class SidebarFolderItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String path;
  final String currentLocation;

  /// A user folder or tag keeps its own color, selected or not.
  final Color? iconColor;
  final int? unreadCount;
  final GestureTapUpCallback? onSecondaryTapUp;
  final VoidCallback? onLongPress;

  const SidebarFolderItem({
    super.key,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.path,
    required this.currentLocation,
    this.iconColor,
    this.unreadCount,
    this.onSecondaryTapUp,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selected =
        currentLocation == path || currentLocation.startsWith('$path/');
    final foreground = selected ? colorScheme.onSecondaryContainer : null;
    final unread = unreadCount ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LayoutConstants.navigationInset,
        vertical: 2,
      ),
      child: GestureDetector(
        onSecondaryTapUp: onSecondaryTapUp,
        child: ListTile(
          leading: Icon(
            selected ? selectedIcon : icon,
            color: iconColor ?? foreground,
          ),
          title: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: foreground,
              fontWeight: selected || unread > 0 ? FontWeight.w600 : null,
            ),
          ),
          trailing: unread > 0
              ? Semantics(
                  label: l.mailboxUnreadCount(unread),
                  child: ExcludeSemantics(
                    child: Text(
                      '$unread',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: foreground,
                      ),
                    ),
                  ),
                )
              : null,
          selected: selected,
          selectedTileColor: colorScheme.secondaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          onTap: () {
            // The same rows fill the mobile drawer, which a tap closes.
            final scaffold = Scaffold.maybeOf(context);
            if (scaffold?.isDrawerOpen ?? false) scaffold!.closeDrawer();
            context.go(path);
          },
          onLongPress: onLongPress,
        ),
      ),
    );
  }
}
