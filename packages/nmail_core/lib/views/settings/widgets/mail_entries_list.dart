import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/mailboxes_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/mailbox.dart';
import 'package:nmail_core/utils/toast_helper.dart';
import '../../shared/layout_constants.dart';
import 'mail_entries_empty_state.dart';
import 'mail_entry_add_tile.dart';
import 'mail_entry_tile.dart';

/// The folders or the tags, in the order the sidebar shows them.
class MailEntriesList extends StatelessWidget {
  final MailEntryKind kind;

  const MailEntriesList({super.key, required this.kind});

  static const _maxWidth = 600.0;

  @override
  Widget build(BuildContext context) {
    final mailboxes = Get.find<MailboxesController>();
    // Centered by padding, not a width constraint, to keep the scrollbar at
    // the screen edge: reordering needs the list to own its scroll.
    return LayoutBuilder(
      builder: (context, constraints) {
        final gutter = max(0.0, (constraints.maxWidth - _maxWidth) / 2);
        return Obx(() {
          final entries = mailboxes.entriesOf(kind);
          if (entries.isEmpty) return MailEntriesEmptyState(kind: kind);
          return ReorderableListView.builder(
            buildDefaultDragHandles: false,
            padding: EdgeInsets.fromLTRB(
              gutter,
              8,
              gutter,
              LayoutConstants.fabClearance,
            ),
            itemCount: entries.length,
            onReorderItem: (oldIndex, newIndex) =>
                _reorder(context, oldIndex, newIndex),
            itemBuilder: (context, index) => MailEntryTile(
              key: ValueKey(entries[index].id),
              kind: kind,
              entry: entries[index],
              index: index,
            ),
            footer: MailEntryAddTile(kind: kind),
          );
        });
      },
    );
  }

  Future<void> _reorder(
    BuildContext context,
    int oldIndex,
    int newIndex,
  ) async {
    final l = AppLocalizations.of(context);
    try {
      await Get.find<MailboxesController>().reorder(kind, oldIndex, newIndex);
    } catch (_) {
      if (context.mounted) ToastHelper.error(context, l.mailboxSaveFailed);
    }
  }
}
