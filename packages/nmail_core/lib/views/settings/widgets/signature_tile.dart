import 'package:flutter/material.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/segmented_list_shape.dart';
import 'package:nmail_core/utils/signature_html.dart';
import 'confirm_delete_signature.dart';
import 'show_signature_form.dart';

class SignatureTile extends StatelessWidget {
  const SignatureTile({
    super.key,
    required this.signature,
    required this.index,
    required this.count,
  });

  final Signature signature;
  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final preview = signaturePreview(signature.html);

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
        title: Text(signature.name, overflow: TextOverflow.ellipsis),
        subtitle: preview.isEmpty
            ? null
            : Text(preview, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: l.actionDelete,
          onPressed: () => confirmDeleteSignature(context, signature),
        ),
        onTap: () => showSignatureForm(context, signature: signature),
      ),
    );
  }
}
