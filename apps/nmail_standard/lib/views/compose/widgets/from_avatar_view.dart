import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:nmail_standard/controllers/auth_controller.dart';
import 'package:nmail_standard/models/from_option.dart';
import 'package:nmail_standard/widgets/nostr_avatar.dart';

class FromAvatarView extends StatelessWidget {
  final FromOption option;

  const FromAvatarView({super.key, required this.option});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final pubkey = authController.publicKey!;

    return NostrAvatar(
      pubkey: pubkey,
      metadata: Metadata(
        pubKey: pubkey,
        picture: option.picture,
        displayName: option.displayName,
      ),
      radius: 14,
    );
  }
}
