import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/auth_controller.dart';
import 'logout_dialog.dart';

Future<void> confirmLogout(BuildContext context) async {
  final auth = Get.find<AuthController>();
  final pubkey = auth.currentPubkey;
  if (pubkey == null) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => LogoutDialog(pubkey: pubkey),
  );
  if (confirmed != true || pubkey != auth.currentPubkey) return;

  await auth.logout();
}
