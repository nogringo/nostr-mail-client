import 'package:flutter/material.dart';
import 'package:ndk/ndk.dart';

import '../../../app/config/app_config.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/segmented_list_shape.dart';
import 'package:nmail_core/widgets/nostr_avatar.dart';
import 'package:nmail_core/widgets/nostr_display_name.dart';
import 'about_icon_link_button.dart';

/// Bottom row of the identity group: the app, then who makes it.
class AboutDeveloperTile extends StatelessWidget {
  const AboutDeveloperTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final pubkey = Nip19.decode(AppConfig.developerNpub);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: segmentedListGap / 2,
      ),
      child: ListTile(
        tileColor: theme.colorScheme.surfaceContainerHigh,
        shape: segmentedListShape(index: 1, count: 2),
        minTileHeight: 72,
        isThreeLine: true,
        titleAlignment: ListTileTitleAlignment.top,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: NostrAvatar(pubkey: pubkey, radius: 24),
        title: NostrDisplayName(
          pubkey: pubkey,
          style: theme.textTheme.headlineMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.settingsDeveloper),
            const SizedBox(height: 8),
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AboutIconLinkButton(
                  asset: 'icons/github.svg',
                  tooltip: 'GitHub',
                  url: AppConfig.developerGithubUrl,
                ),
                SizedBox(width: 8),
                AboutIconLinkButton(
                  asset: 'icons/nostr.svg',
                  tooltip: 'Nostr',
                  url: AppConfig.developerNostrUrl,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
