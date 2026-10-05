import 'package:flutter/material.dart';

import 'package:nmail_core/controllers/share_theme_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

class ShareThemeNsfwTile extends StatelessWidget {
  const ShareThemeNsfwTile({
    super.key,
    required this.controller,
    required this.gutter,
  });

  final ShareThemeController controller;

  /// Inside the tile, so its ink reaches the dialog edges.
  final EdgeInsets gutter;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => SwitchListTile(
        contentPadding: gutter,
        title: Text(l.communityThemesShareNsfw),
        value: controller.isNsfw,
        onChanged: (value) => controller.isNsfw = value,
      ),
    );
  }
}
