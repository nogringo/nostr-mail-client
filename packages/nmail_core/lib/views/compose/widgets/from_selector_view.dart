import 'package:flutter/material.dart';
import 'package:nmail_core/controllers/compose_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

import 'from_avatar_view.dart';
import 'from_selector_sheet.dart';

class FromSelectorView extends StatelessWidget {
  const FromSelectorView({super.key, required this.controller});

  final ComposeController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final selected = controller.selectedFrom;

    return Semantics(
      button: true,
      child: InkWell(
        onTap: () => FromSelectorSheet.show(context, controller),
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
                child: selected == null
                    ? Text(
                        l.stateLoadingEllipsis,
                        style: TextStyle(color: colorScheme.outline),
                      )
                    : Row(
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
                          Icon(
                            Icons.arrow_drop_down,
                            color: colorScheme.primary,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
