import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/metadata_extensions.dart';
import '../../widgets/nostr_avatar.dart';
import 'account_switcher_section.dart';
import 'layout_constants.dart';

class LeftRail extends StatelessWidget {
  const LeftRail({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return SizedBox(
      width: LayoutConstants.railWidth,
      child: Column(
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.all(8),
            child: Tooltip(
              message: l.folderInbox,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => context.go(AppRoutes.inbox),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: SvgPicture.asset(
                    'icons/original_transparent_2x.svg',
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.surface,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.contacts_outlined),
            tooltip: l.contactsTitle,
            onPressed: () => context.go(AppRoutes.contacts),
          ),
          const Spacer(),
          // Settings
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l.leftRailSettings,
            onPressed: () => context.go(AppRoutes.settings),
          ),
          // Account menu
          const _AccountMenuButton(),
        ],
      ),
    );
  }
}

class _AccountMenuButton extends StatelessWidget {
  const _AccountMenuButton();

  Widget _buildAvatar(BuildContext context) {
    final authController = Get.find<AuthController>();
    final pubkey = authController.currentPubkey!;
    return NostrAvatar(
      pubkey: pubkey,
      metadata: authController.userMetadata.value,
      radius: 14,
    );
  }

  Widget _buildAccountHeader(BuildContext context) {
    final authController = Get.find<AuthController>();
    final metadata = authController.userMetadata.value;
    final pubkey = authController.currentPubkey!;
    final npub = authController.currentNpub ?? '';
    final shortNpub = npub.length >= 20
        ? '${npub.substring(0, 10)}...${npub.substring(npub.length - 6)}'
        : npub;
    final colorScheme = Theme.of(context).colorScheme;

    final displayName = metadata?.getBestName() ?? getAnonName(pubkey);

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
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
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
    final l = AppLocalizations.of(context);
    return MenuAnchor(
      // TODO: Refactor account popup into a reusable widget to avoid duplication with inbox_view.dart
      alignmentOffset: const Offset(LayoutConstants.railWidth - 8, -44),
      style: MenuStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LayoutConstants.borderRadius),
            side: BorderSide(
              width: 2,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
      ),
      menuChildren: [
        Obx(() => _buildAccountHeader(context)),
        const Divider(height: 1),
        const AccountSwitcherMenuSection(),
        MenuItemButton(
          leadingIcon: const Icon(Icons.person_add_outlined),
          onPressed: () => context.go(AppRoutes.addAccount),
          child: Text(l.inboxAddAccount),
        ),
        const Divider(height: 1),
        MenuItemButton(
          leadingIcon: const Icon(Icons.person_outline),
          onPressed: () => context.go(AppRoutes.profile),
          child: Text(l.inboxProfile),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.copy),
          onPressed: () {
            final npub = Get.find<AuthController>().currentNpub;
            if (npub != null) {
              Clipboard.setData(ClipboardData(text: npub));
            }
          },
          child: Text(l.inboxCopyNpub),
        ),
        MenuItemButton(
          leadingIcon: Icon(
            Icons.logout,
            color: Theme.of(context).colorScheme.error,
          ),
          onPressed: () {
            Get.find<AuthController>().logout();
            context.go(AppRoutes.login);
          },
          child: Text(
            l.inboxLogout,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
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
          tooltip: l.inboxAccount,
        );
      },
    );
  }
}
