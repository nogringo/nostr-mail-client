import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import '../../widgets/nostr_avatar.dart';
import 'account_menu.dart';
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
              // No label alongside: IconButton announces a tooltip the same
              // way, and both would read the name twice.
              child: Semantics(
                button: true,
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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final auth = Get.find<AuthController>();

    return AccountMenu(
      alignmentOffset: const Offset(LayoutConstants.railWidth - 8, -44),
      builder: (context, menuController, child) {
        return IconButton(
          onPressed: () {
            if (menuController.isOpen) {
              menuController.close();
            } else {
              menuController.open();
            }
          },
          icon: Obx(
            () => NostrAvatar(
              pubkey: auth.currentPubkey!,
              metadata: auth.userMetadata.value,
              radius: 14,
            ),
          ),
          tooltip: l.inboxAccount,
        );
      },
    );
  }
}
