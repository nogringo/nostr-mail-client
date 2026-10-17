import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:nmail_core/controllers/auth_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/key_address.dart';
import 'package:nmail_core/views/shared/key_format_pill.dart';

class FromAddressText extends StatelessWidget {
  const FromAddressText({super.key, required this.address, this.style});

  final String address;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final pubkey = GetIt.I<AuthController>().currentPubkey;
    final match = pubkey == null ? null : matchKeyAddress(address, pubkey);
    if (match == null) {
      return Text(address, style: style, overflow: TextOverflow.ellipsis);
    }
    if (match.domain == 'nostr') {
      return Text(
        AppLocalizations.of(context).composeFromNostrOnly,
        style: style,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Tooltip(
      message: address,
      triggerMode: TooltipTriggerMode.tap,
      child: Text.rich(
        TextSpan(
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: KeyFormatPill(format: match.format),
            ),
            TextSpan(text: '@${match.domain}'),
          ],
        ),
        style: style,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
