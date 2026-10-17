import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:nmail_core/controllers/signatures_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/utils/key_address.dart';
import 'package:nmail_core/utils/toast_helper.dart';
import 'settings_group.dart';
import 'settings_section_header.dart';
import 'key_format_pill.dart';
import 'show_signature_picker.dart';
import 'signature_choice_labels.dart';
import 'signature_choice_tile.dart';

/// The signatures of one entry of `identities`, falling back to the default.
class SignatureIdentitySection extends StatelessWidget {
  const SignatureIdentitySection({super.key, required this.identity});

  final MailAddress identity;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = GetIt.I<SignaturesController>();
    final choice = controller.choiceOf(identity);
    final name = identity.personalName?.trim();
    final hasName = name != null && name.isNotEmpty;
    final pubkey = GetIt.I<NostrMailService>().getPublicKey();
    final keyMatch = pubkey == null
        ? null
        : matchKeyAddress(identity.email, pubkey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (keyMatch == null)
          SettingsSectionHeader(
            title: hasName ? name : identity.email,
            description: hasName ? identity.email : null,
          )
        else
          // As the identities list shows a key address: a 64-character local
          // part has nowhere to wrap but inside the domain.
          Tooltip(
            message: identity.email,
            triggerMode: TooltipTriggerMode.tap,
            child: _keyAddressHeader(keyMatch, hasName ? name : null),
          ),
        SettingsGroup(
          rows: [
            for (final use in SignatureUse.values)
              (index, count) => SignatureChoiceTile(
                use: use,
                value: switch (choice?.idFor(
                  reply: use == SignatureUse.reply,
                )) {
                  null => _defaultLabel(l, controller, use),
                  final id => signatureNameOf(l, controller, id),
                },
                index: index,
                count: count,
                onTap: () => _pick(context, controller, use),
              ),
          ],
        ),
      ],
    );
  }

  static Widget _keyAddressHeader(KeyAddressMatch match, String? name) {
    final address = TextSpan(
      children: [
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: KeyFormatPill(format: match.format),
        ),
        TextSpan(text: '@${match.domain}'),
      ],
    );
    return name == null
        ? SettingsSectionHeader.rich(titleSpan: address)
        : SettingsSectionHeader.rich(
            titleSpan: TextSpan(text: name),
            descriptionSpan: address,
          );
  }

  static String _defaultLabel(
    AppLocalizations l,
    SignaturesController controller,
    SignatureUse use,
  ) => l.signatureInheritDefault(
    signatureNameOf(
      l,
      controller,
      controller.defaultChoice?.idFor(reply: use == SignatureUse.reply),
    ),
  );

  Future<void> _pick(
    BuildContext context,
    SignaturesController controller,
    SignatureUse use,
  ) async {
    final l = AppLocalizations.of(context);
    final current = controller
        .choiceOf(identity)
        ?.idFor(reply: use == SignatureUse.reply);
    final picked = await showSignaturePicker(
      context,
      title: signatureUseLabel(l, use),
      selectedId: current == null
          ? null
          : knownSignatureId(controller, current),
      inheritLabel: _defaultLabel(l, controller, use),
    );
    if (picked == null) return;
    try {
      await controller.setForIdentity(identity, use, picked.id);
    } catch (_) {
      if (context.mounted) ToastHelper.error(context, l.signatureSaveFailed);
    }
  }
}
