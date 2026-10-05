import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:nmail_core/models/email_person.dart';
import 'package:nmail_core/services/address_book_service.dart';
import 'package:nmail_core/utils/email_person_utils.dart';

import 'person_card_actions.dart';
import 'person_card_header.dart';

Future<void> showPersonCardSheet(
  BuildContext context,
  EmailPerson person,
  PersonCardActionsBuilder actions, {
  Listenable? actionsListenable,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => PersonCardSheet(
      person: person,
      actionContext: context,
      actions: actions,
      actionsListenable: actionsListenable,
    ),
  );
}

class PersonCardSheet extends StatelessWidget {
  final EmailPerson person;
  final BuildContext actionContext;
  final PersonCardActionsBuilder actions;
  final Listenable? actionsListenable;

  const PersonCardSheet({
    super.key,
    required this.person,
    required this.actionContext,
    required this.actions,
    this.actionsListenable,
  });

  @override
  Widget build(BuildContext context) {
    final contacts = GetIt.I<AddressBookService>().contacts;
    return SafeArea(
      child: ListenableBuilder(
        listenable: Listenable.merge([contacts, actionsListenable]),
        builder: (context, _) {
          final contact = findEmailPersonContact(contacts.value, person);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PersonCardHeader(person: person),
              const Divider(),
              for (final action in actions(actionContext, contact))
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
        },
      ),
    );
  }
}
