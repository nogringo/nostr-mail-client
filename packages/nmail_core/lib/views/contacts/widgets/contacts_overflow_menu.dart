import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/contacts_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

enum _ContactsMenuAction { import, export }

/// Overflow menu in the Contacts AppBar exposing the bulk import/export of the
/// whole address book as a `.vcf` file. Available on both desktop and mobile.
///
/// Uses [PopupMenuButton] rather than the app's [MenuAnchor] pattern because it
/// self-positions with a screen-edge margin in every locale; a [MenuAnchor] at
/// the far right of the AppBar would need a hardcoded, locale-fragile offset to
/// avoid sticking to the screen edge. The [shape] matches the app's shared menu
/// look (16px radius, 2px outlineVariant border).
class ContactsOverflowMenu extends StatelessWidget {
  const ContactsOverflowMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = Get.find<ContactsController>();
    return PopupMenuButton<_ContactsMenuAction>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          width: 2,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      onSelected: (action) {
        switch (action) {
          case _ContactsMenuAction.import:
            controller.importContacts(context);
          case _ContactsMenuAction.export:
            controller.exportContacts(context);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _ContactsMenuAction.import,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.file_download_outlined),
            title: Text(l.contactsImport),
          ),
        ),
        PopupMenuItem(
          value: _ContactsMenuAction.export,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.file_upload_outlined),
            title: Text(l.contactsExport),
          ),
        ),
      ],
    );
  }
}
