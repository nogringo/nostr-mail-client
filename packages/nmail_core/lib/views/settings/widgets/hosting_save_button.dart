import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/blossom_servers_controller.dart';
import '../../../controllers/bridges_controller.dart';
import '../../../controllers/dm_relays_controller.dart';
import '../../../controllers/nip65_relays_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

/// Publishes every hosting list holding staged edits. Each list is its own
/// record on the network, so one save can broadcast several events; untouched
/// lists are skipped.
///
/// The sections build the same controllers, and whichever mounts first owns
/// the instance the others share.
class HostingSaveButton extends StatelessWidget {
  const HostingSaveButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return GetBuilder<Nip65RelaysController>(
      init: Nip65RelaysController(),
      builder: (nip65Relays) => GetBuilder<DmRelaysController>(
        init: DmRelaysController(),
        builder: (dmRelays) => GetBuilder<BlossomServersController>(
          init: BlossomServersController(),
          builder: (blossomServers) => GetBuilder<BridgesController>(
            init: BridgesController(),
            builder: (bridges) {
              final pending = <Future<void> Function()>[
                if (nip65Relays.hasChanges) nip65Relays.saveChanges,
                if (dmRelays.hasChanges) dmRelays.saveChanges,
                if (blossomServers.hasChanges) blossomServers.saveChanges,
                if (bridges.hasChanges) bridges.saveChanges,
              ];
              final isSaving =
                  nip65Relays.isSaving ||
                  dmRelays.isSaving ||
                  blossomServers.isSaving ||
                  bridges.isSaving;

              return FilledButton(
                onPressed: pending.isEmpty || isSaving
                    ? null
                    : () async {
                        for (final save in pending) {
                          await save();
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l.actionSave),
              );
            },
          ),
        ),
      ),
    );
  }
}
