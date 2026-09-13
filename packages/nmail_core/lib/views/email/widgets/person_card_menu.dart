import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/models/email_person.dart';
import 'package:nmail_core/services/address_book_service.dart';
import 'package:nmail_core/utils/email_person_utils.dart';

import 'person_card_actions.dart';
import 'person_card_menu_header.dart';

class PersonCardMenu extends StatelessWidget {
  final EmailPerson person;
  final BuildContext actionContext;

  const PersonCardMenu({
    super.key,
    required this.person,
    required this.actionContext,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final contact = findEmailPersonContact(
        Get.find<AddressBookService>().contacts,
        person,
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          PersonCardMenuHeader(person: person),
          const Divider(height: 1),
          for (final action in buildPersonCardActions(
            actionContext,
            person,
            contact,
          ))
            MenuItemButton(
              leadingIcon: Icon(action.icon),
              onPressed: action.onPressed,
              child: Text(action.label),
            ),
        ],
      );
    });
  }
}
