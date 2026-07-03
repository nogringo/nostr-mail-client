import 'package:flutter/material.dart';

import '../../../controllers/create_identity_controller.dart';
import '../../../l10n/generated/app_localizations.dart';

class DisplayNameField extends StatelessWidget {
  final CreateIdentityController controller;

  const DisplayNameField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return TextField(
      controller: controller.nameController,
      decoration: InputDecoration(labelText: l.profileDisplayNameLabel),
      textCapitalization: TextCapitalization.words,
    );
  }
}
