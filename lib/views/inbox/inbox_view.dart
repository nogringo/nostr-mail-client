import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nostr_mail/nostr_mail.dart';
import 'package:toastification/toastification.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/inbox_controller.dart';
import '../../utils/responsive_helper.dart';
import '../../utils/toast_helper.dart';
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

  Widget _buildAccountHeader(BuildContext context) {
    final authController = Get.find<AuthController>();
    final metadata = authController.userMetadata.value;
    final npub = authController.npub ?? '';
    final shortNpub = npub.length >= 20
        ? '${npub.substring(0, 10)}...${npub.substring(npub.length - 6)}'
        : npub;

    final displayName = metadata?.name?.isNotEmpty == true
        ? metadata!.name!
        : shortNpub;

    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildAvatar(context),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  shortNpub,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = ResponsiveHelper.isNotMobile(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(
      () => ResponsiveScaffold(
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
              return Text('${controller.selectedIds.length} selected');
            }
            final title = switch (controller.currentFolder.value) {
              MailFolder.inbox => 'Inbox',
              MailFolder.sent => 'Sent',
              MailFolder.trash => 'Trash',
            };
            return Text(title);
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
                          ? 'Deselect all'
                          : 'Select all',
                      onPressed: controller.allSelected
                          ? controller.clearSelection
                          : controller.selectAll,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Delete',
                      onPressed: controller.deleteSelected,
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Settings',
              onPressed: () => Get.toNamed('/settings'),
            ),
            const SizedBox(width: 8),
            Builder(
              builder: (context) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: isWide
                    ? MenuAnchor(
                        alignmentOffset: const Offset(-200, 8),
                        style: MenuStyle(
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        menuChildren: [
                          Obx(() => _buildAccountHeader(context)),
                          const Divider(height: 1),
                          MenuItemButton(
                            leadingIcon: const Icon(Icons.person_outline),
                            onPressed: () => Get.toNamed('/profile'),
                            child: const Text('Profile'),
                          ),
                          MenuItemButton(
                            leadingIcon: const Icon(Icons.copy),
                            onPressed: () {
                              final npub = Get.find<AuthController>().npub;
                              if (npub != null) {
                                Clipboard.setData(ClipboardData(text: npub));
                                toastification.show(
                                  context: context,
                                  type: ToastificationType.success,
                                  title: const Text('npub copied'),
                                  autoCloseDuration: const Duration(seconds: 2),
                                  alignment: Alignment.bottomRight,
                                );
                              }
                            },
                            child: const Text('Copy npub'),
                          ),
                          MenuItemButton(
                            leadingIcon: const Icon(
                              Icons.logout,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              Get.find<AuthController>().logout();
                              Get.offAllNamed('/login');
                            },
                            child: const Text(
                              'Logout',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                        builder: (context, menuController, child) {
                          return GestureDetector(
                            onTap: () {
                              if (menuController.isOpen) {
                                menuController.close();
                              } else {
                                menuController.open();
                              }
                            },
                            child: Obx(() => _buildAvatar(context)),
                          );
                        },
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
          if (controller.emails.isEmpty) {
            final (icon, message) = switch (controller.currentFolder.value) {
              MailFolder.inbox => (Icons.inbox, 'No emails yet'),
              MailFolder.sent => (Icons.send, 'No sent emails'),
              MailFolder.trash => (Icons.delete_outline, 'Trash is empty'),
            };
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    message,
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
                      onToggleSelect: () =>
                          controller.toggleSelection(email.id),
                      onReply: () => _replyTo(email),
                      onForward: () => _forward(email),
                      onDelete: () => _deleteEmail(context, email),
                      onRestore: () => _restoreEmail(context, email),
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
      ),
    );
  }

  void _replyTo(Email email) {
    Get.toNamed('/compose', arguments: {'email': email, 'mode': 'reply'});
  }

  void _forward(Email email) {
    Get.toNamed('/compose', arguments: {'email': email, 'mode': 'forward'});
  }

  void _deleteEmail(BuildContext context, Email email) {
    controller.deleteEmail(email.id);
    if (controller.currentFolder.value != MailFolder.trash) {
      ToastHelper.success(context, 'Email moved to trash');
    }
  }

  void _restoreEmail(BuildContext context, Email email) {
    controller.restoreFromTrash(email.id);
    ToastHelper.success(context, 'Email restored');
  }
}
