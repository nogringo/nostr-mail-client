import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

class ContactActionRow extends StatelessWidget {
  final IconData icon;
  final Widget title;
  final Widget? leading;
  final VoidCallback onCompose;

  const ContactActionRow({
    super.key,
    required this.icon,
    required this.title,
    required this.onCompose,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: leading ?? Icon(icon),
      title: title,
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        tooltip: l.inboxCompose,
        onPressed: onCompose,
      ),
    );
  }
}
