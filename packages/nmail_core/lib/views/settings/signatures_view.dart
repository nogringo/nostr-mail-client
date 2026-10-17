import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:nmail_core/controllers/signatures_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import 'widgets/legacy_signature_tile.dart';
import 'widgets/settings_group.dart';
import 'widgets/settings_section_header.dart';
import 'widgets/signature_add_tile.dart';
import 'widgets/signature_default_section.dart';
import 'widgets/signature_identity_section.dart';
import 'widgets/signature_tile.dart';

class SignaturesView extends StatelessWidget {
  const SignaturesView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = GetIt.I<SignaturesController>();

    return Scaffold(
      appBar: AppBar(title: Text(l.signaturesTitle)),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: ResponsiveCenter(
            maxWidth: 600,
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                final legacy = controller.legacyText;
                final signatures = controller.signatures;
                final isEmpty = legacy == null && signatures.isEmpty;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SettingsSectionHeader(
                      title: l.signaturesListHeader,
                      description: isEmpty
                          ? l.signaturesEmptyDescription(
                              l.settingsEmailSignatureDefault,
                            )
                          : null,
                    ),
                    SettingsGroup(
                      rows: [
                        if (legacy != null)
                          (index, count) => LegacySignatureTile(
                            text: legacy,
                            index: index,
                            count: count,
                          ),
                        for (final signature in signatures)
                          (index, count) => SignatureTile(
                            signature: signature,
                            index: index,
                            count: count,
                          ),
                        (index, count) =>
                            SignatureAddTile(index: index, count: count),
                      ],
                    ),
                    if (signatures.isNotEmpty) ...[
                      const SignatureDefaultSection(),
                      for (final identity in controller.identities)
                        SignatureIdentitySection(identity: identity),
                    ],
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
