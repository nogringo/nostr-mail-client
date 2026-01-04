import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/inbox_controller.dart';

class AppSidebar extends StatelessWidget {
  final bool collapsed;

  const AppSidebar({super.key, this.collapsed = false});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InboxController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(collapsed ? 8 : 16),
            child: collapsed
                ? FloatingActionButton(
                    onPressed: () => Get.toNamed('/compose'),
                    backgroundColor: colorScheme.primary,
                    child: Icon(Icons.edit, color: colorScheme.onPrimary),
                  )
                : SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => Get.toNamed('/compose'),
                      icon: const Icon(Icons.edit),
                      label: const Text('Compose'),
                    ),
                  ),
          ),
          Obx(
            () => _NavItem(
              icon: Icons.inbox_outlined,
              selectedIcon: Icons.inbox,
              label: 'Inbox',
              selected: controller.currentFolder.value == MailFolder.inbox,
              onTap: () => controller.setFolder(MailFolder.inbox),
              collapsed: collapsed,
            ),
          ),
          Obx(
            () => _NavItem(
              icon: Icons.send_outlined,
              selectedIcon: Icons.send,
              label: 'Sent',
              selected: controller.currentFolder.value == MailFolder.sent,
              onTap: () => controller.setFolder(MailFolder.sent),
              collapsed: collapsed,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool collapsed;
  final Color? iconColor;
  final Color? textColor;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.collapsed = false,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (collapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Tooltip(
          message: label,
          child: IconButton(
            onPressed: onTap,
            icon: Icon(
              selected ? selectedIcon : icon,
              color:
                  iconColor ??
                  (selected ? colorScheme.onSecondaryContainer : null),
            ),
            style: IconButton.styleFrom(
              backgroundColor: selected ? colorScheme.secondaryContainer : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              minimumSize: const Size(56, 56),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(
          selected ? selectedIcon : icon,
          color:
              iconColor ?? (selected ? colorScheme.onSecondaryContainer : null),
        ),
        title: Text(
          label,
          style: TextStyle(
            color:
                textColor ??
                (selected ? colorScheme.onSecondaryContainer : null),
            fontWeight: selected ? FontWeight.w600 : null,
          ),
        ),
        selected: selected,
        selectedTileColor: colorScheme.secondaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        onTap: onTap,
      ),
    );
  }
}
