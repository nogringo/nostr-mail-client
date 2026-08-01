import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/identities_controller.dart';
import 'widgets/discard_changes_dialog.dart';

/// Asks before leaving the identities page with unsaved edits, and throws them
/// away once confirmed. Returns whether the page may be left.
///
/// Wired as the route's `onExit` rather than a [PopScope] so it also covers the
/// browser back button, which changes the URL instead of popping the navigator.
Future<bool> confirmDiscardIdentityChanges(BuildContext context) async {
  if (!Get.isRegistered<IdentitiesController>()) return true;

  final controller = Get.find<IdentitiesController>();
  if (!controller.hasChanges) return true;

  final shouldDiscard = await showDialog<bool>(
    context: context,
    builder: (_) => const DiscardChangesDialog(),
  );
  if (shouldDiscard != true) return false;

  controller.discardChanges();
  return true;
}
