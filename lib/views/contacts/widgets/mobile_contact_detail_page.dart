import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/contacts_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'contact_actions.dart';
import 'contact_detail_pane.dart';

class MobileContactDetailPage extends StatelessWidget {
  final String uid;

  const MobileContactDetailPage({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ContactsController>();
    final l = AppLocalizations.of(context);
    return Obx(() {
      final contact = controller.addressBookService.contacts.firstWhereOrNull(
        (contact) => contact.uid == uid,
      );
      return Scaffold(
        appBar: AppBar(
          title: Text(contact?.index.formattedName ?? l.contactsTitle),
          actionsPadding: const EdgeInsets.only(right: 8),
          actions: [
            if (contact != null)
              ContactActions(
                contact: contact,
                onDeleted: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              ),
          ],
        ),
        body: ContactDetailPane(
          uid: uid,
          onDeleted: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
      );
    });
  }
}
