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

  Color _avatarColor() {
    final pubkey = Get.find<AuthController>().publicKey;
    if (pubkey == null || pubkey.isEmpty) return Colors.deepPurple;
    final hash = pubkey.hashCode;
    return Color.fromARGB(
      255,
      (hash & 0xFF0000) >> 16,
      (hash & 0x00FF00) >> 8,
      hash & 0x0000FF,
    ).withValues(alpha: 1);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InboxController>();
    final pubkey = Get.find<AuthController>().publicKey;
    final initial = pubkey != null && pubkey.isNotEmpty
        ? pubkey.substring(0, 2).toUpperCase()
        : '?';

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple.shade50),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: _avatarColor(),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _copyNpub(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              _shortNpub(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.copy, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => ListTile(
              leading: const Icon(Icons.inbox),
              title: const Text('Inbox'),
              selected: controller.currentFolder.value == MailFolder.inbox,
              selectedTileColor: Colors.deepPurple.shade50,
              onTap: () {
                controller.setFolder(MailFolder.inbox);
                Navigator.pop(context);
              },
            ),
          ),
          Obx(
            () => ListTile(
              leading: const Icon(Icons.send),
              title: const Text('Sent'),
              selected: controller.currentFolder.value == MailFolder.sent,
              selectedTileColor: Colors.deepPurple.shade50,
              onTap: () {
                controller.setFolder(MailFolder.sent);
                Navigator.pop(context);
              },
            ),
          ),
          const Spacer(),
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.find<AuthController>().logout();
                Get.offAllNamed('/login');
              },
            ),
          ),
        ],
      ),
    );
  }
}
