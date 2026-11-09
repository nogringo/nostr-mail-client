import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nmail_core/app/routes/app_routes.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'settings_nav_tile.dart';

class SignaturesNavTile extends StatelessWidget {
  const SignaturesNavTile({
    super.key,
    required this.index,
    required this.count,
  });

  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SettingsNavTile(
      icon: Icons.edit_note,
      title: l.signaturesTitle,
      index: index,
      count: count,
      onTap: () => context.go(AppRoutes.settingsSignatures),
    );
  }
}
