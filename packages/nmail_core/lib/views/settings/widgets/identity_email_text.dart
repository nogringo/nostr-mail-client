import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../controllers/identities_controller.dart';
import 'package:nmail_core/views/shared/key_format_pill.dart';

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
    final controller = GetIt.I<IdentitiesController>();
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

    return Tooltip(
      message: '${match.localPart}@${match.domain}',
      triggerMode: TooltipTriggerMode.tap,
      child: Text.rich(
        TextSpan(
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Opacity(
                opacity: isMarked ? 0.38 : 1,
                child: KeyFormatPill(format: match.format),
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
