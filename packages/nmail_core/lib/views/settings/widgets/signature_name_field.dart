import 'package:flutter/material.dart';

import 'package:nmail_core/controllers/signature_form_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

class SignatureNameField extends StatelessWidget {
  final SignatureFormController controller;

  const SignatureNameField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => TextField(
        controller: controller.nameController,
        autofocus: !controller.isEditing,
        maxLength: SignatureFormController.maxNameLength,
        buildCounter:
            (_, {required currentLength, required isFocused, maxLength}) =>
                null,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => controller.editorFocusNode.requestFocus(),
        decoration: InputDecoration(
          labelText: l.signatureName,
          helperText: controller.isEditing ? null : l.signatureNameHint,
          errorText: controller.error == SignatureFormError.nameTaken
              ? l.signatureNameTaken
              : null,
        ),
      ),
    );
  }
}
