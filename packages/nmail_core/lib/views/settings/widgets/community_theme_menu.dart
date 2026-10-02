import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/community_theme.dart';
import 'community_theme_mute_dialog.dart';

class CommunityThemeMenu extends StatelessWidget {
  const CommunityThemeMenu({super.key, required this.theme});

  final CommunityTheme theme;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PopupMenuButton<void>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          width: 2,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      // The menu is closed by then, so the dialog opens from this context.
      itemBuilder: (_) => [
        PopupMenuItem(
          onTap: () => showDialog<void>(
            context: context,
            builder: (_) => CommunityThemeMuteDialog(theme: theme),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.volume_off_outlined),
            title: Text(l.communityThemeMuteAuthor),
          ),
        ),
      ],
    );
  }
}
