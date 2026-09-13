import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/models/email_person.dart';
import 'package:nmail_core/services/address_book_service.dart';
import 'package:nmail_core/utils/email_person_utils.dart';

import 'person_card_actions.dart';
import 'person_card_header.dart';

Future<void> showPersonCardSheet(BuildContext context, EmailPerson person) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => PersonCardSheet(person: person, actionContext: context),
  );
}

class PersonCardSheet extends StatelessWidget {
  final EmailPerson person;
  final BuildContext actionContext;

  const PersonCardSheet({
    super.key,
    required this.person,
    required this.actionContext,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        final contact = findEmailPersonContact(
          Get.find<AddressBookService>().contacts,
          person,
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PersonCardHeader(person: person),
            const Divider(),
            for (final action in buildPersonCardActions(
              actionContext,
              person,
              contact,
            ))
              ListTile(
                leading: Icon(action.icon),
                title: Text(action.label),
                onTap: () {
                  Navigator.pop(context);
                  action.onPressed();
                },
              ),
          ],
        );
      }),
    );
  }
}
