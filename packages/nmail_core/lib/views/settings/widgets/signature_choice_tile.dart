import 'package:flutter/material.dart';

import 'package:nmail_core/controllers/signatures_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/segmented_list_shape.dart';
import 'signature_choice_labels.dart';

/// Which signature goes on one kind of email, opening the picker on tap.
class SignatureChoiceTile extends StatelessWidget {
  const SignatureChoiceTile({
    super.key,
    required this.use,
    required this.value,
    required this.index,
    required this.count,
    required this.onTap,
  });

  final SignatureUse use;
  final String value;
  final int index;
  final int count;
  final VoidCallback onTap;

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
        leading: Icon(switch (use) {
          SignatureUse.newEmail => Icons.edit_outlined,
          SignatureUse.reply => Icons.reply,
        }),
        title: Text(signatureUseLabel(l, use)),
        subtitle: Text(value, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
