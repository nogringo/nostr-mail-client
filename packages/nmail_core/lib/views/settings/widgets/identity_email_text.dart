import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/identities_controller.dart';

class IdentityEmailText extends StatelessWidget {
  final MailAddress identity;
  final bool isMarked;

  const IdentityEmailText({
    super.key,
    required this.identity,
    required this.isMarked,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IdentitiesController>();
    final disabledColor = Theme.of(context).disabledColor;
    final decoration = isMarked ? TextDecoration.lineThrough : null;
    final baseStyle = TextStyle(
      fontSize: 14,
      decoration: decoration,
      color: isMarked ? disabledColor : null,
    );

    final match = controller.matchedKeyFormat(identity);
    if (match == null) {
      return Text(
        identity.email,
        overflow: TextOverflow.ellipsis,
        style: baseStyle,
      );
    }

    final accentColor = isMarked
        ? disabledColor
        : Theme.of(context).colorScheme.primary;
    return Tooltip(
      message: '${match.localPart}@${match.domain}',
      triggerMode: TooltipTriggerMode.tap,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: match.format.name,
              style: baseStyle.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(text: '@${match.domain}', style: baseStyle),
          ],
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
