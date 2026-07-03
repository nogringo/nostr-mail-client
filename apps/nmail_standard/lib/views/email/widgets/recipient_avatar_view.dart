import 'package:flutter/material.dart';
import 'package:nmail_standard/views/email/email_controller.dart';
import 'package:nmail_standard/views/email/widgets/main_recipient_avatar_view.dart';

import 'recipient_bridge_badge_view.dart';

class RecipientAvatarView extends StatelessWidget {
  const RecipientAvatarView({super.key});

  @override
  Widget build(BuildContext context) {
    final mainAvatar = MainRecipientAvatarView();

    if (!EmailController.to.email!.isBridged) {
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
          right: -3,
          bottom: -3,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.surface, width: 1.5),
            ),
            child: RecipientBridgeBadgeView(),
          ),
        ),
      ],
    );
  }
}
