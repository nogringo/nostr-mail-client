import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:nmail_core/controllers/community_themes_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'widgets/community_themes_empty_state.dart';
import 'widgets/community_themes_list.dart';
import 'widgets/show_share_theme_dialog.dart';

class CommunityThemesView extends StatelessWidget {
  const CommunityThemesView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    final controller = GetIt.I<CommunityThemesController>();

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsCommunityThemes)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showShareThemeDialog(context),
        icon: const Icon(Icons.share_outlined),
        label: Text(l.communityThemesShare),
      ),
      body: SafeArea(
        top: false,
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            if (controller.themes.isEmpty) {
              return controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : const CommunityThemesEmptyState();
            }

            return Column(
              children: [
                SizedBox(
                  height: 4,
                  child: controller.isLoading
                      ? const LinearProgressIndicator()
                      : null,
                ),
                const Expanded(child: CommunityThemesList()),
              ],
            );
          },
        ),
      ),
    );
  }
}
