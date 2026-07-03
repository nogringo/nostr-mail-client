import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/contacts_controller.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Trailing actions for a phone row in the contact detail: call and SMS.
///
/// Each button is shown only when the platform actually has an app to handle
/// the matching scheme (see [ContactsController.canCall] / [canSms]), so the
/// row stays clean on devices or desktops without a dialer or SMS app.
class PhoneActionButtons extends StatelessWidget {
  final String phone;

  const PhoneActionButtons({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ContactsController>();
    final l = AppLocalizations.of(context);
    return Obx(() {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (controller.canCall.value)
            IconButton(
              icon: const Icon(Icons.call_outlined),
              tooltip: l.contactsCall,
              onPressed: () => controller.callNumber(phone),
            ),
          if (controller.canSms.value)
            IconButton(
              icon: const Icon(Icons.sms_outlined),
              tooltip: l.contactsSendSms,
              onPressed: () => controller.smsNumber(phone),
            ),
        ],
      );
    });
  }
}
