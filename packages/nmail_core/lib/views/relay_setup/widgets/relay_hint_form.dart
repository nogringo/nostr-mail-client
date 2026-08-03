import 'package:flutter/material.dart';

import 'package:nmail_core/controllers/relay_setup_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/relay_hint_parser.dart';

/// One field for every way the user can point us at their relay list: a relay
/// URL, a NIP-05 address, or an nprofile. The hint may name any account, since
/// all we take from it is a set of relays to query.
class RelayHintForm extends StatelessWidget {
  const RelayHintForm({super.key, required this.controller});

  final RelaySetupController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: controller.hintController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            autocorrect: false,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.search,
            onFieldSubmitted: (_) => controller.searchHint(),
            onChanged: (_) => controller.clearHintOutcome(),
            decoration: InputDecoration(
              labelText: l.relaySetupHintLabel,
              hintText: l.relaySetupHintHint,
              helperText: l.relaySetupHintHelper,
              helperMaxLines: 2,
              errorMaxLines: 3,
              errorText: switch (controller.hintOutcome) {
                null => null,
                HintOutcome.notFound => l.relaySetupHintNotFound,
                HintOutcome.unreachable => l.relaySetupHintUnreachable,
                HintOutcome.nip05NotFound => l.relaySetupHintNip05NotFound,
                HintOutcome.nip05Unreachable => l.relaySetupHintNip05Unreachable,
              },
            ),
            validator: (value) => switch (parseRelayHint(value ?? '').error) {
              null => null,
              RelayHintError.empty => l.relaySetupHintErrorEmpty,
              RelayHintError.npubWithoutRelays => l.relaySetupHintErrorNpub,
              RelayHintError.malformed => l.relaySetupHintErrorMalformed,
            },
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: controller.isSearchingHint || controller.isLeaving
                ? null
                : controller.searchHint,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: controller.isSearchingHint
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l.relaySetupSearch),
          ),
        ],
      ),
    );
  }
}
