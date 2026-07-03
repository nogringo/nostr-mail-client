import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/debug_tools_controller.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../utils/responsive_helper.dart';

class DebugToolsView extends StatelessWidget {
  const DebugToolsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = Get.put(DebugToolsController());

    Widget content = Scaffold(
      appBar: AppBar(title: Text(l.settingsDebugTools)),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: ResponsiveCenter(
            maxWidth: 600,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    l.debugToolsEmailTesting,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => controller.createOldTrashedEmail(context),
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l.debugToolsCreateOldTrashed),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.debugToolsCreateOldTrashedDescription,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return content;
  }
}
