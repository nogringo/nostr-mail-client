import 'package:flutter/material.dart';

import '../../shared/layout_constants.dart';

/// Heads the user folders or tags in the sidebar, with a button to add one.
class SidebarSectionHeader extends StatelessWidget {
  final String title;
  final String addLabel;
  final VoidCallback onAdd;

  const SidebarSectionHeader({
    super.key,
    required this.title,
    required this.addLabel,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      // The title lines up with the row icons, which ListTile pads by 16, and
      // the button ends where the rows do.
      padding: const EdgeInsets.fromLTRB(
        LayoutConstants.navigationInset + 16,
        16,
        LayoutConstants.navigationInset,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: addLabel,
            visualDensity: VisualDensity.compact,
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}
