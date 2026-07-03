import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/inbox_controller.dart';
import '../../../l10n/generated/app_localizations.dart';

class SearchField extends GetView<InboxController> {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        autofocus: true,
        style: const TextStyle(fontSize: 16),
        onChanged: controller.setSearchQuery,
        decoration: InputDecoration(
          hintText: l.inboxSearchHint,
          hintStyle: TextStyle(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            fontSize: 14,
          ),
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: controller.exitSearchMode,
            tooltip: l.inboxCloseSearch,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
