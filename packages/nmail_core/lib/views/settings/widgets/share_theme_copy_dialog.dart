import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:nmail_core/controllers/community_themes_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

/// Shown instead of the share form when the current look is a published
/// theme, so it is not published again as a copy.
class ShareThemeCopyDialog extends StatelessWidget {
  const ShareThemeCopyDialog({super.key, required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final title = GetIt.I<CommunityThemesController>().themes
        .firstWhereOrNull((theme) => theme.address == address)
        ?.title;

    return AlertDialog(
      title: Text(l.communityThemesShare),
      content: Text(
        title == null
            ? l.communityThemesShareCopyUnnamed
            : l.communityThemesShareCopy(title),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    );
  }
}
