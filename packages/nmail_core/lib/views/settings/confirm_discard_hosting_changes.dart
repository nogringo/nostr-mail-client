import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/blossom_servers_controller.dart';
import '../../controllers/bridges_controller.dart';
import '../../controllers/dm_relays_controller.dart';
import '../../controllers/nip65_relays_controller.dart';
import 'widgets/discard_changes_dialog.dart';

/// Asks before leaving the hosting page with staged edits, and throws them away
/// once confirmed. Returns whether the page may be left.
///
/// Wired as the route's `onExit` rather than a [PopScope] so it also covers the
/// browser back button, which changes the URL instead of popping the navigator.
Future<bool> confirmDiscardHostingChanges(BuildContext context) async {
  final isReady =
      Get.isRegistered<Nip65RelaysController>() &&
      Get.isRegistered<DmRelaysController>() &&
      Get.isRegistered<BlossomServersController>() &&
      Get.isRegistered<BridgesController>();
  if (!isReady) return true;

  final nip65Relays = Get.find<Nip65RelaysController>();
  final dmRelays = Get.find<DmRelaysController>();
  final blossomServers = Get.find<BlossomServersController>();
  final bridges = Get.find<BridgesController>();

  final discards = <VoidCallback>[
    if (nip65Relays.hasChanges) nip65Relays.discardChanges,
    if (dmRelays.hasChanges) dmRelays.discardChanges,
    if (blossomServers.hasChanges) blossomServers.discardChanges,
    if (bridges.hasChanges) bridges.discardChanges,
  ];
  if (discards.isEmpty) return true;

  final shouldDiscard = await showDialog<bool>(
    context: context,
    builder: (_) => const DiscardChangesDialog(),
  );
  if (shouldDiscard != true) return false;

  for (final discard in discards) {
    discard();
  }
  return true;
}
