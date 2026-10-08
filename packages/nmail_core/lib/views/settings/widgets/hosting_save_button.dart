import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../controllers/blossom_servers_controller.dart';
import '../../../controllers/bridges_controller.dart';
import '../../../controllers/dm_relays_controller.dart';
import '../../../controllers/nip65_relays_controller.dart';
import '../../../controllers/private_relays_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

/// Publishes every hosting list holding staged edits. Each list is its own
/// record on the network, so one save can broadcast several events; untouched
/// lists are skipped.
class HostingSaveButton extends StatelessWidget {
  const HostingSaveButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    final nip65Relays = GetIt.I<Nip65RelaysController>();
    final dmRelays = GetIt.I<DmRelaysController>();
    final privateRelays = GetIt.I<PrivateRelaysController>();
    final blossomServers = GetIt.I<BlossomServersController>();
    final bridges = GetIt.I<BridgesController>();

    return ListenableBuilder(
      listenable: Listenable.merge([
        nip65Relays,
        dmRelays,
        privateRelays,
        blossomServers,
        bridges,
      ]),
      builder: (context, _) {
        final pending = <Future<void> Function()>[
          if (nip65Relays.hasChanges) nip65Relays.saveChanges,
          if (dmRelays.hasChanges) dmRelays.saveChanges,
          if (privateRelays.hasChanges) privateRelays.saveChanges,
          if (blossomServers.hasChanges) blossomServers.saveChanges,
          if (bridges.hasChanges) bridges.saveChanges,
        ];
        final isSaving =
            nip65Relays.isSaving ||
            dmRelays.isSaving ||
            privateRelays.isSaving ||
            blossomServers.isSaving ||
            bridges.isSaving;
        if (pending.isEmpty && !isSaving) return const SizedBox.shrink();

        return FilledButton(
          onPressed: isSaving
              ? null
              : () async {
                  for (final save in pending) {
                    await save();
                  }
                },
          child: Text(l.actionSave),
        );
      },
    );
  }
}
