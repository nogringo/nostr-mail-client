import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nostr_address_book/nostr_address_book.dart';

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

  final tag = UniqueKey().toString();
  Get.put(
    ContactFormController(contact: contact, initialForm: initialForm),
    tag: tag,
  );
  final form = ContactFormSheet(controllerTag: tag);
  if (ResponsiveHelper.isNotMobile(context)) {
    try {
      return await showDialog<void>(
        context: context,
        builder: (_) => Dialog(
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: form,
          ),
        ),
      );
    } finally {
      Get.delete<ContactFormController>(tag: tag);
    }
  }

  try {
    return await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => form,
    );
  } finally {
    Get.delete<ContactFormController>(tag: tag);
  }
}
