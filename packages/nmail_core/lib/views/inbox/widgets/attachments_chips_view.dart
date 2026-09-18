import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'attachment_chip_view.dart';

class AttachmentsChipsView extends StatelessWidget {
  final List<AttachmentRef> attachments;

  const AttachmentsChipsView({super.key, required this.attachments});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Row(
        spacing: 6,
        children: [
          for (final attachment in attachments.take(2))
            Flexible(child: AttachmentChipView(attachment: attachment)),
          // Reserved even when hidden, so file chips keep the same width on
          // every row.
          Visibility(
            visible: attachments.length > 2,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: Chip(
              label: Text('+${max(attachments.length - 2, 1)}'),
              shape: const CircleBorder(),
              labelPadding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
