import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ndk/ndk.dart';

import 'package:nmail_core/app/config/app_config.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/community_theme.dart';
import 'community_theme_apply_button.dart';
import 'community_theme_author.dart';
import 'community_theme_copy_button.dart';
import 'community_theme_large_preview.dart';

class CommunityThemeDetails extends StatelessWidget {
  const CommunityThemeDetails({super.key, required this.theme});

  final CommunityTheme theme;

  static const _maxWidth = 720.0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final description = theme.description;

    // Centered by padding, not a width constraint, to keep the scrollbar at the
    // screen edge.
    return LayoutBuilder(
      builder: (context, constraints) {
        final gutter = max(16.0, (constraints.maxWidth - _maxWidth) / 2);
        return ListView(
          padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 24),
          children: [
            CommunityThemeLargePreview(theme: theme),
            const SizedBox(height: 16),
            CommunityThemeAuthor(theme: theme),
            if (description != null) ...[
              const SizedBox(height: 12),
              Text(
                description,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                CommunityThemeApplyButton(theme: theme),
                CommunityThemeCopyButton(
                  icon: Icons.link,
                  label: l.communityThemeCopyLink,
                  copiedLabel: l.linkCopied,
                  text: '${AppConfig.webAppUrl}/${theme.naddr}',
                ),
                CommunityThemeCopyButton(
                  icon: Icons.copy_outlined,
                  label: l.inboxCopyNpub,
                  copiedLabel: l.authCopied,
                  text: Nip19.encodePubKey(theme.pubkey),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
