import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';

import '../../controllers/auth_controller.dart';
import 'layout_constants.dart';

class LeftRail extends StatelessWidget {
  const LeftRail({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: LayoutConstants.railWidth,
      color: Colors.transparent,
      child: Column(
        children: [
          const SizedBox(height: LayoutConstants.shellPadding),
          // Logo
          Padding(
            padding: const EdgeInsets.all(8),
            child: SvgPicture.asset(
              'icons/original_transparent_2x.svg',
              width: 32,
              height: 32,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.primary,
                BlendMode.srcIn,
              ),
            ),
          ),
          const Spacer(),
          // Settings
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Get.toNamed('/settings'),
          ),
          // Account menu
          const _AccountMenuButton(),
          const SizedBox(height: LayoutConstants.shellPadding),
        ],
      ),
    );
  }
}

class _AccountMenuButton extends StatelessWidget {
  const _AccountMenuButton();

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
        radius: 14,
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
      radius: 14,
      backgroundColor: _avatarColor(context),
      child: Text(
        initial,
        style: TextStyle(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 10,
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
      width: 220,
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
    return MenuAnchor(
      alignmentOffset: const Offset(LayoutConstants.railWidth, 0),
      style: MenuStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LayoutConstants.borderRadius),
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
          leadingIcon: const Icon(Icons.logout, color: Colors.red),
          onPressed: () {
            Get.find<AuthController>().logout();
            Get.offAllNamed('/login');
          },
          child: const Text('Logout', style: TextStyle(color: Colors.red)),
        ),
      ],
      builder: (context, menuController, child) {
        return IconButton(
          onPressed: () {
            if (menuController.isOpen) {
              menuController.close();
            } else {
              menuController.open();
            }
          },
          icon: Obx(() => _buildAvatar(context)),
        );
      },
    );
  }
}
