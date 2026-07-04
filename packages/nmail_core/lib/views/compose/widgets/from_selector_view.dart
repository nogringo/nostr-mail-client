import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nmail_core/controllers/compose_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

import 'from_avatar_view.dart';
import 'from_selector_sheet.dart';

class FromSelectorView extends StatelessWidget {
  const FromSelectorView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => FromSelectorSheet.show(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              l.composeFrom,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() {
                final selected = ComposeController.to.selectedFrom.value;
                if (selected == null) {
                  return Text(
                    l.stateLoadingEllipsis,
                    style: TextStyle(color: colorScheme.outline),
                  );
                }
                return Row(
                  children: [
                    FromAvatarView(option: selected),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selected.label,
                            style: const TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (selected.displayName != null &&
                              selected.displayName!.isNotEmpty)
                            Text(
                              selected.shortAddress,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: colorScheme.primary),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
