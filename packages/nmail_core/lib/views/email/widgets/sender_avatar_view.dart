import 'package:flutter/material.dart';
import 'package:nmail_core/views/email/email_controller.dart';

import 'bridged_person_avatar.dart';

class SenderAvatarView extends StatelessWidget {
  const SenderAvatarView({super.key});

  @override
  Widget build(BuildContext context) {
    return BridgedPersonAvatar(
      person: EmailController.to.senderPerson,
      radius: 24,
    );
  }
}
