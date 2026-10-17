import 'package:flutter/material.dart';

import 'package:nmail_core/controllers/signature_form_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'signature_form_error_text.dart';
import 'signature_form_fields.dart';
import 'signature_form_title.dart';

/// The signature form in a centered dialog, on wide layouts.
class SignatureFormSheet extends StatelessWidget {
  final SignatureFormController controller;

  const SignatureFormSheet({super.key, required this.controller});

  static const _gutter = 24.0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _gutter),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    signatureFormTitle(l, controller),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ListenableBuilder(
                  listenable: controller,
                  builder: (context, _) => IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onPressed: controller.isSaving
                        ? null
                        : () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(_gutter, 8, _gutter, 0),
              child: SignatureFormFields(controller: controller),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _gutter),
            child: SignatureFormErrorText(controller: controller),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _gutter),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 8,
              children: [
                ListenableBuilder(
                  listenable: controller,
                  builder: (context, _) => TextButton(
                    onPressed: controller.isSaving
                        ? null
                        : () => Navigator.pop(context),
                    child: Text(l.actionCancel),
                  ),
                ),
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
          ),
        ],
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    final saved = await controller.save();
    if (saved != null && context.mounted) Navigator.pop(context, saved);
  }
}
