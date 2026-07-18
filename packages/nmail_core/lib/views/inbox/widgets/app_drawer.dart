import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';

import '../../../app/routes/app_routes.dart';
import '../../../controllers/auth_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/metadata_extensions.dart';
import '../../../widgets/nostr_avatar.dart';

const _folderPaths = [
  AppRoutes.inbox,
  AppRoutes.sent,
  AppRoutes.scheduled,
  AppRoutes.archive,
  AppRoutes.trash,
  AppRoutes.contacts,
];

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  String _shortNpub(AppLocalizations l) {
    final npub = Get.find<AuthController>().currentNpub;
    if (npub == null || npub.length < 20) return l.inboxUnknown;
    return '${npub.substring(0, 10)}...${npub.substring(npub.length - 6)}';
  }

  void _copyNpub(BuildContext context) {
    final l = AppLocalizations.of(context);
    final npub = Get.find<AuthController>().currentNpub;
    if (npub == null) return;
    Clipboard.setData(ClipboardData(text: npub));
    toastification.show(
      context: context,
      type: ToastificationType.success,
      title: Text(l.inboxNpubCopied),
      autoCloseDuration: const Duration(seconds: 2),
      alignment: Alignment.bottomRight,
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final authController = Get.find<AuthController>();
    final pubkey = authController.currentPubkey!;
    return NostrAvatar(
      pubkey: pubkey,
      metadata: authController.userMetadata.value,
      radius: 28,
    );
  }

  String _displayName() {
    final authController = Get.find<AuthController>();
    final metadata = authController.userMetadata.value;
    final pubkey = authController.currentPubkey!;

    return metadata?.getBestName() ?? getAnonName(pubkey);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final loc = GoRouterState.of(context).matchedLocation;
    // Match the folder OR any nested child route, so `/sent/email/<hex>`
    // keeps Sent highlighted in the drawer.
    final selectedIndex = _folderPaths.indexWhere(
      (path) => loc == path || loc.startsWith('$path/'),
    );

    return NavigationDrawer(
      selectedIndex: selectedIndex >= 0 ? selectedIndex : null,
      onDestinationSelected: (index) {
        Navigator.pop(context);
        context.go(_folderPaths[index]);
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
                      Semantics(
                        label: l.inboxEditProfile,
                        button: true,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            context.go(AppRoutes.profile);
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
                            Semantics(
                              label: l.inboxCopyNpub,
                              button: true,
                              child: InkWell(
                                onTap: () => _copyNpub(context),
                                borderRadius: BorderRadius.circular(4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        _shortNpub(l),
                                        style: TextStyle(
                                          color: colorScheme.onSurfaceVariant,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.copy,
                                      size: 12,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ],
                                ),
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
                      context.push(AppRoutes.compose);
                    },
                    icon: const Icon(Icons.edit),
                    label: Text(l.inboxCompose),
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
        NavigationDrawerDestination(
          icon: const Icon(Icons.inbox_outlined),
          selectedIcon: const Icon(Icons.inbox),
          label: Text(l.folderInbox),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.send_outlined),
          selectedIcon: const Icon(Icons.send),
          label: Text(l.folderSent),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.schedule_outlined),
          selectedIcon: const Icon(Icons.schedule),
          label: Text(l.folderScheduled),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.archive_outlined),
          selectedIcon: const Icon(Icons.archive),
          label: Text(l.folderArchive),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.delete_outlined),
          selectedIcon: const Icon(Icons.delete),
          label: Text(l.folderTrash),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.contacts_outlined),
          selectedIcon: const Icon(Icons.contacts),
          label: Text(l.contactsTitle),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListTile(
            leading: const Icon(Icons.settings),
            title: Text(l.inboxSettings),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.settings);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListTile(
            leading: const Icon(Icons.person_add_outlined),
            title: Text(l.inboxAddAccount),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.addAccount);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListTile(
            leading: Icon(Icons.logout, color: colorScheme.error),
            title: Text(
              l.inboxLogout,
              style: TextStyle(color: colorScheme.error),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            onTap: () {
              Get.find<AuthController>().logout();
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
