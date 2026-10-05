import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ndk/ndk.dart';

import 'package:nmail_core/controllers/community_theme_controller.dart';
import 'widgets/community_theme_details.dart';
import 'widgets/community_theme_menu.dart';
import 'widgets/community_theme_not_found.dart';

class CommunityThemeView extends StatelessWidget {
  const CommunityThemeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GetIt.I<CommunityThemeController>();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final theme = controller.theme;
        final page = Scaffold(
          appBar: AppBar(
            title: theme == null ? null : Text(theme.title),
            actionsPadding: .only(right: 8),
            actions: [
              if (theme != null &&
                  theme.pubkey != GetIt.I<Ndk>().accounts.getPublicKey())
                CommunityThemeMenu(theme: theme),
            ],
          ),
          body: SafeArea(
            top: false,
            child: theme != null
                ? CommunityThemeDetails(theme: theme)
                : controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : const CommunityThemeNotFound(),
          ),
        );
        // Drawn as the app looks once the theme is applied.
        return theme == null
            ? page
            : Theme(
                data: ThemeData.from(colorScheme: theme.colorScheme),
                child: page,
              );
      },
    );
  }
}
