import 'package:flutter/material.dart';

import 'package:nmail_core/utils/segmented_list_shape.dart';

class ContactNoteTile extends StatelessWidget {
  final String note;

  const ContactNoteTile({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: segmentedListGap / 2),
      child: ListTile(
        tileColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        shape: segmentedListShape(index: 0, count: 1),
        // At 16 the title sits 16 px down on one line or many, like the icon.
        minVerticalPadding: 16,
        titleAlignment: ListTileTitleAlignment.top,
        leading: const Icon(Icons.notes),
        title: SelectableText(note),
      ),
    );
  }
}
