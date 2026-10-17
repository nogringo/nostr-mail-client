import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/segmented_list_shape.dart';
import 'show_signature_form.dart';

/// The plain text signature of earlier versions, which saving turns into the
/// first signature.
class LegacySignatureTile extends StatelessWidget {
  const LegacySignatureTile({
    super.key,
    required this.text,
    required this.index,
    required this.count,
  });

  final String text;
  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: segmentedListGap / 2,
      ),
      child: ListTile(
        tileColor: colorScheme.surfaceContainerHigh,
        shape: segmentedListShape(index: index, count: count),
        minTileHeight: 72,
        leading: const Icon(Icons.draw_outlined),
        title: Text(l.signaturesLegacyName),
        subtitle: Text(
          text.trim(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () => showSignatureForm(context, legacyText: text),
      ),
    );
  }
}
