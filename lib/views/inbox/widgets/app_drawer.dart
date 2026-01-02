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

  Widget _buildAvatar() {
    final authController = Get.find<AuthController>();
    final metadata = authController.userMetadata.value;
    final pubkey = authController.publicKey;

    if (metadata?.picture != null && metadata!.picture!.isNotEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(metadata.picture!),
        backgroundColor: _avatarColor(),
      );
    }

    final initial = metadata?.name?.isNotEmpty == true
        ? metadata!.name![0].toUpperCase()
        : pubkey != null && pubkey.isNotEmpty
        ? pubkey.substring(0, 2).toUpperCase()
        : '?';

    return CircleAvatar(
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

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple.shade50),
            child: Obx(
              () => Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed('/profile');
                    },
                    child: Stack(
                      children: [
                        _buildAvatar(),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.deepPurple.shade50,
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 12,
                              color: Colors.deepPurple.shade700,
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
