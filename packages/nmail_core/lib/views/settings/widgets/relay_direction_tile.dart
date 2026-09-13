import 'package:flutter/material.dart';
import 'package:ndk/entities.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/segmented_list_shape.dart';

class RelayDirectionTile extends StatelessWidget {
  const RelayDirectionTile({
    super.key,
    required this.marker,
    required this.isSelected,
    required this.onSelected,
    required this.index,
    required this.count,
  });

  final ReadWriteMarker marker;
  final bool isSelected;
  final VoidCallback onSelected;
  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: segmentedListGap / 2),
      child: ListTile(
        selected: isSelected,
        tileColor: colorScheme.surfaceContainerHigh,
        selectedTileColor: colorScheme.secondaryContainer,
        selectedColor: colorScheme.onSecondaryContainer,
        shape: segmentedListShape(
          index: index,
          count: count,
          isSelected: isSelected,
        ),
        minTileHeight: 56,
        title: Text(switch (marker) {
          ReadWriteMarker.readWrite => l.relayReadWrite,
          ReadWriteMarker.readOnly => l.relayRead,
          ReadWriteMarker.writeOnly => l.relayWrite,
        }),
        subtitle: Text(switch (marker) {
          ReadWriteMarker.readWrite => l.relayReadWriteDescription,
          ReadWriteMarker.readOnly => l.relayReadDescription,
          ReadWriteMarker.writeOnly => l.relayWriteDescription,
        }),
        onTap: isSelected ? null : onSelected,
      ),
    );
  }
}
