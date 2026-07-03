import 'package:flutter/material.dart';
import 'package:nostr_mail/nostr_mail.dart';
import 'package:nmail_standard/utils/get_attachements.dart';

class AttachmentChipView extends StatelessWidget {
  final AttachmentRef? attachment;

  const AttachmentChipView({super.key, this.attachment});

  @override
  Widget build(BuildContext context) {
    final filename = attachment?.filename ?? '';
    IconData icon = getAttachmentIcon(filename);

    return Chip(
      avatar: Icon(icon),
      label: Text(filename, maxLines: 1, overflow: TextOverflow.ellipsis),
      shape: const StadiumBorder(),
    );
  }
}
