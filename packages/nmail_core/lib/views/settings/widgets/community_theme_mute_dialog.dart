import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:nmail_core/app/routes/app_routes.dart';
import 'package:nmail_core/controllers/community_theme_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/community_theme.dart';
import 'package:nmail_core/services/metadata_service.dart';
import 'package:nmail_core/utils/metadata_extensions.dart';
import 'package:nmail_core/utils/toast_helper.dart';

class CommunityThemeMuteDialog extends StatelessWidget {
  const CommunityThemeMuteDialog({super.key, required this.theme});

  final CommunityTheme theme;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = GetIt.I<CommunityThemeController>();

    return AlertDialog(
      title: Obx(() {
        final author = Get.find<MetadataService>().of(theme.pubkey).value;
        return Text(
          l.communityThemeMuteTitle(
            author?.getBestName() ?? getAnonName(theme.pubkey),
          ),
        );
      }),
      content: Text(l.communityThemeMuteMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.actionCancel),
        ),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) => FilledButton(
            onPressed: controller.isMuting ? null : () => _mute(context),
            child: controller.isMuting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l.communityThemeMuteAction),
          ),
        ),
      ],
    );
  }

  Future<void> _mute(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final router = GoRouter.of(context);
    try {
      await GetIt.I<CommunityThemeController>().muteAuthor();
    } catch (_) {
      if (context.mounted) {
        ToastHelper.error(context, l.communityThemeMuteError);
      }
      return;
    }
    if (!context.mounted) return;
    Navigator.of(context).pop();
    router.go(AppRoutes.settingsAppearanceThemes);
  }
}
