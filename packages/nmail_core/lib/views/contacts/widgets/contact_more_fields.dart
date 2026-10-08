import 'package:flutter/material.dart';

import '../../../controllers/contact_form_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'quiet_field.dart';

class ContactMoreFields extends StatelessWidget {
  final ContactFormController controller;

  const ContactMoreFields({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (!controller.moreFieldsExpanded) {
          return Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: controller.expandMoreFields,
              icon: const Icon(Icons.expand_more, size: 18),
              label: Text(l.contactsMoreFields),
            ),
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: QuietField(
                label: l.contactsOrganizationLabel,
                controller: controller.organizationController,
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: QuietField(
                label: l.contactsJobTitleLabel,
                controller: controller.jobTitleController,
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        );
      },
    );
  }
}
