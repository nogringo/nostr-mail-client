import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/inbox_controller.dart';
import '../../utils/responsive_helper.dart';
import 'widgets/app_drawer.dart';
import 'widgets/app_sidebar.dart';
import 'widgets/email_tile.dart';

class InboxView extends GetView<InboxController> {
  const InboxView({super.key});

  Color _avatarColor(BuildContext context) {
    final pubkey = Get.find<AuthController>().publicKey;
    if (pubkey == null || pubkey.isEmpty) {
      return Theme.of(context).colorScheme.primary;
    }
    final hash = pubkey.hashCode;
    return Color.fromARGB(
      255,
      (hash & 0xFF0000) >> 16,
      (hash & 0x00FF00) >> 8,
      hash & 0x0000FF,
    ).withValues(alpha: 1);
  }

  Widget _buildAvatar(BuildContext context) {
    final authController = Get.find<AuthController>();
    final metadata = authController.userMetadata.value;
    final pubkey = authController.publicKey;
    final colorScheme = Theme.of(context).colorScheme;

    if (metadata?.picture != null && metadata!.picture!.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(metadata.picture!),
        backgroundColor: _avatarColor(context),
      );
    }

    final initial = metadata?.name?.isNotEmpty == true
        ? metadata!.name![0].toUpperCase()
        : pubkey != null && pubkey.isNotEmpty
        ? pubkey.substring(0, 2).toUpperCase()
        : '?';

    return CircleAvatar(
      radius: 18,
      backgroundColor: _avatarColor(context),
      child: Text(
        initial,
        style: TextStyle(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = ResponsiveHelper.isNotMobile(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() => ResponsiveScaffold(
      sidebarWidth: controller.isSidebarCollapsed.value ? 72 : 280,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        leading: isWide
            ? Obx(() {
                if (controller.hasSelection) {
                  return IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: controller.clearSelection,
                  );
                }
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: controller.toggleSidebar,
                );
              })
            : null,
        title: Obx(() {
          if (controller.hasSelection) {
            return Text('${controller.selectedIds.length} sélectionné(s)');
          }
          return Text(
            controller.currentFolder.value == MailFolder.inbox
                ? 'Inbox'
                : 'Sent',
          );
        }),
        actions: [
          Obx(() {
            if (controller.hasSelection) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      controller.allSelected
                          ? Icons.deselect
                          : Icons.select_all,
                    ),
                    tooltip: controller.allSelected
                        ? 'Désélectionner tout'
                        : 'Tout sélectionner',
                    onPressed: controller.allSelected
                        ? controller.clearSelection
                        : controller.selectAll,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Supprimer',
                    onPressed: controller.deleteSelected,
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Paramètres',
            onPressed: () => Get.toNamed('/settings'),
          ),
          const SizedBox(width: 8),
          Builder(
            builder: (context) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: isWide
                  ? PopupMenuButton<String>(
                      offset: const Offset(0, 48),
                      onSelected: (value) {
                        if (value == 'profile') {
                          Get.toNamed('/profile');
                        } else if (value == 'logout') {
                          Get.find<AuthController>().logout();
                          Get.offAllNamed('/login');
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'profile',
                          child: Row(
                            children: [
                              Icon(Icons.person_outline),
                              SizedBox(width: 12),
                              Text('Profile'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, color: Colors.red),
                              SizedBox(width: 12),
                              Text(
                                'Logout',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                      child: Obx(() => _buildAvatar(context)),
                    )
                  : GestureDetector(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: Obx(() => _buildAvatar(context)),
                    ),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      sidebar: AppSidebar(collapsed: controller.isSidebarCollapsed.value),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.emails.isEmpty) {
          final isInbox = controller.currentFolder.value == MailFolder.inbox;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isInbox ? Icons.inbox : Icons.send,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  isInbox ? 'No emails yet' : 'No sent emails',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: controller.sync,
                  child: const Text('Sync from relays'),
                ),
              ],
            ),
          );
        }

        return Container(
          margin: isWide ? const EdgeInsets.only(top: 8, left: 8) : null,
          decoration: isWide
              ? BoxDecoration(
                  color: colorScheme.surfaceContainerLowest,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                  ),
                )
              : null,
          clipBehavior: isWide ? Clip.antiAlias : Clip.none,
          child: RefreshIndicator(
            onRefresh: controller.sync,
            child: ListView.builder(
              itemCount: controller.emails.length,
              itemBuilder: (context, index) {
                final email = controller.emails[index];
                return Obx(
                  () => EmailTile(
                    email: email,
                    onTap: () => Get.toNamed('/email', arguments: email.id),
                    isSelected: controller.isSelected(email.id),
                    onToggleSelect: () => controller.toggleSelection(email.id),
                  ),
                );
              },
            ),
          ),
        );
      }),
      floatingActionButton: isWide
          ? null
          : FloatingActionButton(
              onPressed: () => Get.toNamed('/compose'),
              backgroundColor: colorScheme.primary,
              child: Icon(Icons.edit, color: colorScheme.onPrimary),
            ),
    ));
  }
}
