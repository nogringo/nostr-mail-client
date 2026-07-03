import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/contacts_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
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

  const ContactActionRow({
    super.key,
    required this.icon,
    required this.title,
    required this.copyValue,
    this.onCompose,
    this.trailing,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _copyValue(context),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
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
    );
  }

  void _copyValue(BuildContext context) {
    Get.find<ContactsController>().copyText(copyValue);
    showContactCopyFeedback(context, AppLocalizations.of(context).authCopied);
  }
}
