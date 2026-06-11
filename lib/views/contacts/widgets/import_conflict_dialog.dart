import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

enum ImportConflictChoice { mergeAll, replaceAll, skipDuplicates, cancel }

/// Dialog shown when an imported `.vcf` contains contacts already present in the
/// address book. Lets the user pick a single resolution applied to every
/// conflict (merge, replace, or skip), like a file-conflict prompt.
class ImportConflictDialog extends StatelessWidget {
  final int conflictCount;

  const ImportConflictDialog({super.key, required this.conflictCount});

  static Future<ImportConflictChoice?> show(
    BuildContext context,
    int conflictCount,
  ) {
    return showDialog<ImportConflictChoice>(
      context: context,
      builder: (_) => ImportConflictDialog(conflictCount: conflictCount),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.contactsImportConflictTitle),
      content: Text(l.contactsImportConflictBody(conflictCount)),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(ImportConflictChoice.cancel),
          child: Text(l.contactsCancel),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(ImportConflictChoice.skipDuplicates),
          child: Text(l.contactsImportSkip),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(ImportConflictChoice.replaceAll),
          child: Text(l.contactsImportReplaceAll),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(ImportConflictChoice.mergeAll),
          child: Text(l.contactsImportMergeAll),
        ),
      ],
    );
  }
}
