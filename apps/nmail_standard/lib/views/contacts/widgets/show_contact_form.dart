import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_address_book/nostr_address_book.dart';

import '../../../app/routes/app_routes.dart';
import '../../../controllers/contact_form_controller.dart';
import '../../../controllers/contacts_controller.dart';
import '../../../models/address_book_contact_form.dart';
import '../../../utils/responsive_helper.dart';
import 'contact_form_sheet.dart';

Future<void> showContactForm(
  BuildContext context, {
  AddressBookContact? contact,
  AddressBookContactForm? initialForm,
}) async {
  if (!Get.isRegistered<ContactsController>()) {
    Get.put(ContactsController());
  }

  // Mobile: a full-screen go_router route (ContactFormPage owns its
  // controller via GetBuilder). Desktop: a centered dialog whose controller
  // is created and disposed locally here.
  if (!ResponsiveHelper.isNotMobile(context)) {
    await context.push<void>(
      AppRoutes.contactForm,
      extra: {'contact': contact, 'initialForm': initialForm},
    );
    return;
  }

  final tag = UniqueKey().toString();
  final controller = Get.put(
    ContactFormController(contact: contact, initialForm: initialForm),
    tag: tag,
  );
  try {
    return await showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ContactFormSheet(controller: controller),
        ),
      ),
    );
  } finally {
    Get.delete<ContactFormController>(tag: tag);
  }
}
