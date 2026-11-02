import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:nmail_core/controllers/compose_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/email_person.dart';
import 'package:nmail_core/models/recipient.dart';
import 'package:nmail_core/services/metadata_service.dart';
import 'package:nmail_core/utils/email_person_utils.dart';

/// Names, under the chips of one address field, the recipients the email
/// cannot reach, or could not check yet: the colour of their chip alone does
/// not say why.
class UnreachableRecipientsText extends StatelessWidget {
  const UnreachableRecipientsText({
    super.key,
    required this.controller,
    required this.recipients,
  });

  final ComposeController controller;
  final List<Recipient> recipients;

  @override
  Widget build(BuildContext context) {
    final reachability = {
      for (final r in recipients) ?r.pubkey: ?controller.reachabilityOf(r),
    };
    final metadata = GetIt.I<MetadataService>();

    return ListenableBuilder(
      listenable: Listenable.merge([
        controller,
        ...reachability.values,
        for (final pubkey in reachability.keys) metadata.of(pubkey),
      ]),
      builder: (context, _) {
        List<String> namesOf(RecipientReachability state) => [
          for (final MapEntry(key: pubkey, :value) in reachability.entries)
            if (value.value == state)
              emailPersonName(EmailPerson.nostr(pubkey)),
        ];
        final unreachable = namesOf(RecipientReachability.unreachable);
        final unknown = namesOf(RecipientReachability.unknown);
        if (unreachable.isEmpty && unknown.isEmpty) {
          return const SizedBox.shrink();
        }

        final l = AppLocalizations.of(context);
        final theme = Theme.of(context);
        final style = theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        );
        final queued = controller.sendsUncheckedRecipients;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (unreachable.isNotEmpty)
                Text(
                  l.composeRecipientsUnreachable(
                    unreachable.length,
                    unreachable.join(', '),
                  ),
                  style: style,
                ),
              if (unknown.isNotEmpty && queued)
                Text(
                  l.composeRecipientsUncheckedQueued(
                    unknown.length,
                    unknown.join(', '),
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              else if (unknown.isNotEmpty)
                Text(
                  l.composeRecipientsUnchecked(
                    unknown.length,
                    unknown.join(', '),
                  ),
                  style: style,
                ),
            ],
          ),
        );
      },
    );
  }
}
