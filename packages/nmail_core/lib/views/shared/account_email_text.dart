import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/auth_controller.dart';
import 'package:nmail_core/utils/key_address.dart';

/// Shows a key local part by its format name and never truncates the domain.
class AccountEmailText extends StatelessWidget {
  const AccountEmailText({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant);

    return Obx(() {
      final email = auth.primaryEmail;
      final pubkey = auth.currentPubkey;
      if (email == null || pubkey == null) return const SizedBox.shrink();

      final keyMatch = matchKeyAddress(email, pubkey);
      final atIndex = email.lastIndexOf('@');
      final localPart =
          keyMatch?.format.name ??
          (atIndex < 0 ? email : email.substring(0, atIndex));
      final domain = atIndex < 0 ? '' : email.substring(atIndex);

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              localPart,
              style: keyMatch == null
                  ? textStyle
                  : textStyle?.copyWith(color: colorScheme.primary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(domain, style: textStyle, maxLines: 1),
        ],
      );
    });
  }
}
