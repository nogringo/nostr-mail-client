import 'package:flutter/material.dart';

import 'package:nmail_core/utils/segmented_list_shape.dart';

/// One choice of the signature picker. The picked row detaches from the group
/// with its own full rounding, as the language picker does.
class SignatureOptionTile extends StatelessWidget {
  const SignatureOptionTile({
    super.key,
    required this.id,
    required this.label,
    required this.isSelected,
    required this.index,
    required this.count,
  });

  final String? id;
  final String label;
  final bool isSelected;
  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isAlone = count == 1;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: segmentedListGap / 2,
      ),
      child: ListTile(
        selected: isSelected,
        tileColor: colorScheme.surfaceContainerHigh,
        selectedTileColor: colorScheme.secondaryContainer,
        selectedColor: colorScheme.onSecondaryContainer,
        shape: isAlone
            ? const StadiumBorder()
            : segmentedListShape(
                index: index,
                count: count,
                isSelected: isSelected,
              ),
        contentPadding: isAlone
            ? const EdgeInsets.symmetric(horizontal: 24)
            : null,
        minTileHeight: 56,
        title: Text(label, overflow: TextOverflow.ellipsis),
        onTap: () => Navigator.pop(context, (id: id)),
      ),
    );
  }
}
