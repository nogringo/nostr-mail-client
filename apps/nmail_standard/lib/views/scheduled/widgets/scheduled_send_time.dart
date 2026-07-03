import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';

/// The future send time, shown where an email row shows its date. Labelled for
/// screen readers as "Sends <time>".
class ScheduledSendTime extends StatelessWidget {
  final String sendTime;
  final double fontSize;

  const ScheduledSendTime({
    super.key,
    required this.sendTime,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: l.scheduledSendsAt(sendTime),
      child: ExcludeSemantics(
        child: Text(
          sendTime,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}
