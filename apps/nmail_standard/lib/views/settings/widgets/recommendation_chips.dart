import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

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
    final filtered = recommendations.where((r) => !isAlreadyAdded(r)).toList();

    if (filtered.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title ?? l.hostingRecommended,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filtered.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    avatar: const Icon(Icons.add, size: 14),
                    label: Text(formatLabel(item)),
                    onPressed: () => onAdd(item),
                    visualDensity: VisualDensity.compact,
                    labelStyle: const TextStyle(fontSize: 12),
                    shape: StadiumBorder(),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
