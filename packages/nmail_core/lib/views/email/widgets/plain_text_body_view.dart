import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nostr_mail/nostr_mail.dart';
import 'package:nmail_core/controllers/plain_text_body_controller.dart';
import 'package:nmail_core/models/email_person.dart';
import 'package:nmail_core/utils/confirm_open_link.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import 'package:nmail_core/utils/text_links.dart';

import 'person_anchor.dart';
import 'person_card_actions.dart';
import 'person_card_menu.dart';
import 'person_card_sheet.dart';

class PlainTextBodyView extends StatelessWidget {
  final Email email;

  const PlainTextBodyView({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final linkStyle = TextStyle(
      color: Theme.of(context).colorScheme.primary,
      decoration: TextDecoration.underline,
    );
    PersonCardActionsBuilder actionsFor(EmailPerson person) =>
        (actionContext, contact) =>
            buildPersonCardActions(actionContext, person, contact);

    return GetBuilder<PlainTextBodyController>(
      tag: email.id,
      init: PlainTextBodyController(
        // On web, the browser drops each \r from the text Cmd+C copies,
        // which shifts the selection by one character per line.
        email.body.replaceAll('\r\n', '\n'),
        onOpenUrl: (url) => confirmOpenLink(context, url),
        onOpenAddress: (person, position) {
          if (ResponsiveHelper.isNotMobile(context)) {
            Get.find<PlainTextBodyController>(
              tag: email.id,
            ).openMenu(person, position);
          } else {
            showPersonCardSheet(context, person, actionsFor(person));
          }
        },
      ),
      builder: (controller) => MenuAnchor(
        controller: controller.menuController,
        style: personCardMenuStyle(context),
        menuChildren: [
          if (controller.menuPerson case final person?)
            PersonCardMenu(
              person: person,
              actionContext: context,
              actions: actionsFor(person),
            ),
        ],
        child: SelectionArea(
          child: Text.rich(
            TextSpan(
              children: [
                for (final (i, segment) in controller.segments.indexed)
                  segment.kind == TextSegmentKind.text
                      ? TextSpan(text: segment.text)
                      : TextSpan(
                          text: segment.text,
                          style: linkStyle,
                          mouseCursor: SystemMouseCursors.click,
                          recognizer: controller.recognizers[i],
                        ),
              ],
            ),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
