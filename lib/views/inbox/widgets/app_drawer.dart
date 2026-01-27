import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/inbox_controller.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  String _shortNpub() {
    final npub = Get.find<AuthController>().npub;
    if (npub == null || npub.length < 20) return 'Unknown';
    return '${npub.substring(0, 10)}...${npub.substring(npub.length - 6)}';
  }

  void _copyNpub(BuildContext context) {
    final npub = Get.find<AuthController>().npub;
    if (npub == null) return;
    Clipboard.setData(ClipboardData(text: npub));
    toastification.show(
      context: context,
      type: ToastificationType.success,
      title: const Text('npub copied'),
      autoCloseDuration: const Duration(seconds: 2),
      alignment: Alignment.bottomRight,
    );
  }

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

    if (metadata?.picture != null && metadata!.picture!.isNotEmpty) {
      return CircleAvatar(
        radius: 28,
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
      radius: 28,
      backgroundColor: _avatarColor(context),
      child: Text(
        initial,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  String _displayName() {
    final authController = Get.find<AuthController>();
    final metadata = authController.userMetadata.value;

    if (metadata?.name != null && metadata!.name!.isNotEmpty) {
      return metadata.name!;
    }
    return _shortNpub();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InboxController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final selectedIndex = switch (controller.currentFolder.value) {
        MailFolder.inbox => 0,
        MailFolder.sent => 1,
        MailFolder.trash => 2,
      };

      return NavigationDrawer(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          final folder = switch (index) {
            0 => MailFolder.inbox,
            1 => MailFolder.sent,
            _ => MailFolder.trash,
          };
          controller.setFolder(folder);
          Navigator.pop(context);
        },
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Get.toNamed('/profile');
                          },
                          child: Stack(
                            children: [
                              _buildAvatar(context),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: colorScheme.surface,
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    size: 12,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _displayName(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              InkWell(
                                onTap: () => _copyNpub(context),
                                borderRadius: BorderRadius.circular(4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        _shortNpub(),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.copy,
                                      size: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Get.toNamed('/compose');
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Compose'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.inbox_outlined),
            selectedIcon: Icon(Icons.inbox),
            label: Text('Inbox'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.send_outlined),
            selectedIcon: Icon(Icons.send),
            label: Text('Sent'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.delete_outlined),
            selectedIcon: Icon(Icons.delete),
            label: Text('Trash'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed('/settings');
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              onTap: () {
                Get.find<AuthController>().logout();
                Get.offAllNamed('/login');
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    });
  }
}
