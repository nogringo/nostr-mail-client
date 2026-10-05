import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:nmail_core/controllers/community_theme_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

class CommunityThemeNotFound extends StatelessWidget {
  const CommunityThemeNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final controller = GetIt.I<CommunityThemeController>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Icon(
              Icons.style_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            Text(
              l.communityThemeNotFound,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: controller.load,
              icon: const Icon(Icons.refresh),
              label: Text(l.communityThemesRetry),
            ),
          ],
        ),
      ),
    );
  }
}
