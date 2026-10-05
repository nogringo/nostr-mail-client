import 'package:flutter/material.dart';

import 'package:nmail_core/models/email_person.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import 'package:nmail_core/views/shared/layout_constants.dart';

import 'person_card_actions.dart';
import 'person_card_menu.dart';
import 'person_card_sheet.dart';

MenuStyle personCardMenuStyle(BuildContext context) => MenuStyle(
  shape: WidgetStatePropertyAll(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(LayoutConstants.borderRadius),
      side: BorderSide(
        width: 2,
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
    ),
  ),
);

/// Opens the person card from whatever [builder] renders: a bottom sheet on
/// mobile, a menu anchored to the widget on wider screens.
class PersonAnchor extends StatelessWidget {
  final EmailPerson person;
  final Widget Function(BuildContext context, VoidCallback open) builder;

  /// Defaults to [buildPersonCardActions].
  final PersonCardActionsBuilder? actions;

  /// Rebuilds the open card's [actions] when it notifies.
  final Listenable? actionsListenable;

  const PersonAnchor({
    super.key,
    required this.person,
    required this.builder,
    this.actions,
    this.actionsListenable,
  });

  @override
  Widget build(BuildContext context) {
    final actions =
        this.actions ??
        (actionContext, contact) =>
            buildPersonCardActions(actionContext, person, contact);
    if (!ResponsiveHelper.isNotMobile(context)) {
      return builder(
        context,
        () => showPersonCardSheet(
          context,
          person,
          actions,
          actionsListenable: actionsListenable,
        ),
      );
    }
    return MenuAnchor(
      alignmentOffset: const Offset(0, 4),
      style: personCardMenuStyle(context),
      menuChildren: [
        PersonCardMenu(
          person: person,
          actionContext: context,
          actions: actions,
          actionsListenable: actionsListenable,
        ),
      ],
      builder: (context, controller, _) => builder(
        context,
        () => controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}
