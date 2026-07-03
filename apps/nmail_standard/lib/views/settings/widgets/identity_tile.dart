import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/identities_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'identity_email_text.dart';

class IdentityTile extends StatelessWidget {
  final MailAddress identity;
  final int index;

  const IdentityTile({super.key, required this.identity, required this.index});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = Get.find<IdentitiesController>();
    return Obx(() {
      final isMarked = controller.markedForDeletion.contains(index);
      final disabledColor = Theme.of(context).disabledColor;
      final name = identity.personalName;
      final hasName = name != null && name.isNotEmpty;
      final colorScheme = Theme.of(context).colorScheme;

      return ListTile(
        leading: ReorderableDragStartListener(
          index: index,
          child: Icon(
            Icons.drag_indicator,
            color: isMarked ? disabledColor : colorScheme.onSurfaceVariant,
          ),
        ),
        title: IdentityEmailText(identity: identity, isMarked: isMarked),
        subtitle: hasName
            ? Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  decoration: isMarked ? TextDecoration.lineThrough : null,
                  color: isMarked
                      ? disabledColor
                      : colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: IconButton(
          icon: Icon(isMarked ? Icons.undo : Icons.close, size: 20),
          tooltip: isMarked ? l.actionUndo : l.actionRemove,
          onPressed: () => controller.toggleDeletion(index),
        ),
      );
    });
  }
}
