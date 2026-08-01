import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';

class RecommendationChips extends StatelessWidget {
  final List<String> recommendations;
  final bool Function(String) isAlreadyAdded;
  final Function(String) onAdd;
  final String Function(String) formatLabel;
  final String? title;

  const RecommendationChips({
    super.key,
    required this.recommendations,
    required this.isAlreadyAdded,
    required this.onAdd,
    required this.formatLabel,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final filtered = recommendations.where((r) => !isAlreadyAdded(r)).toList();

    if (filtered.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title ?? l.hostingRecommended,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final item in filtered)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      avatar: const Icon(Icons.add),
                      label: Text(formatLabel(item)),
                      onPressed: () => onAdd(item),
                      visualDensity: VisualDensity.compact,
                      shape: const StadiumBorder(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
