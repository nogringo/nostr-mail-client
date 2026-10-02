import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/community_themes_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'widgets/community_themes_empty_state.dart';
import 'widgets/community_themes_list.dart';

class CommunityThemesView extends StatelessWidget {
  const CommunityThemesView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = Get.find<CommunityThemesController>();

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsCommunityThemes)),
      body: SafeArea(
        top: false,
        child: Obx(() {
          if (controller.themes.isEmpty) {
            return controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : const CommunityThemesEmptyState();
          }

          return Column(
            children: [
              SizedBox(
                height: 4,
                child: controller.isLoading.value
                    ? const LinearProgressIndicator()
                    : null,
              ),
              const Expanded(child: CommunityThemesList()),
            ],
          );
        }),
      ),
    );
  }
}
