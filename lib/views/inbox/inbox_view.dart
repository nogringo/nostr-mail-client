import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/inbox_controller.dart';
import 'widgets/app_drawer.dart';
import 'widgets/email_tile.dart';

class InboxView extends GetView<InboxController> {
  const InboxView({super.key});

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
    final pubkey = Get.find<AuthController>().publicKey;
    final initial = pubkey != null && pubkey.isNotEmpty
        ? pubkey.substring(0, 2).toUpperCase()
        : '?';

    return CircleAvatar(
      radius: 18,
      backgroundColor: _avatarColor(),
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
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
                child: _buildAvatar(),
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
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}
