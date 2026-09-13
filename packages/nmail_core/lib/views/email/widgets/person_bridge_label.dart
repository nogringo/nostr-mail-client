import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/services/metadata_service.dart';
import 'package:nmail_core/utils/metadata_extensions.dart';
import 'package:nmail_core/widgets/nostr_avatar.dart';

class PersonBridgeLabel extends StatelessWidget {
  final String bridgePubkey;

  const PersonBridgeLabel({super.key, required this.bridgePubkey});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        NostrAvatar(pubkey: bridgePubkey, radius: 8),
        const SizedBox(width: 6),
        Flexible(
          child: Obx(() {
            final metadata = Get.find<MetadataService>().of(bridgePubkey).value;
            return Text(
              l.personCardViaBridge(
                metadata?.getBestName() ?? getAnonName(bridgePubkey),
              ),
            );
          }),
        ),
      ],
    );
  }
}
