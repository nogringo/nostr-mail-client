import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:nmail_core/controllers/auth_controller.dart';
import 'package:nmail_core/utils/key_address.dart';
import 'package:nmail_core/views/shared/key_format_pill.dart';

/// Shows a key local part by its format name and never truncates the domain.
class AccountEmailText extends StatelessWidget {
  const AccountEmailText({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = GetIt.I<AuthController>();
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant);

    return ListenableBuilder(
      listenable: Listenable.merge([auth.activeNpub, auth.activePubkey]),
      builder: (context, _) {
        final email = auth.primaryEmail;
        final pubkey = auth.currentPubkey;
        if (email == null || pubkey == null) return const SizedBox.shrink();

        final keyMatch = matchKeyAddress(email, pubkey);
        final atIndex = email.lastIndexOf('@');
        final domain = atIndex < 0 ? '' : email.substring(atIndex);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (keyMatch == null)
              Flexible(
                child: Text(
                  atIndex < 0 ? email : email.substring(0, atIndex),
                  style: textStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            else
              KeyFormatPill(format: keyMatch.format),
            Text(domain, style: textStyle, maxLines: 1),
          ],
        );
      },
    );
  }
}
