import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../controllers/contacts_controller.dart';
import 'contact_actions.dart';
import 'contact_detail_pane.dart';

class MobileContactDetailPage extends StatelessWidget {
  final String uid;

  const MobileContactDetailPage({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final controller = GetIt.I<ContactsController>();
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final contact = controller.addressBookService.contacts.value
            .firstWhereOrNull((contact) => contact.uid == uid);
        return Scaffold(
          appBar: AppBar(
            actionsPadding: .only(right: 8),
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
      },
    );
  }
}
