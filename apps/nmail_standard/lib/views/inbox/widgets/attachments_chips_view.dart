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
        children: [
          Expanded(
            flex: 1,
            child: Visibility(
              visible: attachments.isNotEmpty,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: AttachmentChipView(
                attachment: attachments.isNotEmpty ? attachments[0] : null,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 1,
            child: Visibility(
              visible: attachments.length >= 2,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: AttachmentChipView(
                attachment: attachments.length > 1 ? attachments[1] : null,
              ),
            ),
          ),
          Visibility(
            visible: attachments.length > 2,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: Chip(
              label: Text('+${attachments.length - 2}'),
              shape: CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
