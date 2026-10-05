import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/community_theme.dart';
import 'package:nmail_core/services/metadata_service.dart';
import 'package:nmail_core/utils/metadata_extensions.dart';
import 'package:nmail_core/widgets/nostr_avatar.dart';

class CommunityThemeAuthor extends StatelessWidget {
  const CommunityThemeAuthor({super.key, required this.theme});

  final CommunityTheme theme;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ValueListenableBuilder(
      valueListenable: GetIt.I<MetadataService>().of(theme.pubkey),
      builder: (context, author, _) => Row(
        spacing: 8,
        children: [
          NostrAvatar(pubkey: theme.pubkey, radius: 12),
          Flexible(
            child: Text(
              l.communityThemeByAuthor(
                author?.getBestName() ?? getAnonName(theme.pubkey),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
