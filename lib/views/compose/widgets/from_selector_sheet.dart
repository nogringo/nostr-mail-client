import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/compose_controller.dart';
import '../../../models/from_option.dart';

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
            'Envoyer en tant que',
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
                itemCount: controller.fromOptions.length,
                itemBuilder: (context, index) {
                  final option = controller.fromOptions[index];
                  final isSelected =
                      controller.selectedFrom.value?.address == option.address;
                  return _FromOptionTile(
                    option: option,
                    isSelected: isSelected,
                    onTap: () {
                      controller.selectFrom(option);
                      Get.back();
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
            if (option.source == FromSource.history)
              Icon(Icons.history, size: 18, color: colorScheme.outline),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // History items without nostr metadata
    if (!option.isNostrAddress) {
      final initial = option.address.isNotEmpty
          ? option.address[0].toUpperCase()
          : '?';
      return CircleAvatar(
        radius: 20,
        backgroundColor: colorScheme.surfaceContainerHighest,
        child: Text(
          initial,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    }

    // Nostr addresses with potential picture
    if (option.picture != null && option.picture!.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(option.picture!),
        backgroundColor: colorScheme.primaryContainer,
      );
    }

    final initial = option.displayName?.isNotEmpty == true
        ? option.displayName![0].toUpperCase()
        : 'N';

    return CircleAvatar(
      radius: 20,
      backgroundColor: colorScheme.primaryContainer,
      child: Text(
        initial,
        style: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
