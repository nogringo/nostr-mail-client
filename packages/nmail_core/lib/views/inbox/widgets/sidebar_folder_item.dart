import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  const SidebarFolderItem({
    super.key,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.path,
    required this.currentLocation,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selected =
        currentLocation == path || currentLocation.startsWith('$path/');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Icon(
          selected ? selectedIcon : icon,
          color: selected ? colorScheme.onSecondaryContainer : null,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: selected ? colorScheme.onSecondaryContainer : null,
            fontWeight: selected ? FontWeight.w600 : null,
          ),
        ),
        selected: selected,
        selectedTileColor: colorScheme.secondaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        onTap: selected ? null : () => context.go(path),
      ),
    );
  }
}
