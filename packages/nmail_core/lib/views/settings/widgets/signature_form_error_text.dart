import 'package:flutter/material.dart';

import 'package:nmail_core/controllers/signature_form_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

/// The errors the name field does not show itself.
class SignatureFormErrorText extends StatelessWidget {
  final SignatureFormController controller;

  const SignatureFormErrorText({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final message = switch (controller.error) {
          SignatureFormError.imageFailed => l.signatureImageFailed,
          SignatureFormError.saveFailed => l.signatureSaveFailed,
          SignatureFormError.nameTaken || null => null,
        };
        if (message == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        );
      },
    );
  }
}
