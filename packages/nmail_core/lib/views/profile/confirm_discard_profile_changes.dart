import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../controllers/profile_controller.dart';
import '../settings/widgets/discard_changes_dialog.dart';

/// Asks before leaving the profile page with unsaved edits. Returns whether the
/// page may be left.
///
/// Wired as the route's `onExit` rather than a [PopScope] so it also covers the
/// browser back button, which changes the URL instead of popping the navigator.
Future<bool> confirmDiscardProfileChanges(BuildContext context) async {
  if (!GetIt.I.isRegistered<ProfileController>()) return true;
  if (!GetIt.I<ProfileController>().hasChanges) return true;

  final shouldDiscard = await showDialog<bool>(
    context: context,
    builder: (_) => const DiscardChangesDialog(),
  );
  return shouldDiscard == true;
}
