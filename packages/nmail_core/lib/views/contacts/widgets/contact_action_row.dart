import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/contacts_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/segmented_list_shape.dart';
import 'contact_copy_feedback.dart';

class ContactActionRow extends StatelessWidget {
  final IconData icon;
  final Widget title;
  final Widget? leading;
  final String copyValue;
  final VoidCallback? onCompose;

  /// Custom trailing actions (e.g. call / SMS buttons for a phone row). Takes
  /// precedence over the [onCompose] mail button when provided.
  final Widget? trailing;

  /// Position within its section, so the row picks the matching segmented
  /// shape. A lone row takes `index: 0, count: 1` and is rounded on all sides.
  final int index;
  final int count;

  const ContactActionRow({
    super.key,
    required this.icon,
    required this.title,
    required this.copyValue,
    required this.index,
    required this.count,
    this.onCompose,
    this.trailing,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: segmentedListGap / 2),
      child: Tooltip(
        message: l.actionCopy,
        // Anything but manual steals the hold-to-copy gesture: the long-press
        // trigger opens the bubble and the tile's tap never fires.
        triggerMode: TooltipTriggerMode.manual,
        child: ListTile(
          onTap: () => _copyValue(context),
          tileColor: colorScheme.surfaceContainerHigh,
          shape: segmentedListShape(index: index, count: count),
          leading: leading ?? Icon(icon),
          title: title,
          trailing:
              trailing ??
              (onCompose == null
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.mail_outline),
                      tooltip: l.inboxCompose,
                      onPressed: onCompose,
                    )),
        ),
      ),
    );
  }

  void _copyValue(BuildContext context) {
    Get.find<ContactsController>().copyText(copyValue);
    showContactCopyFeedback(context, AppLocalizations.of(context).authCopied);
  }
}
