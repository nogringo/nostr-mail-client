import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_address_book/nostr_address_book.dart';

import '../../../app/routes/app_routes.dart';
import '../../../controllers/contact_form_controller.dart';
import 'package:nmail_core/models/address_book_contact_form.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import 'contact_form_sheet.dart';

Future<void> showContactForm(
  BuildContext context, {
  AddressBookContact? contact,
  AddressBookContactForm? initialForm,
}) async {
  // Mobile: a full-screen go_router route (ContactFormPage owns its
  // controller via ControllerBuilder). Desktop: a centered dialog whose
  // controller is created and disposed locally here.
  if (!ResponsiveHelper.isNotMobile(context)) {
    await context.push<void>(
      AppRoutes.contactForm,
      extra: {'contact': contact, 'initialForm': initialForm},
    );
    return;
  }

  final controller = ContactFormController(
    contact: contact,
    initialForm: initialForm,
  );
  ModalRoute<Object?>? route;
  try {
    return await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        route = ModalRoute.of(dialogContext);
        return Dialog(
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ContactFormSheet(controller: controller),
          ),
        );
      },
    );
  } finally {
    // The fields keep building through the exit animation, so their text
    // controllers are disposed once the route is gone, not on pop.
    final shown = route;
    if (shown == null) {
      controller.dispose();
    } else {
      shown.completed.then((_) => controller.dispose());
    }
  }
}
