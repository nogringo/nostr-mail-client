import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'package:nmail_core/l10n/generated/app_localizations.dart';

/// Completes with the new name, or null when cancelled or left unchanged.
Future<String?> showRenameAttachmentDialog(
  BuildContext context,
  String current,
) async {
  final controller = TextEditingController(text: current)
    ..selection = TextSelection(
      baseOffset: 0,
      extentOffset: p.basenameWithoutExtension(current).length,
    );
  ModalRoute<Object?>? route;
  final filename = await showDialog<String>(
    context: context,
    builder: (dialogContext) {
      route = ModalRoute.of(dialogContext);
      return RenameAttachmentDialog(controller: controller);
    },
  );
  // The dialog still rebuilds while it animates out.
  route?.completed.then((_) => controller.dispose());
  return filename == current ? null : filename;
}

class RenameAttachmentDialog extends StatelessWidget {
  const RenameAttachmentDialog({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final filename = value.text.trim();
        void submit() => Navigator.pop(context, controller.text.trim());

        return AlertDialog(
          title: Text(l.composeRenameAttachment),
          content: SizedBox(
            width: 400,
            child: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l.composeAttachmentFilename,
              ),
              onSubmitted: filename.isEmpty ? null : (_) => submit(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.actionCancel),
            ),
            TextButton(
              onPressed: filename.isEmpty ? null : submit,
              child: Text(l.actionRename),
            ),
          ],
        );
      },
    );
  }
}
