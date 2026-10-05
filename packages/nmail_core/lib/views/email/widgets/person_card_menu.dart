import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:nmail_core/models/email_person.dart';
import 'package:nmail_core/services/address_book_service.dart';
import 'package:nmail_core/utils/email_person_utils.dart';

import 'person_card_actions.dart';
import 'person_card_menu_header.dart';

class PersonCardMenu extends StatelessWidget {
  final EmailPerson person;
  final BuildContext actionContext;
  final PersonCardActionsBuilder actions;
  final Listenable? actionsListenable;

  const PersonCardMenu({
    super.key,
    required this.person,
    required this.actionContext,
    required this.actions,
    this.actionsListenable,
  });

  @override
  Widget build(BuildContext context) {
    final contacts = GetIt.I<AddressBookService>().contacts;
    return ListenableBuilder(
      listenable: Listenable.merge([contacts, actionsListenable]),
      builder: (context, _) {
        final contact = findEmailPersonContact(contacts.value, person);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            PersonCardMenuHeader(person: person),
            const Divider(height: 1),
            for (final action in actions(actionContext, contact))
              MenuItemButton(
                leadingIcon: Icon(action.icon),
                onPressed: action.onPressed,
                child: Text(action.label),
              ),
          ],
        );
      },
    );
  }
}
