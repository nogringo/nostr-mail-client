import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/inbox_controller.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InboxController>();

    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
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
            ),
          ),
          Obx(
            () => _NavItem(
              icon: Icons.send_outlined,
              selectedIcon: Icons.send,
              label: 'Sent',
              selected: controller.currentFolder.value == MailFolder.sent,
              onTap: () => controller.setFolder(MailFolder.sent),
            ),
          ),
          Obx(
            () => _NavItem(
              icon: Icons.delete_outlined,
              selectedIcon: Icons.delete,
              label: 'Trash',
              selected: controller.currentFolder.value == MailFolder.trash,
              onTap: () => controller.setFolder(MailFolder.trash),
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

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
        onTap: onTap,
      ),
    );
  }
}
