import 'package:flutter/material.dart';

import 'package:nmail_core/models/recipient.dart';
import 'recipient_chip.dart';

/// Horizontal strip of recipient chips for one address field.
///
/// Sizes itself to the chips rather than pinning a height. A [Chip] outgrows
/// 48 logical pixels once the text scale passes 150%, and a fixed box lays its
/// avatar and label out for the taller size before clamping, which leaves them
/// off-centre and clipped.
class RecipientChipsRow extends StatelessWidget {
  const RecipientChipsRow({
    super.key,
    required this.recipients,
    required this.onDelete,
  });

  final List<Recipient> recipients;
  final void Function(int index) onDelete;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        spacing: 8,
        children: [
          for (final (index, recipient) in recipients.indexed)
            RecipientChip(
              recipient: recipient,
              onDelete: () => onDelete(index),
            ),
        ],
      ),
    );
  }
}
