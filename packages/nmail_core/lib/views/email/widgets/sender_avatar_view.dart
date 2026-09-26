import 'package:flutter/material.dart';
import 'package:nmail_core/views/email/email_controller.dart';
import 'package:nmail_core/views/email/widgets/sender_bridge_badge_view.dart';

import 'person_avatar.dart';

class SenderAvatarView extends StatelessWidget {
  const SenderAvatarView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = EmailController.to;
    final email = controller.email!;
    final mainAvatar = PersonAvatar(
      person: controller.senderPerson,
      radius: 24,
    );

    if (!email.isBridged) {
      return mainAvatar;
    }

    // Bridged: stack the legacy contact's avatar with a small badge for
    // the bridge that relayed the email.
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        mainAvatar,
        Positioned(
          right: -4,
          bottom: -4,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.surface, width: 2),
            ),
            child: SenderBridgeBadgeView(email: email),
          ),
        ),
      ],
    );
  }
}
