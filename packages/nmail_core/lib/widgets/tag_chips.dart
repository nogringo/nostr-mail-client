import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/mailboxes_controller.dart';
import 'tag_chip.dart';

/// The tags of one email, in the user's order, tags with no entry last.
class TagChips extends StatelessWidget {
  final List<String> tagIds;

  /// Chips shown before a "+N" one, or null to show them all.
  final int? maxVisible;

  /// Offered on each chip whose tag this returns true for.
  final bool Function(String id)? canRemove;
  final void Function(String id)? onRemove;

  const TagChips({
    super.key,
    required this.tagIds,
    this.maxVisible,
    this.canRemove,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final mailboxes = Get.find<MailboxesController>();
    return Obx(() {
      final order = {
        for (final (index, tag) in mailboxes.tags.indexed) tag.id: index,
      };
      final ids = [...tagIds]
        ..sort(
          (a, b) =>
              (order[a] ?? order.length).compareTo(order[b] ?? order.length),
        );
      if (ids.isEmpty) return const SizedBox.shrink();

      final visible = maxVisible == null ? ids : ids.take(maxVisible!);
      final hidden = ids.length - visible.length;
      return Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          for (final id in visible)
            TagChip(
              id: id,
              tag: mailboxes.tagById(id),
              onDeleted: onRemove != null && (canRemove?.call(id) ?? true)
                  ? () => onRemove!(id)
                  : null,
            ),
          if (hidden > 0)
            Chip(
              label: Text('+$hidden'),
              labelStyle: Theme.of(context).textTheme.labelSmall,
              shape: const StadiumBorder(),
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              mouseCursor: MouseCursor.defer,
            ),
        ],
      );
    });
  }
}
