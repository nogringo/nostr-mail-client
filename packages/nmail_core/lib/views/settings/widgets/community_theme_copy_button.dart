import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:nmail_core/controllers/community_theme_controller.dart';

class CommunityThemeCopyButton extends StatelessWidget {
  const CommunityThemeCopyButton({
    super.key,
    required this.icon,
    required this.label,
    required this.copiedLabel,
    required this.text,
  });

  final IconData icon;
  final String label;
  final String copiedLabel;
  final String text;

  @override
  Widget build(BuildContext context) {
    final controller = GetIt.I<CommunityThemeController>();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final isCopied = controller.copied == text;
        return TextButton.icon(
          onPressed: () => controller.copy(text),
          icon: Icon(isCopied ? Icons.check : icon),
          label: Text(isCopied ? copiedLabel : label),
        );
      },
    );
  }
}
