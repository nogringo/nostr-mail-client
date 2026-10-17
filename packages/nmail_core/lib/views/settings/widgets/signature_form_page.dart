import 'package:flutter/material.dart';

import 'package:nmail_core/controllers/signature_form_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'signature_form_error_text.dart';
import 'signature_form_fields.dart';
import 'signature_form_title.dart';

/// The signature form as a full-screen dialog, on phones.
class SignatureFormPage extends StatelessWidget {
  final SignatureFormController controller;

  const SignatureFormPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        // AppBar only centers a leading that is itself an IconButton.
        leading: Center(
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) => IconButton(
              icon: const Icon(Icons.close),
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              onPressed: controller.isSaving
                  ? null
                  : () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(signatureFormTitle(l, controller)),
        actionsPadding: const EdgeInsets.only(right: 8),
        actions: [
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) => FilledButton(
              onPressed: controller.isSaving || !controller.canSave
                  ? null
                  : () => _save(context),
              child: Text(l.actionSave),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SignatureFormFields(controller: controller),
              SignatureFormErrorText(controller: controller),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    final saved = await controller.save();
    if (saved != null && context.mounted) Navigator.pop(context, saved);
  }
}
