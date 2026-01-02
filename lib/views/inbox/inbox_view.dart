import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/inbox_controller.dart';
import 'widgets/app_drawer.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.currentFolder.value == MailFolder.inbox
                ? 'Inbox'
                : 'Sent',
          ),
        ),
        actions: [
          Builder(
            builder: (context) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Obx(() => _buildAvatar(context)),
              ),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
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

        return RefreshIndicator(
          onRefresh: controller.sync,
          child: ListView.builder(
            itemCount: controller.emails.length,
            itemBuilder: (context, index) {
              final email = controller.emails[index];
              return EmailTile(
                email: email,
                onTap: () => Get.toNamed('/email', arguments: email.id),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/compose'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.edit, color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }
}
