import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:nmail_core/controllers/signatures_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/toast_helper.dart';
import 'settings_group.dart';
import 'settings_section_header.dart';
import 'show_signature_picker.dart';
import 'signature_choice_labels.dart';
import 'signature_choice_tile.dart';

class SignatureDefaultSection extends StatelessWidget {
  const SignatureDefaultSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = GetIt.I<SignaturesController>();
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsSectionHeader(
            title: l.signaturesDefaultHeader,
            description: controller.identities.isEmpty
                ? null
                : l.signaturesDefaultDescription,
          ),
          SettingsGroup(
            rows: [
              for (final use in SignatureUse.values)
                (index, count) => SignatureChoiceTile(
                  use: use,
                  value: signatureNameOf(
                    l,
                    controller,
                    controller.defaultChoice?.idFor(
                      reply: use == SignatureUse.reply,
                    ),
                  ),
                  index: index,
                  count: count,
                  onTap: () => _pick(context, controller, use),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pick(
    BuildContext context,
    SignaturesController controller,
    SignatureUse use,
  ) async {
    final l = AppLocalizations.of(context);
    final current = controller.defaultChoice?.idFor(
      reply: use == SignatureUse.reply,
    );
    final picked = await showSignaturePicker(
      context,
      title: signatureUseLabel(l, use),
      selectedId: knownSignatureId(controller, current),
    );
    if (picked == null) return;
    try {
      await controller.setDefault(use, picked.id ?? '');
    } catch (_) {
      if (context.mounted) ToastHelper.error(context, l.signatureSaveFailed);
    }
  }
}
