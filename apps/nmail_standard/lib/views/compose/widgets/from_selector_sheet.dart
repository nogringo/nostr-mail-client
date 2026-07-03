import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/ndk.dart';

import '../../../app/routes/app_routes.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/compose_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/from_option.dart';
import '../../../widgets/nostr_avatar.dart';

class FromSelectorSheet extends StatelessWidget {
  const FromSelectorSheet({super.key});

  static Future<void> show() {
    return Get.bottomSheet(
      const FromSelectorSheet(),
      backgroundColor: Get.theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = Get.find<ComposeController>();
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l.composeSendAs,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Obx(
              () => ListView.builder(
                shrinkWrap: true,
                itemCount: controller.fromOptions.length + 1,
                itemBuilder: (context, index) {
                  // Create new identity option at top
                  if (index == 0) {
                    return _CreateNewIdentityTile(
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push(AppRoutes.settingsIdentitiesNew);
                      },
                    );
                  }

                  // Regular from options (shifted by 1)
                  final option = controller.fromOptions[index - 1];
                  final isSelected =
                      controller.selectedFrom.value?.address == option.address;
                  return _FromOptionTile(
                    option: option,
                    isSelected: isSelected,
                    onTap: () {
                      controller.selectFrom(option);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _CreateNewIdentityTile extends StatelessWidget {
  final VoidCallback onTap;

  const _CreateNewIdentityTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.outline, width: 1),
              ),
              child: Icon(Icons.add, size: 16, color: colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Text(
              l.composeCreateNewIdentity,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FromOptionTile extends StatelessWidget {
  final FromOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _FromOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.3)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? colorScheme.primary : colorScheme.outline,
                  width: 2,
                ),
                color: isSelected ? colorScheme.primary : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 16, color: colorScheme.onPrimary)
                  : null,
            ),
            const SizedBox(width: 12),
            _buildAvatar(context),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (option.displayName != null &&
                      option.displayName!.isNotEmpty) ...[
                    Text(
                      option.displayName!,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    option.shortAddress,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final authController = Get.find<AuthController>();
    final pubkey = authController.publicKey!;

    return NostrAvatar(
      pubkey: pubkey,
      metadata: Metadata(
        pubKey: pubkey,
        picture: option.picture,
        displayName: option.displayName,
      ),
      radius: 20,
    );
  }
}
